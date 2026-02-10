# Smart Paste

![Version](https://img.shields.io/badge/version-0.3-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334455?logo=autohotkey&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![Tauri](https://img.shields.io/badge/Tauri-2.0-FFC131?logo=tauri&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-backend-DEA584?logo=rust&logoColor=white)
![HTML/CSS/JS](https://img.shields.io/badge/HTML%2FCSS%2FJS-frontend-E34F26?logo=html5&logoColor=white)

> 🌐 [English](README.md) | **Tiếng Việt**

> **Dán nhiều dòng tuần tự** — Công cụ điền form nhanh và nhập liệu hàng loạt trên Windows.

## 📦 Hai phiên bản

| | AHK Edition | Tauri Edition |
|--|-------------|---------------|
| **Phù hợp** | Tối giản, nhanh, nhẹ | Giao diện hiện đại, chuyên nghiệp |
| **Kích thước** | ~1.3 MB | ~5 MB |
| **Giao diện** | Windows chuẩn | Dark mode, animation |
| **Yêu cầu** | [AutoHotkey v2](https://autohotkey.com) hoặc .exe | Chỉ chạy .exe |
| **Thư mục** | [`ahk/`](ahk/) | [`tauri/`](tauri/) |

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

### AHK Edition (Nhẹ)
```bash
# Cách 1: Chạy script (cần AutoHotkey v2)
cd ahk
# Double-click SmartPaste.ahk

# Cách 2: Tải .exe từ Releases
```

### Tauri Edition (UI hiện đại)
```bash
# Tải từ Releases — chỉ cần chạy .exe
```

## 📂 Cấu trúc

```
smartpaste/
├── ahk/                        ← AHK Edition
│   ├── SmartPaste.ahk
│   ├── smart_paste_queue.py
│   ├── config.ini
│   └── scripts/build-exe.bat
├── tauri/                      ← Tauri Edition
│   ├── src-tauri/
│   └── src/
├── LICENSE
├── README.md
└── README.vi.md
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
