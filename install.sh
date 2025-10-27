#!/bin/bash
# Installation script for work time tracker

set -e

echo "Installing Work Time Tracker..."

# Create directories
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user

# Copy scripts
cp time_tracker.sh ~/.local/bin/
cp time_report.sh ~/.local/bin/
cp time_history.sh ~/.local/bin/
chmod +x ~/.local/bin/time_tracker.sh
chmod +x ~/.local/bin/time_report.sh
chmod +x ~/.local/bin/time_history.sh

# Copy systemd files
cp time_tracker.service ~/.config/systemd/user/
cp time_tracker.timer ~/.config/systemd/user/

# Reload systemd and enable timer
systemctl --user daemon-reload
systemctl --user enable time_tracker.timer
systemctl --user start time_tracker.timer

echo ""
echo "✓ Installation complete!"
echo ""
echo "The tracker is now running and will log every 10 minutes."
echo "Old data will be archived to ~/.worktime/archive/ organized by month."
echo ""
echo "Commands:"
echo "  time_report.sh           - View last 7 days"
echo "  time_history.sh 30       - View last 30 days (includes archives)"
echo "  systemctl --user status time_tracker.timer - Check tracker status"
echo ""
echo "Note: Add ~/.local/bin to your PATH if not already there:"
echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
