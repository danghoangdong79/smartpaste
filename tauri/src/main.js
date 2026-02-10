// ============ STATE ============
const state = {
  queue: [],
  currentIndex: 0,
  history: [],
  isAutoPasting: false,
  autoTimer: null,
  settings: {
    loop: false,
    auto: false,
    onTop: true,
    sound: true,
    startup: false,
    lang: 'en',
    skipEmpty: true,
    delay: 0.1,
    separator: 'Tab',
    pasteKey: 'F9',
    backKey: 'F10',
    autoKey: 'F11',
  },
  lastClip: '',
};

const CIRCUMFERENCE = 2 * Math.PI * 52; // ~326.7

// ============ DOM ============
const $ = (s) => document.querySelector(s);
const $$ = (s) => document.querySelectorAll(s);

const dom = {
  mainView: $('#mainView'),
  settingsView: $('#settingsView'),
  ringProgress: $('#ringProgress'),
  currentNum: $('#currentNum'),
  totalNum: $('#totalNum'),
  statusBadge: $('#statusBadge'),
  previewList: $('#previewList'),
  pasteKeyLabel: $('#pasteKeyLabel'),
  backKeyLabel: $('#backKeyLabel'),
  delaySlider: $('#delaySlider'),
  delayValue: $('#delayValue'),
  toast: $('#toast'),
};

// ============ INIT ============
function init() {
  loadSettings();
  setupEvents();
  refreshUI();
  startClipboardWatch();
}

// ============ SETTINGS ============
function loadSettings() {
  try {
    const saved = localStorage.getItem('smartpaste_settings');
    if (saved) {
      Object.assign(state.settings, JSON.parse(saved));
    }
  } catch (e) { }

  const hist = localStorage.getItem('smartpaste_history');
  if (hist) {
    try { state.history = JSON.parse(hist); } catch (e) { }
  }

  // Apply to UI
  $('#chkLoop').checked = state.settings.loop;
  $('#chkAuto').checked = state.settings.auto;
  $('#chkOnTop').checked = state.settings.onTop;
  $('#chkSound').checked = state.settings.sound;
  $('#chkStartup').checked = state.settings.startup;
  $('#chkLang').checked = state.settings.lang === 'vi';
  $('#chkSkipEmpty').checked = state.settings.skipEmpty;
  dom.delaySlider.value = state.settings.delay;
  dom.delayValue.textContent = state.settings.delay + ' sec';
  dom.pasteKeyLabel.textContent = state.settings.pasteKey;
  dom.backKeyLabel.textContent = state.settings.backKey;
  $('#btnHkPaste').textContent = state.settings.pasteKey;
  $('#btnHkBack').textContent = state.settings.backKey;
  $('#btnHkAuto').textContent = state.settings.autoKey;

  // Separator pills
  $$('.pill').forEach(p => {
    p.classList.toggle('active', p.dataset.sep === state.settings.separator);
  });
}

function saveSettings() {
  localStorage.setItem('smartpaste_settings', JSON.stringify(state.settings));
}

function saveHistory() {
  localStorage.setItem('smartpaste_history', JSON.stringify(state.history.slice(0, 10)));
}

