#!/bin/bash
# Establish a persistent SSH connection to a remote computer which can
# be used as a reverse tunnel to connect back to this computer.
#
# This would be useful if you'd like to be able to SSH into this computer,
# but direct connections are not possible beacuse this computer is behind
# a restrictive firewall or has a dynamic IP,

# Load:
# VISIBLEADDR - remote server address as user@address
# VISIBLESSHPORT - SSH server port on VISBILEADDR
# VISIBLELOCALPORT - SSH port on visible computer which connects to hidden
# HIDDENSSHPORT - SSH server port on this, the hidden computer
# PRIVATEKEY - location of private key file for VISIBLEADDR
if [[ "$#" -ne 1 ]]; then
  echo "$(basename $0) reversetunnel.conf"
  exit 1
fi
CONFFILE=$1
if [[ ! -e "$CONFFILE" ]]; then
  echo "Config file $CONFFILE does not exist"
  exit 1
fi

source "$CONFFILE"

# On remote/visible SSH server set
#   ClientAliveInterval 60
#   ClientAliveCountMax 3
# to make sure the tunnel on the server end shuts down if the
# network connection is lost for 3 minutes.
date
/usr/bin/ssh -i "${PRIVATEKEY?:randomFilenameThatAlmostCertainlyIsAbsent}" \
  -p "${VISIBLESSHPORT?:notAPort}" \
  -o ConnectTimeout=60 \
  -o ExitOnForwardFailure=True \
  -o ServerAliveInterval=60 \
  -o ServerAliveInterval=3 -N -T -R \
  "${VISIBLELOCALPORT?:notAPort}":localhost:"${HIDDENSSHPORT?:notAPort}" \
  "${VISIBLEADDR?:notARealAddress}" 2>&1
