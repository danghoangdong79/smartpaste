# Smart Paste v0.3 - PowerShell Edition
# Sequential Clipboard Paster - Zero Install
# https://github.com/danghoangdong79/smartpaste
# MIT License - Copyright (c) 2026 Dahodo (DHD)
#
# USAGE: Right-click → Run with PowerShell
# OR: powershell -ExecutionPolicy Bypass -File SmartPaste.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============ Win32 API for Global Hotkeys ============
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class HotKeyHelper {
    [DllImport("user32.dll")]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
    [DllImport("user32.dll")]
    public static extern bool UnregisterHotKey(IntPtr hWnd, int id);
}
"@

# ============ SendInput API for reliable text input ============
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class SendInputHelper {
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        public uint type;
        public INPUTUNION u;
    }
    [StructLayout(LayoutKind.Explicit)]
    public struct INPUTUNION {
        [FieldOffset(0)] public KEYBDINPUT ki;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }
    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    public static void SendUnicodeString(string text) {
        foreach (char c in text) {
            INPUT[] inputs = new INPUT[2];
            // Key down
            inputs[0].type = 1; // INPUT_KEYBOARD
            inputs[0].u.ki.wVk = 0;
            inputs[0].u.ki.wScan = (ushort)c;
            inputs[0].u.ki.dwFlags = 0x0004; // KEYEVENTF_UNICODE
            // Key up
            inputs[1].type = 1;
            inputs[1].u.ki.wVk = 0;
            inputs[1].u.ki.wScan = (ushort)c;
            inputs[1].u.ki.dwFlags = 0x0004 | 0x0002; // UNICODE | KEYUP
            SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
        }
    }
}
"@

# ============ GLOBAL STATE ============
$script:Queue = @()
$script:CurrentIndex = 0
$script:LastClip = ""
$script:IsPasting = $false
$script:IsAutoPasting = $false
$script:PasteDelay = 0.1
$script:AutoSepKey = "Tab"

# Hotkey IDs
$HOTKEY_PASTE = 1
$HOTKEY_BACK  = 2
$HOTKEY_AUTO  = 3
# VK codes
$VK_F9  = 0x78
$VK_F10 = 0x79
$VK_F11 = 0x7A

# ============ HELPER FUNCTIONS ============
function Send-Text([string]$text) {
    [SendInputHelper]::SendUnicodeString($text)
}

function Send-Key([string]$key) {
    [System.Windows.Forms.SendKeys]::SendWait($key)
}

function Show-Toast([string]$msg) {
    $script:StatusLabel.Text = $msg
}

function Load-Queue([string]$text) {
    $lines = $text -split "`r?`n"
    $filtered = @()
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -ne "") {
            $filtered += $trimmed
        }
    }
    if ($filtered.Count -gt 1) {
        $script:Queue = $filtered
        $script:CurrentIndex = 0
        Refresh-UI
        Show-Toast ("Da nap " + $filtered.Count + " muc")
        [System.Media.SystemSounds]::Asterisk.Play()
    }
}

