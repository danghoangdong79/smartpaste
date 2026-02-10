# Smart Paste v0.1

![Version](https://img.shields.io/badge/version-0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-orange)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

> 🌐 [English](README.md) | **Tiếng Việt**

> **Dán nhiều dòng tuần tự** — Công cụ hỗ trợ điền form nhanh và nhập liệu hàng loạt trên Windows.

## ✨ Tính năng

- ✅ **Copy → Tự nạp**: Copy nhiều dòng từ Excel/Text, app tự nhận diện
- ✅ **F9 dán tiến**: Dán từng dòng tuần tự vào vị trí con trỏ
- ✅ **F10 dán lùi**: Quay lại dán dòng trước nếu nhầm
- ✅ **Đổi phím tự do**: Gán bất kỳ phím hoặc tổ hợp phím (Ctrl+K, Shift+F5...)
- ✅ **Chế độ lặp**: Quay vòng khi hết danh sách
- ✅ **Song ngữ**: Tiếng Việt / English
- ✅ **An toàn**: Chạy trực tiếp script, không lo virus

## 📥 Cài đặt

### Yêu cầu
- Windows 10/11
- [AutoHotkey v2.0](https://www.autohotkey.com/)

### Bắt đầu nhanh

1. Cài [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Tải repo:
   ```bash
   git clone https://github.com/danghoangdong79/smartpaste.git
   ```
   Hoặc [tải ZIP](https://github.com/danghoangdong79/smartpaste/archive/refs/heads/master.zip)
3. Double-click `SmartPaste.ahk` để chạy

### Phiên bản Python (thay thế)

```bash
pip install PyQt5 pywin32 keyboard
python smart_paste_queue.py
```

## 📖 Cách sử dụng

```
┌──────────────────┐
│  Copy nhiều dòng  │  ← Từ Excel, Word, Notepad...
│  dữ liệu         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  App tự động      │  ← Hiện "Đã nạp X mục"
│  nhận diện        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Nhấn F9 để      │  ← Dán từng dòng một
│  DÁN              │
└──────────────────┘
```

### Phím tắt mặc định

| Phím | Chức năng |
|------|-----------|
| **F9** | Dán dòng tiếp theo |
| **F10** | Dán lùi dòng trước |

> 💡 Click vào nút phím trong app để gán lại bất kỳ phím/tổ hợp phím nào

### Tùy chọn

| Tính năng | Mô tả |
|-----------|-------|
| 🔁 Lặp lại | Quay vòng khi hết danh sách |
| 📌 Luôn nổi | Giữ app trên cùng mọi cửa sổ |
| 🚀 Khởi động | Tự chạy khi Windows khởi động |

## 🛠️ Xử lý lỗi

### "Phím tắt không hoạt động"

**Nguyên nhân**: Phần mềm khác chiếm phím

**Cách fix**:
```
Cách 1: Chạy quyền Admin
  → Chuột phải SmartPaste.ahk
  → "Run as administrator"

Cách 2: Đổi phím khác
  → Click nút phím trong app
  → Nhấn phím hoặc tổ hợp mới
```

## 📂 Cấu trúc

```
smartpaste/
├── SmartPaste.ahk          # Phiên bản AHK (khuyên dùng)
├── smart_paste_queue.py    # Phiên bản Python
├── config.ini              # Cấu hình
├── scripts/
│   └── build-exe.bat       # Build thành .exe
├── LICENSE
├── README.md               # English
└── README.vi.md            # Tiếng Việt
```

## 🤝 Đóng góp

1. Fork repository
2. Tạo branch (`git checkout -b feature/ten-tinh-nang`)
3. Commit (`git commit -m "Add: tính năng mới"`)
4. Push (`git push origin feature/ten-tinh-nang`)
5. Tạo Pull Request

## 📝 License

MIT License - Copyright (c) 2026 [Dahodo (DHD)](https://dahodo.com)

---

<p align="center">
  <a href="https://dahodo.com">Website</a> •
  <a href="mailto:danghoangdong79@gmail.com">Email</a> •
  <a href="https://github.com/danghoangdong79/smartpaste">GitHub</a>
</p>
