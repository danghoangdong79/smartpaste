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

> 🌐 [English](README.md) | **Tiếng Việt**

> **Dán nhiều dòng tuần tự** — Công cụ điền form nhanh và nhập liệu hàng loạt trên Windows.

## 📦 Các phiên bản

| | AHK Edition | PowerShell Edition | Python Edition | Tauri Edition |
|--|-------------|-------------------|----------------|---------------|
| **Phù hợp** | Đầy đủ tính năng, nhẹ | 🏢 Máy công ty / hạn chế | Có sẵn Python | Giao diện hiện đại |
| **Kích thước** | ~1.3 MB | ~15 KB (1 file) | ~22 KB (1 file) | ~5 MB |
| **Giao diện** | Windows chuẩn | WinForms (.NET) | PyQt5 | Dark mode, animation |
| **Cài đặt?** | [AutoHotkey v2](https://autohotkey.com) hoặc .exe | ⚡ **Không cần cài** | Python + pip packages | Chỉ chạy .exe |
| **Thư mục** | [`ahk/`](ahk/) | [`powershell/`](powershell/) | [`ahk/`](ahk/) | [`tauri/`](tauri/) |

## ✨ Tính năng

- ✅ **Tự nhận clipboard** — Copy nhiều dòng, app tự nạp
- ✅ **F9 dán tiến** — Dán từng dòng tuần tự
- ✅ **F10 dán lùi** — Quay lại dán dòng trước
- ✅ **⚡ Tự động dán** — Tự điền form với Tab/Enter/Space
- ✅ **Đổi phím tự do** — Gán bất kỳ phím hoặc tổ hợp
- ✅ **Nạp từ file** — Import .txt / .csv
- ✅ **Lịch sử clipboard** — Nhớ 10 bộ dữ liệu gần nhất
- ✅ **Tùy chỉnh delay** — Điều chỉnh tốc độ dán
- ✅ **Song ngữ** — Tiếng Việt / English

## 📥 Bắt đầu nhanh

### AHK Edition (Đầy đủ tính năng)
```bash
# Cách 1: Chạy script (cần AutoHotkey v2)
cd ahk
# Double-click SmartPaste.ahk

# Cách 2: Tải .exe từ Releases
```

### PowerShell Edition (Không cần cài — cho máy công ty) ⭐
```powershell
# Chuột phải SmartPaste.ps1 → "Run with PowerShell"
# HOẶC chạy từ cmd:
powershell -ExecutionPolicy Bypass -File powershell\SmartPaste.ps1
```
> 💡 **Không cần quyền admin.** Chạy trên mọi máy Windows 7+. Không cài đặt, không bị antivirus chặn.

### Tauri Edition (UI hiện đại)
```bash
# Tải từ Releases — chỉ cần chạy .exe
```

### Python Edition (với Python Portable — Không cần cài)

<details>
<summary>📦 Bấm để xem hướng dẫn Python Portable</summary>

Nếu máy công ty không cho cài Python, dùng **Python Embeddable** (portable, không cần admin):

**Bước 1:** Tải [Python Embeddable](https://www.python.org/downloads/) (chọn "Windows embeddable package (64-bit)")

**Bước 2:** Giải nén vào thư mục, vd: `C:\Tools\python\`

**Bước 3:** Cài pip (thư mục đã có `python.exe`):
```cmd
C:\Tools\python\python.exe -c "import ensurepip; ensurepip.default_pip()"
```

**Bước 4:** Sửa file `python312._pth` (hoặc tương tự) — **bỏ comment** dòng `import site`:
```
# Uncomment to run site.main() automatically
import site
```

**Bước 5:** Cài thư viện:
```cmd
C:\Tools\python\python.exe -m pip install PyQt5 pywin32 keyboard
```

**Bước 6:** Chạy SmartPaste:
```cmd
C:\Tools\python\python.exe ahk\smart_paste_queue.py
```

> 💡 **Cách khác:** Dùng [WinPython](https://winpython.github.io/) — bản Python portable đầy đủ, không cần cấu hình.

</details>

## 📂 Cấu trúc

```
smartpaste/
├── ahk/                        ← AHK Edition
│   ├── SmartPaste.ahk          # Script chính (AutoHotkey v2)
│   ├── smart_paste_queue.py    # Python Edition
│   ├── config.ini              # Cấu hình
│   └── scripts/build-exe.bat   # Build thành .exe
├── powershell/                 ← PowerShell Edition ⭐
│   └── SmartPaste.ps1          # 1 file duy nhất, không cần cài
├── tauri/                      ← Tauri Edition
│   ├── src-tauri/              # Rust backend
│   └── src/                    # Web frontend (HTML/CSS/JS)
├── LICENSE
├── README.md                   # English
└── README.vi.md                # Tiếng Việt
```

## 🤝 Đóng góp

1. Fork repo
2. Tạo branch (`git checkout -b feature/ten-tinh-nang`)
3. Commit và Push
4. Tạo Pull Request

## 📝 License

MIT License - Copyright (c) 2026 [Dahodo (DHD)](https://dahodo.com)

---

<p align="center">
  <a href="https://dahodo.com">Website</a> •
  <a href="mailto:danghoangdong79@gmail.com">Email</a> •
  <a href="https://github.com/danghoangdong79/smartpaste">GitHub</a>
</p>