function Refresh-UI {
    $total = $script:Queue.Count
    if ($total -eq 0) {
        $script:CurrentLabel.Text = "Dang cho du lieu..."
        $script:CurrentLabel.ForeColor = [System.Drawing.Color]::Gray
        $script:ProgressBar.Value = 0
        $script:ProgressLabel.Text = "0 / 0"
        $script:PreviewLabel.Text = ""
        $script:StatusLabel.Text = "Copy nhieu dong de bat dau"
        $script:ListBox.Items.Clear()
        return
    }

    # Update listbox
    $script:ListBox.Items.Clear()
    for ($i = 0; $i -lt $total; $i++) {
        $prefix = "  "
        if ($i -eq $script:CurrentIndex) { $prefix = "▶ " }
        elseif ($i -lt $script:CurrentIndex) { $prefix = "✓ " }
        $display = $script:Queue[$i]
        if ($display.Length -gt 35) { $display = $display.Substring(0, 35) + "..." }
        $script:ListBox.Items.Add("$prefix$($i+1). $display") | Out-Null
    }
    if ($script:CurrentIndex -lt $script:ListBox.Items.Count) {
        $script:ListBox.SelectedIndex = $script:CurrentIndex
    }

    if ($script:CurrentIndex -lt $total) {
        $item = $script:Queue[$script:CurrentIndex]
        if ($item.Length -gt 40) { $item = $item.Substring(0, 40) + "..." }
        $script:CurrentLabel.Text = $item
        $script:CurrentLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#1E293B")

        # Preview
        $preview = ""
        if ($script:CurrentIndex + 1 -lt $total) {
            $p1 = $script:Queue[$script:CurrentIndex + 1]
            if ($p1.Length -gt 30) { $p1 = $p1.Substring(0, 30) + "..." }
            $preview = [char]0x2192 + " " + $p1
        }
        $script:PreviewLabel.Text = $preview
    } else {
        $script:CurrentLabel.Text = "Da hoan thanh!"
        $script:CurrentLabel.ForeColor = [System.Drawing.Color]::Green
        $script:PreviewLabel.Text = ""
    }

    $done = $script:CurrentIndex
    $pct = if ($total -gt 0) { [math]::Round($done / $total * 100) } else { 0 }
    $script:ProgressBar.Maximum = 100
    $script:ProgressBar.Value = $pct
    $script:ProgressLabel.Text = "$done / $total  ($pct%)"
    $remain = $total - $done
    $script:StatusLabel.Text = "Da dan $done/$total - Con $remain muc"
}

function Do-Paste {
    if ($script:Queue.Count -eq 0) { Show-Toast "Chua co du lieu"; return }
    if ($script:CurrentIndex -ge $script:Queue.Count) {
        if ($script:ChkLoop.Checked) {
            $script:CurrentIndex = 0
        } else {
            Show-Toast "Da hoan thanh!"
            [System.Media.SystemSounds]::Exclamation.Play()
            return
        }
    }

    $text = $script:Queue[$script:CurrentIndex]
    $script:CurrentIndex++
    $script:IsPasting = $true

    # Use SendInput for reliable text entry (bypasses clipboard)
    Send-Text $text

    Start-Sleep -Milliseconds 30
    $script:IsPasting = $false
    [System.Media.SystemSounds]::Asterisk.Play()
    Refresh-UI
}

function Do-Back {
    if ($script:Queue.Count -eq 0) { Show-Toast "Chua co du lieu"; return }
    if ($script:CurrentIndex -gt 0) {
        $script:CurrentIndex--
        $text = $script:Queue[$script:CurrentIndex]
        $script:IsPasting = $true
        Send-Text $text
        Start-Sleep -Milliseconds 30
        $script:IsPasting = $false
        [System.Media.SystemSounds]::Asterisk.Play()
        Refresh-UI
    } else {
        Show-Toast "Da o muc dau tien"
    }
}

function Do-Reset {
    $script:CurrentIndex = 0
    Refresh-UI
    Show-Toast "Reset!"
}

function Do-AutoPaste {
    if ($script:IsAutoPasting) {
        Stop-AutoPaste
        return
    }
    if ($script:Queue.Count -eq 0) { Show-Toast "Chua co du lieu"; return }
    if ($script:CurrentIndex -ge $script:Queue.Count) { Show-Toast "Da hoan thanh!"; return }

    # Read delay
    try { $script:PasteDelay = [double]$script:EdtDelay.Text } catch { $script:PasteDelay = 0.1 }
    $delayMs = [math]::Max(50, [math]::Round($script:PasteDelay * 1000))

    # Read separator
    $sep = $script:DdlSep.SelectedItem
    $sepKey = switch ($sep) {
        "Enter" { "{ENTER}" }
        "Space" { " " }
        default { "{TAB}" }
    }

    $script:IsAutoPasting = $true
    $script:IsPasting = $true
    $script:BtnAuto.Text = [char]0x23F9 + " STOP"
    $script:BtnAuto.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444")
    Show-Toast "Dang tu dong dan... (Click STOP de dung)"

    $script:AutoTimer.Tag = @{ DelayMs = $delayMs; SepKey = $sepKey }
    $script:AutoTimer.Interval = 1
    $script:AutoTimer.Start()
}

