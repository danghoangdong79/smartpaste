; Smart Paste v0.1 - AutoHotkey Edition
; Sequential Clipboard Paster
; https://github.com/dahodo/smartpaste
; MIT License - Copyright (c) 2026 Dahodo (DHD)

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

SendMode "Input"
SetKeyDelay -1, -1

; ============ CONFIG ============
global ConfigFile := A_ScriptDir "\config.ini"
global Lang := "vi"
global PasteKey := "F9"
global BackKey := "F10"
global Queue := []
global CurrentIndex := 1
global LastClip := ""
global IsPasting := false

; ============ TRANSLATIONS ============
BuildTexts() {
    t := Map()
    ; Vietnamese
    t["vi.title"]        := "Smart Paste v0.1"
    t["vi.grpData"]      := "Dữ liệu"
    t["vi.grpAction"]    := "Thao tác"
    t["vi.grpHotkey"]    := "Phím tắt"
    t["vi.grpOption"]    := "Tùy chọn khác"
    t["vi.statusReady"]  := "Copy nhiều dòng để bắt đầu"
    t["vi.waiting"]      := "Đang chờ dữ liệu..."
    t["vi.btnPaste"]     := "▶ DÁN"
    t["vi.btnBack"]      := "◀ LÙI"
    t["vi.btnReset"]     := "↺ Reset"
    t["vi.labelPaste"]   := "Phím DÁN:"
    t["vi.labelBack"]    := "Phím LÙI:"
    t["vi.loop"]         := "Lặp lại khi hết danh sách"
    t["vi.ontop"]        := "Luôn hiển thị trên cùng"
    t["vi.startup"]      := "Khởi động cùng Windows"
    t["vi.langBtn"]      := "Vietnamese interface"
    t["vi.manual"]       := "Nhập thủ công"
    t["vi.load"]         := "Nạp dữ liệu"
    t["vi.btnGuide"]     := "Hướng dẫn"
    t["vi.btnAbout"]     := "Thông tin"
    t["vi.btnClose"]     := "Thu nhỏ"
    t["vi.captureTitle"] := "Đổi phím"
    t["vi.captureText"]  := "Nhấn phím hoặc tổ hợp phím bất kỳ (Esc để hủy)"
    t["vi.msgEmpty"]     := "Chưa có dữ liệu"
    t["vi.msgDone"]      := "Đã hoàn thành!"
    t["vi.msgLoaded"]    := "Đã nạp {1} mục"
    t["vi.msgPasteKey"]  := "Phím DÁN: "
    t["vi.msgBackKey"]   := "Phím LÙI: "
    t["vi.msgBack"]      := "Quay lại mục {1}/{2}"
    t["vi.msgFirst"]     := "Đã ở mục đầu tiên"
    t["vi.copyright"]    := "© 2026 Dahodo (DHD)"
    t["vi.trayShow"]     := "Hiện"
    t["vi.trayExit"]     := "Thoát"
    t["vi.warnAdmin"]    := "Nếu phím lỗi: Chạy Admin"
    ; English
    t["en.title"]        := "Smart Paste v0.1"
    t["en.grpData"]      := "Data"
    t["en.grpAction"]    := "Actions"
    t["en.grpHotkey"]    := "Hotkeys"
    t["en.grpOption"]    := "Other Options"
    t["en.statusReady"]  := "Copy multiple lines to start"
    t["en.waiting"]      := "Waiting for data..."
    t["en.btnPaste"]     := "▶ PASTE"
    t["en.btnBack"]      := "◀ BACK"
    t["en.btnReset"]     := "↺ Reset"
    t["en.labelPaste"]   := "Paste Key:"
    t["en.labelBack"]    := "Back Key:"
    t["en.loop"]         := "Loop when list ends"
    t["en.ontop"]        := "Always on top"
    t["en.startup"]      := "Launch with Windows"
    t["en.langBtn"]      := "Vietnamese interface"
    t["en.manual"]       := "Manual Input"
    t["en.load"]         := "Load Data"
    t["en.btnGuide"]     := "Guide"
    t["en.btnAbout"]     := "About"
    t["en.btnClose"]     := "Minimize"
    t["en.captureTitle"] := "Change Hotkey"
    t["en.captureText"]  := "Press any key or combo (Esc to cancel)"
    t["en.msgEmpty"]     := "No data"
    t["en.msgDone"]      := "All done!"
    t["en.msgLoaded"]    := "Loaded {1} items"
    t["en.msgPasteKey"]  := "Paste Key: "
    t["en.msgBackKey"]   := "Back Key: "
    t["en.msgBack"]      := "Back to item {1}/{2}"
    t["en.msgFirst"]     := "Already at first item"
    t["en.copyright"]    := "© 2026 Dahodo (DHD)"
    t["en.trayShow"]     := "Show"
    t["en.trayExit"]     := "Exit"
    t["en.warnAdmin"]    := "Hotkey fails? Run as Admin"
    return t
}

