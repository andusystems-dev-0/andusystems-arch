// A very simple ratatui app launcher.
//
// Pick an entry with j/k (or arrow keys), press Enter to spawn it, q/Esc to quit.
// Add or remove entries by editing the APPS array below.

use std::os::unix::process::CommandExt;
use std::process::{Command, Stdio};

use color_eyre::eyre::Result;
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::{
    DefaultTerminal, Frame,
    style::{Modifier, Style},
    widgets::{Block, Borders, List, ListItem, ListState},
};

// (label shown in the UI, command to run)
const APPS: &[(&str, &str)] = &[
    ("Zen Browser",  "zen-browser"),
    ("Kitty",        "kitty"),
    ("Neovim",       "kitty -e nvim"),
    ("File Manager", "nautilus"),
];

fn main() -> Result<()> {
    color_eyre::install()?;
    let terminal = ratatui::init();
    let result = run(terminal);
    ratatui::restore();
    result
}

fn run(mut terminal: DefaultTerminal) -> Result<()> {
    let mut state = ListState::default();
    state.select(Some(0));

    loop {
        terminal.draw(|frame| draw(frame, &mut state))?;

        // Block until the next input event, then handle it.
        let Event::Key(key) = event::read()? else { continue };
        if key.kind != KeyEventKind::Press {
            continue;
        }

        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
            KeyCode::Down | KeyCode::Char('j') => move_selection(&mut state, 1),
            KeyCode::Up   | KeyCode::Char('k') => move_selection(&mut state, -1),
            KeyCode::Enter | KeyCode::Char('l') => {
                if let Some(i) = state.selected() {
                    launch(APPS[i].1);
                    return Ok(());
                }
            }
            _ => {}
        }
    }
}

fn draw(frame: &mut Frame, state: &mut ListState) {
    let items: Vec<ListItem> = APPS
        .iter()
        .map(|(label, _)| ListItem::new(*label))
        .collect();

    let list = List::new(items)
        .block(Block::default().title(" Launcher ").borders(Borders::ALL))
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED))
        .highlight_symbol("> ");

    frame.render_stateful_widget(list, frame.area(), state);
}

fn move_selection(state: &mut ListState, delta: isize) {
    let n = APPS.len() as isize;
    let current = state.selected().unwrap_or(0) as isize;
    let next = ((current + delta) % n + n) % n;
    state.select(Some(next as usize));
}

fn launch(cmd: &str) {
    // Whitespace split is good enough for this simple launcher.
    // (Doesn't handle quoted args — fine for `kitty -e nvim` style commands.)
    let mut parts = cmd.split_whitespace();
    if let Some(program) = parts.next() {
        // Detach the child from the launcher's terminal: redirect stdio to
        // /dev/null and put the child in its own session via setsid(). Without
        // this, the child inherits the kitty PTY as its controlling terminal
        // and is killed by SIGHUP the moment the launcher (and its kitty
        // wrapper) exits — which happens immediately after this call.
        let mut command = Command::new(program);
        command
            .args(parts)
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null());
        unsafe {
            command.pre_exec(|| {
                if libc::setsid() == -1 {
                    return Err(std::io::Error::last_os_error());
                }
                Ok(())
            });
        }
        let _ = command.spawn();
    }
}
