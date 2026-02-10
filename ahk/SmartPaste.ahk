; Smart Paste v0.3 - AutoHotkey Edition
; Sequential Clipboard Paster
; https://github.com/danghoangdong79/smartpaste
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
global AutoKey := "F11"
global ToggleKey := "F12"
global Queue := []
global CurrentIndex := 1
global LastClip := ""
global IsPasting := false
global IsAutoPasting := false
global IsEnabled := true
global PasteDelay := 0.1
global SkipEmpty := 1
global AutoSepKey := "Tab"
global AutoSepAfterPaste := 0
global History := []

; ============ TRANSLATIONS ============
BuildTexts() {
    t := Map()
    ; Vietnamese
    t["vi.title"]        := "Smart Paste v0.4"
    t["vi.grpData"]      := "Dữ liệu"
    t["vi.grpAction"]    := "Thao tác"
    t["vi.grpHotkey"]    := "Phím tắt"
    t["vi.grpOption"]    := "Tùy chọn khác"
    t["vi.grpAdvanced"]  := "Nâng cao"
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
    t["vi.enabled"]      := "✅ ĐANG BẬT"
    t["vi.disabled"]     := "❌ ĐÃ TẮT"
    t["vi.labelToggle"]  := "Bật/Tắt:"
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
    t["vi.delay"]        := "Nghỉ:"
    t["vi.sec"]           := "giây"
    t["vi.skipEmpty"]    := "Bỏ dòng trống"
    t["vi.loadFile"]     := "📂 File"
    t["vi.autoMode"]     := "⚡ Tự động"
    t["vi.labelAuto"]    := "Phím Auto:"
    t["vi.autoSep"]      := "Sau mỗi dòng:"
    t["vi.customSep"]    := "🔧"
    t["vi.sepPaste"]     := "F9 + ngăn cách"
    t["vi.history"]      := "📋 Lịch sử"
    t["vi.msgAuto"]      := "Đang tự động dán... (ESC để dừng)"
    t["vi.msgAutoStop"]  := "Đã dừng tự động dán"
    t["vi.msgAutoDone"]  := "Tự động dán xong!"
    t["vi.noHistory"]    := "Chưa có lịch sử"
    t["vi.captureSep"]   := "Nhấn phím/tổ hợp phím để dùng làm ngăn cách (Esc hủy)"
    t["vi.preview"]      := "Xem trước:"
    ; English
    t["en.title"]        := "Smart Paste v0.4"
    t["en.grpData"]      := "Data"
    t["en.grpAction"]    := "Actions"
    t["en.grpHotkey"]    := "Hotkeys"
    t["en.grpOption"]    := "Other Options"
    t["en.grpAdvanced"]  := "Advanced"
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
    t["en.enabled"]      := "✅ ENABLED"
    t["en.disabled"]     := "❌ DISABLED"
    t["en.labelToggle"]  := "On/Off:"
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
    t["en.delay"]        := "Delay:"
    t["en.sec"]           := "sec"
    t["en.skipEmpty"]    := "Skip empty"
    t["en.loadFile"]     := "📂 File"
    t["en.autoMode"]     := "⚡ Auto"
    t["en.labelAuto"]    := "Auto Key:"
    t["en.autoSep"]      := "After each:"
    t["en.customSep"]    := "🔧"
    t["en.sepPaste"]     := "F9 + separator"
    t["en.history"]      := "📋 History"
    t["en.msgAuto"]      := "Auto-pasting... (ESC to stop)"
    t["en.msgAutoStop"]  := "Auto-paste stopped"
    t["en.msgAutoDone"]  := "Auto-paste complete!"
    t["en.noHistory"]    := "No history"
    t["en.captureSep"]   := "Press a key/combo to use as separator (Esc to cancel)"
    t["en.preview"]      := "Preview:"
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
    global ConfigFile, Lang, PasteKey, BackKey, PasteDelay, SkipEmpty, AutoSepKey
    if FileExist(ConfigFile) {
        try {
            Lang := IniRead(ConfigFile, "Settings", "Language", "vi")
            PasteKey := IniRead(ConfigFile, "Settings", "PasteKey", "F9")
            BackKey := IniRead(ConfigFile, "Settings", "BackKey", "F10")
            AutoKey := IniRead(ConfigFile, "Settings", "AutoKey", "F11")
            ToggleKey := IniRead(ConfigFile, "Settings", "ToggleKey", "F12")
            PasteDelay := Float(IniRead(ConfigFile, "Settings", "PasteDelay", "0.1"))
            SkipEmpty := Integer(IniRead(ConfigFile, "Settings", "SkipEmpty", "1"))
            AutoSepAfterPaste := Integer(IniRead(ConfigFile, "Settings", "SepAfterPaste", "0"))
            AutoSepKey := IniRead(ConfigFile, "Settings", "AutoSepKey", "Tab")
        }
    }
}