// ============ EVENTS ============
function setupEvents() {
  // Settings toggle
  $('#btnSettings').addEventListener('click', () => {
    dom.settingsView.classList.remove('hidden');
  });

  $('#btnBack2Main').addEventListener('click', closeSettings);
  $('#btnDone').addEventListener('click', closeSettings);

  // Main buttons
  $('#btnPaste').addEventListener('click', doPaste);
  $('#btnBack').addEventListener('click', doBack);
  $('#btnReset').addEventListener('click', doReset);
  $('#btnViewAll').addEventListener('click', showViewAll);

  // Toggles
  $('#chkLoop').addEventListener('change', (e) => { state.settings.loop = e.target.checked; saveSettings(); });
  $('#chkAuto').addEventListener('change', (e) => {
    state.settings.auto = e.target.checked;
    saveSettings();
    if (e.target.checked && state.queue.length > 0) {
      startAutoPaste();
    } else {
      stopAutoPaste();
    }
  });
  $('#chkOnTop').addEventListener('change', (e) => { state.settings.onTop = e.target.checked; saveSettings(); });
  $('#chkSound').addEventListener('change', (e) => { state.settings.sound = e.target.checked; saveSettings(); });
  $('#chkStartup').addEventListener('change', (e) => { state.settings.startup = e.target.checked; saveSettings(); });
  $('#chkLang').addEventListener('change', (e) => { state.settings.lang = e.target.checked ? 'vi' : 'en'; saveSettings(); });
  $('#chkSkipEmpty').addEventListener('change', (e) => { state.settings.skipEmpty = e.target.checked; saveSettings(); });

  // Delay slider
  dom.delaySlider.addEventListener('input', (e) => {
    state.settings.delay = parseFloat(e.target.value);
    dom.delayValue.textContent = state.settings.delay + ' sec';
    saveSettings();
  });

  // Separator pills
  $$('.pill').forEach(pill => {
    pill.addEventListener('click', () => {
      $$('.pill').forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      state.settings.separator = pill.dataset.sep;
      saveSettings();
    });
  });

  // Data actions
  $('#btnLoadFile').addEventListener('click', loadFromFile);
  $('#btnHistory').addEventListener('click', showHistory);
  $('#btnManual').addEventListener('click', () => $('#manualModal').classList.remove('hidden'));
  $('#closeManual').addEventListener('click', () => $('#manualModal').classList.add('hidden'));
  $('#btnLoadManual').addEventListener('click', loadManual);
  $('#closeHistory').addEventListener('click', () => $('#historyModal').classList.remove('hidden'));
  $('#closeHistory').addEventListener('click', () => $('#historyModal').classList.add('hidden'));
  $('#closeViewAll').addEventListener('click', () => $('#viewAllModal').classList.add('hidden'));

  // Modal backdrop close
  ['manualModal', 'historyModal', 'viewAllModal'].forEach(id => {
    $(`#${id}`).addEventListener('click', (e) => {
      if (e.target.id === id) e.target.classList.add('hidden');
    });
  });

  // Keyboard shortcuts
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (state.isAutoPasting) {
        stopAutoPaste();
        return;
      }
      // Close modals
      $$('.modal:not(.hidden)').forEach(m => m.classList.add('hidden'));
      if (!dom.settingsView.classList.contains('hidden')) closeSettings();
    }
  });
}

function closeSettings() {
  dom.settingsView.classList.add('hidden');
}

// ============ CORE ACTIONS ============
function doPaste() {
  if (state.queue.length === 0) {
    showToast('No data loaded');
    return;
  }

  if (state.currentIndex >= state.queue.length) {
    if (state.settings.loop) {
      state.currentIndex = 0;
    } else {
      showToast('✅ All done!');
      playSound(800, 200);
      return;
    }
  }

  const text = state.queue[state.currentIndex];
  state.currentIndex++;

  copyToClipboard(text);
  playSound(1500, 30);
  showToast(`📋 Pasted ${state.currentIndex}/${state.queue.length}`);
  refreshUI();
}

function doBack() {
  if (state.queue.length === 0) {
    showToast('No data');
    return;
  }

  if (state.currentIndex > 1) {
    state.currentIndex--;
    const text = state.queue[state.currentIndex - 1];
    copyToClipboard(text);
    playSound(1500, 30);
    refreshUI();
  } else {
    showToast('Already at first item');
  }
}

function doReset() {
  state.currentIndex = 0;
  stopAutoPaste();
  refreshUI();
  showToast('↺ Reset');
}

// ============ AUTO PASTE ============
function startAutoPaste() {
  if (state.queue.length === 0 || state.currentIndex >= state.queue.length) return;

  state.isAutoPasting = true;
  refreshUI();
  showToast('⚡ Auto-pasting...');

  doAutoPasteTick();
}

