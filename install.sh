#!/usr/bin/env bash

# maybe display help
displayHelp() {
  printf "Usage: ./install\n"
  printf "Installs and sets you up to be a host of a 'shared_tmux' session. "
  printf "This script fiddles quite a lot with your machine internals so you "
  printf "might want to read over this script before running it\n"
}
thereIsAHelpArgument() { [[($# -eq 1 && ($1 = -h || $1 = --help)) ]]; }
if thereIsAHelpArgument "$@"; then
  displayHelp
  exit 0
fi

error() {
  msg="$1"
  (2>&1 echo "Error: $msg")
}

# cd to the directory of this script
project_root=$(dirname "$0")
project_root=$(readlink -f $project_root) # make sure . gets expanded
cd $project_root

# make sure systemd is installed
systemd --version >/dev/null 2>&1
if [[ "$?" != "0" ]]; then
  error "systemd must be installed"
fi

# make sure tmux is installed
tmux -V > /dev/null 2>&1
if [[ "$?" != "0" ]]; then
  error "tmux must be installed"
fi

########### stop on errors ###########
#                                    #
set -e

# deploy to share
deploy_location=/usr/local/share/shared_tmux
if [[ ! -d "$deploy_location" ]]; then
  sudo mkdir -p $deploy_location
fi
sudo cp ./package/perpetual_size_checker.sh $deploy_location
sudo cp ./package/gatekeeper.sh $deploy_location

# enable and start shared-tmux service in systemd
service=shared-tmux
sudo cp ./package/${service}.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/${service}.service
sudo chmod 731 /etc/systemd/system/${service}.service
sudo systemctl enable ${service}
sudo systemctl start ${service}

# deploy bin files
deploy_bin() {
  file="$1"
  sudo cp ./package/bin/$file /usr/local/bin/$file
}
deploy_bin start_shared_tmux_session
deploy_bin stop_shared_tmux_session
deploy_bin attach_shared_tmux_session

set +e
#                                    #
#### don't stop on errors anymore ####

# create the read-only user shared_tmux_read
user=read_shared_tmux
id -u read_shared_tmux >/dev/null 2>&1 # check if user exists
if [[ "$?" == 0 ]]; then # it exists
  echo "User read_shared_tmux already exists, skipping user setup ..."
else
  # create the user
  printf "Please enter a password for the read_shared_tmux user that will be "
  printf "created:\n"
  read -s password
  sudo adduser $user --gecos "" --disabled-password
  echo "${user}:${password}" | sudo chpasswd

  # run gatekeeper.sh instead of /bin/bash on login
  sudo sed -i \
    "s/\(^${user}.*\)\(:[^:]*$\)/\1:\/usr\/local\/share\/shared_tmux\/gatekeeper\.sh/" /etc/passwd
fi

echo "Install complete"
