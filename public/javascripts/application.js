// Septober 2026 Theme Manager, A2UI Swipe-to-Done, In-Loco Show Editors & Modern Bento Form
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

    row.addEventListener('touchstart', function(e) {
      if (e.touches.length === 1) onStart(e.touches[0].clientX, e.touches[0].clientY, e.target);
    }, { passive: true });
    row.addEventListener('touchmove', function(e) {
      if (e.touches.length === 1) onMove(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });
    row.addEventListener('touchend', onEnd);

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

  // --- Shared Helpers for Todo #show In-Loco & Modern Form (v2.6.4) ---
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

  function escapeHtml(str) {
    return String(str || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function pad2(n) {
    return n < 10 ? '0' + n : String(n);
  }

  function datePlusDaysIso(days) {
    var d = new Date();
    d.setDate(d.getDate() + (parseInt(days, 10) || 0));
    return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
  }

  function snoozePlusDaysIso(days) {
    var d = new Date();
    d.setDate(d.getDate() + (parseInt(days, 10) || 1));
    d.setHours(9, 0, 0, 0);
    return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()) + 'T09:00';
  }

  function buildMapsEmbedUrl(rawWhere, aerial, zoom) {
    var w = String(rawWhere || '').trim();
    if (!w) return '';
    var enc = encodeURIComponent(w).replace(/!/g, '%21');
    var mode = aerial ? 1 : 0;
    var z = zoom || 16;
    return 'https://www.google.com/maps/embed?origin=mfe&pb=!1m4!2m1!1s' + enc + '!5e' + mode + '!6i' + z;
  }

  function buildMapsExternalUrl(rawWhere) {
    var w = String(rawWhere || '').trim();
    if (!w) return '';
    return 'https://www.google.com/maps/search/?api=1&query=' + encodeURIComponent(w);
  }

  function autoResizeTextarea(ta) {
    if (!ta) return;
    ta.style.height = 'auto';
    ta.style.height = Math.max(120, ta.scrollHeight + 4) + 'px';
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

  function saveTodoInline(todoId, todoFields, statusEl, onDone, onError) {
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
      method: 'PUT',
      credentials: 'same-origin',
      headers: headers,
      body: JSON.stringify({ todo: todoFields })
    })
      .then(function(res) {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      })
      .then(function(data) {
        showSaveStatus(statusEl, 'saved', '✓ Salvato');
        if (typeof onDone === 'function') onDone(data || {});
      })
      .catch(function(err) {
        showSaveStatus(statusEl, 'error', '⚠ Errore');
        if (typeof onError === 'function') onError(err);
      });
  }

  // --- Progress Slider (Show In-Loco OR Form Mode) ---
  function initProgressWidget(card, opts) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var formMode = !!(opts && opts.formMode);
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
      if (!formMode && todoId) {
        saveTodoInline(todoId, { progress_status: pct }, status);
      }
    });

    for (var i = 0; i < ticks.length; i++) {
      (function(btn) {
        btn.addEventListener('click', function() {
          var pct = syncVisual(btn.getAttribute('data-progress-tick'));
          if (!formMode && todoId) {
            saveTodoInline(todoId, { progress_status: pct }, status);
          }
        });
      })(ticks[i]);
    }
  }

  // --- Google P0..P4 Rotary Wheel (Show In-Loco OR Form Mode) ---
  function initPriorityWheelWidget(card, opts) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var formMode    = !!(opts && opts.formMode);
    var todoId      = card.getAttribute('data-todo-id');
    var hiddenInput = card.querySelector('[data-form-prio-input]');
    var dial        = card.querySelector('[data-prio-dial]');
    var dialCode    = card.querySelector('[data-prio-dial-code]');
    var pill        = card.querySelector('[data-prio-pill]');
    var dbHint      = card.querySelector('[data-prio-db-hint]');
    var status      = card.querySelector('[data-prio-status]');
    var stops       = card.querySelectorAll('[data-prio-stop]');
    var currentP    = Math.max(0, Math.min(4, parseInt(card.getAttribute('data-google-p'), 10) || 2));
    var saveDebounce = null;

    function applyGoogleP(gp, shouldPersist) {
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
      if (hiddenInput) hiddenInput.value = String(meta.db);
      if (dialCode) dialCode.textContent = meta.code;
      if (pill) pill.textContent = meta.code + ' · ' + meta.label;
      if (dbHint) dbHint.textContent = 'DB ' + meta.db + '/5';
      for (var i = 0; i < stops.length; i++) {
        var sp = parseInt(stops[i].getAttribute('data-prio-stop'), 10);
        var sel = sp === clamped;
        stops[i].classList.toggle('is-selected', sel);
        stops[i].setAttribute('aria-checked', sel ? 'true' : 'false');
      }
      if (shouldPersist && !formMode && todoId) {
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
      dial.addEventListener('wheel', function(e) {
        e.preventDefault();
        var delta = e.deltaY > 0 ? 1 : -1;
        var next = Math.max(0, Math.min(4, currentP + delta));
        if (next !== currentP) applyGoogleP(next, true);
      }, { passive: false });

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

  // --- Where / Location Card: In-Loco Edit + Mini Aerial Google Maps ---
  function initWhereMapWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var todoId     = card.getAttribute('data-todo-id');
    var toggleBtn  = card.querySelector('[data-map-expand-toggle]');
    var placeBtn   = card.querySelector('[data-map-expand-trigger]');
    var overlayBtn = card.querySelector('[data-map-overlay]');
    var modeBtn    = card.querySelector('[data-map-mode-toggle]');
    var iframe     = card.querySelector('[data-map-iframe]');
    var editBtn    = card.querySelector('[data-where-edit-btn]');
    var emptyBtn   = card.querySelector('[data-where-empty-btn]');
    var populated  = card.querySelector('[data-where-populated]');
    var editor     = card.querySelector('[data-where-editor]');
    var input      = card.querySelector('[data-where-input]');
    var saveBtn    = card.querySelector('[data-where-save]');
    var cancelBtn  = card.querySelector('[data-where-cancel]');
    var whereText  = card.querySelector('[data-where-text]');
    var extLink    = card.querySelector('[data-where-ext-link]');
    var statusEl   = card.querySelector('[data-where-status]');

    var aerialSrc  = card.getAttribute('data-aerial-src') || '';
    var roadSrc    = card.getAttribute('data-road-src') || '';
    var isAerial   = true;

    function setExpanded(expanded) {
      card.classList.toggle('is-expanded', expanded);
      if (toggleBtn) {
        toggleBtn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        toggleBtn.textContent = expanded ? '✕ Riduci' : '🔍 Espandi';
      }
      if (modeBtn) {
        modeBtn.hidden = !(expanded && aerialSrc);
      }
    }

    function openEditor() {
      if (!editor) return;
      editor.hidden = false;
      if (emptyBtn) emptyBtn.hidden = true;
      if (input) {
        input.value = card.getAttribute('data-where-value') || '';
        input.focus();
        input.select();
      }
    }

    function closeEditor() {
      if (!editor) return;
      editor.hidden = true;
      var hasVal = !!(card.getAttribute('data-where-value') || '').trim();
      if (emptyBtn) emptyBtn.hidden = hasVal;
    }

    function commitWhere() {
      if (!input || !todoId) return;
      var newWhere = input.value.trim();
      saveTodoInline(todoId, { where: newWhere }, statusEl, function(data) {
        var finalWhere = (data && typeof data.where === 'string') ? data.where.trim() : newWhere;
        card.setAttribute('data-where-value', finalWhere);
        aerialSrc = (data && data.maps_aerial_url) || buildMapsEmbedUrl(finalWhere, true, 16);
        roadSrc   = (data && data.maps_road_url) || buildMapsEmbedUrl(finalWhere, false, 15);
        var ext   = (data && data.maps_ext_url) || buildMapsExternalUrl(finalWhere);
        card.setAttribute('data-aerial-src', aerialSrc);
        card.setAttribute('data-road-src', roadSrc);

        editor.hidden = true;
        if (finalWhere && aerialSrc) {
          card.classList.add('has-where');
          card.classList.remove('is-empty-where');
          if (whereText) whereText.textContent = finalWhere;
          if (extLink) extLink.href = ext;
          if (iframe) iframe.src = isAerial ? aerialSrc : roadSrc;
          if (populated) populated.hidden = false;
          if (toggleBtn) toggleBtn.hidden = false;
          if (emptyBtn) emptyBtn.hidden = true;
        } else {
          card.classList.remove('has-where');
          card.classList.add('is-empty-where');
          setExpanded(false);
          if (populated) populated.hidden = true;
          if (toggleBtn) toggleBtn.hidden = true;
          if (modeBtn) modeBtn.hidden = true;
          if (emptyBtn) emptyBtn.hidden = false;
        }
      });
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
    if (modeBtn && iframe) {
      modeBtn.addEventListener('click', function() {
        if (!aerialSrc || !roadSrc) return;
        isAerial = !isAerial;
        iframe.src = isAerial ? aerialSrc : roadSrc;
        modeBtn.textContent = isAerial ? '🗺️ Mappa' : '🛰️ Aerea';
      });
    }
    if (editBtn) editBtn.addEventListener('click', openEditor);
    if (emptyBtn) emptyBtn.addEventListener('click', openEditor);
    if (saveBtn) saveBtn.addEventListener('click', commitWhere);
    if (cancelBtn) cancelBtn.addEventListener('click', closeEditor);
    if (input) {
      input.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          commitWhere();
        } else if (e.key === 'Escape') {
          e.preventDefault();
          closeEditor();
        }
      });
    }
  }

  // --- Favorite Toolbar Toggle (In-Loco) ---
  function initFavToggle(btn) {
    if (!btn || btn.getAttribute('data-bound')) return;
    btn.setAttribute('data-bound', 'true');
    var todoId = btn.getAttribute('data-todo-id');
    btn.addEventListener('click', function() {
      var nextFav = btn.getAttribute('data-favorite') !== 'true';
      btn.setAttribute('data-favorite', nextFav ? 'true' : 'false');
      btn.classList.toggle('is-fav', nextFav);
      btn.textContent = nextFav ? '★ Preferito' : '☆ Preferito';
      saveTodoInline(todoId, { favorite: nextFav }, null);
    });
  }

  // --- Project In-Loco Switcher ---
  function initProjectWidget(chip) {
    if (!chip || chip.getAttribute('data-bound')) return;
    chip.setAttribute('data-bound', 'true');
    var todoId = chip.getAttribute('data-todo-id');
    var btn    = chip.querySelector('[data-project-edit-btn]');
    var select = chip.querySelector('[data-project-select]');
    var link   = chip.querySelector('[data-project-link]');
    var status = chip.querySelector('[data-project-status]');
    if (!btn || !select) return;

    btn.addEventListener('click', function() {
      var open = select.hidden;
      select.hidden = !open;
      if (open) select.focus();
    });

    select.addEventListener('change', function() {
      var pid = parseInt(select.value, 10);
      if (!pid) return;
      saveTodoInline(todoId, { project_id: pid }, status, function(data) {
        if (link) {
          link.textContent = (data && data.project_name) || select.options[select.selectedIndex].text;
          if (link.tagName === 'A' && data && data.project_id) {
            link.setAttribute('href', '/projects/' + data.project_id);
          }
          if (data && typeof data.project_color === 'string') {
            link.style.color = data.project_color || '';
          }
        }
        select.hidden = true;
      });
    });

    select.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') select.hidden = true;
    });
  }

  // --- Title In-Loco Editor ---
  function initTitleWidget(wrap) {
    if (!wrap || wrap.getAttribute('data-bound')) return;
    wrap.setAttribute('data-bound', 'true');
    var todoId  = wrap.getAttribute('data-todo-id');
    var heading = wrap.querySelector('[data-title-heading]');
    var display = wrap.querySelector('[data-title-display]');
    var editBtn = wrap.querySelector('[data-title-edit-btn]');
    var editor  = wrap.querySelector('[data-title-editor]');
    var input   = wrap.querySelector('[data-title-input]');
    var saveBtn = wrap.querySelector('[data-title-save]');
    var cancel  = wrap.querySelector('[data-title-cancel]');
    var status  = wrap.querySelector('[data-title-status]');
    if (!display || !editor || !input) return;

    function open() {
      input.value = display.textContent.trim();
      heading.hidden = true;
      editor.hidden = false;
      input.focus();
      input.select();
    }

    function close() {
      editor.hidden = true;
      heading.hidden = false;
    }

    function save() {
      var nextName = input.value.trim();
      if (!nextName) return;
      display.textContent = nextName;
      close();
      saveTodoInline(todoId, { name: nextName }, status, function(data) {
        if (data && data.name) display.textContent = data.name;
      });
    }

    display.addEventListener('click', open);
    display.addEventListener('keydown', function(e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        open();
      }
    });
    if (editBtn) editBtn.addEventListener('click', open);
    if (saveBtn) saveBtn.addEventListener('click', save);
    if (cancel) cancel.addEventListener('click', close);
    input.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        save();
      } else if (e.key === 'Escape') {
        e.preventDefault();
        close();
      }
    });
  }

  // --- Tags In-Loco Chip Editor ---
  function initTagsWidget(wrap) {
    if (!wrap || wrap.getAttribute('data-bound')) return;
    wrap.setAttribute('data-bound', 'true');
    var todoId = wrap.getAttribute('data-todo-id');
    var listEl = wrap.querySelector('[data-tags-list]');
    var addBtn = wrap.querySelector('[data-tag-add-btn]');
    var formEl = wrap.querySelector('[data-tag-form]');
    var input  = wrap.querySelector('[data-tag-input]');
    var saveB  = wrap.querySelector('[data-tag-save]');
    var cancel = wrap.querySelector('[data-tag-cancel]');
    var status = wrap.querySelector('[data-tags-status]');
    if (!listEl) return;

    function currentTagNames() {
      var chips = listEl.querySelectorAll('[data-tag-name]');
      var names = [];
      for (var i = 0; i < chips.length; i++) {
        var n = (chips[i].getAttribute('data-tag-name') || '').trim();
        if (n && names.indexOf(n) === -1) names.push(n);
      }
      return names;
    }

    function renderTags(items) {
      var html = '';
      for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var name = typeof item === 'string' ? item : item.name;
        var id   = (typeof item === 'object' && item && item.id) ? item.id : null;
        var safe = escapeHtml(name);
        var inner = id
          ? '<a href="/tags/' + encodeURIComponent(id) + '" class="todo-tag-chip-link">🏷️ ' + safe + '</a>'
          : '<span class="todo-tag-chip-link">🏷️ ' + safe + '</span>';
        html += '<span class="todo-tag-chip" data-tag-name="' + safe + '">' +
          inner +
          '<button type="button" class="todo-tag-remove" data-tag-remove="' + safe + '" title="Rimuovi tag ' + safe + '">×</button>' +
          '</span>';
      }
      listEl.innerHTML = html;
    }

    function persistTags(namesArray) {
      renderTags(namesArray);
      saveTodoInline(todoId, { tag_list: namesArray.join(', ') }, status, function(data) {
        if (data && data.tags && data.tags.length >= 0) {
          renderTags(data.tags);
        }
      });
    }

    listEl.addEventListener('click', function(e) {
      var rm = e.target && e.target.closest('[data-tag-remove]');
      if (!rm) return;
      var targetName = rm.getAttribute('data-tag-remove');
      var next = currentTagNames().filter(function(n) { return n !== targetName; });
      persistTags(next);
    });

    function openAdd() {
      if (!formEl) return;
      formEl.hidden = false;
      if (addBtn) addBtn.hidden = true;
      if (input) {
        input.value = '';
        input.focus();
      }
    }

    function closeAdd() {
      if (!formEl) return;
      formEl.hidden = true;
      if (addBtn) addBtn.hidden = false;
    }

    function submitNewTag() {
      if (!input) return;
      var raw = input.value;
      var parts = raw.split(',');
      var names = currentTagNames();
      var changed = false;
      for (var i = 0; i < parts.length; i++) {
        var clean = parts[i].replace(/^#+/, '').trim();
        if (clean && names.indexOf(clean) === -1) {
          names.push(clean);
          changed = true;
        }
      }
      input.value = '';
      closeAdd();
      if (changed) persistTags(names);
    }

    if (addBtn) addBtn.addEventListener('click', openAdd);
    if (saveB) saveB.addEventListener('click', submitNewTag);
    if (cancel) cancel.addEventListener('click', closeAdd);
    if (input) {
      input.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' || e.key === ',') {
          e.preventDefault();
          submitNewTag();
        } else if (e.key === 'Escape') {
          e.preventDefault();
          closeAdd();
        }
      });
    }
  }

  // --- External URL In-Loco Editor ---
  function initUrlWidget(wrap) {
    if (!wrap || wrap.getAttribute('data-bound')) return;
    wrap.setAttribute('data-bound', 'true');
    var todoId   = wrap.getAttribute('data-todo-id');
    var banner   = wrap.querySelector('[data-url-banner]');
    var valBox   = wrap.querySelector('[data-url-value]');
    var editBtn  = wrap.querySelector('[data-url-edit-btn]');
    var addBtn   = wrap.querySelector('[data-url-add-btn]');
    var editor   = wrap.querySelector('[data-url-editor]');
    var input    = wrap.querySelector('[data-url-input]');
    var saveBtn  = wrap.querySelector('[data-url-save]');
    var clearBtn = wrap.querySelector('[data-url-clear]');
    var cancelB  = wrap.querySelector('[data-url-cancel]');
    var status   = wrap.querySelector('[data-url-status]');

    function open() {
      if (!editor) return;
      editor.hidden = false;
      if (banner) banner.hidden = true;
      if (addBtn) addBtn.hidden = true;
      if (input) {
        input.value = wrap.getAttribute('data-raw-url') || '';
        input.focus();
        input.select();
      }
    }

    function restoreDisplay() {
      if (!editor) return;
      editor.hidden = true;
      var hasUrl = !!(wrap.getAttribute('data-raw-url') || '').trim();
      if (banner) banner.hidden = !hasUrl;
      if (addBtn) addBtn.hidden = hasUrl;
    }

    function commitUrl(rawVal) {
      var trimmed = String(rawVal || '').trim();
      saveTodoInline(todoId, { url: trimmed }, status, function(data) {
        var savedUrl = (data && typeof data.url === 'string') ? data.url.trim() : trimmed;
        wrap.setAttribute('data-raw-url', savedUrl);
        if (data && data.url_html) {
          if (valBox) valBox.innerHTML = data.url_html;
          if (banner) banner.hidden = false;
          if (addBtn) addBtn.hidden = true;
        } else if (savedUrl) {
          var href = /^https?:\/\//i.test(savedUrl) ? savedUrl : 'https://' + savedUrl;
          if (valBox) {
            valBox.innerHTML = '<a href="' + escapeHtml(href) + '" target="_blank" rel="noopener noreferrer" class="todo-url-link"><span class="todo-url-raw">' + escapeHtml(savedUrl) + '</span> <span class="todo-url-arrow">↗</span></a>';
          }
          if (banner) banner.hidden = false;
          if (addBtn) addBtn.hidden = true;
        } else {
          if (valBox) valBox.innerHTML = '';
          if (banner) banner.hidden = true;
          if (addBtn) addBtn.hidden = false;
        }
        if (editor) editor.hidden = true;
      });
    }

    if (editBtn) editBtn.addEventListener('click', open);
    if (addBtn) addBtn.addEventListener('click', open);
    if (cancelB) cancelB.addEventListener('click', restoreDisplay);
    if (saveBtn) saveBtn.addEventListener('click', function() { commitUrl(input ? input.value : ''); });
    if (clearBtn) clearBtn.addEventListener('click', function() { commitUrl(''); });
    if (input) {
      input.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          commitUrl(input.value);
        } else if (e.key === 'Escape') {
          e.preventDefault();
          restoreDisplay();
        }
      });
    }
  }

  // --- Description In-Loco Editor ---
  function initDescWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var todoId   = card.getAttribute('data-todo-id');
    var editBtn  = card.querySelector('[data-desc-edit-btn]');
    var display  = card.querySelector('[data-desc-display]');
    var prose    = card.querySelector('[data-desc-prose]');
    var emptyBtn = card.querySelector('[data-desc-empty]');
    var provBar  = card.querySelector('[data-desc-provenance]');
    var provTxt  = card.querySelector('[data-desc-provenance-text]');
    var editor   = card.querySelector('[data-desc-editor]');
    var textarea = card.querySelector('[data-desc-textarea]');
    var saveBtn  = card.querySelector('[data-desc-save]');
    var cancelB  = card.querySelector('[data-desc-cancel]');
    var status   = card.querySelector('[data-desc-status]');
    if (!editor || !textarea || !display) return;

    var lastSavedRaw = textarea.value;

    function open() {
      textarea.value = lastSavedRaw;
      display.hidden = true;
      editor.hidden = false;
      autoResizeTextarea(textarea);
      textarea.focus();
    }

    function close() {
      editor.hidden = true;
      display.hidden = false;
    }

    function save() {
      var val = textarea.value;
      saveTodoInline(todoId, { description: val }, status, function(data) {
        lastSavedRaw = (data && typeof data.description === 'string') ? data.description : val;
        var html = data && data.desc_html ? data.desc_html : '';
        if (prose) {
          prose.innerHTML = html;
          prose.hidden = !html;
        }
        if (emptyBtn) emptyBtn.hidden = !!html;
        if (provBar && provTxt) {
          var pl = (data && data.provenance_line) || '';
          provTxt.textContent = pl;
          provBar.hidden = !pl;
        }
        close();
      });
    }

    if (editBtn) editBtn.addEventListener('click', function() { editor.hidden ? open() : close(); });
    if (emptyBtn) emptyBtn.addEventListener('click', open);
    if (prose) {
      prose.addEventListener('dblclick', function(e) {
        if (e.target && e.target.closest('a')) return;
        open();
      });
    }
    if (saveBtn) saveBtn.addEventListener('click', save);
    if (cancelB) cancelB.addEventListener('click', close);
    textarea.addEventListener('input', function() { autoResizeTextarea(textarea); });
    textarea.addEventListener('keydown', function(e) {
      if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
        e.preventDefault();
        save();
      } else if (e.key === 'Escape') {
        e.preventDefault();
        close();
      }
    });
  }

  // --- Due Date In-Loco Editor ---
  function initDueWidget(card) {
    if (!card || card.getAttribute('data-bound')) return;
    card.setAttribute('data-bound', 'true');
    var todoId   = card.getAttribute('data-todo-id');
    var editBtn  = card.querySelector('[data-due-edit-btn]');
    var display  = card.querySelector('[data-due-display]');
    var editor   = card.querySelector('[data-due-editor]');
    var input    = card.querySelector('[data-due-input]');
    var presets  = card.querySelectorAll('[data-due-offset]');
    var clearBtn = card.querySelector('[data-due-clear]');
    var status   = card.querySelector('[data-due-status]');
    if (!editor || !input) return;

    function toggleEditor() {
      editor.hidden = !editor.hidden;
      if (!editor.hidden) input.focus();
    }

    function commitDue(isoDate) {
      input.value = isoDate || '';
      saveTodoInline(todoId, { due: isoDate || '' }, status, function(data) {
        card.setAttribute('data-due-iso', (data && data.due) || '');
        if (display && data && data.due_html) {
          display.innerHTML = data.due_html;
        }
        var overdue = !!(data && data.is_overdue);
        card.classList.toggle('is-overdue-card', overdue);

        var shell = document.querySelector('[data-todo-show-root]');
        if (shell) shell.classList.toggle('is-overdue-shell', overdue);
        var topPill = document.querySelector('[data-todo-status-pill]');
        if (topPill && data && !data.is_done) {
          topPill.className = 'todo-status-pill ' + (overdue ? 'is-overdue' : 'is-active');
          topPill.textContent = overdue ? '● Attivo · Scaduto' : '● Attivo';
        }
        editor.hidden = true;
      });
    }

    if (editBtn) editBtn.addEventListener('click', toggleEditor);
    if (display) display.addEventListener('click', toggleEditor);
    input.addEventListener('change', function() { commitDue(input.value); });
    for (var i = 0; i < presets.length; i++) {
      (function(btn) {
        btn.addEventListener('click', function() {
          commitDue(datePlusDaysIso(btn.getAttribute('data-due-offset')));
        });
      })(presets[i]);
    }
    if (clearBtn) {
      clearBtn.addEventListener('click', function() { commitDue(''); });
    }
  }

  // --- Modern Edit/New Form Interactive Wiring ---
  function initModernTodoForm(form) {
    if (!form || form.getAttribute('data-bound')) return;
    form.setAttribute('data-bound', 'true');

    // Check pills visual state
    var checkPills = form.querySelectorAll('[data-check-pill]');
    for (var c = 0; c < checkPills.length; c++) {
      (function(lbl) {
        var cb = lbl.querySelector('input[type="checkbox"]');
        if (!cb) return;
        cb.addEventListener('change', function() {
          var isFav = cb.name.indexOf('favorite') !== -1;
          lbl.classList.toggle(isFav ? 'is-checked-fav' : 'is-checked-success', cb.checked);
        });
      })(checkPills[c]);
    }

    // Priority & Progress inside form (formMode: true -> no XHR, syncs form inputs)
    var prioCard = form.querySelector('[data-form-prio-widget]');
    if (prioCard) initPriorityWheelWidget(prioCard, { formMode: true });

    var progCard = form.querySelector('[data-form-progress-widget]');
    if (progCard) initProgressWidget(progCard, { formMode: true });

    // Tag chips editor inside form
    var tagEditor = form.querySelector('[data-form-tags-editor]');
    var flushPendingFormTag = null;
    if (tagEditor) {
      var hiddenTag = tagEditor.querySelector('[data-form-tag-hidden]');
      var chipsBox  = tagEditor.querySelector('[data-form-tags-chips]');
      var entryInp  = tagEditor.querySelector('[data-form-tag-entry]');

      function readFormTags() {
        var els = chipsBox.querySelectorAll('[data-chip-val]');
        var arr = [];
        for (var i = 0; i < els.length; i++) {
          var v = (els[i].getAttribute('data-chip-val') || '').trim();
          if (v && arr.indexOf(v) === -1) arr.push(v);
        }
        return arr;
      }

      function writeFormTags(arr) {
        if (hiddenTag) hiddenTag.value = arr.join(', ');
        var html = '';
        for (var i = 0; i < arr.length; i++) {
          var safe = escapeHtml(arr[i]);
          html += '<span class="todo-tag-chip" data-chip-val="' + safe + '">' +
            '<span class="todo-tag-chip-link">🏷️ ' + safe + '</span>' +
            '<button type="button" class="todo-tag-remove" data-form-tag-remove="' + safe + '" title="Rimuovi ' + safe + '">×</button>' +
            '</span>';
        }
        chipsBox.innerHTML = html;
      }

      flushPendingFormTag = function() {
        if (!entryInp || !entryInp.value.trim()) return;
        var parts = entryInp.value.split(',');
        var cur = readFormTags();
        for (var i = 0; i < parts.length; i++) {
          var t = parts[i].replace(/^#+/, '').trim();
          if (t && cur.indexOf(t) === -1) cur.push(t);
        }
        entryInp.value = '';
        writeFormTags(cur);
      };

      chipsBox.addEventListener('click', function(e) {
        var rm = e.target && e.target.closest('[data-form-tag-remove]');
        if (!rm) return;
        var target = rm.getAttribute('data-form-tag-remove');
        writeFormTags(readFormTags().filter(function(x) { return x !== target; }));
      });

      if (entryInp) {
        entryInp.addEventListener('keydown', function(e) {
          if (e.key === 'Enter' || e.key === ',') {
            e.preventDefault();
            flushPendingFormTag();
          } else if (e.key === 'Backspace' && !entryInp.value) {
            var cur = readFormTags();
            if (cur.length > 0) {
              cur.pop();
              writeFormTags(cur);
            }
          }
        });
        entryInp.addEventListener('blur', flushPendingFormTag);
      }
    }

    // Form Due quick presets
    var dueInp = form.querySelector('[data-form-due-input]');
    var dueOffsets = form.querySelectorAll('[data-form-due-offset]');
    var dueClear = form.querySelector('[data-form-due-clear]');
    if (dueInp) {
      for (var d = 0; d < dueOffsets.length; d++) {
        (function(btn) {
          btn.addEventListener('click', function() {
            dueInp.value = datePlusDaysIso(btn.getAttribute('data-form-due-offset'));
          });
        })(dueOffsets[d]);
      }
      if (dueClear) dueClear.addEventListener('click', function() { dueInp.value = ''; });
    }

    // Form Snooze quick presets
    var snoozeInp = form.querySelector('[data-form-snooze-input]');
    var snoozeBtns = form.querySelectorAll('[data-snooze-days]');
    var snoozeClr = form.querySelector('[data-snooze-clear]');
    if (snoozeInp) {
      for (var s = 0; s < snoozeBtns.length; s++) {
        (function(btn) {
          btn.addEventListener('click', function() {
            snoozeInp.value = snoozePlusDaysIso(btn.getAttribute('data-snooze-days'));
          });
        })(snoozeBtns[s]);
      }
      if (snoozeClr) snoozeClr.addEventListener('click', function() { snoozeInp.value = ''; });
    }

    // Form Where live aerial map preview
    var whereInp   = form.querySelector('[data-form-where-input]');
    var mapFrame   = form.querySelector('[data-form-map-frame]');
    var mapIframe  = form.querySelector('[data-form-map-iframe]');
    var whereExt   = form.querySelector('[data-form-where-ext]');
    var mapTimer   = null;
    if (whereInp && mapFrame && mapIframe) {
      whereInp.addEventListener('input', function() {
        if (mapTimer) clearTimeout(mapTimer);
        mapTimer = setTimeout(function() {
          var w = whereInp.value.trim();
          if (w) {
            mapIframe.src = buildMapsEmbedUrl(w, true, 16);
            mapFrame.hidden = false;
            if (whereExt) {
              whereExt.href = buildMapsExternalUrl(w);
              whereExt.hidden = false;
            }
          } else {
            mapFrame.hidden = true;
            if (whereExt) whereExt.hidden = true;
          }
        }, 480);
      });
    }

    // Form URL live preview button
    var urlInp = form.querySelector('[data-form-url-input]');
    var urlPrv = form.querySelector('[data-form-url-preview]');
    if (urlInp && urlPrv) {
      urlInp.addEventListener('input', function() {
        var u = urlInp.value.trim();
        if (u && !/^\s*(javascript|data|vbscript):/i.test(u)) {
          urlPrv.href = /^https?:\/\//i.test(u) ? u : 'https://' + u;
          urlPrv.hidden = false;
        } else {
          urlPrv.hidden = true;
        }
      });
    }

    // Auto-grow textareas
    var textareas = form.querySelectorAll('[data-auto-grow]');
    for (var t = 0; t < textareas.length; t++) {
      (function(ta) {
        autoResizeTextarea(ta);
        ta.addEventListener('input', function() { autoResizeTextarea(ta); });
      })(textareas[t]);
    }

    // Flush pending tag entry before submit + Cmd/Ctrl+Enter shortcut
    form.addEventListener('submit', function() {
      if (flushPendingFormTag) flushPendingFormTag();
    });
    form.addEventListener('keydown', function(e) {
      if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
        e.preventDefault();
        if (flushPendingFormTag) flushPendingFormTag();
        form.submit();
      }
    });
  }

  function initTodoShowWidgets() {
    var progCards = document.querySelectorAll('[data-todo-progress-widget]');
    for (var i = 0; i < progCards.length; i++) initProgressWidget(progCards[i]);

    var prioCards = document.querySelectorAll('[data-todo-prio-widget]');
    for (var j = 0; j < prioCards.length; j++) initPriorityWheelWidget(prioCards[j]);

    var whereCards = document.querySelectorAll('[data-todo-where-widget]');
    for (var k = 0; k < whereCards.length; k++) initWhereMapWidget(whereCards[k]);

    var favBtns = document.querySelectorAll('[data-todo-fav-toggle]');
    for (var f = 0; f < favBtns.length; f++) initFavToggle(favBtns[f]);

    var projChips = document.querySelectorAll('[data-todo-project-widget]');
    for (var p = 0; p < projChips.length; p++) initProjectWidget(projChips[p]);

    var titleWraps = document.querySelectorAll('[data-todo-title-widget]');
    for (var tw = 0; tw < titleWraps.length; tw++) initTitleWidget(titleWraps[tw]);

    var tagWraps = document.querySelectorAll('[data-todo-tags-widget]');
    for (var tg = 0; tg < tagWraps.length; tg++) initTagsWidget(tagWraps[tg]);

    var urlWraps = document.querySelectorAll('[data-todo-url-widget]');
    for (var u = 0; u < urlWraps.length; u++) initUrlWidget(urlWraps[u]);

    var descCards = document.querySelectorAll('[data-todo-desc-widget]');
    for (var dc = 0; dc < descCards.length; dc++) initDescWidget(descCards[dc]);

    var dueCards = document.querySelectorAll('[data-todo-due-widget]');
    for (var du = 0; du < dueCards.length; du++) initDueWidget(dueCards[du]);

    var modernForms = document.querySelectorAll('[data-todo-modern-form]');
    for (var mf = 0; mf < modernForms.length; mf++) initModernTodoForm(modernForms[mf]);
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
