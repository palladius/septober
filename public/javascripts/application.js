// Septober 2026 Theme Manager & A2UI Swipe-to-Done (10s Undo Countdown)
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

  // --- A2UI Swipe Gesture & 10-Second Undo Countdown Engine ---
  var SWIPE_THRESHOLD = 85;
  var UNDO_SECONDS = 10;

  function extractTodoId(row) {
    if (row.getAttribute('data-todo-id')) return row.getAttribute('data-todo-id');
    var detailDiv = row.querySelector('[id^="todo-"][id$="-detail"]');
    if (detailDiv) {
      var m = detailDiv.id.match(/^todo-(\d+)-detail$/);
      if (m) return m[1];
    }
    var doneLink = row.querySelector('a[href*="/todos/"][href$="/done"]');
    if (doneLink) {
      var m2 = doneLink.getAttribute('href').match(/\/todos\/(\d+)\/done/);
      if (m2) return m2[1];
    }
    return null;
  }

  function triggerDoneWithCountdown(row, todoId) {
    if (row.classList.contains('pending-vanish')) return;
    row.classList.add('pending-vanish');
    row.style.transform = '';
    row.classList.remove('swiping-right', 'swiping-left');

    // Immediately notify backend that todo is done
    if (todoId) {
      fetch('/todos/' + todoId + '/done', { credentials: 'same-origin' }).catch(function() {});
    }

    var nameEl = row.querySelector('.todo');
    if (nameEl) {
      nameEl.style.textDecoration = 'line-through';
      nameEl.style.opacity = '0.6';
    }

    var hostCell = row.cells && row.cells[1] ? row.cells[1] : row;
    var banner = document.createElement('div');
    banner.className = 'a2ui-undo-banner';
    banner.innerHTML =
      '<span class="a2ui-undo-text">✅ Completato! Scompare tra <strong class="a2ui-sec">' + UNDO_SECONDS + '.0s</strong></span>' +
      '<button type="button" class="a2ui-undo-btn">↩️ Annulla</button>' +
      '<div class="a2ui-undo-progress"></div>';
    hostCell.appendChild(banner);

    var secSpan = banner.querySelector('.a2ui-sec');
    var progBar = banner.querySelector('.a2ui-undo-progress');
    var undoBtn = banner.querySelector('.a2ui-undo-btn');

    var startTime = Date.now();
    var durationMs = UNDO_SECONDS * 1000;
    var timerId = setInterval(function() {
      var elapsed = Date.now() - startTime;
      var remaining = Math.max(0, durationMs - elapsed);
      var pct = (remaining / durationMs) * 100;
      if (secSpan) secSpan.textContent = (remaining / 1000).toFixed(1) + 's';
      if (progBar) progBar.style.width = pct + '%';

      if (remaining <= 0) {
        clearInterval(timerId);
        row.classList.add('vanishing');
        setTimeout(function() {
          if (row.parentNode) row.parentNode.removeChild(row);
        }, 360);
      }
    }, 100);

    undoBtn.addEventListener('click', function(ev) {
      ev.stopPropagation();
      ev.preventDefault();
      clearInterval(timerId);
      row.classList.remove('pending-vanish');
      if (nameEl) {
        nameEl.style.textDecoration = '';
        nameEl.style.opacity = '';
      }
      if (banner.parentNode) banner.parentNode.removeChild(banner);
      if (todoId) {
        fetch('/todos/' + todoId + '/undone', { credentials: 'same-origin' }).catch(function() {});
      }
    });
  }

  function triggerProcrastinate(row, todoId) {
    row.style.transform = '';
    row.classList.remove('swiping-right', 'swiping-left');
    if (todoId) {
      fetch('/todos/' + todoId + '/procrastinate', { credentials: 'same-origin' }).catch(function() {});
    }
    var dueCell = row.querySelector('.todo_due_column') || (row.cells && row.cells[2]);
    if (dueCell) {
      var badge = document.createElement('div');
      badge.style.cssText = 'color:#f59e0b;font-size:0.75rem;font-weight:700;margin-top:4px;';
      badge.textContent = '💤 Rimandato di +7 giorni';
      dueCell.appendChild(badge);
    }
  }

  function attachRowSwipe(row) {
    if (row.getAttribute('data-swipe-bound')) return;
    row.setAttribute('data-swipe-bound', 'true');
    var todoId = extractTodoId(row);

    // Intercept click on the Done (V.png) link so it uses the 10s Undo countdown too
    var doneLink = row.querySelector('a[href*="/todos/"][href$="/done"]');
    if (doneLink) {
      doneLink.addEventListener('click', function(ev) {
        ev.preventDefault();
        triggerDoneWithCountdown(row, todoId);
      });
    }

    var startX = 0;
    var startY = 0;
    var currentDx = 0;
    var dragging = false;

    function onStart(clientX, clientY, target) {
      if (row.classList.contains('pending-vanish')) return;
      if (target && target.closest('input, textarea, select, button, .on_the_spot_editing')) return;
      startX = clientX;
      startY = clientY;
      currentDx = 0;
      dragging = true;
      row.style.transition = 'none';
    }

    function onMove(clientX, clientY) {
      if (!dragging) return;
      var dx = clientX - startX;
      var dy = clientY - startY;
      if (Math.abs(dy) > Math.abs(dx) && Math.abs(dx) < 18) return;
      currentDx = Math.max(-150, Math.min(150, dx));
      row.style.transform = 'translateX(' + currentDx + 'px)';
      row.classList.toggle('swiping-right', currentDx > 35);
      row.classList.toggle('swiping-left', currentDx < -35);
    }

    function onEnd() {
      if (!dragging) return;
      dragging = false;
      row.style.transition = 'transform 0.22s ease, background-color 0.22s ease';
      if (currentDx >= SWIPE_THRESHOLD) {
        triggerDoneWithCountdown(row, todoId);
      } else if (currentDx <= -SWIPE_THRESHOLD) {
        triggerProcrastinate(row, todoId);
      } else {
        row.style.transform = '';
        row.classList.remove('swiping-right', 'swiping-left');
      }
      currentDx = 0;
    }

    // Touch events (mobile / tablet)
    row.addEventListener('touchstart', function(e) {
      if (e.touches.length === 1) onStart(e.touches[0].clientX, e.touches[0].clientY, e.target);
    }, { passive: true });
    row.addEventListener('touchmove', function(e) {
      if (e.touches.length === 1) onMove(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });
    row.addEventListener('touchend', onEnd);

    // Mouse drag events (desktop)
    row.addEventListener('mousedown', function(e) {
      if (e.button !== 0 || (e.target && e.target.closest('a'))) return;
      onStart(e.clientX, e.clientY, e.target);
    });
    window.addEventListener('mousemove', function(e) {
      if (dragging) onMove(e.clientX, e.clientY);
    });
    window.addEventListener('mouseup', function() {
      if (dragging) onEnd();
    });
  }

  function initSwipeTodos() {
    var rows = document.querySelectorAll('tr.todo_line, .todo-item');
    for (var i = 0; i < rows.length; i++) {
      attachRowSwipe(rows[i]);
    }
  }

  function boot() {
    initToggle();
    initSwipeTodos();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
