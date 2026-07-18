import 'package:blogger_theme/blogger_theme.dart';

final theme_mode_sync_script = Script(
  contentInCDATA: true,
  content: ''' 
           /**
         * Toggles responsive state for the mobile drawer container panel.
         */
        function toggleSidebarDrawer() {
            const sidebar = document.getElementById('sidebar-drawer');
            const backdrop = document.getElementById('sidebar-backdrop');
            
            if (sidebar && backdrop) {
                sidebar.classList.toggle('drawer-open');
                backdrop.classList.toggle('backdrop-active');
            }
        }

        /**
         * Handles module option dropdown panel expansion and triggers smooth arrow transforms dynamically.
         * @param {string} moduleId - Target DOM container node identifier token string.
         */
        function toggleModuleDropdown(moduleId) {
            const targetModule = document.getElementById(moduleId);
            const arrowIndicator = document.getElementById(moduleId + '-arrow');
            
            if (targetModule) {
                const isCurrentlyHidden = targetModule.classList.contains('ui-hidden');
                
                if (isCurrentlyHidden) {
                    targetModule.classList.remove('ui-hidden');
                    if (arrowIndicator) {
                        arrowIndicator.style.transform = 'rotate(0deg)';
                    }
                } else {
                    targetModule.classList.add('ui-hidden');
                    if (arrowIndicator) {
                        arrowIndicator.style.transform = 'rotate(-90deg)';
                    }
                }
            }
        }

        /**
         * Global Routing Logic Engine: Automatically scans, parses, and assigns 
         * active highlight states based on browser route path locations.
         */
        function highlightActivePathsByRoute() {
            const currentSystemPathname = window.location.pathname;
            const structuralNavLinks = document.querySelectorAll('.nav-route-link');
            
            structuralNavLinks.forEach(linkElement => {
                const assignedTargetHref = linkElement.getAttribute('href');
                
                if (assignedTargetHref) {
                    // Remove parameters and hashes to cleanly match endpoints
                    const standardizedHref = assignedTargetHref.trim().split('?')[0].split('#')[0];
                    
                    if (currentSystemPathname === standardizedHref) {
                        linkElement.classList.add('active');
                    } else {
                        linkElement.classList.remove('active');
                    }
                }
            });
        }

        /**
         * Global Workspace Listeners Initializer Pipeline.
         */
        document.addEventListener('DOMContentLoaded', () => {
            const themeBtn = document.getElementById('theme-mode-switcher');
            const htmlEl = document.documentElement;
            // 1. Resolve Initial Theme State if LocalStorage is empty
            const savedTheme = localStorage.getItem('antinna-theme');
            if (savedTheme === 'dark') {
                htmlEl.classList.add('dark');
            } else if (savedTheme === 'light') {
                htmlEl.classList.remove('dark');
            } else {
                // Fallback: Check if user's operating system/browser prefers dark mode
                if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                    htmlEl.classList.add('dark');
                } else {
                    // If your application defaults to light mode when empty, keep it removed
                    htmlEl.classList.remove('dark');
                }
            }

            // 2. Run icon synchronization immediately on startup
            syncThemeIconDisplays();
            
            // Automatically match, map, and highlight routes across navigation groups
            highlightActivePathsByRoute();

            if (themeBtn) {
                themeBtn.addEventListener('click', () => {
                    const isDark = htmlEl.classList.contains('dark');
                    if (isDark) {
                        htmlEl.classList.remove('dark');
                        localStorage.setItem('antinna-theme', 'light');
                    } else {
                        htmlEl.classList.add('dark');
                        localStorage.setItem('antinna-theme', 'dark');
                    }
                    syncThemeIconDisplays();
                });
            }

            function syncThemeIconDisplays() {
                const moonIcon = document.querySelector('.icon-moon');
                const sunIcon = document.querySelector('.icon-sun');
                
                if (moonIcon && sunIcon) {
                    if (htmlEl.classList.contains('dark')) {
                        moonIcon.classList.add('ui-hidden');
                        sunIcon.classList.remove('ui-hidden');
                    } else {
                        moonIcon.classList.remove('ui-hidden');
                        sunIcon.classList.add('ui-hidden');
                    }
                }
            }
        });
      ''',
);
