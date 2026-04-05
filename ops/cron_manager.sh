#!/bin/bash

SCRIPT_PATH="$PWD/your_script.sh"
ACTION=$1

case "$ACTION" in
  setup)
    (crontab -l 2>/dev/null; echo "0 0 * * * /bin/bash $SCRIPT_PATH") | crontab -
    echo "Cron job has been set up to run daily at midnight."
    ;;
  stop)
    crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
    echo "Cron job has been removed."
    ;;
  *)
    echo "Usage: $0 {setup|stop}"
    exit 1
    ;;
esac