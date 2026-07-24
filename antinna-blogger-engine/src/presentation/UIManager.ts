export class UIManager {
  static el<T extends HTMLElement>(id: string): T | null {
    return document.getElementById(id) as T;
  }

  static query<T extends HTMLElement>(selector: string): T | null {
    return document.querySelector(selector) as T;
  }

  static setContent(idOrSelector: string, content: string): void {
    const e = this.el(idOrSelector) || this.query(idOrSelector);
    if (e) e.textContent = content;
  }

  static setHtml(idOrSelector: string, html: string): void {
    const e = this.el(idOrSelector) || this.query(idOrSelector);
    if (e) e.innerHTML = html;
  }

  static toggleClass(idOrSelector: string, className: string, force?: boolean): void {
    const e = this.el(idOrSelector) || this.query(idOrSelector);
    if (e) e.classList.toggle(className, force);
  }

  static injectModalStyles(): void {
    // Modal styles are pre-compiled and served directly in blogger_theme/bin/head/css/css.dart to minimize IIFE bundle size
  }

  static injectModelViewer(): Promise<void> {
    return new Promise((resolve) => {
        if (document.querySelector('script[src*="model-viewer"]')) return resolve();
        const script = document.createElement('script');
        script.type = 'module';
        script.src = 'https://ajax.googleapis.com/ajax/libs/model-viewer/3.5.0/model-viewer.min.js';
        script.onload = () => resolve();
        document.head.appendChild(script);
    });
  }

  static injectLeaflet(): Promise<void> {
    return new Promise((resolve) => {
        if ((window as any).L) return resolve();

        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
        document.head.appendChild(link);

        const script = document.createElement('script');
        script.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
        script.onload = () => resolve();
        document.head.appendChild(script);
    });
  }

  static async show3DViewer(url: string): Promise<void> {
    this.injectModalStyles();
    await this.injectModelViewer();

    let backdrop = this.el('antinna-3d-modal');
    if (!backdrop) {
        backdrop = document.createElement('div');
        backdrop.id = 'antinna-3d-modal';
        backdrop.className = 'antinna-3d-backdrop';
        backdrop.innerHTML = `
            <div class="antinna-3d-header">
                <h3 style="margin:0;">3D Model Preview</h3>
                <button class="antinna-3d-close" onclick="UIManager.hide3DViewer()">&times;</button>
            </div>
            <div id="antinna-3d-container"></div>
        `;
        document.body.appendChild(backdrop);
    }

    const container = this.el('antinna-3d-container');
    if (container) {
        container.innerHTML = `
            <model-viewer src="${url}" ar ar-modes="webxr scene-viewer quick-look" camera-controls touch-action="pan-y" alt="A 3D model" shadow-intensity="1">
                <button slot="ar-button" class="antinna-ar-button">
                   <span>📷</span> View in your space (AR)
                </button>
                <div slot="progress-bar"></div>
            </model-viewer>
        `;
    }

    backdrop.classList.add('active');
    document.body.classList.add('antinna-3d-active');
  }

  static hide3DViewer(): void {
      const backdrop = this.el('antinna-3d-modal');
      if (backdrop) {
          backdrop.classList.remove('active');
          document.body.classList.remove('antinna-3d-active');
          const container = this.el('antinna-3d-container');
          if (container) container.innerHTML = ''; // Stop the model viewer
      }
  }

  static showToast(message: string, type: 'success' | 'error' | 'info' = 'success'): void {
    this.injectModalStyles();
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.style.cssText = `
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#1e293b'};
        color: white;
        padding: 12px 24px;
        border-radius: 10px;
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 10px;
        margin-top: 10px;
        font-size: 0.9rem;
        font-weight: 600;
        animation: slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1) forwards;
        pointer-events: auto;
        border: 1px solid rgba(255,255,255,0.1);
    `;
    toast.innerText = message;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'fadeOut 0.3s forwards';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
  }
}
