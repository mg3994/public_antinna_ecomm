import { BloggerDataService } from '../infrastructure/BloggerDataService';

export class SchemaResolver {
  private cache: Map<string, Promise<any>> = new Map();
  private bloggerDataService: BloggerDataService;

  constructor(bloggerDataService?: BloggerDataService) {
    this.bloggerDataService = bloggerDataService || new BloggerDataService();
  }

  /**
   * Helper to clean up / normalize a potential blog post ID.
   * Matches 15-22 digit numeric sequences typical of Blogger post IDs.
   * Gracefully extracts "@id" fields from schema-compliant nested reference objects,
   * handles paths and query strings, and isolates the unique leaf numeric identifier.
   * In compliance with strict schema.org guidelines, string values are only resolved
   * if they are defined inside an "@id" field.
   */
  private getPostId(val: any, isIdField: boolean = false): string | null {
    if (val === null || val === undefined) return null;

    // Handle nested reference objects as per schema.org guidelines
    if (typeof val === 'object' && val['@id'] !== undefined && val['@id'] !== null) {
      return this.getPostId(val['@id'], true);
    }

    // Direct strings are only resolved if they came from an "@id" field
    if (isIdField) {
      if (typeof val === 'string') {
        const trimmed = val.trim();
        // Extract numeric leaf from URLs or hash references
        const parts = trimmed.split(/[\/#\?]/);
        for (let i = parts.length - 1; i >= 0; i--) {
          const segment = parts[i].trim();
          if (/^\d{15,22}$/.test(segment)) {
            return segment;
          }
        }
        if (/^\d{15,22}$/.test(trimmed)) {
          return trimmed;
        }
      }

      if (typeof val === 'number') {
        const str = String(val);
        if (/^\d{15,22}$/.test(str)) {
          return str;
        }
      }
    }

    return null;
  }

  /**
   * Asynchronously resolves all `@id` references in the given schema.
   * Modifies the schema in-place or returns a resolved deep copy.
   */
  public async resolve(schema: any, resolving: Set<string> = new Set()): Promise<any> {
    if (!schema || typeof schema !== 'object') {
      return schema;
    }

    // If it's an array, resolve each item in parallel with path-isolated resolving sets
    if (Array.isArray(schema)) {
      return Promise.all(schema.map(async item => {
        const pathResolving = new Set(resolving);
        const postId = this.getPostId(item, false);
        if (postId) {
          return this.fetchAndResolve(postId, pathResolving);
        }
        return this.resolve(item, pathResolving);
      }));
    }

    // If this object itself represents a pure reference: e.g., { "@id": "8077604533075111071" }
    const objectId = this.getPostId(schema['@id'], true);
    const isRootOrParent = objectId && !resolving.has(objectId);

    if (objectId) {
      if (Object.keys(schema).length === 1) {
        return this.fetchAndResolve(objectId, resolving);
      }
      if (isRootOrParent) {
        resolving.add(objectId);
      }
    }

    // Traverse all properties of the object
    for (const key of Object.keys(schema)) {
      const val = schema[key];
      const postId = this.getPostId(val, false);
      const pathResolving = new Set(resolving);

      if (postId) {
        // Direct reference to resolve
        const resolvedValue = await this.fetchAndResolve(postId, pathResolving);
        if (resolvedValue) {
          schema[key] = resolvedValue;
        }
      } else if (val && typeof val === 'object') {
        const nestedPostId = this.getPostId(val['@id'], true);
        if (nestedPostId && Object.keys(val).length === 1) {
          // Object reference: e.g., "seller": { "@id": "8077604533075111071" }
          const resolvedValue = await this.fetchAndResolve(nestedPostId, pathResolving);
          if (resolvedValue) {
            schema[key] = resolvedValue;
          }
        } else {
          // Deep recursion
          schema[key] = await this.resolve(val, pathResolving);
        }
      }
    }

    if (objectId && isRootOrParent) {
      resolving.delete(objectId);
    }

    return schema;
  }

  /**
   * Fetches the blog post by ID, extracts its schema, and resolves any nested references.
   */
  private async fetchAndResolve(postId: string, resolving: Set<string>): Promise<any> {
    if (resolving.has(postId)) {
      console.warn(`Circular reference detected for blog post ID: ${postId}`);
      return { "@id": postId };
    }

    // Check cache for existing promise
    if (this.cache.has(postId)) {
      return this.cache.get(postId)!;
    }

    // Create the promise and store it in cache immediately
    const promise = (async () => {
      resolving.add(postId);
      try {
        const feedUrl = `/feeds/posts/default/${postId}?alt=json`;
        const res = await fetch(feedUrl);
        if (!res.ok) {
          throw new Error(`Failed to fetch blogger post ${postId}: ${res.statusText}`);
        }
        const data = await res.json();
        const entry = data.entry;
        if (!entry) {
          throw new Error(`No entry found in feed for post ${postId}`);
        }
        const rawSchema = this.bloggerDataService.extractSchemaFromEntry(entry);
        if (!rawSchema) {
          throw new Error(`No JSON-LD schema found in post ${postId}`);
        }

        // Deeply resolve references inside the fetched schema
        return this.resolve(rawSchema, resolving);
      } catch (e) {
        console.error(`Error resolving schema for post ID ${postId}:`, e);
        // Fallback: return the original reference
        return { "@id": postId };
      } finally {
        resolving.delete(postId);
      }
    })();

    this.cache.set(postId, promise);
    return promise;
  }
}
