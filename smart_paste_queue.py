#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Smart Paste v0.1 - Python + PyQt5 Edition
Paste nhiều dòng tuần tự

Copyright (c) 2026 Dahodo (DHD)
MIT License
"""

import sys
import json
import os
import ctypes
import time
import winreg
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QListWidget, QListWidgetItem, QLabel, QTextEdit,
    QSystemTrayIcon, QMenu, QMessageBox, QFileDialog, QCheckBox,
    QDialog, QLineEdit, QTabWidget, QScrollArea
)
from PyQt5.QtCore import Qt, QTimer, pyqtSignal, QObject
from PyQt5.QtGui import QFont, QColor, QIcon, QPixmap, QPainter, QBrush

import win32clipboard
import win32con
import keyboard

CONFIG_FILE = "spq_config.json"
APP_NAME = "SmartPaste"


def get_exe_path():
    """Lấy đường dẫn exe hiện tại"""
    if getattr(sys, 'frozen', False):
        return sys.executable
    return os.path.abspath(sys.argv[0])


def is_startup_enabled():
    """Kiểm tra app có trong startup không"""
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, 
                            r"Software\Microsoft\Windows\CurrentVersion\Run",
                            0, winreg.KEY_READ)
        try:
            winreg.QueryValueEx(key, APP_NAME)
            winreg.CloseKey(key)
            return True
        except:
            winreg.CloseKey(key)
            return False
    except:
        return False


def set_startup(enable):
    """Bật/tắt khởi động cùng Windows"""
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                            r"Software\Microsoft\Windows\CurrentVersion\Run",
                            0, winreg.KEY_SET_VALUE)
        if enable:
            exe_path = get_exe_path()
            winreg.SetValueEx(key, APP_NAME, 0, winreg.REG_SZ, f'"{exe_path}"')
        else:
            try:
                winreg.DeleteValue(key, APP_NAME)
            except:
                pass
        winreg.CloseKey(key)
        return True
    except Exception as e:
        print(f"Startup error: {e}")
        return False


def get_clipboard():
    """Lấy text từ clipboard"""
    try:
        win32clipboard.OpenClipboard()
        if win32clipboard.IsClipboardFormatAvailable(win32con.CF_UNICODETEXT):
            data = win32clipboard.GetClipboardData(win32con.CF_UNICODETEXT)
            win32clipboard.CloseClipboard()
            return str(data) if data else ""
        win32clipboard.CloseClipboard()
    except:
        try:
            win32clipboard.CloseClipboard()
        except:
            pass
    return ""


def set_clipboard(text):
    """Đặt text vào clipboard"""
    try:
        win32clipboard.OpenClipboard()
        win32clipboard.EmptyClipboard()
        win32clipboard.SetClipboardData(win32con.CF_UNICODETEXT, str(text))
        win32clipboard.CloseClipboard()
        return True
    except:
        try:
            win32clipboard.CloseClipboard()
        except:
            pass
    return False


def press_ctrl_v():
    """Nhấn Ctrl+V"""
    user32 = ctypes.windll.user32
    VK_CONTROL, VK_V, KEYUP = 0x11, 0x56, 0x0002
    user32.keybd_event(VK_CONTROL, 0, 0, 0)
    user32.keybd_event(VK_V, 0, 0, 0)
    time.sleep(0.02)
    user32.keybd_event(VK_V, 0, KEYUP, 0)
    user32.keybd_event(VK_CONTROL, 0, KEYUP, 0)


class Signals(QObject):
    paste_signal = pyqtSignal()
    back_signal = pyqtSignal()


class HotkeyDialog(QDialog):
    def __init__(self, current_key, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Đổi phím")
        self.setFixedSize(200, 100)
        self.key = current_key
        
        layout = QVBoxLayout(self)
        self.label = QLabel("Nhấn phím mới:")
        layout.addWidget(self.label)
        
        self.display = QLineEdit(current_key.upper())
        self.display.setReadOnly(True)
        self.display.setAlignment(Qt.AlignCenter)
        self.display.setStyleSheet("font-size:16px;font-weight:bold;padding:8px")
        layout.addWidget(self.display)
        
        btns = QHBoxLayout()
        ok = QPushButton("OK")
        ok.clicked.connect(self.accept)
        cancel = QPushButton("Hủy")
        cancel.clicked.connect(self.reject)
        btns.addWidget(ok)
        btns.addWidget(cancel)
        layout.addLayout(btns)
        
    def keyPressEvent(self, e):
        key_map = {
            Qt.Key_F1: "f1", Qt.Key_F2: "f2", Qt.Key_F3: "f3", Qt.Key_F4: "f4",
            Qt.Key_F5: "f5", Qt.Key_F6: "f6", Qt.Key_F7: "f7", Qt.Key_F8: "f8",
            Qt.Key_F9: "f9", Qt.Key_F10: "f10", Qt.Key_F11: "f11", Qt.Key_F12: "f12"
        }
        if e.key() in key_map:
            self.key = key_map[e.key()]
            self.display.setText(self.key.upper())


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Smart Paste")
        self.setFixedSize(320, 480)
        
        # Data
        self.queue = []
        self.index = 0
        self.last_clip = ""
        self.hk_paste = "f9"
        self.hk_back = "f10"
        self.loop_mode = False
        self.on_top = True
        self.auto_start = is_startup_enabled()
        self._is_pasting = False
        
        self.load_config()
        
        # Signals
        self.sig = Signals()
        self.sig.paste_signal.connect(self.do_paste)
        self.sig.back_signal.connect(self.do_back)
        
        self.init_ui()
        self.setup_hotkeys()
        self.setup_tray()
        
        # Clipboard timer
        self.timer = QTimer()
        self.timer.timeout.connect(self.check_clipboard)
        self.timer.start(150)
        
        self.apply_on_top()
        
    def load_config(self):
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r') as f:
                    cfg = json.load(f)
                    self.hk_paste = cfg.get('paste', 'f9')
                    self.hk_back = cfg.get('back', 'f10')
                    self.loop_mode = cfg.get('loop', False)
                    self.on_top = cfg.get('on_top', True)
            except:
                pass
                
    def save_config(self):
        try:
            with open(CONFIG_FILE, 'w') as f:
                json.dump({
                    'paste': self.hk_paste,
                    'back': self.hk_back,
                    'loop': self.loop_mode,
                    'on_top': self.on_top
                }, f)
        except:
            pass
            
    def init_ui(self):
        w = QWidget()
        self.setCentralWidget(w)
        main_layout = QVBoxLayout(w)
        main_layout.setSpacing(6)
        main_layout.setContentsMargins(8, 8, 8, 8)
        
        # Tabs
        self.tabs = QTabWidget()
        self.tabs.setStyleSheet("""
            QTabWidget::pane { border: 1px solid #cbd5e1; border-radius: 8px; background: white; }
            QTabBar::tab { padding: 8px 16px; background: #e2e8f0; border-radius: 6px 6px 0 0; margin-right: 2px; }
            QTabBar::tab:selected { background: #3b82f6; color: white; font-weight: bold; }
        """)
        
        # === TAB 1: Main ===
        tab_main = QWidget()
        layout = QVBoxLayout(tab_main)
        layout.setSpacing(8)
        layout.setContentsMargins(8, 8, 8, 8)
        
        # Status
        self.status = QLabel("📋 Copy nhiều dòng để bắt đầu")
        self.status.setAlignment(Qt.AlignCenter)
        self.status.setStyleSheet("""
            background: #e0f2fe;
            color: #0369a1;
            padding: 8px;
            border-radius: 8px;
            font-weight: bold;
        """)
        layout.addWidget(self.status)
        
        # List
        self.listbox = QListWidget()
        self.listbox.setStyleSheet("""
            QListWidget {
                background: white;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                font-size: 12px;
            }
            QListWidget::item { padding: 6px; border-radius: 4px; }
            QListWidget::item:selected { background: #2563eb; color: white; }
        """)
        layout.addWidget(self.listbox)
        
        # Buttons
        btn_row = QHBoxLayout()
        
        self.btn_paste = QPushButton("▶ DÁN")
        self.btn_paste.setStyleSheet("background:#22c55e;color:white;font-weight:bold;padding:12px;border:none;border-radius:8px;font-size:14px")
        self.btn_paste.clicked.connect(self.do_paste)
        btn_row.addWidget(self.btn_paste)
        
        self.btn_back = QPushButton("◀ LÙI")
        self.btn_back.setStyleSheet("background:#3b82f6;color:white;font-weight:bold;padding:12px;border:none;border-radius:8px;font-size:14px")
        self.btn_back.clicked.connect(self.do_back)
        btn_row.addWidget(self.btn_back)
        
        btn_reset = QPushButton("↺")
        btn_reset.setStyleSheet("background:#f59e0b;color:white;font-weight:bold;padding:12px;border:none;border-radius:8px;font-size:16px;min-width:45px")
        btn_reset.clicked.connect(self.reset_index)
        btn_row.addWidget(btn_reset)
        
        layout.addLayout(btn_row)
        
        # Hotkey row
        hk_row = QHBoxLayout()
        
        self.lbl_paste_hk = QPushButton(self.hk_paste.upper())
        self.lbl_paste_hk.setStyleSheet("background:#166534;color:white;font-weight:bold;padding:5px 12px;border:none;border-radius:4px")
        self.lbl_paste_hk.clicked.connect(lambda: self.change_hk('paste'))
        hk_row.addWidget(self.lbl_paste_hk)
        
        self.lbl_back_hk = QPushButton(self.hk_back.upper())
        self.lbl_back_hk.setStyleSheet("background:#1e40af;color:white;font-weight:bold;padding:5px 12px;border:none;border-radius:4px")
        self.lbl_back_hk.clicked.connect(lambda: self.change_hk('back'))
        hk_row.addWidget(self.lbl_back_hk)
        
        hk_row.addStretch()
        
        btn_clear = QPushButton("🗑️")
        btn_clear.setStyleSheet("background:#ef4444;color:white;padding:5px 10px;border:none;border-radius:4px")
        btn_clear.clicked.connect(self.clear_queue)
        hk_row.addWidget(btn_clear)
        
        btn_file = QPushButton("📁")
        btn_file.setStyleSheet("background:#64748b;color:white;padding:5px 10px;border:none;border-radius:4px")
        btn_file.clicked.connect(self.load_file)
        hk_row.addWidget(btn_file)
        
        layout.addLayout(hk_row)
        
        # Options
        opt_row = QHBoxLayout()
        
        self.chk_loop = QCheckBox("🔄 Lặp")
        self.chk_loop.setChecked(self.loop_mode)
        self.chk_loop.stateChanged.connect(self.toggle_loop)
        opt_row.addWidget(self.chk_loop)
        
        self.chk_top = QCheckBox("📌 Nổi")
        self.chk_top.setChecked(self.on_top)
        self.chk_top.stateChanged.connect(self.toggle_on_top)
        opt_row.addWidget(self.chk_top)
        
        self.chk_startup = QCheckBox("🚀 Startup")
        self.chk_startup.setChecked(self.auto_start)
        self.chk_startup.stateChanged.connect(self.toggle_startup)
        opt_row.addWidget(self.chk_startup)
        
        layout.addLayout(opt_row)
        
        # Text input
        self.txt_input = QTextEdit()
        self.txt_input.setPlaceholderText("Nhập thủ công, mỗi dòng 1 mục...")
        self.txt_input.setMaximumHeight(50)
        self.txt_input.setStyleSheet("border:1px solid #cbd5e1;border-radius:6px;padding:4px")
        layout.addWidget(self.txt_input)
        
        btn_load = QPushButton("📥 Nạp từ text")
        btn_load.setStyleSheet("background:#6366f1;color:white;padding:8px;border:none;border-radius:6px")
        btn_load.clicked.connect(self.load_text)
        layout.addWidget(btn_load)
        
        self.tabs.addTab(tab_main, "📋 Paste")
        
        # === TAB 2: Hướng dẫn ===
        tab_help = QWidget()
        help_layout = QVBoxLayout(tab_help)
        help_layout.setContentsMargins(10, 10, 10, 10)
        
        help_text = QLabel("""
<h2 style="color:#2563eb;">📖 Hướng dẫn sử dụng</h2>

<h3>🚀 Bắt đầu nhanh</h3>
<ol>
<li><b>Copy nhiều dòng</b> từ Excel/Text → App tự động nạp</li>
<li>Nhấn <b>F9</b> để dán từng dòng tuần tự</li>
<li>Nhấn <b>F10</b> để quay lại dòng trước</li>
</ol>

<h3>⌨️ Phím tắt</h3>
<table style="margin-left:10px;">
<tr><td><b>F9</b></td><td>Dán dòng tiếp theo</td></tr>
<tr><td><b>F10</b></td><td>Quay lại dòng trước</td></tr>
</table>
<p><i>💡 Click vào nút phím để đổi phím khác</i></p>

<h3>⚙️ Tùy chọn</h3>
<ul>
<li><b>🔄 Lặp:</b> Khi hết sẽ quay lại từ đầu</li>
<li><b>📌 Nổi:</b> Luôn hiện trên các cửa sổ khác</li>
<li><b>🚀 Startup:</b> Tự khởi động cùng Windows</li>
</ul>

<h3>📁 Nạp dữ liệu</h3>
<ul>
<li><b>Copy nhiều dòng:</b> Tự động nạp</li>
<li><b>Nút 📁:</b> Mở file .txt</li>
<li><b>Nhập thủ công:</b> Gõ vào ô text rồi nhấn Nạp</li>
</ul>

<h3>💡 Mẹo</h3>
<ul>
<li>Copy cột từ Excel → Paste vào form nhanh</li>
<li>Dùng để điền nhiều mã, tên, số liên tục</li>
<li>Click icon tray để ẩn/hiện app</li>
</ul>

<hr style="margin-top: 20px;">
<p style="text-align: center; color: #64748b; font-size: 11px;">
<b>Smart Paste v0.1</b><br>
© 2026 Dahodo (DHD)<br>
MIT License | dahodo.com
</p>
        """)
        help_text.setWordWrap(True)
        help_text.setAlignment(Qt.AlignTop)
        help_text.setStyleSheet("font-size: 12px; line-height: 1.5;")
        
        scroll = QScrollArea()
        scroll.setWidget(help_text)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("border: none;")
        help_layout.addWidget(scroll)
        
        self.tabs.addTab(tab_help, "❓ Hướng dẫn")
        
        main_layout.addWidget(self.tabs)
        
        self.setStyleSheet("QMainWindow{background:#f8fafc}")
        
    def toggle_startup(self):
        enable = self.chk_startup.isChecked()
        if set_startup(enable):
            self.auto_start = enable
        else:
            self.chk_startup.setChecked(not enable)
            QMessageBox.warning(self, "Lỗi", "Không thể thay đổi cài đặt startup")
        
    def change_hk(self, which):
        current = self.hk_paste if which == 'paste' else self.hk_back
        dlg = HotkeyDialog(current, self)
        if dlg.exec_() == QDialog.Accepted:
            new_key = dlg.key
            if which == 'paste':
                if new_key == self.hk_back:
                    return
                self.hk_paste = new_key
                self.lbl_paste_hk.setText(new_key.upper())
            else:
                if new_key == self.hk_paste:
                    return
                self.hk_back = new_key
                self.lbl_back_hk.setText(new_key.upper())
            self.setup_hotkeys()
            self.save_config()
            
    def toggle_loop(self):
        self.loop_mode = self.chk_loop.isChecked()
        self.save_config()
        
    def toggle_on_top(self):
        self.on_top = self.chk_top.isChecked()
        self.apply_on_top()
        self.save_config()
        
    def apply_on_top(self):
        flags = self.windowFlags()
        if self.on_top:
            self.setWindowFlags(flags | Qt.WindowStaysOnTopHint)
        else:
            self.setWindowFlags(flags & ~Qt.WindowStaysOnTopHint)
        self.show()
        
    def setup_hotkeys(self):
        try:
            keyboard.unhook_all()
        except:
            pass
        keyboard.on_press_key(self.hk_paste, lambda e: self.sig.paste_signal.emit(), suppress=True)
        keyboard.on_press_key(self.hk_back, lambda e: self.sig.back_signal.emit(), suppress=True)
        
    def setup_tray(self):
        self.tray = QSystemTrayIcon(self)
        pm = QPixmap(32, 32)
        pm.fill(Qt.transparent)
        p = QPainter(pm)
        p.setBrush(QBrush(QColor("#2563eb")))
        p.setPen(Qt.NoPen)
        p.drawRoundedRect(2, 2, 28, 28, 6, 6)
        p.setPen(QColor("white"))
        p.setFont(QFont("Arial", 16, QFont.Bold))
        p.drawText(pm.rect(), Qt.AlignCenter, "P")
        p.end()
        self.tray.setIcon(QIcon(pm))
        self.tray.setToolTip("Smart Paste")
        
        menu = QMenu()
        menu.addAction("Hiện", self.show_window)
        menu.addAction("Thoát", self.quit_app)
        self.tray.setContextMenu(menu)
        self.tray.activated.connect(lambda r: self.show_window() if r == QSystemTrayIcon.DoubleClick else None)
        self.tray.show()
        
    def show_window(self):
        self.show()
        self.raise_()
        self.activateWindow()
        
    def quit_app(self):
        keyboard.unhook_all()
        self.tray.hide()
        QApplication.quit()
        
    def check_clipboard(self):
        if self._is_pasting:
            return
        try:
            clip = get_clipboard()
            if clip and clip != self.last_clip:
                self.last_clip = clip
                self.process_clipboard(clip)
        except:
            pass
            
    def process_clipboard(self, text):
        text = text.replace('\r\n', '\n').replace('\r', '\n')
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        if len(lines) > 1:
            self.queue = lines
            self.index = 0
            self.refresh_list()
            self.tabs.setCurrentIndex(0)  # Switch to main tab
            
    def refresh_list(self):
        self.listbox.clear()
        for i, item in enumerate(self.queue):
            display = f"{i+1}. {item[:40]}{'...' if len(item) > 40 else ''}"
            li = QListWidgetItem(display)
            
            if i == self.index:
                li.setBackground(QColor("#2563eb"))
                li.setForeground(QColor("white"))
                li.setFont(QFont("Segoe UI", 11, QFont.Bold))
            elif i < self.index:
                li.setForeground(QColor("#9ca3af"))
                f = QFont()
                f.setStrikeOut(True)
                li.setFont(f)
                
            self.listbox.addItem(li)
            
        if self.index < self.listbox.count():
            self.listbox.setCurrentRow(self.index)
            
        total = len(self.queue)
        if total == 0:
            self.status.setText("📋 Copy nhiều dòng để bắt đầu")
        else:
            pct = int(self.index / total * 100)
            self.status.setText(f"📊 {self.index}/{total} ({pct}%) | Còn {total - self.index}")
            
    def do_paste(self):
        if not self.queue:
            return
        if self.index >= len(self.queue):
            if self.loop_mode:
                self.index = 0
            else:
                return
        
        text = self.queue[self.index]
        self._is_pasting = True
        set_clipboard(text)
        press_ctrl_v()
        self._is_pasting = False
        self.index += 1
        self.refresh_list()
        
    def do_back(self):
        if self.index > 0:
            self.index -= 1
            self.refresh_list()
            
    def reset_index(self):
        self.index = 0
        self.refresh_list()
        
    def clear_queue(self):
        self.queue = []
        self.index = 0
        self.refresh_list()
        
    def load_file(self):
        path, _ = QFileDialog.getOpenFileName(self, "Chọn file", "", "Text (*.txt);;All (*.*)")
        if path:
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    lines = [l.strip() for l in f.readlines() if l.strip()]
                self.queue = lines
                self.index = 0
                self.refresh_list()
            except UnicodeDecodeError:
                try:
                    with open(path, 'r', encoding='cp1252') as f:
                        lines = [l.strip() for l in f.readlines() if l.strip()]
                    self.queue = lines
                    self.index = 0
                    self.refresh_list()
                except Exception as e:
                    QMessageBox.warning(self, "Lỗi", f"Không đọc được file:\n{e}")
            except Exception as e:
                QMessageBox.warning(self, "Lỗi", f"Không đọc được file:\n{e}")
                
    def load_text(self):
        text = self.txt_input.toPlainText().strip()
        if text:
            lines = [l.strip() for l in text.split('\n') if l.strip()]
            self.queue = lines
            self.index = 0
            self.refresh_list()
            self.txt_input.clear()
            
    def closeEvent(self, e):
        self.hide()
        e.ignore()


def main():
    # Enable High DPI scaling
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)
    except:
        try:
            ctypes.windll.user32.SetProcessDPIAware()
        except:
            pass
    
    QApplication.setAttribute(Qt.AA_EnableHighDpiScaling, True)
    QApplication.setAttribute(Qt.AA_UseHighDpiPixmaps, True)
    
    try:
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("smartpaste.v10")
    except:
        pass
        
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)
    app.setFont(QFont("Segoe UI", 9))
    
    win = MainWindow()
    win.show()
    
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
