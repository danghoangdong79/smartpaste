# Smart Paste

![Version](https://img.shields.io/badge/version-0.3-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334455?logo=autohotkey&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-012456?logo=powershell&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![Tauri](https://img.shields.io/badge/Tauri-2.0-FFC131?logo=tauri&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-backend-DEA584?logo=rust&logoColor=white)
![HTML/CSS/JS](https://img.shields.io/badge/HTML%2FCSS%2FJS-frontend-E34F26?logo=html5&logoColor=white)

> **English** | [Tiếng Việt](README.vi.md)

> **Sequential multi-line paster** — A lightweight tool for fast form filling and batch data entry on Windows.

## 📦 Editions

| | AHK Edition | PowerShell Edition | Python Edition | Tauri Edition |
|--|-------------|-------------------|----------------|---------------|
| **Best for** | Feature-rich, lightweight | 🏢 Corporate / restricted PCs | Cross-platform ready | Modern UI, premium feel |
| **Size** | ~1.3 MB | ~15 KB (single file) | ~22 KB (single file) | ~5 MB |
| **UI** | Windows native | Windows native (WinForms) | PyQt5 modern UI | Dark mode, animations |
| **Install?** | [AutoHotkey v2](https://autohotkey.com) or .exe | ⚡ **Zero install** | Python + pip packages | Just run .exe |
| **Folder** | [`ahk/`](ahk/) | [`powershell/`](powershell/) | [`ahk/`](ahk/) | [`tauri/`](tauri/) |

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

### AHK Edition (Full-featured)
```bash
# Option 1: Run script (requires AutoHotkey v2)
cd ahk
# Double-click SmartPaste.ahk

# Option 2: Download pre-built .exe from Releases
```

### PowerShell Edition (Zero Install — for Corporate PCs) ⭐
```powershell
# Just right-click SmartPaste.ps1 → "Run with PowerShell"
# OR run from command line:
powershell -ExecutionPolicy Bypass -File powershell\SmartPaste.ps1
```
> 💡 **No admin rights needed.** Works on any Windows 7+ PC. No installation, no antivirus issues.

### Tauri Edition (Modern UI)
```bash
# Download from Releases — just run the .exe
```

### Python Edition (with Python Portable — No Install)

<details>
<summary>📦 Click to expand Python Portable setup instructions</summary>

If you can't install Python on your corporate PC, use **Python Embeddable** (portable, no admin needed):

**Step 1:** Download [Python Embeddable](https://www.python.org/downloads/) (choose "Windows embeddable package (64-bit)")

**Step 2:** Extract to a folder, e.g. `C:\Tools\python\`

**Step 3:** Install pip (the folder already contains `python.exe`):
```cmd
C:\Tools\python\python.exe -c "import ensurepip; ensurepip.default_pip()"
```

**Step 4:** Edit `python312._pth` (or similar) — **uncomment** the `import site` line:
```
# Uncomment to run site.main() automatically
import site
```

**Step 5:** Install dependencies:
```cmd
C:\Tools\python\python.exe -m pip install PyQt5 pywin32 keyboard
```

**Step 6:** Run SmartPaste:
```cmd
C:\Tools\python\python.exe ahk\smart_paste_queue.py
```

> 💡 **Alternative:** Use [WinPython](https://winpython.github.io/) — a full portable Python distribution with batteries included.

</details>

## 📂 Project Structure

```
smartpaste/
├── ahk/                        ← AHK Edition
│   ├── SmartPaste.ahk          # Main script (AutoHotkey v2)
│   ├── smart_paste_queue.py    # Python Edition
│   ├── config.ini              # Settings
│   └── scripts/
│       └── build-exe.bat       # Build to standalone .exe
├── powershell/                 ← PowerShell Edition ⭐
│   └── SmartPaste.ps1          # Single file, zero install
├── tauri/                      ← Tauri Edition
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
