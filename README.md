# A basic setup for reverse SSH tunnels

This repo provides files to help with the setup of a reverse SSH tunnel. This
method can be used to connect to a computer hidden behind a firewall or some
otherwise restrictive network policy.

Throughout this repo, the familiar terms "local" and "remote" have been
replaced by the conceptually clearer (to me) terms of "visible" and "hidden",
where "visible" refers to the computer that you have direct access to, and
"hidden" refers to the computer behind the restrictive network policy.

The files in this repo should be run from the hidden computer to establish a
persistent SSH connection to an SSH server on the visible computer. The user
can then connect back to the hidden computer from the visible computer
using a reverse tunnel on the persistent connection.

## Usage
Clone this repository on the hidden computer.

Copy the file `reversetunnel.conf.example` to a new location

```sh
cp reversetunnel.conf.example reversetunnel.conf
```

and edit the variables in the copied file for your setup.

You may need to create an SSH public key pair and install the public key
in `~/.ssh/authorized_keys` on the visible computer.

Start the persistent SSH connection on the hidden computer with

```sh
./reversetunnel.sh reversetunnel.conf
```

Now from the visible computer, connect to the hidden computer with

```sh
 -p "$VISIBLELOCALPORT" hidden-user@localhost
```

It can be useful to maintain this persistent connection with a launchd on
MacOS or a systemd unit on Linux. You can find an example template for a
launchd job in `local.reversetunnel.plist`.
