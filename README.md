# Smart Paste

![Version](https://img.shields.io/badge/version-0.3-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334455?logo=autohotkey&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![Tauri](https://img.shields.io/badge/Tauri-2.0-FFC131?logo=tauri&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-backend-DEA584?logo=rust&logoColor=white)
![HTML/CSS/JS](https://img.shields.io/badge/HTML%2FCSS%2FJS-frontend-E34F26?logo=html5&logoColor=white)

> **English** | [Tiếng Việt](README.vi.md)

> **Sequential multi-line paster** — A lightweight tool for fast form filling and batch data entry on Windows.

## 📦 Two Editions

| | AHK Edition | Tauri Edition |
|--|-------------|---------------|
| **Best for** | Minimal, fast, lightweight | Modern UI, premium feel |
| **Size** | ~1.3 MB | ~5 MB |
| **UI** | Windows native | Dark mode, animations |
| **Requires** | [AutoHotkey v2](https://autohotkey.com) or standalone .exe | Just run .exe |
| **Folder** | [`ahk/`](ahk/) | [`tauri/`](tauri/) |

## ✨ Core Features

- ✅ **Auto-detect clipboard** — Copy multiple lines, app loads automatically
- ✅ **F9 paste forward** — Paste lines sequentially
- ✅ **F10 paste backward** — Go back and re-paste
- ✅ **⚡ Auto-paste mode** — Auto-fill forms with Tab/Enter/Space
- ✅ **Custom hotkeys** — Assign any key or combo
- ✅ **Load from file** — Import .txt / .csv data
- ✅ **Clipboard history** — Recall last 10 data sets
- ✅ **Adjustable delay** — Fine-tune paste speed
- ✅ **Bilingual UI** — Vietnamese / English

## 📥 Quick Start

### AHK Edition (Lightweight)
```bash
# Option 1: Run script (requires AutoHotkey v2)
cd ahk
# Double-click SmartPaste.ahk

# Option 2: Download pre-built .exe from Releases
```

### Tauri Edition (Modern UI)
```bash
# Download from Releases — just run the .exe
```

## 📂 Project Structure

```
smartpaste/
├── ahk/                        ← AHK Edition
│   ├── SmartPaste.ahk          # Main script
│   ├── smart_paste_queue.py    # Python alternative
│   ├── config.ini              # Settings
│   └── scripts/
│       └── build-exe.bat       # Build to standalone .exe
├── tauri/                      ← Tauri Edition (coming soon)
│   ├── src-tauri/              # Rust backend
│   └── src/                    # Web frontend (HTML/CSS/JS)
├── LICENSE
├── README.md                   # English
└── README.vi.md                # Vietnamese
```

## 🤝 Contributing

1. Fork this repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Commit (`git commit -m "Add: feature"`)
4. Push and open a Pull Request

## 📝 License

MIT License - Copyright (c) 2026 [Dahodo (DHD)](https://dahodo.com)

---

<p align="center">
  <a href="https://dahodo.com">Website</a> •
  <a href="mailto:danghoangdong79@gmail.com">Email</a> •
  <a href="https://github.com/danghoangdong79/smartpaste">GitHub</a>
</p>