function AutoPaste-Tick {
    $tag = $script:AutoTimer.Tag
    $delayMs = $tag.DelayMs
    $sepKey = $tag.SepKey

    if (-not $script:IsAutoPasting -or $script:CurrentIndex -ge $script:Queue.Count) {
        if ($script:CurrentIndex -ge $script:Queue.Count -and $script:IsAutoPasting) {
            Show-Toast "Tu dong dan xong!"
            [System.Media.SystemSounds]::Exclamation.Play()
        }
        Stop-AutoPaste
        return
    }

    $script:AutoTimer.Stop()

    $text = $script:Queue[$script:CurrentIndex]
    $script:CurrentIndex++

    # Send text directly (no clipboard)
    Send-Text $text
    Start-Sleep -Milliseconds 30

    Refresh-UI

    # Send separator + schedule next
    if ($script:CurrentIndex -lt $script:Queue.Count -and $script:IsAutoPasting) {
        Send-Key $sepKey
        Start-Sleep -Milliseconds 30
        $script:AutoTimer.Interval = $delayMs
        $script:AutoTimer.Start()
    } else {
        if ($script:CurrentIndex -ge $script:Queue.Count) {
            Show-Toast "Tu dong dan xong!"
            [System.Media.SystemSounds]::Exclamation.Play()
        }
        Stop-AutoPaste
    }
}

function Stop-AutoPaste {
    $script:IsAutoPasting = $false
    $script:IsPasting = $false
    $script:AutoTimer.Stop()
    $script:BtnAuto.Text = [char]0x26A1 + " Tu dong"
    $script:BtnAuto.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7C3AED")
    Refresh-UI
}

function Load-FromManual {
    $text = $script:EdtInput.Text.Trim()
    if ($text -ne "") {
        Load-Queue $text
        $script:EdtInput.Text = ""
    }
}

function Load-FromFile {
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Text files (*.txt)|*.txt|CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    $ofd.Title = "Chon file du lieu"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $content = [System.IO.File]::ReadAllText($ofd.FileName, [System.Text.Encoding]::UTF8)
            Load-Queue $content
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Khong doc duoc file: $_", "Loi", "OK", "Error")
        }
    }
}

function Check-Clipboard {
    if ($script:IsPasting) { return }
    try {
        if ([System.Windows.Forms.Clipboard]::ContainsText()) {
            $current = [System.Windows.Forms.Clipboard]::GetText()
            if ($current -and $current -ne $script:LastClip) {
                if ($current -match "`n") {
                    $script:LastClip = $current
                    Load-Queue $current
                }
            }
        }
    } catch { }
}

# ============ BUILD GUI ============
$form = New-Object System.Windows.Forms.Form
$form.Text = "Smart Paste v0.3 - PowerShell"
$form.Size = New-Object System.Drawing.Size(460, 620)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#F1F5F9")
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# ---- Status Bar ----
$script:StatusLabel = New-Object System.Windows.Forms.Label
$script:StatusLabel.Location = New-Object System.Drawing.Point(15, 12)
$script:StatusLabel.Size = New-Object System.Drawing.Size(420, 24)
$script:StatusLabel.TextAlign = "MiddleCenter"
$script:StatusLabel.Text = "Copy nhieu dong de bat dau"
$script:StatusLabel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#E0F2FE")
$script:StatusLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0369A1")
$script:StatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($script:StatusLabel)

# ---- Current Item ----
$script:CurrentLabel = New-Object System.Windows.Forms.Label
$script:CurrentLabel.Location = New-Object System.Drawing.Point(15, 42)
$script:CurrentLabel.Size = New-Object System.Drawing.Size(420, 30)
$script:CurrentLabel.TextAlign = "MiddleCenter"
$script:CurrentLabel.Text = "Dang cho du lieu..."
$script:CurrentLabel.ForeColor = [System.Drawing.Color]::Gray
$script:CurrentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($script:CurrentLabel)

# ---- Progress Bar ----
$script:ProgressBar = New-Object System.Windows.Forms.ProgressBar
$script:ProgressBar.Location = New-Object System.Drawing.Point(15, 78)
$script:ProgressBar.Size = New-Object System.Drawing.Size(420, 10)
$script:ProgressBar.Style = "Continuous"
$form.Controls.Add($script:ProgressBar)

