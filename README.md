# Simple Time Tracker

A lightweight service that tracks when your machine is on to help monitor work hours.

## Features
- Logs activity every 10 minutes using systemd timers
- Minimal resource usage (just a timestamp written to a file)
- Shows start/end times and total hours per day
- Automatic archiving by month - never loses historical data
- Query any date range (last 7, 30, 90 days, etc.)

## Installation

```bash
./install.sh
```

If `~/.local/bin` is not in your PATH, add it:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Usage

View your last 7 days:
```bash
worktime-report.sh
```

View longer history (including archived data):
```bash
worktime-history.sh 30    # Last 30 days
worktime-history.sh 90    # Last 90 days
worktime-history.sh 180   # Last 6 months
```

Check if the tracker is running:
```bash
systemctl --user status worktime-tracker.timer
```

## Management

Stop tracking:
```bash
systemctl --user stop worktime-tracker.timer
```

Start tracking:
```bash
systemctl --user start worktime-tracker.timer
```

Disable auto-start on boot:
```bash
systemctl --user disable worktime-tracker.timer
```

## How It Works

1. A systemd timer runs `worktime-tracker.sh` every 10 minutes
2. Each run appends a timestamp to `~/.worktime/worklog.txt`
3. Data older than 8 days is automatically moved to `~/.worktime/archive/YYYY-MM.txt`
4. The main log stays small (only last 7 days) for quick daily reports
5. `worktime-history.sh` searches both current and archived data for longer queries

## Data Location

- Current log: `~/.worktime/worklog.txt` (last 7 days)
- Archives: `~/.worktime/archive/2024-10.txt`, `2024-11.txt`, etc.
- Archives are organized by month and kept indefinitely

## Limitations

- 10-minute resolution means times are approximate
- Tracks machine uptime, not actual active work time
- If you suspend/hibernate frequently, gaps will appear
- First/last times of day show first/last 10-min check, not exact on/off times

## Uninstall

```bash
systemctl --user stop worktime-tracker.timer
systemctl --user disable worktime-tracker.timer
rm ~/.local/bin/worktime-*.sh
rm ~/.config/systemd/user/worktime-tracker.*
rm -rf ~/.worktime  # Warning: This deletes all historical data
systemctl --user daemon-reload
```
