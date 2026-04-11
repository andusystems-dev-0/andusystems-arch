// dock — minimal ratatui dock for system controls.
//
// Dock view:    a single icon (display settings). Enter opens it, q/Esc quits.
// Display view: three stacked slider bars — brightness, gamma, warmth.
//               j/k moves between bars, h/l adjusts the active bar,
//               Esc/q returns to the dock.

use std::process::{Command, Stdio};

use color_eyre::eyre::Result;
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::{
    DefaultTerminal, Frame,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Modifier, Style},
    widgets::{Gauge, Paragraph},
};

#[derive(Clone, Copy)]
enum Kind {
    Brightness, // brightnessctl set N%
    Gamma,      // hyprctl hyprsunset gamma N
    Warmth,     // hyprctl hyprsunset temperature N (Kelvin)
}

#[derive(Clone, Copy)]
struct Slider {
    min: u32,
    max: u32,
    step: u32,
    kind: Kind,
}

// Top-to-bottom render order in the display view.
const SLIDERS: [Slider; 3] = [
    Slider { min: 5,    max: 100,  step: 5,   kind: Kind::Brightness },
    Slider { min: 10,   max: 100,  step: 5,   kind: Kind::Gamma },
    Slider { min: 1000, max: 6500, step: 250, kind: Kind::Warmth },
];

enum View {
    Dock,
    Display,
}

struct App {
    view: View,
    selected: usize, // active slider in the display view
    values: [u32; 3],
}

impl App {
    fn new() -> Self {
        let mut values = [0u32; 3];
        for (i, s) in SLIDERS.iter().enumerate() {
            values[i] = (s.min + s.max) / 2;
        }
        Self { view: View::Dock, selected: 0, values }
    }
}

fn main() -> Result<()> {
    color_eyre::install()?;
    let terminal = ratatui::init();
    let result = run(terminal);
    ratatui::restore();
    result
}

fn run(mut terminal: DefaultTerminal) -> Result<()> {
    let mut app = App::new();
    loop {
        terminal.draw(|f| draw(f, &app))?;

        let Event::Key(key) = event::read()? else { continue };
        if key.kind != KeyEventKind::Press {
            continue;
        }

        match app.view {
            View::Dock => match key.code {
                KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
                KeyCode::Enter => app.view = View::Display,
                _ => {}
            },
            View::Display => match key.code {
                KeyCode::Char('q') | KeyCode::Esc => app.view = View::Dock,
                KeyCode::Char('j') | KeyCode::Down => {
                    app.selected = (app.selected + 1).min(SLIDERS.len() - 1);
                }
                KeyCode::Char('k') | KeyCode::Up => {
                    app.selected = app.selected.saturating_sub(1);
                }
                KeyCode::Char('h') | KeyCode::Left  => adjust(&mut app, -1),
                KeyCode::Char('l') | KeyCode::Right => adjust(&mut app,  1),
                _ => {}
            },
        }
    }
}

// Step the active slider by ±step, clamp to its range, then push to the system.
fn adjust(app: &mut App, dir: i32) {
    let i = app.selected;
    let s = SLIDERS[i];
    let next = (app.values[i] as i32 + dir * s.step as i32)
        .clamp(s.min as i32, s.max as i32) as u32;
    app.values[i] = next;
    apply(s.kind, next);
}

// Shell out to apply a value. Stdio is silenced so command output (e.g. the
// "ok" reply from hyprctl) doesn't bleed onto the ratatui canvas. Errors are
// intentionally ignored.
fn apply(kind: Kind, value: u32) {
    let (program, args): (&str, Vec<String>) = match kind {
        Kind::Brightness => ("brightnessctl", vec!["set".into(), format!("{value}%")]),
        Kind::Gamma      => ("hyprctl", vec!["hyprsunset".into(), "gamma".into(), value.to_string()]),
        Kind::Warmth     => ("hyprctl", vec!["hyprsunset".into(), "temperature".into(), value.to_string()]),
    };
    let _ = Command::new(program)
        .args(args)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status();
}

fn draw(frame: &mut Frame, app: &App) {
    match app.view {
        View::Dock    => draw_dock(frame),
        View::Display => draw_display(frame, app),
    }
}

// Just the display-settings icon, centered and highlighted.
fn draw_dock(frame: &mut Frame) {
    let area = center(frame.area(), 3, 1);
    let icon = Paragraph::new("⚙")
        .style(Style::default().add_modifier(Modifier::REVERSED));
    frame.render_widget(icon, area);
}

// Three stacked slider bars: no borders, no labels, no values. The active
// bar renders normally; inactive bars are dimmed.
fn draw_display(frame: &mut Frame, app: &App) {
    // Three 1-row bars separated by 1-row spacers → total height 5.
    let area = center(frame.area(), 40, 5);
    let rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(1),
            Constraint::Length(1),
            Constraint::Length(1),
            Constraint::Length(1),
            Constraint::Length(1),
        ])
        .split(area);

    for (i, s) in SLIDERS.iter().enumerate() {
        let v = app.values[i];
        let ratio = (v - s.min) as f64 / (s.max - s.min) as f64;

        let style = if i == app.selected {
            Style::default()
        } else {
            Style::default().add_modifier(Modifier::DIM)
        };

        let gauge = Gauge::default()
            .ratio(ratio.clamp(0.0, 1.0))
            .label("")
            .gauge_style(style);

        // rows[0], rows[2], rows[4] — odd rows are blank spacers.
        frame.render_widget(gauge, rows[i * 2]);
    }
}

// Centered Rect of (width, height) inside `area`.
fn center(area: Rect, width: u16, height: u16) -> Rect {
    let w = width.min(area.width);
    let h = height.min(area.height);
    Rect {
        x: area.x + (area.width - w) / 2,
        y: area.y + (area.height - h) / 2,
        width: w,
        height: h,
    }
}