global Texts := BuildTexts()

GetText(key, replace*) {
    global Texts, Lang
    langKey := Lang . "." . key
    if Texts.Has(langKey) {
        result := Texts[langKey]
    } else {
        result := key
    }
    for i, val in replace {
        result := StrReplace(result, "{" i "}", val)
    }
    return result
}

; ============ LOAD CONFIG ============
LoadConfig() {
    global ConfigFile, Lang, PasteKey, BackKey
    if FileExist(ConfigFile) {
        try {
            Lang := IniRead(ConfigFile, "Settings", "Language", "vi")
            PasteKey := IniRead(ConfigFile, "Settings", "PasteKey", "F9")
            BackKey := IniRead(ConfigFile, "Settings", "BackKey", "F10")
        }
    }
}

SaveConfig() {
    global ConfigFile, Lang, PasteKey, BackKey, ChkLoop
    IniWrite(Lang, ConfigFile, "Settings", "Language")
    IniWrite(PasteKey, ConfigFile, "Settings", "PasteKey")
    IniWrite(BackKey, ConfigFile, "Settings", "BackKey")
    try IniWrite(ChkLoop.Value, ConfigFile, "Settings", "Loop")
}

; ============ GUI ============
CreateGUI() {
    global MainGui, StatusText, CurrentText, ProgressText, ProgressBar
    global BtnPaste, BtnBack, BtnReset, BtnPasteKey, BtnBackKey
    global ChkLoop, ChkOnTop, ChkStartup, ChkLang, EdtInput

    ; --- Window ---
    MainGui := Gui("+AlwaysOnTop -Resize", GetText("title"))
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.OnEvent("Close", (*) => MainGui.Hide())

    ; ==========================================
    ; GroupBox: Dữ liệu
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y8 w420 h155", GetText("grpData"))

    StatusText := MainGui.Add("Text", "x25 y30 w390 h20 Center", GetText("statusReady"))
    StatusText.SetFont("s9 Bold c0369A1")

    CurrentText := MainGui.Add("Text", "x25 y55 w390 h30 Center c1E293B", GetText("waiting"))
    CurrentText.SetFont("s13 Bold")

    ProgressBar := MainGui.Add("Progress", "x25 y90 w390 h8 c2563EB BackgroundE2E8F0 Range0-100", 0)
    ProgressText := MainGui.Add("Text", "x25 y102 w390 Center c64748B", "0 / 0")
    ProgressText.SetFont("s8")

    ; Manual input inline
    EdtInput := MainGui.Add("Edit", "x25 y120 w290 h28", "")
    EdtInput.SetFont("s9")
    BtnLoad := MainGui.Add("Button", "x320 y120 w95 h28", GetText("load"))
    BtnLoad.SetFont("s8")
    BtnLoad.OnEvent("Click", LoadFromManual)

    ; ==========================================
    ; GroupBox: Thao tác  (right side)
    ; ==========================================
    MainGui.Add("GroupBox", "x250 y170 w180 h105", GetText("grpAction"))

    BtnPaste := MainGui.Add("Button", "x265 y192 w150 h35", GetText("btnPaste"))
    BtnPaste.SetFont("s11 Bold")
    BtnPaste.OnEvent("Click", DoPaste)

    BtnBack := MainGui.Add("Button", "x265 y232 w72 h30", GetText("btnBack"))
    BtnBack.SetFont("s8 Bold")
    BtnBack.OnEvent("Click", DoBack)

    BtnReset := MainGui.Add("Button", "x343 y232 w72 h30", GetText("btnReset"))
    BtnReset.SetFont("s8 Bold")
    BtnReset.OnEvent("Click", DoReset)

    ; ==========================================
    ; GroupBox: Phím tắt  (left side)
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y170 w230 h105", GetText("grpHotkey"))

    MainGui.Add("Text", "x25 y195 w70 h20", GetText("labelPaste")).SetFont("s9")
    BtnPasteKey := MainGui.Add("Button", "x100 y192 w55 h24", PasteKey)
    BtnPasteKey.SetFont("s9 Bold")
    BtnPasteKey.OnEvent("Click", (*) => ChangeHotkey("paste"))

    MainGui.Add("Text", "x165 y195 w30 h20", "...").SetFont("s9 c999999")

    MainGui.Add("Text", "x25 y225 w70 h20", GetText("labelBack")).SetFont("s9")
    BtnBackKey := MainGui.Add("Button", "x100 y222 w55 h24", BackKey)
    BtnBackKey.SetFont("s9 Bold")
    BtnBackKey.OnEvent("Click", (*) => ChangeHotkey("back"))

    MainGui.Add("Text", "x25 y252 w200 h16 cB45309", GetText("warnAdmin")).SetFont("s7")

    ; ==========================================
    ; GroupBox: Tùy chọn khác
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y280 w420 h95", GetText("grpOption"))

    ChkLoop := MainGui.Add("Checkbox", "x25 y300 w200", GetText("loop"))
    try ChkLoop.Value := IniRead(ConfigFile, "Settings", "Loop", "0")
    ChkLoop.OnEvent("Click", (*) => SaveConfig())

    ChkOnTop := MainGui.Add("Checkbox", "x235 y300 w180 Checked", GetText("ontop"))
    ChkOnTop.OnEvent("Click", ToggleOnTop)

    ChkStartup := MainGui.Add("Checkbox", "x25 y325 w200", GetText("startup"))
    ChkStartup.Value := IsStartupEnabled()
    ChkStartup.OnEvent("Click", ToggleStartup)

    ChkLang := MainGui.Add("Checkbox", "x235 y325 w180", GetText("langBtn"))
    ChkLang.Value := (Lang = "vi") ? 1 : 0
    ChkLang.OnEvent("Click", ToggleLanguage)

    ; ==========================================
    ; Bottom buttons (like Unikey)
    ; ==========================================
    BtnGuide := MainGui.Add("Button", "x10 y385 w135 h32", GetText("btnGuide"))
    BtnGuide.SetFont("s9")
    BtnGuide.OnEvent("Click", ShowGuide)

    BtnAbout := MainGui.Add("Button", "x155 y385 w135 h32", GetText("btnAbout"))
    BtnAbout.SetFont("s9")
    BtnAbout.OnEvent("Click", ShowAbout)

    BtnClose := MainGui.Add("Button", "x300 y385 w130 h32", GetText("btnClose"))
    BtnClose.SetFont("s9")
    BtnClose.OnEvent("Click", (*) => MainGui.Hide())

    MainGui.Show("w440 h425")
}