SaveConfig() {
    global
    IniWrite(Lang, ConfigFile, "Settings", "Language")
    IniWrite(PasteKey, ConfigFile, "Settings", "PasteKey")
    IniWrite(BackKey, ConfigFile, "Settings", "BackKey")
    IniWrite(AutoKey, ConfigFile, "Settings", "AutoKey")
    IniWrite(ToggleKey, ConfigFile, "Settings", "ToggleKey")
    IniWrite(PasteDelay, ConfigFile, "Settings", "PasteDelay")
    IniWrite(SkipEmpty, ConfigFile, "Settings", "SkipEmpty")
    IniWrite(AutoSepKey, ConfigFile, "Settings", "AutoSepKey")
    IniWrite(AutoSepAfterPaste, ConfigFile, "Settings", "SepAfterPaste")
    try IniWrite(ChkLoop.Value, ConfigFile, "Settings", "Loop")
}

; ============ GUI ============
CreateGUI() {
    global MainGui, StatusText, CurrentText, PreviewText, ProgressText, ProgressBar
    global BtnPaste, BtnBack, BtnReset, BtnPasteKey, BtnBackKey
    global ChkLoop, ChkOnTop, ChkStartup, ChkLang, ChkSkipEmpty, EdtInput
    global EdtDelay, DdlSep, DdlHistory, BtnAuto, BtnAutoKey, ChkSepPaste, BtnToggleKey
    global AutoSepKey, AutoKey, ToggleKey, SkipEmpty, PasteDelay

    ; --- Window ---
    MainGui := Gui("+AlwaysOnTop -Resize", GetText("title"))
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.OnEvent("Close", (*) => MainGui.Hide())

    ; ==========================================
    ; MASTER TOGGLE - BẬT / TẮT
    ; ==========================================
    global BtnToggle
    BtnToggle := MainGui.Add("Button", "x10 y8 w510 h36", GetText("enabled"))
    BtnToggle.SetFont("s11 Bold")
    BtnToggle.OnEvent("Click", ToggleEnabled)
    UpdateToggleButton()

    ; ==========================================
    ; GroupBox: Dữ liệu (with preview)
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y50 w510 h185", GetText("grpData"))

    StatusText := MainGui.Add("Text", "x25 y72 w480 h20 Center", GetText("statusReady"))
    StatusText.SetFont("s9 Bold c0369A1")

    CurrentText := MainGui.Add("Text", "x25 y97 w480 h28 Center c1E293B", GetText("waiting"))
    CurrentText.SetFont("s13 Bold")

    ProgressBar := MainGui.Add("Progress", "x25 y130 w480 h8 c2563EB BackgroundE2E8F0 Range0-100", 0)
    ProgressText := MainGui.Add("Text", "x25 y142 w480 Center c64748B", "0 / 0")
    ProgressText.SetFont("s8")

    ; Preview next 2 items
    PreviewText := MainGui.Add("Text", "x25 y160 w480 h28 c94A3B8", "")
    PreviewText.SetFont("s8")

    ; Manual input inline
    EdtInput := MainGui.Add("Edit", "x25 y192 w370 h28", "")
    EdtInput.SetFont("s9")
    BtnLoad := MainGui.Add("Button", "x400 y192 w105 h28", GetText("load"))
    BtnLoad.SetFont("s8")
    BtnLoad.OnEvent("Click", LoadFromManual)

    ; ==========================================
    ; GroupBox: Phím tắt  (left side)
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y242 w290 h130", GetText("grpHotkey"))

    ; Row 1: DÁN + LÙI
    MainGui.Add("Text", "x25 y264 w75 h20", GetText("labelPaste")).SetFont("s9")
    BtnPasteKey := MainGui.Add("Button", "x105 y261 w55 h24", PasteKey)
    BtnPasteKey.SetFont("s9 Bold")
    BtnPasteKey.OnEvent("Click", (*) => ChangeHotkey("paste"))

    MainGui.Add("Text", "x170 y264 w65 h20", GetText("labelBack")).SetFont("s9")
    BtnBackKey := MainGui.Add("Button", "x235 y261 w55 h24", BackKey)
    BtnBackKey.SetFont("s9 Bold")
    BtnBackKey.OnEvent("Click", (*) => ChangeHotkey("back"))

    ; Row 2: Auto + Bật/Tắt
    MainGui.Add("Text", "x25 y296 w75 h20", GetText("labelAuto")).SetFont("s9")
    BtnAutoKey := MainGui.Add("Button", "x105 y293 w55 h24", AutoKey)
    BtnAutoKey.SetFont("s9 Bold")
    BtnAutoKey.OnEvent("Click", (*) => ChangeHotkey("auto"))

    MainGui.Add("Text", "x170 y296 w65 h20", GetText("labelToggle")).SetFont("s9")
    BtnToggleKey := MainGui.Add("Button", "x235 y293 w55 h24", ToggleKey)
    BtnToggleKey.SetFont("s9 Bold")
    BtnToggleKey.OnEvent("Click", (*) => ChangeHotkey("toggle"))

    MainGui.Add("Text", "x25 y325 w270 h16 cB45309", GetText("warnAdmin")).SetFont("s7")

    ; ==========================================
    ; GroupBox: Thao tác  (right side)
    ; ==========================================
    MainGui.Add("GroupBox", "x310 y242 w210 h130", GetText("grpAction"))

    BtnPaste := MainGui.Add("Button", "x325 y264 w180 h38", GetText("btnPaste"))
    BtnPaste.SetFont("s11 Bold")
    BtnPaste.OnEvent("Click", DoPaste)

    BtnBack := MainGui.Add("Button", "x325 y308 w87 h30", GetText("btnBack"))
    BtnBack.SetFont("s8 Bold")
    BtnBack.OnEvent("Click", DoBack)

    BtnReset := MainGui.Add("Button", "x418 y308 w87 h30", GetText("btnReset"))
    BtnReset.SetFont("s8 Bold")
    BtnReset.OnEvent("Click", DoReset)

    ; ==========================================
    ; GroupBox: Nâng cao
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y380 w510 h135", GetText("grpAdvanced"))

    ; Row 1: Delay + Skip empty + Load file + History
    MainGui.Add("Text", "x25 y402 w38 h20", GetText("delay")).SetFont("s8")
    EdtDelay := MainGui.Add("Edit", "x65 y400 w50 h22", PasteDelay)
    EdtDelay.SetFont("s8")
    MainGui.Add("Text", "x118 y402 w35 h20", GetText("sec")).SetFont("s8 c64748B")

    ChkSkipEmpty := MainGui.Add("Checkbox", "x165 y402 w125", GetText("skipEmpty"))
    ChkSkipEmpty.Value := SkipEmpty
    ChkSkipEmpty.SetFont("s8")
    ChkSkipEmpty.OnEvent("Click", (*) => (SkipEmpty := ChkSkipEmpty.Value, SaveConfig()))

    BtnLoadFile := MainGui.Add("Button", "x340 y398 w80 h26", GetText("loadFile"))
    BtnLoadFile.SetFont("s8")
    BtnLoadFile.OnEvent("Click", LoadFromFile)

    BtnHistory := MainGui.Add("Button", "x425 y398 w85 h26", GetText("history"))
    BtnHistory.SetFont("s8")
    BtnHistory.OnEvent("Click", ShowHistory)

    ; Row 2: Auto button + Separator label + Dropdown + Custom button
    BtnAuto := MainGui.Add("Button", "x25 y432 w100 h35", GetText("autoMode"))
    BtnAuto.SetFont("s10 Bold")
    BtnAuto.OnEvent("Click", DoAutoPaste)

    MainGui.Add("Text", "x135 y440 w80 h20 Right", GetText("autoSep")).SetFont("s8")
    sepList := ["Tab", "Enter", "Space", "Ctrl+N", "Ctrl+Enter", "Ctrl+Tab", "Down", "Ctrl+Down"]
    sepIdx := 1
    for i, v in sepList {
        if (v = AutoSepKey) {
            sepIdx := i
        }
    }
    ; If custom key not in list, add it
    if (sepIdx = 1 && AutoSepKey != "Tab") {
        sepList.Push(AutoSepKey)
        sepIdx := sepList.Length
    }
    DdlSep := MainGui.Add("DropDownList", "x220 y436 w145 Choose" sepIdx, sepList)
    DdlSep.SetFont("s8")
    DdlSep.OnEvent("Change", OnSepChange)

    BtnCustomSep := MainGui.Add("Button", "x370 y436 w40 h26", GetText("customSep"))
    BtnCustomSep.SetFont("s10")
    BtnCustomSep.OnEvent("Click", CaptureCustomSep)

    ; Row 3: F9 + separator checkbox
    ChkSepPaste := MainGui.Add("Checkbox", "x25 y475 w485", GetText("sepPaste"))
    ChkSepPaste.Value := AutoSepAfterPaste
    ChkSepPaste.SetFont("s8")
    ChkSepPaste.OnEvent("Click", (*) => (AutoSepAfterPaste := ChkSepPaste.Value, SaveConfig()))

    ; ==========================================
    ; GroupBox: Tùy chọn khác
    ; ==========================================
    MainGui.Add("GroupBox", "x10 y520 w510 h95", GetText("grpOption"))

    ChkLoop := MainGui.Add("Checkbox", "x25 y540 w230", GetText("loop"))
    try ChkLoop.Value := IniRead(ConfigFile, "Settings", "Loop", "0")
    ChkLoop.OnEvent("Click", (*) => SaveConfig())

    ChkOnTop := MainGui.Add("Checkbox", "x270 y540 w240 Checked", GetText("ontop"))
    ChkOnTop.OnEvent("Click", ToggleOnTop)

    ChkStartup := MainGui.Add("Checkbox", "x25 y565 w230", GetText("startup"))
    ChkStartup.Value := IsStartupEnabled()
    ChkStartup.OnEvent("Click", ToggleStartup)

    ChkLang := MainGui.Add("Checkbox", "x270 y565 w240", GetText("langBtn"))
    ChkLang.Value := (Lang = "vi") ? 1 : 0
    ChkLang.OnEvent("Click", ToggleLanguage)

    ; ==========================================
    ; Bottom buttons
    ; ==========================================
    BtnGuide := MainGui.Add("Button", "x10 y625 w165 h32", GetText("btnGuide"))
    BtnGuide.SetFont("s9")
    BtnGuide.OnEvent("Click", ShowGuide)

    BtnAbout := MainGui.Add("Button", "x180 y625 w165 h32", GetText("btnAbout"))
    BtnAbout.SetFont("s9")
    BtnAbout.OnEvent("Click", ShowAbout)

    BtnClose := MainGui.Add("Button", "x350 y625 w170 h32", GetText("btnClose"))
    BtnClose.SetFont("s9")
    BtnClose.OnEvent("Click", (*) => MainGui.Hide())

    MainGui.Show("w530 h665")
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
            . "   • Nhấn F9 để DÁN từng dòng`r`n"
            . "   • Nhấn F10 để LÙI + DÁN dòng trước`r`n`r`n"
            . "Bước 3: Tự động dán`r`n"
            . "   • Click nút ⚡ Tự động`r`n"
            . "   • Chọn phím ngăn cách: Tab, Enter, Space`r`n"
            . "   • App sẽ tự dán + chuyển ô liên tục`r`n"
            . "   • Nhấn ESC để dừng`r`n`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "TÍNH NĂNG MỚI v0.3:`r`n"
            . "   ⚡ Tự động dán + Tab/Enter`r`n"
            . "   📂 Nạp dữ liệu từ file .txt`r`n"
            . "   📋 Lịch sử clipboard (10 bộ)`r`n"
            . "   ⏱ Tùy chỉnh tốc độ dán`r`n"
            . "   🔇 Bỏ qua dòng trống tự động`r`n"
    } else {
        guideContent := ""
            . "SMART PASTE USER GUIDE`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "Step 1: Copy Data`r`n"
            . "   • Copy multiple lines from Excel, Word, Notepad`r`n"
            . "   • App will auto-detect and load data`r`n`r`n"
            . "Step 2: Paste Sequentially`r`n"
            . "   • Press F9 to PASTE next line`r`n"
            . "   • Press F10 to go BACK + PASTE previous`r`n`r`n"
            . "Step 3: Auto-paste`r`n"
            . "   • Click ⚡ Auto button`r`n"
            . "   • Choose separator: Tab, Enter, Space`r`n"
            . "   • App will auto-paste + move to next cell`r`n"
            . "   • Press ESC to stop`r`n`r`n"
            . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━`r`n`r`n"
            . "NEW IN v0.3:`r`n"
            . "   ⚡ Auto-paste with Tab/Enter`r`n"
            . "   📂 Load data from .txt files`r`n"
            . "   📋 Clipboard history (10 sets)`r`n"
            . "   ⏱ Custom paste speed`r`n"
            . "   🔇 Auto-skip empty lines`r`n"
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

    AboutGui.Add("Text", "x20 y15 w320 h20 Center", "Smart Paste v0.3").SetFont("s14 Bold c1E3A5F")
    AboutGui.Add("Text", "x20 y42 w320 h16 Center c64748B", (Lang = "vi") ? "Công cụ dán nhiều dòng tuần tự" : "Sequential Multi-line Paster")

    AboutGui.Add("GroupBox", "x15 y68 w330 h100", "")
    aboutDesc := (Lang = "vi") ? "Smart Paste giúp bạn dán nhiều dòng dữ liệu`ntuần tự vào form, Excel, hoặc bất kỳ ứng dụng`nnào trên Windows." : "Smart Paste helps you paste multiple lines`nsequentially into forms, Excel, or any`nWindows application."
    AboutGui.Add("Text", "x30 y88 w300 h60", aboutDesc)

    AboutGui.Add("Text", "x20 y180 w320 h16 Center", "Web: github.com/danghoangdong79/smartpaste").SetFont("s8 c0369A1")
    AboutGui.Add("Text", "x20 y200 w320 h16 Center c64748B", "© 2026 Dahodo (DHD) | MIT License").SetFont("s8")

    BtnOK := AboutGui.Add("Button", "x130 y228 w100 h28", "OK")
    BtnOK.SetFont("s9")
    BtnOK.OnEvent("Click", (*) => AboutGui.Destroy())

    AboutGui.Show("w360 h268")
}

