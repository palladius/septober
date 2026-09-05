// Septober 2026 Theme Manager & Interactive Enhancements
(function() {
  function getPreferredTheme() {
    var stored = localStorage.getItem('septober_theme');
    if (stored) return stored;
    return 'dark'; // Default: Dark First
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.body && document.body.setAttribute('data-theme', theme);
    localStorage.setItem('septober_theme', theme);
    var btn = document.getElementById('theme-toggle-btn');
    if (btn) {
      btn.innerHTML = theme === 'dark'
        ? '<span class="theme-icon">☀️</span> <span class="theme-label">Light Mode</span>'
        : '<span class="theme-icon">🌙</span> <span class="theme-label">Dark Mode</span>';
      btn.setAttribute('title', 'Switch to ' + (theme === 'dark' ? 'Light' : 'Dark') + ' mode');
    }
  }

  // Set immediately on document element to prevent theme flicker
  var currentTheme = getPreferredTheme();
  document.documentElement.setAttribute('data-theme', currentTheme);

  function initToggle() {
    if (document.getElementById('theme-toggle-btn')) return;
    var toggleBtn = document.createElement('button');
    toggleBtn.id = 'theme-toggle-btn';
    toggleBtn.className = 'theme-toggle';
    toggleBtn.type = 'button';
    toggleBtn.setAttribute('aria-label', 'Toggle light / dark theme');

    toggleBtn.onclick = function() {
      var active = document.documentElement.getAttribute('data-theme') || 'dark';
      var next = active === 'dark' ? 'light' : 'dark';
      applyTheme(next);
    };

    document.body.appendChild(toggleBtn);
    applyTheme(getPreferredTheme());
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initToggle);
  } else {
    initToggle();
  }
})();