; ============ GUIDE DIALOG ============
ShowGuide(*) {
    global MainGui, Lang

    GuideGui := Gui("+AlwaysOnTop +ToolWindow -Resize", (Lang = "vi") ? "Hướng dẫn sử dụng" : "User Guide")
    GuideGui.SetFont("s9", "Segoe UI")

    if (Lang = "vi") {
        guideContent := ""
            . "HƯỚNG DẪN SỬ DỤNG SMART PASTE`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "Bước 1: Copy dữ liệu`r`n"
            . "   • Copy nhiều dòng từ Excel, Word, Notepad`r`n"
            . "   • App sẽ tự động nhận diện và nạp dữ liệu`r`n`r`n"
            . "Bước 2: Dán tuần tự`r`n"
            . "   • Nhấn F9 để DÁN từng dòng vào vị trí con trỏ`r`n"
            . "   • Mỗi lần nhấn F9 sẽ dán dòng tiếp theo`r`n`r`n"
            . "Bước 3: Quay lại (nếu cần)`r`n"
            . "   • Nhấn F10 để LÙI về mục trước`r`n"
            . "   • Nhấn F9 để dán lại mục đó`r`n`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "MẸO HAY:`r`n"
            . "   ✓ Dùng cho điền form nhanh`r`n"
            . "   ✓ Nhập mã sản phẩm hàng loạt`r`n"
            . "   ✓ Nếu F9 không chạy → Chạy Admin`r`n`r`n"
            . "ĐỔI PHÍM TẮT:`r`n"
            . "   • Click vào nút F9 hoặc F10 trong app`r`n"
            . "   • Nhấn phím mới (F1-F12)`r`n"
            . "   • Xong!`r`n"
    } else {
        guideContent := ""
            . "SMART PASTE USER GUIDE`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "Step 1: Copy Data`r`n"
            . "   • Copy multiple lines from Excel, Word, Notepad`r`n"
            . "   • App will auto-detect and load data`r`n`r`n"
            . "Step 2: Paste Sequentially`r`n"
            . "   • Press F9 to PASTE each line at cursor`r`n"
            . "   • Each press pastes the next line`r`n`r`n"
            . "Step 3: Go Back (if needed)`r`n"
            . "   • Press F10 to go BACK to previous item`r`n"
            . "   • Press F9 to re-paste that item`r`n`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "PRO TIPS:`r`n"
            . "   ✓ Great for quick form filling`r`n"
            . "   ✓ Bulk product code entry`r`n"
            . "   ✓ If F9 not working → Run as Admin`r`n`r`n"
            . "CHANGE HOTKEY:`r`n"
            . "   • Click F9 or F10 button in the app`r`n"
            . "   • Press new key (F1-F12)`r`n"
            . "   • Done!`r`n"
    }

    GuideEdit := GuideGui.Add("Edit", "x10 y10 w380 h320 ReadOnly VScroll", guideContent)
    GuideEdit.SetFont("s10", "Consolas")

    BtnOK := GuideGui.Add("Button", "x150 y340 w100 h30", "OK")
    BtnOK.OnEvent("Click", (*) => GuideGui.Destroy())

    GuideGui.Show("w400 h380")
}

