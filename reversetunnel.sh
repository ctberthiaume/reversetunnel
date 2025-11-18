#!/bin/bash
# Establish a persistent SSH connection to a remote computer which can
# be used as a reverse tunnel to connect back to this computer.
#
# This would be useful if you'd like to be able to SSH into this computer,
# but direct connections are not possible because this computer is behind
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

require_var() {
  local var_name=$1
  if [[ -z "${!var_name}" ]]; then
    echo "Error: Required variable $var_name is not set in $CONFFILE" >&2
    exit 1
  fi
}

require_var VISIBLEADDR
require_var VISIBLESSHPORT
require_var VISIBLELOCALPORT
require_var HIDDENSSHPORT
require_var PRIVATEKEY

# Check if autossh is available
if command -v autossh >/dev/null 2>&1; then
  SSH_CMD="autossh -M 0"  # -M 0 disables monitoring port since we use ServerAliveInterval
else
  SSH_CMD="/usr/bin/ssh"
fi

FULL_CMD=(
  $SSH_CMD
  -i "${PRIVATEKEY}"
  -p "${VISIBLESSHPORT}"
  -o ConnectTimeout=60
  -o ExitOnForwardFailure=True
  -o ServerAliveInterval=60
  -o ServerAliveCountMax=3
  -N -T -R "${VISIBLELOCALPORT}":127.0.0.1:"${HIDDENSSHPORT}"
  "${VISIBLEADDR}"
)

# On remote/visible SSH server set
#   ClientAliveInterval 60
#   ClientAliveCountMax 3
# to make sure the tunnel on the server end shuts down if the
# network connection is lost for 3 minutes.
date
printf "Running command:\n"
printf ' %q' "${FULL_CMD[@]}"
printf '\n'

"${FULL_CMD[@]}" 2>&1
