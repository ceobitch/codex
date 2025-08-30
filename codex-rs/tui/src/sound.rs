use std::path::PathBuf;
use std::process::Command;

/// Play sound effects for Nova Shield interactions
pub(crate) struct SoundManager {
    sound_dir: PathBuf,
}

impl SoundManager {
    pub(crate) fn new() -> Self {
        // Sound files are in the project root/sound directory
        let sound_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .parent()
            .map(|p| p.join("sound"))
            .unwrap_or_else(|| PathBuf::from("../sound"));
        
        tracing::debug!("Sound directory: {:?}", sound_dir);
        Self { sound_dir }
    }

    /// Play sound when user sends a message
    pub(crate) fn play_sent(&self) {
        self.play_sound("sent.mp3");
    }

    /// Play sound when Nova responds
    pub(crate) fn play_received(&self) {
        self.play_sound("received.mp3");
    }

    /// Play sound for errors
    pub(crate) fn play_error(&self) {
        self.play_sound("error.mp3");
    }

    fn play_sound(&self, filename: &str) {
        let sound_path = self.sound_dir.join(filename);
        
        if !sound_path.exists() {
            tracing::debug!("Sound file not found: {:?}", sound_path);
            return;
        }

        // Play sound in background without blocking
        let sound_path_clone = sound_path.clone();
        std::thread::spawn(move || {
            #[cfg(target_os = "macos")]
            {
                let _ = Command::new("afplay")
                    .arg(&sound_path_clone)
                    .output();
            }
            
            #[cfg(target_os = "linux")]
            {
                // Try different audio players
                for player in &["paplay", "aplay", "mpg123", "mpv"] {
                    if Command::new("which")
                        .arg(player)
                        .output()
                        .map(|o| o.status.success())
                        .unwrap_or(false)
                    {
                        let _ = Command::new(player)
                            .arg(&sound_path_clone)
                            .output();
                        break;
                    }
                }
            }
        });
    }
}
