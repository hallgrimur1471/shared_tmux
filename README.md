# shared_tmux

With shared_tmux you can easily share a read-only access to a tmux session through a dedicated ssh route.

Deticated ssh route? Yes, the install script creates a new user `read_shared_tmux` and instead of having `/bin/bash` it's login program (as usual) we change the login program to one that attaches the user to the `shared_tmux` session with a read only access. There are probably some security flaws where a client with the `read_shared_tmux` user password can get a full shell access, I don't take any responsibility in that but I challenge you to find it!

There is an anoying property of tmux that if a client with a smaller terminal than the hosts attaches to the hosts tmux session, the tmux window size will get reduced to the smallest session client. shared_tmux tries to address this issue by monitoring the size of a connecting client and asking him to increase terminal window size if it's to small, but there are currently flaws in the functinality. The client can increase the terminal size to get attached to the host's tmux sesison and then the client can decrease the terminal size again and he will not get detached from the tmux session.

### Prerequisites

For hosts:

* tmux

For clients:

* Nothing particular I think? Just a terminal with ssh installed!

### Connecting (for clients)
```
ssh read_shared_tmux@<host_ip_address>
```
Ask the host for the password, he sets it during his installation of `shared_tmux`.

### Installing (for hosts)

```
cd ~
git clone git@github.com:hallgrimur1471/shared_tmux.git
cd shared_tmux
./install.sh
```

### Starting a shared_tmux session (for hosts)

The install script copies 3 bash scripts into `/usr/local/bin`:

```
start_shared_tmux_session
attach_shared_tmux_session
stop_shared_tmux_session
```

So if you got `/usr/local/bin` on $PATH you can just start the session with

```
start_shared_tmux_session
```

Now clients can attach to the shared_tmux session by logging into your machine as the `read_shared_tmux` user. For example with:

```
ssh read_shared_tmux@<host_ip_address>
# or for intruders that have already breached into your computer:
su read_shared_tmux
```

### Configuring minimum terminal size (for hosts)

When clients try to attach to your `shared_tmux` session they will be asked to increase their terminal sizes to match your preferences. Edit `/usr/local/share/shared_tmux/host_size.conf` to configure these values.

## Future development

* Automagically detatch clients that reduce their terminal size after being attached to the shared_tmux session
* Add a write_shared_tmux user with a write permission to the shared_tmux session.

## Authors

* **Hallgrímur Davíð Egilsson**

## Acknowledgement

To [Steina](https://github.com/steina1989) for telling me about the commands `tput lines` and `tput cols`!

## License

This project is not licenced, It's my gift to the universe.