function doAutoPasteTick() {
  if (!state.isAutoPasting || state.currentIndex >= state.queue.length) {
    stopAutoPaste();
    if (state.currentIndex >= state.queue.length) {
      showToast('✅ Auto-paste complete!');
      playSound(800, 200);
    }
    return;
  }

  const text = state.queue[state.currentIndex];
  state.currentIndex++;

  copyToClipboard(text);
  playSound(1500, 20);
  refreshUI();

  const delayMs = Math.max(state.settings.delay * 1000, 50);
  state.autoTimer = setTimeout(doAutoPasteTick, delayMs);
}

function stopAutoPaste() {
  state.isAutoPasting = false;
  if (state.autoTimer) {
    clearTimeout(state.autoTimer);
    state.autoTimer = null;
  }
  $('#chkAuto').checked = false;
  state.settings.auto = false;
  refreshUI();
}

// ============ LOAD DATA ============
function loadQueue(text) {
  // Save current queue to history
  if (state.queue.length > 0) {
    addToHistory();
  }

  const lines = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n');
  state.queue = [];
  state.currentIndex = 0;

  for (const line of lines) {
    if (state.settings.skipEmpty) {
      const trimmed = line.trim();
      if (trimmed) state.queue.push(trimmed);
    } else {
      state.queue.push(line);
    }
  }

  refreshUI();
  showToast(`📦 Loaded ${state.queue.length} items`);
  playSound(1200, 80);
}

function loadManual() {
  const text = $('#manualText').value;
  if (text.trim()) {
    loadQueue(text);
    $('#manualText').value = '';
    $('#manualModal').classList.add('hidden');
  }
}

async function loadFromFile() {
  // Use file input since we're in vanilla JS
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = '.txt,.csv,.tsv';
  input.onchange = async (e) => {
    const file = e.target.files[0];
    if (file) {
      const text = await file.text();
      loadQueue(text);
      closeSettings();
    }
  };
  input.click();
}

// ============ CLIPBOARD ============
function copyToClipboard(text) {
  navigator.clipboard.writeText(text).catch(() => {
    // Fallback
    const ta = document.createElement('textarea');
    ta.value = text;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
  });
}

function startClipboardWatch() {
  // Check clipboard every 500ms for multi-line content
  setInterval(async () => {
    try {
      const text = await navigator.clipboard.readText();
      if (text && text !== state.lastClip && (text.includes('\n') || text.includes('\r'))) {
        state.lastClip = text;
        loadQueue(text);
      }
    } catch (e) {
      // Clipboard read may fail without focus/permission
    }
  }, 500);
}

// ============ HISTORY ============
function addToHistory() {
  if (state.queue.length === 0) return;

  const preview = state.queue.slice(0, 3).map(s => s.length > 15 ? s.slice(0, 15) + '..' : s).join(', ');
  const entry = {
    label: `${state.queue.length} items: ${preview}`,
    data: [...state.queue],
  };

  state.history.unshift(entry);
  if (state.history.length > 10) state.history.pop();
  saveHistory();
}

function showHistory() {
  const list = $('#historyList');

  if (state.history.length === 0) {
    list.innerHTML = '<div class="preview-empty">No history yet</div>';
  } else {
    list.innerHTML = state.history.map((entry, i) => `
      <div class="history-item" data-idx="${i}">
        <span class="history-label">${escapeHtml(entry.label)}</span>
        <span class="history-count">${entry.data.length} items</span>
      </div>
    `).join('');

    list.querySelectorAll('.history-item').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx);
        const entry = state.history[idx];
        state.queue = [...entry.data];
        state.currentIndex = 0;
        refreshUI();
        showToast(`📦 Loaded ${state.queue.length} items`);
        playSound(1200, 80);
        $('#historyModal').classList.add('hidden');
        closeSettings();
      });
    });
  }

  $('#historyModal').classList.remove('hidden');
}