; ============ HOTKEY FUNCTIONS ============
OnSepChange(*) {
    global AutoSepKey, DdlSep
    AutoSepKey := DdlSep.Text
    SaveConfig()
}

CaptureCustomSep(*) {
    global MainGui, ChkOnTop, AutoSepKey, DdlSep

    MainGui.Opt("-AlwaysOnTop")

    CaptureGui := Gui("-MinimizeBox +AlwaysOnTop +ToolWindow", GetText("captureTitle"))
    CaptureGui.SetFont("s10", "Segoe UI")
    CaptureGui.Add("Text", "x20 y15 w360 h40 Center", GetText("captureSep"))
    CaptureGui.Show("w400 h80 Center")

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
            prefixLabel := ""
            if GetKeyState("Ctrl") {
                prefix := prefix "^"
                prefixLabel := prefixLabel "Ctrl+"
            }
            if GetKeyState("Shift") {
                prefix := prefix "+"
                prefixLabel := prefixLabel "Shift+"
            }
            if GetKeyState("Alt") {
                prefix := prefix "!"
                prefixLabel := prefixLabel "Alt+"
            }
            detectedKey := prefixLabel endKey
        }
    }

    CaptureGui.Destroy()

    if (ChkOnTop.Value) {
        MainGui.Opt("+AlwaysOnTop")
    }

    if (!detectedKey) {
        return
    }

    AutoSepKey := detectedKey
    ; Add to dropdown if not exists
    found := false
    for i, v in ["Tab", "Enter", "Space", "Ctrl+N", "Ctrl+Enter", "Ctrl+Tab", "Down", "Ctrl+Down"] {
        if (v = detectedKey) {
            found := true
            break
        }
    }
    if (!found) {
        DdlSep.Add([detectedKey])
    }
    DdlSep.Text := detectedKey
    SaveConfig()
    ShowToast("Separator: " detectedKey)
}

