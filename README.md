# Smart Paste v0.1

![Version](https://img.shields.io/badge/version-0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-orange)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

> **Sequential multi-line paster** — A lightweight tool for fast form filling and batch data entry on Windows.

## ✨ Features

- ✅ **Auto-detect clipboard**: Copy multiple lines from Excel/Text, app detects automatically
- ✅ **F9 to paste forward**: Paste lines sequentially at cursor position
- ✅ **F10 to paste backward**: Go back and re-paste previous line
- ✅ **Custom hotkeys**: Assign any key or combo (Ctrl+K, Shift+F5, etc.)
- ✅ **Loop mode**: Cycle back to start when list ends
- ✅ **Bilingual UI**: Vietnamese / English
- ✅ **No virus risk**: Run the script directly, no compilation needed

## 📥 Installation

### Requirements
- Windows 10/11
- [AutoHotkey v2.0](https://www.autohotkey.com/)

### Quick Start

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Clone or download this repo:
   ```bash
   git clone https://github.com/dahodo/smartpaste.git
   ```
3. Double-click `SmartPaste.ahk` to run

### Python Version (alternative)

For developers who prefer Python:

```bash
pip install PyQt5 pywin32 keyboard
python smart_paste_queue.py
```

## 📖 How to Use

```
┌──────────────────┐
│  Copy multi-line  │  ← From Excel, Word, Notepad...
│  data             │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  App auto-loads   │  ← Shows "Loaded X items"
│  the queue        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Press F9 to      │  ← Pastes one line at a time
│  PASTE            │
└──────────────────┘
```

### Default Hotkeys

| Key | Function |
|-----|----------|
| **F9** | Paste next line |
| **F10** | Paste previous line |

> 💡 Click the hotkey button in the app to reassign to any key or combo

### Options

| Feature | Description |
|---------|-------------|
| 🔁 Loop | Cycle back to start when list ends |
| 📌 Always on top | Keep app above all windows |
| 🚀 Startup | Auto-launch with Windows |

## 🛠️ Troubleshooting

### "Hotkey not working"

**Cause**: Another app is blocking the hotkey

**Fix**:
```
Option 1: Run as Admin
  → Right-click SmartPaste.ahk
  → "Run as administrator"

Option 2: Change hotkey
  → Click the hotkey button in the app
  → Press any new key or combo
```

## 📂 Project Structure

```
smartpaste/
├── SmartPaste.ahk          # AHK version (recommended)
├── smart_paste_queue.py    # Python version
├── config.ini              # Default config
├── scripts/
│   └── build-exe.bat       # Build to .exe
├── LICENSE
├── .gitignore
└── README.md
```

## 🤝 Contributing

Contributions are welcome!

1. Fork this repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m "Add: new feature"`)
4. Push (`git push origin feature/your-feature`)
5. Open a Pull Request

## 📝 License

MIT License - Copyright (c) 2026 [Dahodo (DHD)](https://dahodo.com)

---

<p align="center">
  <a href="https://dahodo.com">Website</a> •
  <a href="mailto:danghoangdong79@gmail.com">Email</a> •
  <a href="https://github.com/dahodo/smartpaste">GitHub</a>
</p>
