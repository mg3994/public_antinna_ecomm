import 'package:blogger_theme/blogger_theme.dart';

final antinna_engine_script = Script(
  type: 'module',
  contentInCDATA: true,
  content: r"""let state = {
  product: null,
  service: null,
  selected: {},
  slide: 0
};

document.addEventListener('DOMContentLoaded', () => {
  // Small timeout to ensure Blogger has finished its own internal rendering
  setTimeout(() => {
    if (document.getElementById('post-body-raw')) initItem();
    if (document.getElementById('app-grid')) initGrid();
  }, 100);
});

function initGrid() {
  const cards = document.querySelectorAll('.card');
  if (cards.length === 0) return;

  // Lazy load observer
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
         const img = e.target.querySelector('.card-img');
         if (img && img.dataset.src) {
            img.src = img.dataset.src;
            delete img.dataset.src;
         }
         observer.unobserve(e.target);
      }
    });
  });
  cards.forEach(c => observer.observe(c));

  // Primary source: Attempt to use the full feed to bypass snippet limitations
  const path = window.location.pathname;
  let feedUrl = '/feeds/posts/default?alt=json&max-results=25';
  if (path.includes('/search/label/')) {
    const label = path.split('/').pop().split('?')[0];
    feedUrl = `/feeds/posts/default/-/${label}?alt=json&max-results=25`;
  }

  fetch(feedUrl)
    .then(res => res.json())
    .then(feedData => {
       const entries = feedData.feed.entry || [];
       cards.forEach(card => {
         const cardUrl = card.href.split('?')[0].split('#')[0];
         const entry = entries.find(e => e.link.some(l => l.rel === 'alternate' && l.href.includes(cardUrl)));

         if (entry) {
           const content = entry.content.$t;
           const data = parseJSON(content);
           if (data) renderCardData(card, data);
         } else {
           // Fallback to hidden grid-data if feed fetch fails or entry not found
           const raw = card.querySelector('.grid-data');
           if (raw) {
             const data = parseJSON(raw.textContent);
             if (data) renderCardData(card, data);
           }
         }
       });
    })
    .catch(() => {
       // Direct fallback on fetch error
       cards.forEach(card => {
         const raw = card.querySelector('.grid-data');
         if (raw) {
           const data = parseJSON(raw.textContent);
           if (data) renderCardData(card, data);
         }
       });
    });
}

function renderCardData(card, data) {
  const badge = card.querySelector('.card-badge');
  const price = card.querySelector('.card-price');
  const img = card.querySelector('.card-img');

  // Reset badges
  badge.textContent = '';
  badge.className = 'card-badge';
  badge.style.display = 'inline-block';

  if (data['@type'] === 'ProductGroup' || data['@type'] === 'Product') {
    badge.textContent = 'Product';
    const variants = data.hasVariant || [data];
    const first = variants[0];

    if (first.offers) {
      price.textContent = (first.offers.priceCurrency || '') + ' ' + (first.offers.price || '');

      const isOut = first.offers.availability === 'https://schema.org/OutOfStock';
      if (isOut) {
        price.classList.add('blurry');
        const outB = document.createElement('div');
        outB.className = 'card-badge out-stock';
        outB.style.marginLeft = '5px';
        outB.textContent = 'Out of Stock';
        badge.after(outB);
      }

      const seller = first.offers.seller;
      if (seller && (seller.knowsAbout || seller.hasOfferCatalog)) {
        const sBadge = document.createElement('div');
        sBadge.className = 'card-badge';
        sBadge.style.background = '#3498db';
        sBadge.style.color = '#fff';
        sBadge.style.marginLeft = '5px';
        sBadge.textContent = '(* Optional Product Related Seller Service Paid Add-Ons available kind stuff)';
        badge.after(sBadge);
      }
    }
    // Prioritize ProductGroup images for Grid/Homepage view as requested
    const imageSource = data.image || first.image || (data.hasVariant && data.hasVariant.find(v => v.image)?.image);
    if (imageSource) img.src = Array.isArray(imageSource) ? imageSource[0] : (imageSource.url || imageSource);

  } else if (data['@type'] === 'LocalBusiness' || data['@type'] === 'Service') {
    badge.textContent = 'Service';
    badge.style.background = '#3498db';
    badge.style.color = '#fff';

    // Check if standalone service provider also has general offerings
    if (data.knowsAbout || (data.hasOfferCatalog && data.hasOfferCatalog.itemListElement && data.hasOfferCatalog.itemListElement.length > 1)) {
      const sBadge = document.createElement('div');
      sBadge.className = 'card-badge';
      sBadge.style.background = '#27ae60';
      sBadge.style.color = '#fff';
      sBadge.style.marginLeft = '5px';
      sBadge.textContent = '(Multi-Service)';
      badge.after(sBadge);
    }

    if (data.hasOfferCatalog && data.hasOfferCatalog.itemListElement) {
      const off = data.hasOfferCatalog.itemListElement[0];
      price.textContent = 'Starts ' + (off.priceCurrency || '') + ' ' + (off.price || '');
    } else if (data.offers) {
      price.textContent = (data.offers.priceCurrency || '') + ' ' + (data.offers.price || '');
    }
    if (data.image) img.src = Array.isArray(data.image) ? data.image[0] : (data.image.url || data.image);
  }
}

function initItem() {
  const rawEl = document.getElementById('post-body-raw');
  if (!rawEl) {
    console.warn("Element post-body-raw not found");
    return;
  }

  let data = parseJSON(rawEl.textContent);

  // If parsing failed, try finding any script tag in the whole document as a last resort
  if (!data) {
    const allScripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (let s of allScripts) {
      data = parseJSON(s.textContent);
      if (data && (data['@type'] === 'ProductGroup' || data['@type'] === 'Service' || data['@type'] === 'LocalBusiness')) break;
    }
  }

  if (!data) {
    const initEl = document.getElementById('initializing-state');
    if (initEl) initEl.innerHTML = '<div style="color:red; font-weight:bold;">Error: No valid Product or Service data found in this post.</div>';
    return;
  }

  if (data['@type'] === 'ProductGroup') {
    state.product = data;
    renderProduct();
  } else if (data['@type'] === 'LocalBusiness' || data['@type'] === 'Service' || data['@type'] === 'Product') {
    state.service = data;
    renderService();
  }

  const init = document.getElementById('initializing-state');
  if (init) init.classList.add('hidden');
  document.getElementById('carousel-section')?.classList.remove('hidden');
  document.getElementById('details-section')?.classList.remove('hidden');
}

function decodeEntities(text) {
  const textArea = document.createElement('textarea');
  textArea.innerHTML = text;
  return textArea.value;
}

function parseJSON(text) {
  if (!text) return null;

  // Try to find JSON-LD in a script tag using regex first (more robust against Blogger wrapping)
  const scriptMatch = text.match(/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/i);
  let jsonStr = scriptMatch ? scriptMatch[1] : text;

  // Decode entities multiple times if needed (Blogger sometimes double-escapes)
  let decoded = decodeEntities(jsonStr);
  if (decoded.includes('&quot;')) decoded = decodeEntities(decoded);

  try {
    // Remove comments that might be inside the script
    const cleanJson = decoded.replace(/\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm, '$1').trim();
    return JSON.parse(cleanJson);
  } catch (e) {
    // Final fallback: try to find the largest JSON-like block { ... }
    const jsonBlock = decoded.match(/\{[\s\S]*\}/);
    if (jsonBlock) {
      try {
        return JSON.parse(jsonBlock[0]);
      } catch (e2) {}
    }
    console.error("Failed to parse JSON-LD:", e, "Original text snippet:", text.substring(0, 100));
    return null;
  }
}

function renderProduct() {
  const p = state.product;
  document.getElementById('p-name').textContent = p.name;
  document.getElementById('p-desc').textContent = p.description;

  // Handle Brand if present
  const brandDiv = document.createElement('div');
  brandDiv.style.color = '#777';
  brandDiv.style.marginTop = '-10px';
  brandDiv.textContent = typeof p.brand === 'string' ? p.brand : (p.brand?.name || '');
  document.getElementById('p-name').after(brandDiv);

  const vars = document.getElementById('p-variants');
  vars.innerHTML = '';

  if (p.variesBy) {
    p.variesBy.forEach(vUrl => {
      const attr = vUrl.split(/[\/#]/).pop();
      const values = [...new Set(p.hasVariant.map(v => v[attr]).filter(Boolean))];

      const group = document.createElement('div');
      group.className = 'v-group';
      group.innerHTML = `<span class="v-label">Select ${attr}:</span>`;
      const opts = document.createElement('div');
      opts.className = 'v-options';

      values.forEach(val => {
        const btn = document.createElement('button');
        btn.className = 'v-btn';
        btn.dataset.attr = attr;
        btn.dataset.val = val;

        if (attr.toLowerCase() === 'color') {
          btn.classList.add('v-color');
          btn.style.backgroundColor = val;
          btn.title = val;
        } else {
          btn.textContent = val;
        }
        btn.onclick = () => {
          state.selected[attr] = val;
          updateProductView(attr);
          checkAvailability();
        };
        opts.appendChild(btn);
      });
      group.appendChild(opts);
      vars.appendChild(group);
      state.selected[attr] = values[0];
    });
  }
  updateProductView();
  checkAvailability();
}

function checkAvailability() {
  const p = state.product;
  const allBtns = document.querySelectorAll('.v-btn[data-attr]');

  allBtns.forEach(btn => {
    const attr = btn.dataset.attr;
    const val = btn.dataset.val;

    // A button is always "possible" if ANY variant has this value.
    // This prevents deadlocks in mutually exclusive attribute sets.
    const globalPossible = p.hasVariant.some(v => v[attr] === val);

    // Check if it's compatible with CURRENT selection (excluding itself)
    const testSelected = { ...state.selected, [attr]: val };
    const matchingVariant = p.hasVariant.find(v =>
      Object.entries(testSelected).every(([k, vVal]) => !v[k] || v[k] === vVal)
    );

    const outOfStock = matchingVariant && matchingVariant.offers && matchingVariant.offers.availability === 'https://schema.org/OutOfStock';

    btn.disabled = !globalPossible;
    // Visual cue for incompatible but selectable: dashed border or lower opacity
    btn.style.opacity = !matchingVariant ? '0.4' : (outOfStock ? '0.6' : '1');
    btn.style.borderStyle = !matchingVariant ? 'dashed' : 'solid';

    if (outOfStock) btn.title = val + ' (Out of Stock)';
    else btn.title = val;
  });
}

function formatValue(v) {
  if (!v) return '';
  if (typeof v === 'string') return v;
  if (v['@type'] === 'QuantitativeValue') return `${v.value} ${v.unitCode || v.unitText || ''}`;
  return v.value || '';
}

function updateProductView(pivotAttr) {
  const p = state.product;
  if (!p.hasVariant || p.hasVariant.length === 0) return;

  let variant = p.hasVariant.find(v =>
    Object.entries(state.selected).every(([key, val]) => v[key] === val)
  );

  // If no perfect match, pivot based on the last clicked attribute
  if (!variant) {
     variant = p.hasVariant.find(v => v[pivotAttr] === state.selected[pivotAttr]) || p.hasVariant[0];
     // Sync selected state to this new variant
     if (p.variesBy) {
       p.variesBy.forEach(vUrl => {
         const attr = vUrl.split(/[\/#]/).pop();
         if (variant[attr]) state.selected[attr] = variant[attr];
       });
     }
  }

  // Display SKU
  const skuEl = document.getElementById('p-sku');
  if (skuEl) skuEl.textContent = variant.sku ? 'SKU: ' + variant.sku : '';

  if (variant.offers) {
    const off = variant.offers;
    const priceEl = document.getElementById('p-price');
    priceEl.textContent = (off.priceCurrency || '') + ' ' + (off.price || '');

    // Advanced Availability Logic
    priceEl.classList.toggle('blurry', off.availability === 'https://schema.org/OutOfStock');

    let badge = document.getElementById('stock-indicator');
    if (!badge) {
      badge = document.createElement('span');
      badge.id = 'stock-indicator';
      badge.className = 'stock-badge';
      priceEl.after(badge);
    }

    let av = off.availability;
    if (av === 'https://schema.org/InStock') {
      badge.textContent = 'In Stock';
      badge.className = 'stock-badge in-stock';
    } else if (av === 'https://schema.org/OutOfStock') {
      badge.textContent = 'Out of Stock';
      badge.className = 'stock-badge out-stock';
    } else if (av === 'https://schema.org/InStoreOnly') {
      badge.textContent = 'In-Store Only';
      badge.className = 'stock-badge instore-only';
    } else if (av === 'https://schema.org/PreOrder') {
      badge.textContent = 'Pre-Order';
      if (off.availabilityStarts) badge.textContent += ' (from ' + off.availabilityStarts.split('T')[0] + ')';
      badge.className = 'stock-badge pre-order';
    }

    // Order Info Section
    const orderSection = document.getElementById('p-order-info');
    const orderList = document.getElementById('order-info-list');
    let orderHtml = '';

    if (off.deliveryLeadTime) orderHtml += `<div>&#128666; <b>Delivery:</b> ~${formatValue(off.deliveryLeadTime)}</div>`;
    if (off.eligibleQuantity && off.eligibleQuantity.minValue) orderHtml += `<div>&#128230; <b>Min Order:</b> ${off.eligibleQuantity.minValue} units</div>`;
    if (off.acceptedPaymentMethod) {
      const payments = Array.isArray(off.acceptedPaymentMethod) ? off.acceptedPaymentMethod : [off.acceptedPaymentMethod];
      orderHtml += `<div>&#128179; <b>Payments:</b> ${payments.map(p => p.split('/').pop()).join(', ')}</div>`;
    }
    if (off.availableDeliveryMethod) orderHtml += `<div>&#128230; <b>Method:</b> ${off.availableDeliveryMethod.split('/').pop()}</div>`;

    if (orderHtml) {
      orderSection.style.display = 'block';
      orderList.innerHTML = orderHtml;
    } else {
      orderSection.style.display = 'none';
    }

    // Resolve Seller
    renderSeller(off.seller);
  }

  // Single view: Prioritize Variant images as requested. Fallback to group images only if variant has none.
  let vImgs = Array.isArray(variant.image) ? variant.image : (variant.image ? [variant.image] : []);
  let pImgs = Array.isArray(p.image) ? p.image : (p.image ? [p.image] : []);
  let allImgs = vImgs.length > 0 ? vImgs : pImgs;

  renderCarousel(allImgs);

  // Render Specifications
  const specs = document.getElementById('p-specs');
  const list = document.getElementById('specs-list');
  const fields = {
    'Model': variant.model || p.model,
    'Material': variant.material || p.material,
    'Condition': (variant.itemCondition || variant.offers?.itemCondition)?.split('/').pop() || '',
    'GTIN': variant.gtin13 || variant.gtin8 || '',
    'MPN': variant.mpn || '',
    'Weight': formatValue(variant.weight || p.weight),
    'Height': formatValue(variant.height || p.height),
    'Width': formatValue(variant.width || p.width),
    'Depth': formatValue(variant.depth || p.depth),
    'Color': variant.color || p.color
  };

  let specsHtml = '';
  for (let [label, val] of Object.entries(fields)) {
    if (val) specsHtml += `<div style="display:flex; justify-content:space-between; padding:4px 0; border-bottom:1px dashed #f0f0f0;">
                              <span style="color:#888;">${label}</span>
                              <span style="font-weight:600;">${val}</span>
                           </div>`;
  }

  if (specsHtml) {
    specs.style.display = 'block';
    list.innerHTML = specsHtml;
  } else {
    specs.style.display = 'none';
  }

  // Highlight buttons
  document.querySelectorAll('.v-btn').forEach(btn => {
    const val = btn.textContent || btn.title;
    const isSelected = Object.values(state.selected).some(v => v === val);
    btn.classList.toggle('active', isSelected);
  });
}

function renderService() {
  const s = state.service;
  document.getElementById('p-name').textContent = s.name;
  document.getElementById('p-desc').textContent = s.description;

  // Handle Area Served
  if (s.areaServed) {
    const area = typeof s.areaServed === 'string' ? s.areaServed : (s.areaServed.name || s.areaServed['@type']);
    const badge = document.createElement('div');
    badge.className = 'geo-badge';
    badge.style.background = '#e8f5e9';
    badge.style.color = '#2e7d32';
    badge.innerHTML = '&#127760; <b>Area Served:</b> ' + area;
    document.getElementById('p-desc').after(badge);
  }

  const vars = document.getElementById('p-variants');
  vars.innerHTML = s.hasOfferCatalog ? '<h4>Available Options</h4>' : '';

  if (s.hasOfferCatalog) {
    const opts = document.createElement('div');
    opts.className = 'v-options';
    s.hasOfferCatalog.itemListElement.forEach(offer => {
      const btn = document.createElement('button');
      btn.className = 'v-btn';
      btn.innerHTML = `${offer.itemOffered.name} <br/> <b>${offer.priceCurrency} ${offer.price}</b>`;
      btn.onclick = () => {
        document.getElementById('p-price').textContent = `${offer.priceCurrency} ${offer.price}`;
        document.querySelectorAll('.v-btn').forEach(b => b.classList.remove("active"));
        btn.classList.add('active');
      };
      opts.appendChild(btn);
    });
    vars.appendChild(opts);
    opts.firstChild.click();
  }

  renderCarousel(s.image);
  renderSeller(s.provider || s);
}

function renderCarousel(images) {
  const inner = document.getElementById('carousel-inner');
  const thumbRow = document.getElementById('thumbnail-row');
  if (!inner) return;

  inner.innerHTML = '';
  if (thumbRow) thumbRow.innerHTML = '';

  state.slide = 0;
  inner.style.transform = `translateX(0)`;

  let list = Array.isArray(images) ? images : [images];
  list = list.filter(Boolean);

  list.forEach((src, idx) => {
    const imgUrl = src.url || src;

    // Main slide
    const div = document.createElement('div');
    div.className = 'carousel-item';
    div.innerHTML = `<img src="${imgUrl}"/>`;
    inner.appendChild(div);

    // Thumbnail
    if (thumbRow && list.length > 1) {
      const thumb = document.createElement('img');
      thumb.className = 'thumb' + (idx === 0 ? ' active' : '');
      thumb.src = imgUrl;
      thumb.onclick = () => goToSlide(idx);
      thumbRow.appendChild(thumb);
    }
  });
}

window.goToSlide = (idx) => {
  const inner = document.getElementById('carousel-inner');
  const thumbs = document.querySelectorAll('.thumb');
  const count = document.querySelectorAll('.carousel-item').length;
  if (idx < 0) idx = count - 1;
  if (idx >= count) idx = 0;

  state.slide = idx;
  if (inner) inner.style.transform = `translateX(-${idx * 100}%)`;
  thumbs.forEach((t, i) => t.classList.toggle('active', i === idx));
};

window.nextSlide = () => {
  const count = document.querySelectorAll('.carousel-item').length;
  if (count > 1) {
    goToSlide(state.slide + 1);
  }
};

window.prevSlide = () => {
  const count = document.querySelectorAll('.carousel-item').length;
  if (count > 1) {
    goToSlide(state.slide - 1);
  }
};

function renderSeller(seller) {
  if (!seller) return;
  const info = document.getElementById('seller-info');

  let contactHtml = `<strong>${seller.name}</strong><br/>`;
  if (seller.telephone) contactHtml += `&#128222; ${seller.telephone}<br/>`;
  if (seller.email) contactHtml += `&#128231; <a href="mailto:${seller.email}" style="color:inherit;">${seller.email}</a><br/>`;
  if (seller.address) {
    const addr = seller.address;
    contactHtml += `&#128205; ${addr.streetAddress || ''} ${addr.addressLocality || ''} ${addr.addressCountry || ''}`;
  }

  // Social Links
  if (seller.sameAs) {
    contactHtml += `<div class="social-row">`;
    const links = Array.isArray(seller.sameAs) ? seller.sameAs : [seller.sameAs];
    links.forEach(url => {
      let label = 'Link';
      if (url.includes('facebook.com')) label = 'Facebook';
      else if (url.includes('instagram.com')) label = 'Instagram';
      else if (url.includes('twitter.com') || url.includes('x.com')) label = 'Twitter';
      else if (url.includes('linkedin.com')) label = 'LinkedIn';
      contactHtml += `<a href="${url}" class="social-link" target="_blank">${label}</a>`;
    });
    contactHtml += `</div>`;
  }

  info.innerHTML = contactHtml;

  if (seller.geo && seller.geo.latitude && seller.geo.longitude) {
    document.getElementById('geo-info').style.display = 'inline-flex';
    const lat = seller.geo.latitude;
    const lon = seller.geo.longitude;
    document.getElementById('geo-text').textContent = lat + ', ' + lon;

    const mapsLink = document.getElementById('maps-link');
    if (mapsLink) {
      const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
      mapsLink.href = isMobile ? `geo:${lat},${lon}` : `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
      mapsLink.style.display = 'inline-block';
    }
  } else {
    document.getElementById('geo-info').style.display = 'none';
    const mapsLink = document.getElementById('maps-link');
    if (mapsLink) mapsLink.style.display = 'none';
  }

  // Handle "Other Services"
  let services = [];
  if (seller.hasOfferCatalog && seller.hasOfferCatalog.itemListElement) {
    services = seller.hasOfferCatalog.itemListElement;
  } else if (seller.knowsAbout) {
    services = Array.isArray(seller.knowsAbout) ? seller.knowsAbout : [seller.knowsAbout];
  }

  const otherSection = document.getElementById('other-services');
  const list = document.getElementById('other-services-list');

  if (services.length > 0) {
    otherSection.style.display = 'block';
    list.innerHTML = '';
    services.forEach(ser => {
      let name = '';
      let price = '';

      if (typeof ser === 'string') name = ser;
      else {
        name = ser.name || (ser.itemOffered ? ser.itemOffered.name : '');
        if (ser.price) price = `${ser.priceCurrency || ''} ${ser.price}`;
      }

      if (name) {
        const div = document.createElement("div");
        div.className = "h-card";
        div.innerHTML = `<strong>${name}</strong>${price ? `<br/><span style="color:var(--accent); font-weight:700;">${price}</span>` : ''}`;
        list.appendChild(div);
      }
    });
  } else {
    otherSection.style.display = 'none';
  }
}""",
);