; Convert separator label to AHK send format
SepToSendKey(sepName) {
    switch sepName {
        case "Tab":         return "{Tab}"
        case "Enter":       return "{Enter}"
        case "Space":       return "{Space}"
        case "Down":        return "{Down}"
        case "Up":          return "{Up}"
        default:
            ; Handle combos like "Ctrl+N" → "^n", "Ctrl+Enter" → "^{Enter}"
            result := sepName
            result := StrReplace(result, "Ctrl+", "^")
            result := StrReplace(result, "Shift+", "+")
            result := StrReplace(result, "Alt+", "!")
            ; If the final key part is a special key, wrap in braces
            specialKeys := ["Enter", "Tab", "Space", "Down", "Up", "Left", "Right", "Home", "End", "Delete", "Backspace", "Escape"]
            for key in specialKeys {
                if (InStr(result, key)) {
                    ; Extract prefix (^, +, !) and wrap key part
                    prefix := ""
                    remaining := result
                    while (SubStr(remaining, 1, 1) = "^" || SubStr(remaining, 1, 1) = "+" || SubStr(remaining, 1, 1) = "!") {
                        prefix := prefix SubStr(remaining, 1, 1)
                        remaining := SubStr(remaining, 2)
                    }
                    return prefix "{" remaining "}"
                }
            }
            return result
    }
}

