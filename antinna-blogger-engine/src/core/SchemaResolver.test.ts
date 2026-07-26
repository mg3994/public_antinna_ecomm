import { describe, it, expect, vi, beforeEach } from 'vitest';
import { SchemaResolver } from './SchemaResolver';
import { BloggerDataService } from '../infrastructure/BloggerDataService';

describe('SchemaResolver', () => {
  let resolver: SchemaResolver;
  let mockBloggerService: any;

  beforeEach(() => {
    vi.restoreAllMocks();

    // Create a mock BloggerDataService
    mockBloggerService = {
      extractSchemaFromEntry: vi.fn(),
    };

    resolver = new SchemaResolver(mockBloggerService as BloggerDataService);

    // Mock global fetch
    global.fetch = vi.fn();
  });

  it('should resolve an object containing an @id reference', async () => {
    const parentSchema = {
      "@type": "ProductGroup",
      "name": "T-Shirt Group",
      "hasVariant": { "@id": "8077604533075111071" }
    };

    const mockPostJson = {
      entry: {
        content: { $t: '<script type="application/ld+json">{"@type": "Product", "name": "Blue S"}</script>' }
      }
    };

    mockBloggerService.extractSchemaFromEntry.mockReturnValue({
      "@type": "Product",
      "name": "Blue S"
    });

    (global.fetch as any).mockResolvedValue({
      ok: true,
      json: async () => mockPostJson,
    });

    const resolved = await resolver.resolve(parentSchema);

    expect(global.fetch).toHaveBeenCalledWith('/feeds/posts/default/8077604533075111071?alt=json');
    expect(resolved.hasVariant).toEqual({
      "@type": "Product",
      "name": "Blue S"
    });
  });

  it('should NOT resolve a bare primitive string as a reference ID', async () => {
    const parentSchema = {
      "@type": "ProductGroup",
      "name": "T-Shirt Group",
      "hasVariant": "8077604533075111071"
    };

    const resolved = await resolver.resolve(parentSchema);

    expect(global.fetch).not.toHaveBeenCalled();
    expect(resolved.hasVariant).toBe("8077604533075111071");
  });

  it('should resolve a nested object @id reference', async () => {
    const parentSchema = {
      "@type": "Product",
      "name": "T-Shirt S",
      "offers": {
        "@type": "Offer",
        "price": "500",
        "seller": { "@id": "8077604533075111072" }
      }
    };

    const mockPostJson = {
      entry: {
        content: { $t: '{"@type": "Store", "name": "Antinna Shop"}' }
      }
    };

    mockBloggerService.extractSchemaFromEntry.mockReturnValue({
      "@type": "Store",
      "name": "Antinna Shop"
    });

    (global.fetch as any).mockResolvedValue({
      ok: true,
      json: async () => mockPostJson,
    });

    const resolved = await resolver.resolve(parentSchema);

    expect(global.fetch).toHaveBeenCalledWith('/feeds/posts/default/8077604533075111072?alt=json');
    expect(resolved.offers.seller).toEqual({
      "@type": "Store",
      "name": "Antinna Shop"
    });
  });

  it('should cache resolved schemas and avoid duplicate fetch calls', async () => {
    const parentSchema = {
      "@type": "ProductGroup",
      "hasVariant": [
        { "@id": "8077604533075111071" },
        { "@id": "8077604533075111071" }
      ]
    };

    const mockPostJson = {
      entry: {
        content: { $t: '{"name": "Blue S"}' }
      }
    };

    mockBloggerService.extractSchemaFromEntry.mockReturnValue({
      "name": "Blue S"
    });

    (global.fetch as any).mockResolvedValue({
      ok: true,
      json: async () => mockPostJson,
    });

    const resolved = await resolver.resolve(parentSchema);

    // Fetch should be called exactly once
    expect(global.fetch).toHaveBeenCalledTimes(1);
    expect(resolved.hasVariant[0]).toEqual({ "name": "Blue S" });
    expect(resolved.hasVariant[1]).toEqual({ "name": "Blue S" });
  });

  it('should handle circular references gracefully without infinite loops', async () => {
    const parentSchema = {
      "@id": "8077604533075111071",
      "@type": "Product",
      "name": "A Circular Product",
      "related": { "@id": "8077604533075111072" }
    };

    // Post 2 references Post 1 back, creating a cycle
    const mockPost2Json = {
      entry: {
        content: { $t: '{"@type": "Product", "name": "Another Product", "related": {"@id": "8077604533075111071"}}' }
      }
    };

    mockBloggerService.extractSchemaFromEntry.mockReturnValue({
      "@type": "Product",
      "name": "Another Product",
      "related": { "@id": "8077604533075111071" }
    });

    (global.fetch as any).mockResolvedValue({
      ok: true,
      json: async () => mockPost2Json,
    });

    // Start resolution
    const resolved = await resolver.resolve(parentSchema);

    expect(resolved.related).toBeDefined();
    expect(resolved.related.name).toBe("Another Product");
    // Circular reference to parent (8077604533075111071) should return the unresolved @id object
    expect(resolved.related.related).toEqual({ "@id": "8077604533075111071" });
  });

  it('should resolve schema.org-compliant nested @id object arrays, hashes, and full URLs', async () => {
    const parentSchema = {
      "@type": "ProductGroup",
      "hasVariant": [
        { "@id": "8077604533075111071" },
        { "@id": "https://mg3994.blogspot.com/feeds/posts/default/8077604533075111072" }
      ]
    };

    mockBloggerService.extractSchemaFromEntry
      .mockReturnValueOnce({ "@type": "Product", "name": "Variant 1" })
      .mockReturnValueOnce({ "@type": "Product", "name": "Variant 2" });

    (global.fetch as any).mockResolvedValue({
      ok: true,
      json: async () => ({
        entry: { content: { $t: '{}' } }
      }),
    });

    const resolved = await resolver.resolve(parentSchema);

    expect(global.fetch).toHaveBeenCalledWith('/feeds/posts/default/8077604533075111071?alt=json');
    expect(global.fetch).toHaveBeenCalledWith('/feeds/posts/default/8077604533075111072?alt=json');

    expect(resolved.hasVariant[0]).toEqual({ "@type": "Product", "name": "Variant 1" });
    expect(resolved.hasVariant[1]).toEqual({ "@type": "Product", "name": "Variant 2" });
  });
});