$script:ProgressLabel = New-Object System.Windows.Forms.Label
$script:ProgressLabel.Location = New-Object System.Drawing.Point(15, 90)
$script:ProgressLabel.Size = New-Object System.Drawing.Size(420, 16)
$script:ProgressLabel.TextAlign = "MiddleCenter"
$script:ProgressLabel.Text = "0 / 0"
$script:ProgressLabel.ForeColor = [System.Drawing.Color]::Gray
$script:ProgressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$form.Controls.Add($script:ProgressLabel)

# ---- Preview ----
$script:PreviewLabel = New-Object System.Windows.Forms.Label
$script:PreviewLabel.Location = New-Object System.Drawing.Point(15, 108)
$script:PreviewLabel.Size = New-Object System.Drawing.Size(420, 18)
$script:PreviewLabel.ForeColor = [System.Drawing.Color]::Gray
$script:PreviewLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$form.Controls.Add($script:PreviewLabel)

# ---- Queue ListBox ----
$script:ListBox = New-Object System.Windows.Forms.ListBox
$script:ListBox.Location = New-Object System.Drawing.Point(15, 130)
$script:ListBox.Size = New-Object System.Drawing.Size(420, 130)
$script:ListBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$script:ListBox.BackColor = [System.Drawing.Color]::White
$script:ListBox.BorderStyle = "FixedSingle"
$form.Controls.Add($script:ListBox)

# ---- Action Buttons ----
$btnPaste = New-Object System.Windows.Forms.Button
$btnPaste.Location = New-Object System.Drawing.Point(15, 268)
$btnPaste.Size = New-Object System.Drawing.Size(140, 40)
$btnPaste.Text = [char]0x25B6 + " DAN (F9)"
$btnPaste.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#22C55E")
$btnPaste.ForeColor = [System.Drawing.Color]::White
$btnPaste.FlatStyle = "Flat"
$btnPaste.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnPaste.Add_Click({ Do-Paste })
$form.Controls.Add($btnPaste)

$btnBack = New-Object System.Windows.Forms.Button
$btnBack.Location = New-Object System.Drawing.Point(162, 268)
$btnBack.Size = New-Object System.Drawing.Size(110, 40)
$btnBack.Text = [char]0x25C0 + " LUI (F10)"
$btnBack.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3B82F6")
$btnBack.ForeColor = [System.Drawing.Color]::White
$btnBack.FlatStyle = "Flat"
$btnBack.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnBack.Add_Click({ Do-Back })
$form.Controls.Add($btnBack)

$btnReset = New-Object System.Windows.Forms.Button
$btnReset.Location = New-Object System.Drawing.Point(279, 268)
$btnReset.Size = New-Object System.Drawing.Size(75, 40)
$btnReset.Text = [char]0x21BA + " Reset"
$btnReset.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#F59E0B")
$btnReset.ForeColor = [System.Drawing.Color]::White
$btnReset.FlatStyle = "Flat"
$btnReset.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnReset.Add_Click({ Do-Reset })
$form.Controls.Add($btnReset)

$btnFile = New-Object System.Windows.Forms.Button
$btnFile.Location = New-Object System.Drawing.Point(361, 268)
$btnFile.Size = New-Object System.Drawing.Size(75, 40)
$btnFile.Text = [char]0x1F4C2 + " File"
$btnFile.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#64748B")
$btnFile.ForeColor = [System.Drawing.Color]::White
$btnFile.FlatStyle = "Flat"
$btnFile.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnFile.Add_Click({ Load-FromFile })
$form.Controls.Add($btnFile)

# ---- Advanced Section ----
$grpAdvanced = New-Object System.Windows.Forms.GroupBox
$grpAdvanced.Location = New-Object System.Drawing.Point(15, 318)
$grpAdvanced.Size = New-Object System.Drawing.Size(420, 100)
$grpAdvanced.Text = "Nang cao"
$form.Controls.Add($grpAdvanced)

# Delay
$lblDelay = New-Object System.Windows.Forms.Label
$lblDelay.Location = New-Object System.Drawing.Point(10, 25)
$lblDelay.Size = New-Object System.Drawing.Size(45, 20)
$lblDelay.Text = "Nghi:"
$grpAdvanced.Controls.Add($lblDelay)