SetupHotkeys() {
    global
    try Hotkey("$" PasteKey, DoPaste)
    try Hotkey("$" BackKey, DoBack)
    try Hotkey("$" AutoKey, DoAutoPaste)
    try Hotkey("$" ToggleKey, ToggleEnabled)
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
    } else if (which = "back" && detectedKey != PasteKey && detectedKey != AutoKey) {
        try Hotkey("$" BackKey, "Off")
        BackKey := detectedKey
        try Hotkey("$" BackKey, DoBack)
        BtnBackKey.Text := BackKey
        SaveConfig()
        ShowToast(GetText("msgBackKey") BackKey)
    } else if (which = "auto" && detectedKey != PasteKey && detectedKey != BackKey && detectedKey != ToggleKey) {
        try Hotkey("$" AutoKey, "Off")
        AutoKey := detectedKey
        try Hotkey("$" AutoKey, DoAutoPaste)
        BtnAutoKey.Text := AutoKey
        SaveConfig()
        ShowToast("Auto Key: " AutoKey)
    } else if (which = "toggle" && detectedKey != PasteKey && detectedKey != BackKey && detectedKey != AutoKey) {
        try Hotkey("$" ToggleKey, "Off")
        ToggleKey := detectedKey
        try Hotkey("$" ToggleKey, ToggleEnabled)
        BtnToggleKey.Text := ToggleKey
        SaveConfig()
        ShowToast("Toggle Key: " ToggleKey)
    }
}

