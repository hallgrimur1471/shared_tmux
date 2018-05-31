#!/usr/bin/env bash

# maybe display help
displayHelp() {
  printf "Usage: ./uninstall\n"
  printf "Tries its best to uninstall an installation of shared_tmux\n"
}
thereIsAHelpArgument() { [[($# -eq 1 && ($1 = -h || $1 = --help)) ]]; }
if thereIsAHelpArgument "$@"; then
  displayHelp
  exit 0
fi

# disable and remove shared-tmux in systemd
service=shared-tmux
systemctl status ${service} > /dev/null 2>&1 # check if service exists
if [[ "$?" != 3 ]]; then # only proceed if the service exists
  sudo systemctl stop ${service}
  sudo systemctl disable ${service}
fi
if [[ -f /etc/systemd/system/${service}.service ]]; then
  sudo rm /etc/systemd/system/${service}.service
fi

# remove share files
share_location=/usr/local/share/shared_tmux
if [[ -d "$share_location" ]]; then
  sudo rm -rf $share_location
fi

# remove bin files
remove_file() {
  file="$1"
  if [[ -f "$file" ]]; then
    sudo rm "$file"
  fi
}
remove_file /usr/local/bin/start_shared_tmux_session
remove_file /usr/local/bin/stop_shared_tmux_session
remove_file /usr/local/bin/attach_shared_tmux_session

# remove read_shared_tmux user
user=read_shared_tmux
id -u $user >/dev/null 2>&1 # check that it exists
if [[ "$?" == 0 ]]; then
  sudo userdel -r read_shared_tmux
fi

echo "Uninstall complete"
