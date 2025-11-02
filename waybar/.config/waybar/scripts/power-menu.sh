#!/bin/bash

options="Lock\nLogout\nReboot\nShutdown"

choice=$(echo -e "$options" | fuzzel --dmenu --prompt "Power: ")

case $choice in
  "Lock")
    swaylock -f
    ;;
  "Logout")
    niri msg action quit
    ;;
  "Reboot")
    systemctl reboot
    ;;
  "Shutdown")
    systemctl poweroff
    ;;
esac