$script:EdtDelay = New-Object System.Windows.Forms.TextBox
$script:EdtDelay.Location = New-Object System.Drawing.Point(55, 22)
$script:EdtDelay.Size = New-Object System.Drawing.Size(45, 22)
$script:EdtDelay.Text = "0.1"
$grpAdvanced.Controls.Add($script:EdtDelay)

$lblSec = New-Object System.Windows.Forms.Label
$lblSec.Location = New-Object System.Drawing.Point(103, 25)
$lblSec.Size = New-Object System.Drawing.Size(35, 20)
$lblSec.Text = "giay"
$lblSec.ForeColor = [System.Drawing.Color]::Gray
$grpAdvanced.Controls.Add($lblSec)

# Separator
$lblSep = New-Object System.Windows.Forms.Label
$lblSep.Location = New-Object System.Drawing.Point(150, 25)
$lblSep.Size = New-Object System.Drawing.Size(80, 20)
$lblSep.Text = "Ngan cach:"
$grpAdvanced.Controls.Add($lblSep)

$script:DdlSep = New-Object System.Windows.Forms.ComboBox
$script:DdlSep.Location = New-Object System.Drawing.Point(230, 22)
$script:DdlSep.Size = New-Object System.Drawing.Size(70, 22)
$script:DdlSep.DropDownStyle = "DropDownList"
$script:DdlSep.Items.AddRange(@("Tab", "Enter", "Space"))
$script:DdlSep.SelectedIndex = 0
$grpAdvanced.Controls.Add($script:DdlSep)

# Loop checkbox
$script:ChkLoop = New-Object System.Windows.Forms.CheckBox
$script:ChkLoop.Location = New-Object System.Drawing.Point(320, 24)
$script:ChkLoop.Size = New-Object System.Drawing.Size(90, 20)
$script:ChkLoop.Text = "Lap lai"
$grpAdvanced.Controls.Add($script:ChkLoop)

# Auto-paste button
$script:BtnAuto = New-Object System.Windows.Forms.Button
$script:BtnAuto.Location = New-Object System.Drawing.Point(10, 55)
$script:BtnAuto.Size = New-Object System.Drawing.Size(130, 35)
$script:BtnAuto.Text = [char]0x26A1 + " Tu dong"
$script:BtnAuto.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7C3AED")
$script:BtnAuto.ForeColor = [System.Drawing.Color]::White
$script:BtnAuto.FlatStyle = "Flat"
$script:BtnAuto.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$script:BtnAuto.Add_Click({ Do-AutoPaste })
$grpAdvanced.Controls.Add($script:BtnAuto)

# Auto info label
$lblAutoInfo = New-Object System.Windows.Forms.Label
$lblAutoInfo.Location = New-Object System.Drawing.Point(150, 62)
$lblAutoInfo.Size = New-Object System.Drawing.Size(260, 20)
$lblAutoInfo.Text = "F11 hoac click de bat/tat tu dong dan"
$lblAutoInfo.ForeColor = [System.Drawing.Color]::Gray
$lblAutoInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$grpAdvanced.Controls.Add($lblAutoInfo)

# ---- Manual Input ----
$grpInput = New-Object System.Windows.Forms.GroupBox
$grpInput.Location = New-Object System.Drawing.Point(15, 425)
$grpInput.Size = New-Object System.Drawing.Size(420, 70)
$grpInput.Text = "Nhap thu cong"
$form.Controls.Add($grpInput)

$script:EdtInput = New-Object System.Windows.Forms.TextBox
$script:EdtInput.Location = New-Object System.Drawing.Point(10, 22)
$script:EdtInput.Size = New-Object System.Drawing.Size(300, 35)
$script:EdtInput.Multiline = $true
$script:EdtInput.ScrollBars = "Vertical"
$grpInput.Controls.Add($script:EdtInput)

$btnLoad = New-Object System.Windows.Forms.Button
$btnLoad.Location = New-Object System.Drawing.Point(318, 22)
$btnLoad.Size = New-Object System.Drawing.Size(90, 35)
$btnLoad.Text = "Nap du lieu"
$btnLoad.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#6366F1")
$btnLoad.ForeColor = [System.Drawing.Color]::White
$btnLoad.FlatStyle = "Flat"
$btnLoad.Add_Click({ Load-FromManual })
$grpInput.Controls.Add($btnLoad)

