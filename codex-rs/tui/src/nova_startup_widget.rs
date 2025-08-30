use std::time::Duration;
use std::time::Instant;

use ratatui::buffer::Buffer;
use ratatui::layout::Rect;
use ratatui::style::Color;
use ratatui::style::Style;
use ratatui::style::Stylize;
use ratatui::text::Line;
use ratatui::text::Span;
use ratatui::widgets::Widget;
use ratatui::widgets::WidgetRef;

use crate::shimmer::shimmer_spans;
use crate::tui::FrameRequester;

pub(crate) struct NovaStartupWidget {
    start_time: Instant,
    frame_requester: FrameRequester,
}

impl NovaStartupWidget {
    pub(crate) fn new(frame_requester: FrameRequester) -> Self {
        Self {
            start_time: Instant::now(),
            frame_requester,
        }
    }

    pub fn desired_height(&self, _width: u16) -> u16 {
        1
    }
}

impl WidgetRef for NovaStartupWidget {
    fn render_ref(&self, area: Rect, buf: &mut Buffer) {
        if area.is_empty() {
            return;
        }

        // Schedule next animation frame.
        self.frame_requester
            .schedule_frame_in(Duration::from_millis(32));
        let elapsed = self.start_time.elapsed().as_secs();

        // ORCA braille spinner
        const ORCA_FRAMES: &[char] = &['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
        let spinner_idx = ((self.start_time.elapsed().as_millis() / 100) as usize) % ORCA_FRAMES.len();
        let spinner_char = ORCA_FRAMES[spinner_idx];

        // Orange color theme
        let orange = Color::Rgb(255, 165, 0);
        
        // Build animated line with ORCA spinner + wave text
        let mut spans = vec![
            " ".into(),
            Span::styled(format!("{spinner_char}"), Style::default().fg(orange)),
            "  ".into(),
        ];
        
        // Add shimmering "Nova Shield" text
        spans.extend(shimmer_spans("Nova Shield"));
        spans.extend(vec![
            "  ".into(),
            "booting up...".dim(),
        ]);

        let line = Line::from(spans);
        line.render_ref(area, buf);
    }
}
