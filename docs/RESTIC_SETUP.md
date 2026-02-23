# Restic Backup Setup with Google Drive

This guide explains how to set up automated backups using Restic and rclone to Google Drive.

## Overview

The system includes:
- **Restic**: Encrypted, deduplicated backup tool
- **rclone**: Syncs data to Google Drive
- **Systemd timer**: Runs backups daily at 12:30 PM

**What gets backed up:**
- `/home` - User data
- `/etc` - System configuration
- `/var` - Variable data
- `/opt` - Optional software

**Retention policy:**
- Daily backups: 7 days
- Weekly backups: 4 weeks
- Monthly backups: 12 months

## Initial Setup

### 1. Configure rclone for Google Drive

Run the interactive configuration:

```bash
rclone config
```

Follow these steps:
1. Choose `n` for new remote
2. Name it: `gdrive`
3. Storage type: `drive` (Google Drive)
4. Client ID/Secret: Press Enter to use defaults (or provide your own OAuth credentials)
5. Scope: Choose `drive` (full access) or `drive.file` (limited to files created by rclone)
6. Root folder: Leave blank for root
7. Service account: `n`
8. Edit advanced config: `n`
9. Auto config: `y` (this will open a browser for authentication)
10. Authenticate with your Google account
11. Configure as team drive: `n`
12. Confirm and exit

Verify the configuration:
```bash
rclone listremotes
# Should show: gdrive:
```

### 2. Set Restic Password

Create the environment file:

```bash
sudo cp /etc/restic/restic-env.template /etc/restic/env
sudo chmod 600 /etc/restic/env
```

Edit `/etc/restic/env` and set a strong password:

```bash
sudo nano /etc/restic/env
```

Change:
```bash
RESTIC_PASSWORD=your_secure_password_here
```

To something like:
```bash
RESTIC_PASSWORD=MyStr0ng!Backup#Password2024
```

**Important:** Save this password securely! You'll need it to restore backups.

### 3. Initialize the Backup Repository

The repository will be automatically initialized on the first backup run, or you can do it manually:

```bash
sudo -E restic -r rclone:gdrive:laptop-backup init
```

### 4. Enable and Start the Backup Timer

The timer should already be enabled via the system preset, but you can verify:

```bash
sudo systemctl status restic-backup.timer
```

If not enabled:
```bash
sudo systemctl enable --now restic-backup.timer
```

## Manual Operations

### Run Backup Manually

```bash
sudo systemctl start restic-backup.service
```

View the backup progress:
```bash
sudo journalctl -u restic-backup.service -f
```

### List Snapshots

```bash
sudo -E restic -r rclone:gdrive:laptop-backup snapshots
```

### Restore Files

Restore everything from the latest snapshot:
```bash
sudo -E restic -r rclone:gdrive:laptop-backup restore latest --target /tmp/restore
```

Restore specific files:
```bash
sudo -E restic -r rclone:gdrive:laptop-backup restore latest --target /tmp/restore --include /home/username/important-file.txt
```

Restore from a specific snapshot:
```bash
# First, list snapshots to get the ID
sudo -E restic -r rclone:gdrive:laptop-backup snapshots

# Then restore
sudo -E restic -r rclone:gdrive:laptop-backup restore <snapshot-id> --target /tmp/restore
```

### Check Repository Health

```bash
sudo -E restic -r rclone:gdrive:laptop-backup check
```

### View Backup Statistics

```bash
sudo -E restic -r rclone:gdrive:laptop-backup stats
```

## Troubleshooting

### Check Timer Status

```bash
systemctl list-timers restic-backup.timer
```

### View Logs

Recent logs:
```bash
sudo journalctl -u restic-backup.service -n 50
```

Follow logs in real-time:
```bash
sudo journalctl -u restic-backup.service -f
```

### Test rclone Connection

```bash
rclone lsd gdrive:
rclone mkdir gdrive:test-folder
rclone lsd gdrive:
```

### Remove Stale Locks

If backups fail due to locks:
```bash
sudo -E restic -r rclone:gdrive:laptop-backup unlock
```

## Customization

### Change Backup Schedule

Edit the timer:
```bash
sudo systemctl edit restic-backup.timer
```

Add:
```ini
[Timer]
OnCalendar=
OnCalendar=*-*-* 02:00:00
```

Reload systemd:
```bash
sudo systemctl daemon-reload
```

### Modify Backup Paths or Exclusions

Edit `/usr/local/bin/restic-backup.sh` and rebuild the container image.

### Change Retention Policy

Edit the `forget` command in `/usr/local/bin/restic-backup.sh`:
```bash
restic -r "$RESTIC_REPO" forget \
    --keep-daily 14 \
    --keep-weekly 8 \
    --keep-monthly 24 \
    --prune
```

## Security Notes

- Backups are encrypted with your RESTIC_PASSWORD
- Only you can decrypt the backups (keep your password safe!)
- `/etc/restic/env` is only readable by root (mode 600)
- Google Drive stores encrypted backup data, not plaintext files

## Useful Commands Reference

```bash
# Check next scheduled backup time
systemctl list-timers restic-backup.timer

# Manually trigger backup
sudo systemctl start restic-backup.service

# View backup logs
sudo journalctl -u restic-backup.service -n 100

# List all snapshots
sudo -E restic -r rclone:gdrive:laptop-backup snapshots

# Check repository integrity
sudo -E restic -r rclone:gdrive:laptop-backup check

# See what changed in latest backup
sudo -E restic -r rclone:gdrive:laptop-backup diff

# Interactive browse of backup
sudo -E restic -r rclone:gdrive:laptop-backup mount /mnt/restic
```

## References

- [Restic Documentation](https://restic.readthedocs.io/)
- [rclone Documentation](https://rclone.org/docs/)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
