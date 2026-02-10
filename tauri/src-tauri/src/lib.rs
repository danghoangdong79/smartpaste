use std::process::Command;
use std::sync::Mutex;
use tauri::State;

struct AhkState {
    pid: Mutex<Option<u32>>,
}

#[tauri::command]
fn launch_ahk(state: State<AhkState>) -> Result<String, String> {
    let mut pid_lock = state.pid.lock().map_err(|e| e.to_string())?;

    // Already running?
    if let Some(pid) = *pid_lock {
        if is_process_running(pid) {
            return Ok(format!("Already running (PID: {})", pid));
        }
    }

    // Find the AHK script path relative to exe
    let ahk_exe = r"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe";
    
    // The script is in ../ahk/ relative to the tauri project
    // At runtime we resolve relative to the exe location
    let script_path = resolve_ahk_script_path();

    let child = Command::new(ahk_exe)
        .arg(&script_path)
        .spawn()
        .map_err(|e| format!("Failed to launch AHK: {}", e))?;

    let child_pid = child.id();
    *pid_lock = Some(child_pid);

    Ok(format!("Launched (PID: {})", child_pid))
}

#[tauri::command]
fn kill_ahk(state: State<AhkState>) -> Result<String, String> {
    let mut pid_lock = state.pid.lock().map_err(|e| e.to_string())?;

    if let Some(pid) = *pid_lock {
        // Kill by PID
        let _ = Command::new("taskkill")
            .args(["/PID", &pid.to_string(), "/F"])
            .output();
        *pid_lock = None;
        Ok("Stopped".to_string())
    } else {
        // Try to kill any running SmartPaste.ahk by window title
        let _ = Command::new("taskkill")
            .args(["/FI", "WINDOWTITLE eq Smart Paste*", "/F"])
            .output();
        Ok("Stopped".to_string())
    }
}

#[tauri::command]
fn check_ahk_status(state: State<AhkState>) -> bool {
    let pid_lock = state.pid.lock().unwrap();
    if let Some(pid) = *pid_lock {
        is_process_running(pid)
    } else {
        // Check if any AutoHotkey is running with our script
        is_ahk_script_running()
    }
}

fn is_process_running(pid: u32) -> bool {
    let output = Command::new("tasklist")
        .args(["/FI", &format!("PID eq {}", pid), "/NH"])
        .output();

    match output {
        Ok(o) => {
            let stdout = String::from_utf8_lossy(&o.stdout);
            stdout.contains(&pid.to_string())
        }
        Err(_) => false,
    }
}

fn is_ahk_script_running() -> bool {
    let output = Command::new("tasklist")
        .args(["/FI", "IMAGENAME eq AutoHotkey64.exe", "/NH"])
        .output();

    match output {
        Ok(o) => {
            let stdout = String::from_utf8_lossy(&o.stdout);
            stdout.contains("AutoHotkey64.exe")
        }
        Err(_) => false,
    }
}

fn resolve_ahk_script_path() -> String {
    // Try multiple possible locations
    let candidates = vec![
        // Dev: relative to the project
        std::env::current_dir()
            .map(|p| p.join("..").join("ahk").join("SmartPaste.ahk"))
            .unwrap_or_default(),
        // Relative to exe
        std::env::current_exe()
            .map(|p| {
                p.parent()
                    .unwrap_or(std::path::Path::new("."))
                    .join("..") 
                    .join("ahk")
                    .join("SmartPaste.ahk")
            })
            .unwrap_or_default(),
        // Absolute fallback - Desktop path
        std::path::PathBuf::from(r"C:\Users\dangh\Desktop\Multi-paste\ahk\SmartPaste.ahk"),
    ];

    for candidate in candidates {
        if candidate.exists() {
            return candidate.to_string_lossy().to_string();
        }
    }

    // Last resort
    r"C:\Users\dangh\Desktop\Multi-paste\ahk\SmartPaste.ahk".to_string()
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(AhkState {
            pid: Mutex::new(None),
        })
        .invoke_handler(tauri::generate_handler![
            launch_ahk,
            kill_ahk,
            check_ahk_status
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
