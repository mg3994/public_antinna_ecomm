import 'package:blogger_theme/blogger_theme.dart';
import "variables.dart";

final bskin_head = BSkin('''
/* ==========================================================================
   DESIGN TOKENS & SYSTEM THEME VARIABLES
   ========================================================================== */
:root {
    --bg-app: #ffffff;
    --bg-surface: #f8f9fa;
    --bg-panel: #1e293b;
    --border-ui: #e2e8f0;
    --text-main: #0f172a;
    --text-muted: #64748b;
    --text-light: #ffffff;
    --color-accent: #2563eb;
    --header-height: 64px;
    --sidebar-width: 280px;
}

html.dark {
    --bg-app: #0f172a;
    --bg-surface: #1e293b;
    --bg-panel: #0f172a;
    --border-ui: #334155;
    --text-main: #f8fafc;
    --text-muted: #94a3b8;
    --color-accent: #3b82f6;
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background-color: var(--bg-app);
    color: var(--text-main);
    overflow: hidden;
    height: 100vh;
}

.ui-hidden { display: none !important; }

.app-container {
    display: flex;
    width: 100vw;
    height: 100vh;
    position: relative;
}

/* ==========================================================================
   DESKTOP SIDEBAR PANEL STYLES & INTERIOR VIEWS SCROLL LAYER
   ========================================================================== */
#sidebar-drawer {
    width: var(--sidebar-width);
    min-width: var(--sidebar-width);
    background-color: var(--bg-panel);
    color: var(--text-light);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100vh;
    border-right: 1px solid var(--border-ui);
    z-index: 100;
    overflow: hidden;
}

.sidebar-header {
    height: var(--header-height);
    padding: 0 1.25rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.brand-logo { display: flex; align-items: center; gap: 0.75rem; }
/* .brand-icon {
    background-color: var(--color-accent); color: #ffffff; font-weight: 800;
    width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; border-radius: 6px;
} */

.brand-icon {
    width: 32px;
    height: 32px;
    border-radius: 6px;
    object-fit: cover;
    display: block;
}


.brand-text { font-size: 1.15rem; font-weight: 700; }
.btn-close-sidebar { display: none; background: transparent; border: none; color: white; font-size: 1.5rem; cursor: pointer; }

.sidebar-scroll-content {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    padding-bottom: 1.5rem;
    scrollbar-width: thin;
    scrollbar-color: rgba(255, 255, 255, 0.15) transparent;
}
 /* This targets only the first character of the element */
  .nav-route-link::first-letter {
    text-transform: uppercase;
  }
.sidebar-scroll-content::-webkit-scrollbar { width: 5px; }
.sidebar-scroll-content::-webkit-scrollbar-thumb { background-color: rgba(255, 255, 255, 0.15); border-radius: 10px; }

.desktop-nav-fallback { padding: 1.5rem 1.25rem 0.75rem 1.25rem; }
.sidebar-static-links { list-style: none; display: flex; flex-direction: column; gap: 0.5rem; }
.sidebar-static-links li a {
    display: block; color: rgba(255, 255, 255, 0.65); text-decoration: none;
    padding: 0.65rem 0.85rem; border-radius: 8px; font-size: 0.95rem; font-weight: 500; transition: all 0.2s ease;
}
.sidebar-static-links li a:hover { background-color: rgba(255, 255, 255, 0.08); color: #ffffff; }
.sidebar-static-links li a.active { background-color: var(--color-accent); color: #ffffff !important; font-weight: 600; }

.sidebar-modules-area { padding: 0.5rem 1.25rem; }
.sidebar-modules-section { padding: 0 !important; }
.sidebar-legal-area { padding: 0.5rem 1.25rem; }
.sidebar-legal-section { padding: 0 !important; }

.module-wrapper { width: 100%; }
.module-trigger {
    width: 100%; background: transparent; border: none; color: white;
    display: flex; align-items: center; justify-content: space-between;
    font-size: 0.9rem; font-weight: 600; cursor: pointer; padding: 0.65rem 0.85rem;
    border-radius: 8px; transition: background 0.2s;
}
.module-trigger:hover { background-color: rgba(255, 255, 255, 0.04); }

.arrow-indicator { 
    font-size: 0.85rem; 
    display: inline-block; 
    transform: rotate(-90deg);
    transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1); 
}
.arrow-indicator.initial-open { transform: rotate(0deg); }

.module-dropdown-list {
    list-style: none; margin-top: 0.25rem; padding-left: 0.75rem; overflow: hidden;
    transition: max-height 0.25s ease-out; max-height: 250px;
}
.module-dropdown-list.ui-hidden { max-height: 0 !important; margin-top: 0; }
.module-dropdown-list li a { display: block; color: rgba(255, 255, 255, 0.6); text-decoration: none; font-size: 0.875rem; padding: 0.5rem 0.85rem; border-radius: 6px; }
.module-dropdown-list li a:hover { color: white; background-color: rgba(255, 255, 255, 0.04); }
.module-dropdown-list li a.active { color: #ffffff !important; font-weight: 600; background-color: rgba(255, 255, 255, 0.1); }

.sidebar-social-wrapper {
  /*   display: flex; 
    align-items: center; 
    justify-content: space-between;  */
    width: 100%; /* Ensure the container takes full width of the parent */
    padding: 1.5rem 1.25rem 0.5rem 1.25rem; 
    margin-top: 0.5rem; 
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}
/* Ensure the widget inner container inherits the flex properties */
.sidebar-social-wrapper .widget {
  /*  display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    */
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
    width: 100%;
}
/* Optional styling to match standard system sidebar labels */
.sidebar-social-wrapper h4 {
    font-size: 0.75rem;
    font-weight: 700;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
/* Dedicated horizontal row for links */
.social-icons-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
}
.social-icon-link { 
 
 display: inline-block;
 width: 24px;  /* Increased size */
 height: 24px;
 background-color: currentColor; /* Inherits color from text */
 -webkit-mask-repeat: no-repeat;
    mask-repeat: no-repeat;
    -webkit-mask-size: contain;
    mask-size: contain;
    -webkit-mask-position: center;
    mask-position: center;
 color: rgba(255, 255, 255, 0.5);
 transition: color 0.2s, 
 transform 0.2s; 
}
.social-icon-link:hover { 
color: var(--color-accent); 
transform: translateY(-2px); 
}

/* ==========================================================================
   FIXED USER PROFILE ELEMENT ROW 
   ========================================================================== */
.avatar-footer-row {
    min-height: 68px; height: 68px; background-color: rgba(15, 23, 42, 0.4);
    border-top: 1px solid rgba(255, 255, 255, 0.08); padding: 0 1.15rem;
    display: flex; align-items: center; justify-content: space-between; gap: 0.75rem;
    position: relative; z-index: 10;
}
html.dark .avatar-footer-row { background-color: rgba(0, 0, 0, 0.2); }

.avatar-left-info { display: flex; align-items: center; gap: 0.75rem; overflow: hidden; }
.user-avatar-circle {
    width: 36px; min-width: 36px; height: 36px; border-radius: 50%;
    background-color: var(--color-accent); display: flex; align-items: center;
    justify-content: center; color: #ffffff; font-weight: 700; font-size: 0.95rem;
}
.user-meta-strings { display: flex; flex-direction: column; overflow: hidden; }
.user-display-name { font-size: 0.875rem; font-weight: 600; color: #ffffff; white-space: nowrap; text-overflow: ellipsis; overflow: hidden; }
.user-display-role { font-size: 0.75rem; color: rgba(255, 255, 255, 0.45); white-space: nowrap; text-overflow: ellipsis; overflow: hidden; }

.btn-settings-gear {
    background: transparent; border: none; color: rgba(255, 255, 255, 0.5);
    font-size: 1.35rem; cursor: pointer; display: flex; align-items: center;
    justify-content: center; width: 32px; height: 32px; border-radius: 50%; transition: all 0.2s ease;
}
.btn-settings-gear:hover { color: #ffffff; background-color: rgba(255, 255, 255, 0.08); transform: rotate(30deg); }

/* ==========================================================================
   MAIN VIEWPORT STYLES & INTERACTIVE SEARCH HEADERS
   ========================================================================== */
.main-view-wrapper { flex: 1; display: flex; flex-direction: column; height: 100vh; background-color: var(--bg-surface); overflow: hidden; position: relative; }
.top-navbar-header {
    height: var(--header-height); 
    min-height: var(--header-height); 
    background-color: var(--bg-app);
    border-bottom: 1px solid var(--border-ui); 
    padding: 0 1.5rem; 
    display: grid; 
    grid-template-columns: 1fr auto 1fr;
    align-items: center; 
    gap: 1rem;
}
.header-left, .header-right { display: flex; align-items: center; height: 100%; }

.btn-hamburger {
    background: transparent; border: none; color: var(--text-main); font-size: 1.4rem;
    cursor: pointer; display: none; height: 40px; width: 40px; align-items: center; justify-content: center;
}

.header-center-search { 
display: flex; 
align-items: center; 
justify-content: center; 
}
.search-container { position: relative; width: 100%; max-width: 20rem; }
.search-form {
    position: relative;
    width: 100%;
}
.search-icon {
pointer-events: none;
opacity: .7;
 position: absolute;
    top: 50%;
    left: 0.75rem;
    transform: translateY(-50%);

    display: flex;
    align-items: center;
    justify-content: center;

    width: 24px;
    height: 24px;

    appearance: none;
    -webkit-appearance: none;

    background: transparent;
    border: none;
    outline: none;
    box-shadow: none;

    padding: 0;
    margin: 0;

    color: var(--text-muted);
    cursor: pointer;

    transition: color .2s ease;
}

.search-icon:focus, .search-icon:active {

    background: transparent;
    border: none;
    outline: none;
    box-shadow: none;
}

.search-form:focus-within .search-icon {
    opacity: 1;
    pointer-events: auto;
    color: var(--color-accent);
}
.search-icon svg { width: 1.25rem; height: 1.25rem; }
.search-input {
    width: 100%; background-color: var(--bg-surface); border: 2px solid transparent;
    border-radius: 0.5rem; padding: 0.5rem 0.75rem 0.5rem 2.5rem; font-size: 0.875rem; color: var(--text-main); transition: all 0.2s; outline: none;
}
html.dark .search-input { background-color: var(--bg-panel); }
.search-input:focus { background-color: #ffffff; border-color: var(--color-accent); box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1); }
html.dark .search-input:focus { background-color: #0f172a; border-color: var(--color-accent); }
/* TODO: fix  background-color: var(--bg-surface); */
.btn-theme-toggle { background-color: var(--bg-surface); border: none; color: var(--text-main); font-size: 1.25rem; cursor: pointer; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 50%; }
.btn-theme-toggle:hover { background-color: var(--bg-surface); }
.scrollable-main-content { flex: 1; overflow-y: auto; padding: 1.5rem; }

/* ==========================================================================
   RESPONSIVE OVERRIDES & SHARED WIDGET STYLES
   ========================================================================== */
.mobile-bottom-navigation-bar { display: none; }

@media (max-width: 992px) {
    /* Hide the desktop list, but allow the mobile nav wrapped inside it to render */
    .desktop-nav-fallback { padding: 0 !important; }
    .sidebar-static-links { display: none !important; }
    
    .btn-hamburger { display: flex; }
    .btn-close-sidebar { display: inline-block; }

    /* FIXED MOBILE SIDEBAR LAYOUT (Left positioning avoids breaking position:fixed children) */
    #sidebar-drawer {
        position: fixed; 
        left: calc(var(--sidebar-width) * -1); 
        width: var(--sidebar-width);
        top: 0; 
        height: 100vh;
        height: -webkit-fill-available;
        display: flex !important;
        flex-direction: column !important;
        justify-content: flex-start !important;
        transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.3s ease;
        box-shadow: none;
    }
    #sidebar-drawer.drawer-open { left: 0; box-shadow: 4px 0 20px rgba(0,0,0,0.2); }

    .sidebar-scroll-content {
        flex: 1 1 auto !important;
        overflow-y: auto !important;
    }

    /* FIXED AVATAR MOBILE POSITION */
    #sidebar-drawer .avatar-footer-row {
        flex-shrink: 0 !important;
        margin-bottom: calc(64px + env(safe-area-inset-bottom, 0px)) !important;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        background-color: #111827 !important;
    }

    #sidebar-backdrop.backdrop-active {
        position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
        background-color: rgba(0, 0, 0, 0.4); backdrop-filter: blur(3px); z-index: 90;
    }

    .scrollable-main-content { 
        padding-bottom: calc(80px + env(safe-area-inset-bottom, 0px)); 
    }

    /* HARDWARE NAVIGATION CHIN ENVIRONMENT TRACKING ENGINE PLACEMENT */
    .mobile-bottom-navigation-bar {
        display: block !important;
        position: fixed; 
        bottom: 0; 
        left: 0; 
        width: 100vw; 
        height: calc(64px + env(safe-area-inset-bottom, 0px));
        background-color: var(--bg-app); 
        border-top: 1px solid var(--border-ui);
        z-index: 200 !important; 
        box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
        padding-bottom: env(safe-area-inset-bottom, 0px);
    }

    .bottom-nav-list {
        list-style: none !important; 
        display: flex !important; 
        width: 100% !important;
        height: 64px !important; 
        margin: 0 !important; 
        padding: 0 !important;
        align-items: center !important; 
        justify-content: space-around !important;
    }

    .bottom-nav-item { flex: 1 !important; height: 100% !important; display: flex !important; align-items: center !important; justify-content: center !important; }

    .bottom-nav-item a {
        display: flex !important; 
        flex-direction: column !important;
        align-items: center !important; 
        justify-content: center !important;
        width: 100% !important; 
        height: 100% !important; 
        gap: 4px !important;
        text-decoration: none !important; 
        color: var(--text-muted) !important; 
        transition: all 0.2s ease;
    }
    .bottom-nav-item a.active { color: var(--color-accent) !important; }


/* Base Icon Wrapper */
.bottom-nav-icon-dot {
    display: inline-block;
    width: 22px;
    height: 22px;
    /* This color is the default state */
    background-color: var(--text-muted); 
    
    /* This creates the icon shape using the dynamic --icon-url from the style attribute */
    -webkit-mask-image: var(--icon-url);
    mask-image: var(--icon-url);
    -webkit-mask-repeat: no-repeat;
    mask-repeat: no-repeat;
    -webkit-mask-size: contain;
    mask-size: contain;
    
    transition: background-color 0.2s ease;
}

/* Active State: When the link has .active, 
   we change the background-color of the mask, 
   not the icon itself. This is perfectly reliable.
*/
.bottom-nav-item a.active .bottom-nav-icon-dot {
    background-color: var(--color-accent);
}

/* Dark Mode adjustment if needed */
html.dark .bottom-nav-item a:not(.active) .bottom-nav-icon-dot {
    background-color: var(--text-muted); /* Dark mode muted color */
}



    .bottom-nav-text {
        font-size: 0.75rem !important; 
        font-weight: 600 !important; 
        line-height: 12px !important; 
        margin: 0 !important; 
        padding: 0 !important; 
        text-align: center !important; 
        display: block !important;
    }
    /* This targets only the first character of the element */
    .bottom-nav-text::first-letter {
        text-transform: uppercase;
      }


   
}

/* ==========================================================================
   GOOGLE LOGIN & PROFILE SETTINGS MODAL
   ========================================================================== */
.btn-google-login {
  background: #ffffff;
  color: #0f172a;
  border: 1.5px solid #e2e8f0;
  padding: 8px 16px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
  width: 100%;
  justify-content: center;
}
.btn-google-login:hover {
  background: #f8fafc;
  border-color: #cbd5e1;
  transform: translateY(-1px);
}
.btn-google-login svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

/* Settings Modal styles */
.settings-modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
}
.settings-modal-backdrop.active {
  opacity: 1;
  pointer-events: auto;
}
.settings-modal {
  background-color: var(--bg-app);
  color: var(--text-main);
  border: 1px solid var(--border-ui);
  width: 95%;
  max-width: 420px;
  border-radius: 16px;
  box-shadow:
    0 20px 25px -5px rgba(0, 0, 0, 0.1),
    0 10px 10px -5px rgba(0, 0, 0, 0.04);
  transform: scale(0.95);
  transition: transform 0.3s ease;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.settings-modal-backdrop.active .settings-modal {
  transform: scale(1);
}
.settings-modal-header {
  padding: 1.25rem;
  border-bottom: 1px solid var(--border-ui);
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.settings-modal-title {
  font-size: 1.1rem;
  font-weight: 700;
}
.settings-modal-close {
  background: transparent;
  border: none;
  color: var(--text-muted);
  font-size: 1.5rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  transition: all 0.2s ease;
}
.settings-modal-close:hover {
  background-color: var(--bg-surface);
  color: var(--text-main);
}
.settings-modal-body {
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.settings-user-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.5rem;
}
.settings-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--color-accent);
}
.settings-name {
  font-weight: 700;
  font-size: 1.1rem;
}
.settings-email {
  font-size: 0.85rem;
  color: var(--text-muted);
  word-break: break-all;
}
.settings-phone {
  font-size: 0.85rem;
  color: var(--text-muted);
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: var(--bg-surface);
  padding: 6px 12px;
  border-radius: 8px;
  border: 1px solid var(--border-ui);
}
.settings-detail-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.settings-detail-label {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.settings-uid-box {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: var(--bg-surface);
  border: 1px solid var(--border-ui);
  padding: 8px 12px;
  border-radius: 10px;
  gap: 8px;
}
.settings-uid-value {
  font-family: monospace;
  font-size: 0.8rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.btn-copy-settings-uid {
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: color 0.2s ease;
}
.btn-copy-settings-uid:hover {
  color: var(--color-accent);
}
.settings-modal-footer {
  padding: 1.25rem;
  border-top: 1px solid var(--border-ui);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.btn-modal-logout {
  width: 100%;
  background-color: #ef4444;
  color: #ffffff;
  border: none;
  padding: 10px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background-color 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.btn-modal-logout:hover {
  background-color: #dc2626;
}

/* Toast Notification Styles */
.toast-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 2500;
  display: flex;
  flex-direction: column;
  gap: 10px;
  pointer-events: none;
}
.toast {
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
}
@keyframes slideUp {
  from {
    transform: translateY(100px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}
@keyframes fadeOut {
  to {
    opacity: 0;
    transform: translateY(-20px);
  }
}


/* ==========================================================================
               Cookie Choices
   ========================================================================== */

/* --- Compact Centered Box --- */
.cookie-choices-info {
    position: fixed !important;
    top: 0 !important;
    bottom: 0 !important;
    left: 0 !important;
    right: 0 !important;
    margin: auto !important; /* Perfect centering */
    width: calc(100% - 32px) !important; 
    max-width: 380px !important; 
    height: fit-content !important; 
    background-color: var(--bg-surface) !important; 
    border: 1px solid var(--border-ui) !important; 
    border-radius: 16px !important; 
    padding: 20px !important;
    z-index: 999999 !important;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2), 0 10px 10px -5px rgba(0, 0, 0, 0.1) !important;
    box-sizing: border-box !important;
    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
}

/* --- Full Screen Backdrop Blur Overlay (Lightened) --- */
.cookie-choices-info::before {
    content: "" !important;
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    width: 100vw !important;
    height: 100vh !important;
    background: rgba(0, 0, 0, 0.15) !important; /* Slightly lighter tint */
    backdrop-filter: blur(3px) !important; /* Reduced from 8px to a subtle 3px */
    -webkit-backdrop-filter: blur(3px) !important; /* Safari compatibility */
    z-index: -1 !important; 
    pointer-events: none !important; 
}

/* --- Inner Layout Wrapper --- */
.cookie-choices-info .cookie-choices-inner {
    position: relative !important;
    width: 100% !important;
    margin: 0 !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 16px !important; 
}

/* --- Content Text --- */
.cookie-choices-info .cookie-choices-text {
    display: block !important;
    font-size: 13.5px !important;
    line-height: 1.5 !important;
    margin: 0 !important;
    color: var(--text-main) !important; 
    text-align: center !important; 
}

/* --- Flexible Button Container --- */
.cookie-choices-info .cookie-choices-buttons {
    display: flex !important;
    flex-direction: row !important; 
    gap: 10px !important;
    width: 100% !important;
}

/* --- Base Button Styling --- */
.cookie-choices-info .cookie-choices-button {
    flex: 1 !important; 
    text-align: center !important;
    padding: 10px 16px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    text-decoration: none !important;
    border-radius: 8px !important;
    transition: background-color 0.2s, opacity 0.2s !important;
    display: inline-block !important;
    box-sizing: border-box !important;
}

/* --- Secondary Button: Privacy Policy --- */
.cookie-choices-info .cookie-choices-button:first-child {
    background-color: transparent !important;
    color: var(--text-muted) !important;
    border: 1px solid var(--border-ui) !important;
}

.cookie-choices-info .cookie-choices-button:first-child:hover {
    background-color: var(--bg-app) !important;
    color: var(--text-main) !important;
}

/* --- Primary Button: Got it! --- */
#cookieChoiceDismiss {
    background-color: var(--color-accent) !important; 
    color: var(--text-light) !important;
    border: 1px solid var(--color-accent) !important;
}

#cookieChoiceDismiss:hover {
    opacity: 0.9 !important;
    cursor: pointer !important;
}

/* --- Mobile Fixes (For ultra-small screens) --- */
@media (max-width: 360px) {
    .cookie-choices-info {
        padding: 16px !important;
    }
    .cookie-choices-info .cookie-choices-buttons {
        flex-direction: column !important; 
    }
}


''', variables: bskin_variables);




// <====removed Css====>

// /* 
//     .bottom-nav-icon-dot {
//         font-size: 1.25rem !important; 
//         width: 22px !important; 
//         height: 22px !important; 
//         line-height: 12px !important;
//         display: flex !important; 
//         align-items: center !important; 
//         justify-content: center !important;
//         text-align: center !important; 
//         margin: 0 !important; 
//         padding: 0 !important;
//         color: var(--text-muted);
//         transition: all 0.2s ease;
//     }
//     .bottom-nav-item a.active .bottom-nav-icon-dot { color: var(--color-accent) !important; }
// */