; ============ ACTIONS ============
DoPaste(*) {
    global

    if (!IsEnabled) {
        return
    }

    Critical "On"
    if (Queue.Length = 0) {
        Critical "Off"
        ShowToast(GetText("msgEmpty"))
        return
    }
    if (CurrentIndex > Queue.Length) {
        if (ChkLoop.Value) {
            CurrentIndex := 1
        } else {
            Critical "Off"
            ShowToast(GetText("msgDone"))
            SoundBeep 800, 200
            return
        }
    }
    text := Queue[CurrentIndex]
    CurrentIndex := CurrentIndex + 1
    Critical "Off"

    IsPasting := true
    ; Clear clipboard and wait for it to be truly empty
    A_Clipboard := ""
    Sleep 50
    ; Set new content
    A_Clipboard := text
    ; Wait for clipboard to actually contain the new text (up to 2s)
    if !ClipWait(2) {
        ; Retry once if failed
        A_Clipboard := ""
        Sleep 50
        A_Clipboard := text
        ClipWait 2
    }
    Sleep 50
    Send "^v"

    ; Send separator after paste if enabled
    if (AutoSepAfterPaste) {
        Sleep 80
        sepCmd := SepToSendKey(AutoSepKey)
        Send sepCmd
    }
    Sleep 100
    IsPasting := false
    SoundBeep 1500, 30
    RefreshUI()
}