function showViewAll() {
  const list = $('#allItemsList');
  if (state.queue.length === 0) {
    list.innerHTML = '<div class="preview-empty">No data loaded</div>';
  } else {
    list.innerHTML = state.queue.map((item, i) => {
      let cls = '';
      if (i === state.currentIndex) cls = 'current';
      else if (i < state.currentIndex) cls = 'done';
      return `
        <div class="all-item ${cls}">
          <span class="all-item-num">${i + 1}</span>
          <span class="all-item-text">${escapeHtml(item)}</span>
        </div>
      `;
    }).join('');
  }
  $('#viewAllModal').classList.remove('hidden');
}

// ============ UI REFRESH ============
function refreshUI() {
  const total = state.queue.length;
  const current = state.currentIndex;
  const done = current;

  // Ring
  dom.currentNum.textContent = done;
  dom.totalNum.textContent = total;

  const pct = total > 0 ? done / total : 0;
  const offset = CIRCUMFERENCE * (1 - pct);
  dom.ringProgress.style.strokeDashoffset = offset;

  // Ring color based on state
  if (state.isAutoPasting) {
    dom.ringProgress.style.stroke = '#f59e0b';
    dom.ringProgress.style.filter = 'drop-shadow(0 0 6px rgba(245,158,11,0.3))';
  } else if (done >= total && total > 0) {
    dom.ringProgress.style.stroke = '#22c55e';
    dom.ringProgress.style.filter = 'drop-shadow(0 0 6px rgba(34,197,94,0.3))';
  } else {
    dom.ringProgress.style.stroke = '#3b82f6';
    dom.ringProgress.style.filter = 'drop-shadow(0 0 6px rgba(59,130,246,0.3))';
  }

  // Badge
  const badge = dom.statusBadge;
  badge.className = 'ring-badge';
  if (state.isAutoPasting) {
    badge.className = 'ring-badge auto';
    badge.innerHTML = '<span class="dot"></span> Auto-pasting';
  } else if (total === 0) {
    badge.innerHTML = '<span class="dot"></span> Waiting';
  } else if (done >= total) {
    badge.className = 'ring-badge done';
    badge.innerHTML = '<span class="dot"></span> Complete';
  } else {
    badge.className = 'ring-badge active';
    badge.innerHTML = '<span class="dot"></span> Ready';
  }

  // Preview
  renderPreview();
}

function renderPreview() {
  const list = dom.previewList;
  if (state.queue.length === 0) {
    list.innerHTML = '<div class="preview-empty">Copy multiple lines to begin</div>';
    return;
  }

  let html = '';
  const idx = state.currentIndex;

  // Current
  if (idx < state.queue.length) {
    const text = truncate(state.queue[idx], 40);
    html += `
      <div class="preview-item current">
        <div>
          <div class="preview-item-label">Current</div>
          <div class="preview-item-text">${escapeHtml(text)}</div>
        </div>
        <span class="arrow">→</span>
      </div>`;
  }

  // Next 2
  for (let i = 1; i <= 2; i++) {
    const ni = idx + i;
    if (ni < state.queue.length) {
      const text = truncate(state.queue[ni], 36);
      html += `
        <div class="preview-item">
          <div class="preview-item-text">${escapeHtml(text)}</div>
        </div>`;
    }
  }

  if (idx >= state.queue.length) {
    html = '<div class="preview-empty">✅ All items pasted!</div>';
  }

  list.innerHTML = html;
}

// ============ UTILITIES ============
function showToast(msg) {
  dom.toast.textContent = msg;
  dom.toast.classList.remove('hidden');
  dom.toast.classList.add('show');
  clearTimeout(dom.toast._timer);
  dom.toast._timer = setTimeout(() => {
    dom.toast.classList.remove('show');
    setTimeout(() => dom.toast.classList.add('hidden'), 300);
  }, 2000);
}

function playSound(freq, duration) {
  if (!state.settings.sound) return;
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.frequency.value = freq;
    gain.gain.value = 0.05;
    osc.start();
    osc.stop(ctx.currentTime + duration / 1000);
  } catch (e) { }
}

function truncate(str, len) {
  return str.length > len ? str.slice(0, len) + '...' : str;
}

function escapeHtml(str) {
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// ============ START ============
document.addEventListener('DOMContentLoaded', init);