# ---- Options Row ----
$chkOnTop = New-Object System.Windows.Forms.CheckBox
$chkOnTop.Location = New-Object System.Drawing.Point(15, 505)
$chkOnTop.Size = New-Object System.Drawing.Size(130, 20)
$chkOnTop.Text = "Luon hien tren cung"
$chkOnTop.Checked = $true
$chkOnTop.Add_CheckedChanged({ $form.TopMost = $chkOnTop.Checked })
$form.Controls.Add($chkOnTop)

# ---- Footer ----
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Location = New-Object System.Drawing.Point(15, 535)
$lblFooter.Size = New-Object System.Drawing.Size(420, 25)
$lblFooter.TextAlign = "MiddleCenter"
$lblFooter.Text = "Smart Paste v0.3 - PowerShell Edition | (c) 2026 Dahodo (DHD)"
$lblFooter.ForeColor = [System.Drawing.Color]::Gray
$lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$form.Controls.Add($lblFooter)

$lblHotkey = New-Object System.Windows.Forms.Label
$lblHotkey.Location = New-Object System.Drawing.Point(15, 555)
$lblHotkey.Size = New-Object System.Drawing.Size(420, 18)
$lblHotkey.TextAlign = "MiddleCenter"
$lblHotkey.Text = "Phim tat: F9 = Dan | F10 = Lui | F11 = Tu dong"
$lblHotkey.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0369A1")
$lblHotkey.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblHotkey)

# ============ TIMERS ============
# Clipboard monitor
$clipTimer = New-Object System.Windows.Forms.Timer
$clipTimer.Interval = 300
$clipTimer.Add_Tick({ Check-Clipboard })
$clipTimer.Start()

# Auto-paste timer
$script:AutoTimer = New-Object System.Windows.Forms.Timer
$script:AutoTimer.Add_Tick({ AutoPaste-Tick })

# ============ GLOBAL HOTKEYS ============
# Register on form load
$form.Add_Load({
    [HotKeyHelper]::RegisterHotKey($form.Handle, $HOTKEY_PASTE, 0, $VK_F9) | Out-Null
    [HotKeyHelper]::RegisterHotKey($form.Handle, $HOTKEY_BACK, 0, $VK_F10) | Out-Null
    [HotKeyHelper]::RegisterHotKey($form.Handle, $HOTKEY_AUTO, 0, $VK_F11) | Out-Null
})

# Cleanup on close
$form.Add_FormClosing({
    [HotKeyHelper]::UnregisterHotKey($form.Handle, $HOTKEY_PASTE) | Out-Null
    [HotKeyHelper]::UnregisterHotKey($form.Handle, $HOTKEY_BACK) | Out-Null
    [HotKeyHelper]::UnregisterHotKey($form.Handle, $HOTKEY_AUTO) | Out-Null
    $clipTimer.Stop()
    $script:AutoTimer.Stop()
})

# Override WndProc to catch hotkey messages
# We use a message filter instead
$messageFilter = New-Object System.Windows.Forms.Timer
$messageFilter.Interval = 50

# Alternative: Use a NativeWindow subclass for WM_HOTKEY
Add-Type @"
using System;
using System.Windows.Forms;
public class HotKeyWindow : NativeWindow {
    public event EventHandler<int> HotKeyPressed;
    private const int WM_HOTKEY = 0x0312;

    public HotKeyWindow(IntPtr handle) {
        this.AssignHandle(handle);
    }

    protected override void WndProc(ref Message m) {
        if (m.Msg == WM_HOTKEY) {
            int id = m.WParam.ToInt32();
            if (HotKeyPressed != null)
                HotKeyPressed(this, id);
        }
        base.WndProc(ref m);
    }
}
"@

$form.Add_Shown({
    $hkWin = New-Object HotKeyWindow($form.Handle)
    $hkWin.add_HotKeyPressed({
        param($sender, $id)
        switch ($id) {
            1 { Do-Paste }
            2 { Do-Back }
            3 { Do-AutoPaste }
        }
    })
})

# ============ RUN ============
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