; ============ ABOUT DIALOG ============
ShowAbout(*) {
    global Lang

    AboutGui := Gui("+AlwaysOnTop +ToolWindow -Resize", (Lang = "vi") ? "Thông tin" : "About")
    AboutGui.SetFont("s9", "Segoe UI")

    AboutGui.Add("Text", "x20 y15 w320 h20 Center", "Smart Paste v10.0").SetFont("s14 Bold c1E3A5F")
    AboutGui.Add("Text", "x20 y42 w320 h16 Center c64748B", (Lang = "vi") ? "Công cụ dán nhiều dòng tuần tự" : "Sequential Multi-line Paster")

    AboutGui.Add("GroupBox", "x15 y68 w330 h100", "")
    aboutDesc := (Lang = "vi") ? "Smart Paste giúp bạn dán nhiều dòng dữ liệu`ntuần tự vào form, Excel, hoặc bất kỳ ứng dụng`nnào trên Windows." : "Smart Paste helps you paste multiple lines`nsequentially into forms, Excel, or any`nWindows application."
    AboutGui.Add("Text", "x30 y88 w300 h60", aboutDesc)

    AboutGui.Add("Text", "x20 y180 w320 h16 Center", "Web: github.com/dahodo/smartpaste").SetFont("s8 c0369A1")
    AboutGui.Add("Text", "x20 y200 w320 h16 Center c64748B", "© 2026 Dahodo (DHD) | MIT License").SetFont("s8")

    BtnOK := AboutGui.Add("Button", "x130 y228 w100 h28", "OK")
    BtnOK.SetFont("s9")
    BtnOK.OnEvent("Click", (*) => AboutGui.Destroy())

    AboutGui.Show("w360 h268")
}

