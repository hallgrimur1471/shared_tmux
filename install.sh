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
sudo cp ./package/gatekeeper.sh $deploy_location
sudo cp ./package/host_size.conf $deploy_location

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
  p1="\(^${user}.*\)" # matches first part of line
  p2="\(:[^:]*$\)" # this will match :/bin/bash at the end of line
  gate_path="\/usr\/local\/share\/shared_tmux\/gatekeeper\.sh"
  sudo sed -i "s/${p1}${p2}/\1:${gate_path}/" /etc/passwd
fi

echo "Install complete"