DoBack(*) {
    global

    if (!IsEnabled) {
        return
    }

    Critical "On"
    if (Queue.Length = 0) {
        Critical "Off"
        ShowToast(GetText("msgEmpty"))
        return
    }
    if (CurrentIndex > 1) {
        CurrentIndex := CurrentIndex - 1
        text := Queue[CurrentIndex]
        Critical "Off"

        IsPasting := true
        ; Clear clipboard and wait for it to be truly empty
        A_Clipboard := ""
        Sleep 50
        ; Set new content
        A_Clipboard := text
        ; Wait for clipboard to actually contain the new text (up to 2s)
        if !ClipWait(2) {
            A_Clipboard := ""
            Sleep 50
            A_Clipboard := text
            ClipWait 2
        }
        Sleep 50
        Send "^v"
        Sleep 100
        IsPasting := false
        SoundBeep 1500, 30
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

; ============ AUTO-PASTE MODE ============
global AutoDelayMs := 200
global AutoSep := "{Tab}"

DoAutoPaste(*) {
    global

    if (!IsEnabled) {
        return
    }

    ; Toggle off if already running
    if (IsAutoPasting) {
        StopAutoPaste()
        return
    }

    if (Queue.Length = 0) {
        ShowToast(GetText("msgEmpty"))
        return
    }

    if (CurrentIndex > Queue.Length) {
        ShowToast(GetText("msgDone"))
        return
    }

    ; Read delay from edit box (seconds → ms)
    try {
        PasteDelay := Float(EdtDelay.Value)
    }
    AutoDelayMs := Round(PasteDelay * 1000)
    ; Minimum 50ms — SendText is reliable even at high speed
    if (AutoDelayMs < 50) {
        AutoDelayMs := 50
    }
    SaveConfig()

    ; Read separator directly from dropdown and convert to AHK format
    AutoSep := SepToSendKey(DdlSep.Text)

    IsAutoPasting := true
    IsPasting := true          ; Block clipboard monitor for ENTIRE auto-paste session
    BtnAuto.Text := "⏹ STOP"
    ShowToast(GetText("msgAuto"))

    ; Register ESC as stop key
    try Hotkey("$Escape", StopAutoPaste, "On")

    ; Start first tick immediately
    SetTimer(AutoPasteTick, -1)
}

AutoPasteTick() {
    global

    ; Block ALL other timers during this critical operation
    Critical "On"

    if (!IsAutoPasting || CurrentIndex > Queue.Length) {
        if (CurrentIndex > Queue.Length && IsAutoPasting) {
            ShowToast(GetText("msgAutoDone"))
            SoundBeep 800, 200
        }
        Critical "Off"
        StopAutoPaste()
        return
    }

    text := Queue[CurrentIndex]
    CurrentIndex := CurrentIndex + 1

    ; === SEND TEXT DIRECTLY — NO CLIPBOARD ===
    ; SendText types each character via SendInput API
    ; This completely bypasses the clipboard, eliminating all race conditions
    ; No ClipWait, no clipboard clear/set — just direct character input
    SendText text

    ; Small wait for target app to process the text
    Sleep 30

    SoundBeep 1500, 20
    RefreshUI()

    ; === Separator + schedule next ===
    if (CurrentIndex <= Queue.Length && IsAutoPasting) {
        Send AutoSep
        Sleep 30    ; Let separator key register in target app
        Critical "Off"

        ; AutoDelayMs is the ONLY delay between items
        SetTimer(AutoPasteTick, -AutoDelayMs)
    } else {
        if (CurrentIndex > Queue.Length) {
            ShowToast(GetText("msgAutoDone"))
            SoundBeep 800, 200
        }
        Critical "Off"
        StopAutoPaste()
    }
}

StopAutoPaste(*) {
    global
    if (!IsAutoPasting) {
        return
    }
    IsAutoPasting := false
    IsPasting := false             ; Re-enable clipboard monitor
    SetTimer(AutoPasteTick, 0)     ; Cancel pending timer
    BtnAuto.Text := GetText("autoMode")
    try Hotkey("$Escape", "Off")
    SoundBeep 600, 100
    RefreshUI()
}

; ============ UI REFRESH ============
RefreshUI() {
    global Queue, CurrentIndex, CurrentText, PreviewText, ProgressText, ProgressBar, StatusText, Lang

    total := Queue.Length
    if (total = 0) {
        CurrentText.Text := GetText("waiting")
        CurrentText.SetFont("s13 Bold c94A3B8")
        PreviewText.Text := ""
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

        ; Preview next 2 items
        preview := ""
        if (CurrentIndex + 1 <= total) {
            p1 := Queue[CurrentIndex + 1]
            if (StrLen(p1) > 35) {
                p1 := SubStr(p1, 1, 35) "..."
            }
            preview := "→ " p1
        }
        if (CurrentIndex + 2 <= total) {
            p2 := Queue[CurrentIndex + 2]
            if (StrLen(p2) > 35) {
                p2 := SubStr(p2, 1, 35) "..."
            }
            preview := preview "   → " p2
        }
        PreviewText.Text := preview
    } else {
        CurrentText.Text := GetText("msgDone")
        CurrentText.SetFont("s13 Bold c16A34A")
        PreviewText.Text := ""
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
    global LastClip, IsPasting, IsEnabled
    if (IsPasting || !IsEnabled) {
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
    global Queue, CurrentIndex, SkipEmpty, History

    ; Save to history before loading new
    if (Queue.Length > 0) {
        AddToHistory()
    }

    Queue := []
    CurrentIndex := 1

    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")

    for line in StrSplit(text, "`n") {
        if (SkipEmpty) {
            line := Trim(line)
            if (line) {
                Queue.Push(line)
            }
        } else {
            Queue.Push(line)
        }
    }

    RefreshUI()
    ShowToast(GetText("msgLoaded", Queue.Length))
    SoundBeep 1200, 80
}

LoadFromManual(*) {
    global EdtInput
    text := EdtInput.Value
    if (text) {
        LoadQueue(text)
        EdtInput.Value := ""
    }
}

; ============ LOAD FROM FILE ============
LoadFromFile(*) {
    global MainGui, ChkOnTop

    MainGui.Opt("-AlwaysOnTop")
    filePath := FileSelect(1,, "Select text file", "Text Files (*.txt; *.csv; *.tsv)")

    if (ChkOnTop.Value) {
        MainGui.Opt("+AlwaysOnTop")
    }

    if (!filePath) {
        return
    }

    try {
        content := FileRead(filePath, "UTF-8")
        if (!content) {
            content := FileRead(filePath)
        }
        if (content) {
            LoadQueue(content)
        }
    } catch as err {
        ShowToast("Error: " err.Message)
    }
}

; ============ CLIPBOARD HISTORY ============
AddToHistory() {
    global History, Queue

    if (Queue.Length = 0) {
        return
    }

    ; Build label: "5 items: val1, val2, val3..."
    label := Queue.Length " items: "
    preview := ""
    maxItems := (Queue.Length < 3) ? Queue.Length : 3
    Loop maxItems {
        if (A_Index > 1) {
            preview := preview ", "
        }
        item := Queue[A_Index]
        if (StrLen(item) > 15) {
            item := SubStr(item, 1, 15) ".."
        }
        preview := preview item
    }
    label := label preview

    ; Store as Map with label and data
    entry := Map()
    entry["label"] := label
    entry["data"] := []
    for item in Queue {
        entry["data"].Push(item)
    }

    ; Add to front, keep max 10
    History.InsertAt(1, entry)
    if (History.Length > 10) {
        History.Pop()
    }
}

ShowHistory(*) {
    global History, Lang

    if (History.Length = 0) {
        ShowToast(GetText("noHistory"))
        return
    }

    HistGui := Gui("+AlwaysOnTop +ToolWindow -Resize", GetText("history"))
    HistGui.SetFont("s9", "Segoe UI")

    HistGui.Add("Text", "x15 y10 w320 h20", (Lang = "vi") ? "Chọn bộ dữ liệu để nạp lại:" : "Select a data set to reload:")

    LB := HistGui.Add("ListBox", "x15 y35 w320 h200")
    for entry in History {
        LB.Add([entry["label"]])
    }
    if (History.Length > 0) {
        LB.Choose(1)
    }

    BtnLoad := HistGui.Add("Button", "x15 y245 w150 h30", (Lang = "vi") ? "Nạp lại" : "Load")
    BtnLoad.SetFont("s9 Bold")
    BtnLoad.OnEvent("Click", LoadFromHistory.Bind(HistGui, LB))

    BtnCancel := HistGui.Add("Button", "x175 y245 w160 h30", (Lang = "vi") ? "Đóng" : "Close")
    BtnCancel.OnEvent("Click", (*) => HistGui.Destroy())

    HistGui.Show("w350 h285")
}

LoadFromHistory(histGui, lb, *) {
    global Queue, CurrentIndex, History

    idx := lb.Value
    if (!idx || idx < 1 || idx > History.Length) {
        return
    }

    entry := History[idx]
    Queue := []
    CurrentIndex := 1
    for item in entry["data"] {
        Queue.Push(item)
    }

    histGui.Destroy()
    RefreshUI()
    ShowToast(GetText("msgLoaded", Queue.Length))
    SoundBeep 1200, 80
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

; ============ TOGGLE ENABLED ============
ToggleEnabled(*) {
    global IsEnabled, BtnToggle
    IsEnabled := !IsEnabled
    UpdateToggleButton()
    if (IsEnabled) {
        SetupHotkeys()
        ShowToast("✅ Smart Paste ON")
        SoundBeep 1200, 80
    } else {
        ; Disable paste/back/auto hotkeys (keep toggle key active!)
        try Hotkey("$" PasteKey, "Off")
        try Hotkey("$" BackKey, "Off")
        try Hotkey("$" AutoKey, "Off")
        if (IsAutoPasting) {
            StopAutoPaste()
        }
        ShowToast("❌ Smart Paste OFF")
        SoundBeep 600, 100
    }
}

UpdateToggleButton() {
    global BtnToggle, IsEnabled, MainGui
    if (IsEnabled) {
        BtnToggle.Text := GetText("enabled")
        BtnToggle.Opt("c16A34A")  ; Green text
        ; Green H icon (default AHK icon)
        try TraySetIcon(A_AhkPath, 1)
        A_IconTip := GetText("title") " — ON"
        try MainGui.Title := GetText("title") "  ✅"
    } else {
        BtnToggle.Text := GetText("disabled")
        BtnToggle.Opt("cDC2626")  ; Red text
        ; Muted H icon (paused AHK icon)
        try TraySetIcon(A_AhkPath, 2)
        A_IconTip := GetText("title") " — OFF"
        try MainGui.Title := GetText("title") "  ❌"
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
A_IconTip := GetText("title") " — ON"