; ============ HOTKEY FUNCTIONS ============
SetupHotkeys() {
    global
    try Hotkey("$" PasteKey, DoPaste)
    try Hotkey("$" BackKey, DoBack)
}

ChangeHotkey(which) {
    global

    MainGui.Opt("-AlwaysOnTop")

    CaptureGui := Gui("-MinimizeBox +AlwaysOnTop +ToolWindow", GetText("captureTitle"))
    CaptureGui.SetFont("s10", "Segoe UI")
    CaptureGui.Add("Text", "x20 y15 w300 h40 Center", GetText("captureText"))
    CaptureGui.Show("w340 h80 Center")

    ih := InputHook("L1 T5")
    ih.KeyOpt("{All}", "E")
    ih.KeyOpt("{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
    ih.Start()
    ih.Wait()

    detectedKey := ""
    if (ih.EndReason = "EndKey") {
        endKey := ih.EndKey
        if (endKey != "Escape") {
            prefix := ""
            if GetKeyState("Ctrl") {
                prefix := prefix "^"
            }
            if GetKeyState("Shift") {
                prefix := prefix "+"
            }
            if GetKeyState("Alt") {
                prefix := prefix "!"
            }
            detectedKey := prefix endKey
        }
    }

    CaptureGui.Destroy()

    if (ChkOnTop.Value) {
        MainGui.Opt("+AlwaysOnTop")
    }

    if (!detectedKey) {
        return
    }

    if (which = "paste" && detectedKey != BackKey) {
        try Hotkey("$" PasteKey, "Off")
        PasteKey := detectedKey
        try Hotkey("$" PasteKey, DoPaste)
        BtnPasteKey.Text := PasteKey
        SaveConfig()
        ShowToast(GetText("msgPasteKey") PasteKey)
    } else if (which = "back" && detectedKey != PasteKey) {
        try Hotkey("$" BackKey, "Off")
        BackKey := detectedKey
        try Hotkey("$" BackKey, DoBack)
        BtnBackKey.Text := BackKey
        SaveConfig()
        ShowToast(GetText("msgBackKey") BackKey)
    }
}

; ============ ACTIONS ============
DoPaste(*) {
    global

    Critical "On"
    if (Queue.Length = 0) {
        ShowToast(GetText("msgEmpty"))
        return
    }
    if (CurrentIndex > Queue.Length) {
        if (ChkLoop.Value) {
            CurrentIndex := 1
        } else {
            ShowToast(GetText("msgDone"))
            return
        }
    }
    text := Queue[CurrentIndex]
    CurrentIndex := CurrentIndex + 1
    Critical "Off"

    IsPasting := true
    A_Clipboard := text
    Sleep 30
    Send "^v"
    IsPasting := false
    RefreshUI()
}

DoBack(*) {
    global

    Critical "On"
    if (Queue.Length = 0) {
        ShowToast(GetText("msgEmpty"))
        return
    }
    if (CurrentIndex > 1) {
        CurrentIndex := CurrentIndex - 1
        text := Queue[CurrentIndex]
        Critical "Off"

        IsPasting := true
        A_Clipboard := text
        Sleep 30
        Send "^v"
        IsPasting := false
        RefreshUI()
    } else {
        ShowToast(GetText("msgFirst"))
    }
}

DoReset(*) {
    global
    CurrentIndex := 1
    RefreshUI()
    ShowToast("Reset!")
}

RefreshUI() {
    global Queue, CurrentIndex, CurrentText, ProgressText, ProgressBar, StatusText, Lang

    total := Queue.Length
    if (total = 0) {
        CurrentText.Text := GetText("waiting")
        CurrentText.SetFont("s13 Bold c94A3B8")
        ProgressText.Text := "0 / 0"
        ProgressBar.Value := 0
        StatusText.Text := GetText("statusReady")
        StatusText.SetFont("s9 Bold c0369A1")
        return
    }

    if (CurrentIndex <= total) {
        item := Queue[CurrentIndex]
        if (StrLen(item) > 40) {
            item := SubStr(item, 1, 40) "..."
        }
        CurrentText.Text := item
        CurrentText.SetFont("s13 Bold c1E293B")
    } else {
        CurrentText.Text := GetText("msgDone")
        CurrentText.SetFont("s13 Bold c16A34A")
    }

    done := CurrentIndex - 1
    pct := Round(done / total * 100)
    remain := total - done

    ProgressBar.Value := pct
    ProgressText.Text := done " / " total "  (" pct "%)"

    if (Lang = "vi") {
        StatusText.Text := "Đã dán " done "/" total " — Còn " remain " mục"
    } else {
        StatusText.Text := "Pasted " done "/" total " — " remain " remaining"
    }
    StatusText.SetFont("s9 Bold c0369A1")
}

ShowToast(msg) {
    ToolTip(msg)
    SetTimer () => ToolTip(), -2000
}

; ============ CLIPBOARD ============
CheckClipboard() {
    global LastClip, IsPasting
    if (IsPasting) {
        return
    }
    try {
        current := A_Clipboard
        if (current && current != LastClip) {
            if (InStr(current, "`n") || InStr(current, "`r")) {
                LastClip := current
                LoadQueue(current)
            }
        }
    }
}

LoadQueue(text) {
    global Queue, CurrentIndex
    Queue := []
    CurrentIndex := 1

    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")

    for line in StrSplit(text, "`n") {
        line := Trim(line)
        if (line) {
            Queue.Push(line)
        }
    }

    RefreshUI()
    ShowToast(GetText("msgLoaded", Queue.Length))
}

LoadFromManual(*) {
    global EdtInput
    text := EdtInput.Value
    if (text) {
        LoadQueue(text)
        EdtInput.Value := ""
    }
}

; ============ OPTIONS ============
ToggleLanguage(*) {
    global Lang, ChkLang
    Lang := (ChkLang.Value) ? "vi" : "en"
    SaveConfig()
    MainGui.Destroy()
    CreateGUI()
    SetupHotkeys()
}

ToggleOnTop(*) {
    global MainGui
    if (ChkOnTop.Value) {
        MainGui.Opt("+AlwaysOnTop")
    } else {
        MainGui.Opt("-AlwaysOnTop")
    }
}

IsStartupEnabled() {
    try {
        RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SmartPaste")
        return true
    }
    return false
}

ToggleStartup(*) {
    if (ChkStartup.Value) {
        try RegWrite(A_ScriptFullPath, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SmartPaste")
    } else {
        try RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "SmartPaste")
    }
}

; ============ TRAY ============
A_TrayMenu.Delete()
A_TrayMenu.Add(GetText("trayShow"), (*) => MainGui.Show())
A_TrayMenu.Add()
A_TrayMenu.Add(GetText("trayExit"), (*) => ExitApp())
A_TrayMenu.Default := GetText("trayShow")

; ============ INIT ============
LoadConfig()
CreateGUI()
SetupHotkeys()
SetTimer CheckClipboard, 300
