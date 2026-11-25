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

  // --- Todo #show Interactive Widgets (v2.6.3): Progress Slider, P0..P4 Dial, Aerial Map ---
  var GP_META = [
    { p: 0, code: 'P0', label: 'Critical', color: '#ef4444', db: 5 },
    { p: 1, code: 'P1', label: 'High',     color: '#f97316', db: 4 },
    { p: 2, code: 'P2', label: 'Normal',   color: '#eab308', db: 3 },
    { p: 3, code: 'P3', label: 'Low',      color: '#0ea5e9', db: 2 },
    { p: 4, code: 'P4', label: 'Backlog',  color: '#94a3b8', db: 1 }
  ];

  function getCsrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  function showSaveStatus(el, state, text) {
    if (!el) return;
    if (el._hideTimer) clearTimeout(el._hideTimer);
    el.className = 'todo-inline-save-status is-visible is-' + state;
    el.textContent = text;
    if (state === 'saved') {
      el._hideTimer = setTimeout(function() {
        el.classList.remove('is-visible');
      }, 1800);
    }
  }

  function saveTodoInline(todoId, todoFields, statusEl) {
    if (!todoId) return;
    showSaveStatus(statusEl, 'saving', 'Salvo…');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest'
    };
    var csrf = getCsrfToken();
    if (csrf) headers['X-CSRF-Token'] = csrf;

    fetch('/todos/' + encodeURIComponent(todoId) + '.json', {
      method: 'POST',
      credentials: 'same-origin',
      headers: headers,
      body: JSON.stringify({ _method: 'put', todo: todoFields })
    })
      .then(function(res) {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      })
      .then(function() {
        showSaveStatus(statusEl, 'saved', '✓ Salvato');
      })
      .catch(function() {
        showSaveStatus(statusEl, 'error', '⚠ Errore');
      });
  }

  function initProgressWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var todoId = card.getAttribute('data-todo-id');
    var slider = card.querySelector('[data-todo-progress-slider]');
    var label  = card.querySelector('[data-todo-progress-text]');
    var status = card.querySelector('[data-progress-status]');
    var ticks  = card.querySelectorAll('[data-progress-tick]');
    if (!slider) return;

    function syncVisual(val) {
      var pct = Math.max(0, Math.min(100, parseInt(val, 10) || 0));
      slider.value = pct;
      slider.style.setProperty('--progress-pct', pct + '%');
      if (label) label.textContent = pct + '%';
      for (var i = 0; i < ticks.length; i++) {
        var tv = parseInt(ticks[i].getAttribute('data-progress-tick'), 10);
        ticks[i].classList.toggle('is-active', tv === pct);
      }
      return pct;
    }

    slider.addEventListener('mousedown', function(e) {
      slider.step = e.shiftKey ? '1' : '5';
    });
    slider.addEventListener('touchstart', function() {
      slider.step = '5';
    }, { passive: true });
    slider.addEventListener('keydown', function(e) {
      slider.step = e.shiftKey ? '1' : '5';
    });

    slider.addEventListener('input', function() {
      syncVisual(slider.value);
    });

    slider.addEventListener('change', function() {
      var pct = syncVisual(slider.value);
      saveTodoInline(todoId, { progress_status: pct }, status);
    });

    for (var i = 0; i < ticks.length; i++) {
      (function(btn) {
        btn.addEventListener('click', function() {
          var pct = syncVisual(btn.getAttribute('data-progress-tick'));
          saveTodoInline(todoId, { progress_status: pct }, status);
        });
      })(ticks[i]);
    }
  }

  function initPriorityWheelWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var todoId   = card.getAttribute('data-todo-id');
    var dial     = card.querySelector('[data-prio-dial]');
    var dialCode = card.querySelector('[data-prio-dial-code]');
    var pill     = card.querySelector('[data-prio-pill]');
    var dbHint   = card.querySelector('[data-prio-db-hint]');
    var status   = card.querySelector('[data-prio-status]');
    var stops    = card.querySelectorAll('[data-prio-stop]');
    var currentP = Math.max(0, Math.min(4, parseInt(card.getAttribute('data-google-p'), 10) || 2));
    var saveDebounce = null;

    function applyGoogleP(gp, shouldSave) {
      var clamped = Math.max(0, Math.min(4, gp));
      var meta = GP_META[clamped];
      currentP = clamped;
      card.setAttribute('data-google-p', String(clamped));
      card.setAttribute('data-db-priority', String(meta.db));
      card.style.setProperty('--gp-index', String(clamped));
      card.style.setProperty('--gp-color', meta.color);
      for (var c = 0; c <= 4; c++) {
        card.classList.toggle('gp-' + c, c === clamped);
      }
      if (dialCode) dialCode.textContent = meta.code;
      if (pill) pill.textContent = meta.code + ' · ' + meta.label;
      if (dbHint) dbHint.textContent = 'DB ' + meta.db + '/5';
      for (var i = 0; i < stops.length; i++) {
        var sp = parseInt(stops[i].getAttribute('data-prio-stop'), 10);
        var sel = sp === clamped;
        stops[i].classList.toggle('is-selected', sel);
        stops[i].setAttribute('aria-checked', sel ? 'true' : 'false');
      }
      if (shouldSave) {
        if (saveDebounce) clearTimeout(saveDebounce);
        saveDebounce = setTimeout(function() {
          saveTodoInline(todoId, { priority: meta.db }, status);
        }, 160);
      }
    }

    for (var i = 0; i < stops.length; i++) {
      (function(btn) {
        btn.addEventListener('click', function() {
          var gp = parseInt(btn.getAttribute('data-prio-stop'), 10);
          applyGoogleP(gp, true);
        });
      })(stops[i]);
    }

    if (dial) {
      // Mouse wheel over rotary dial: scroll up -> more urgent (towards P0), scroll down -> towards P4
      dial.addEventListener('wheel', function(e) {
        e.preventDefault();
        var delta = e.deltaY > 0 ? 1 : -1;
        var next = Math.max(0, Math.min(4, currentP + delta));
        if (next !== currentP) applyGoogleP(next, true);
      }, { passive: false });

      // Dragging horizontally or vertically on the knob spins the wheel smoothly
      var draggingDial = false;
      var dragMoved = false;
      var startX = 0;
      var startY = 0;
      var startP = currentP;

      dial.addEventListener('mousedown', function(e) {
        if (e.button !== 0) return;
        draggingDial = true;
        dragMoved = false;
        startX = e.clientX;
        startY = e.clientY;
        startP = currentP;
      });
      window.addEventListener('mousemove', function(e) {
        if (!draggingDial) return;
        var dx = e.clientX - startX;
        var dy = e.clientY - startY;
        if (Math.abs(dx) > 6 || Math.abs(dy) > 6) {
          dragMoved = true;
          var steps = Math.round((dx + dy) / 18);
          var targetP = Math.max(0, Math.min(4, startP + steps));
          if (targetP !== currentP) applyGoogleP(targetP, true);
        }
      });
      window.addEventListener('mouseup', function() {
        draggingDial = false;
      });

      dial.addEventListener('click', function(e) {
        if (dragMoved) {
          dragMoved = false;
          e.preventDefault();
          return;
        }
        applyGoogleP((currentP + 1) % 5, true);
      });

      dial.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
          e.preventDefault();
          applyGoogleP(Math.max(0, currentP - 1), true);
        } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
          e.preventDefault();
          applyGoogleP(Math.min(4, currentP + 1), true);
        }
      });
    }
  }

  function initWhereMapWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var toggleBtn  = card.querySelector('[data-map-expand-toggle]');
    var placeBtn   = card.querySelector('[data-map-expand-trigger]');
    var overlayBtn = card.querySelector('[data-map-overlay]');
    var modeBtn    = card.querySelector('[data-map-mode-toggle]');
    var iframe     = card.querySelector('[data-map-iframe]');
    var aerialSrc  = card.getAttribute('data-aerial-src');
    var roadSrc    = card.getAttribute('data-road-src');
    var isAerial   = true;

    function setExpanded(expanded) {
      card.classList.toggle('is-expanded', expanded);
      if (toggleBtn) {
        toggleBtn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        toggleBtn.textContent = expanded ? '✕ Riduci' : '🔍 Espandi';
      }
      if (modeBtn) {
        modeBtn.hidden = !expanded;
      }
    }

    if (toggleBtn) {
      toggleBtn.addEventListener('click', function() {
        setExpanded(!card.classList.contains('is-expanded'));
      });
    }
    if (placeBtn) {
      placeBtn.addEventListener('click', function() {
        setExpanded(!card.classList.contains('is-expanded'));
      });
    }
    if (overlayBtn) {
      overlayBtn.addEventListener('click', function() {
        setExpanded(true);
      });
    }
    if (modeBtn && iframe && aerialSrc && roadSrc) {
      modeBtn.addEventListener('click', function() {
        isAerial = !isAerial;
        iframe.src = isAerial ? aerialSrc : roadSrc;
        modeBtn.textContent = isAerial ? '🗺️ Mappa' : '🛰️ Aerea';
      });
    }
  }

  function initTodoShowWidgets() {
    var progCards = document.querySelectorAll('[data-todo-progress-widget]');
    for (var i = 0; i < progCards.length; i++) initProgressWidget(progCards[i]);

    var prioCards = document.querySelectorAll('[data-todo-prio-widget]');
    for (var j = 0; j < prioCards.length; j++) initPriorityWheelWidget(prioCards[j]);

    var whereCards = document.querySelectorAll('[data-todo-where-widget]');
    for (var k = 0; k < whereCards.length; k++) initWhereMapWidget(whereCards[k]);
  }

  function boot() {
    initToggle();
    initSwipeTodos();
    initTodoShowWidgets();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
