#!/bin/bash
# Envoy initialization script responsible for setting up port forwarding.

set -x
set -o errexit
set -o nounset
set -o pipefail

usage() {
  echo "${0} -p PORT -u UID [-h]"
  echo ''
  echo '  -p: Specify the envoy port to which redirect all TCP traffic'
  echo '  -u: Specify the UID of the user for which the redirection is not'
  echo '      applied. Typically, this is the UID of the proxy container'
  echo '  -i: Comma separated list of IP ranges in CIDR form to redirect to envoy (optional)'
  echo ''
}

IP_RANGES_INCLUDE=""

#EDGEMICRO_PORT=8000
#EDGEMICRO_UID=1001

while getopts ":p:u:e:i:h" opt; do
  case ${opt} in
    p)
      EDGEMICRO_PORT=${OPTARG}
      ;;
    u)
      EDGEMICRO_UID=${OPTARG}
      ;;
    i)
      IP_RANGES_INCLUDE=${OPTARG}
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${EDGEMICRO_PORT-}" ]] || [[ -z "${EDGEMICRO_UID-}" ]]; then
  echo "Please set both -p and -u parameters"
  usage
  exit 1
fi


# Create a new chain for redirecting inbound and outbound traffic to
# the common Envoy port.
iptables -t nat -N EDGEMICRO_REDIRECT                                             -m comment --comment "edgemicro/redirect-common-chain"
iptables -t nat -A EDGEMICRO_REDIRECT -p tcp -j REDIRECT --to-port ${ENVOY_PORT}  -m comment --comment "edgemicro/redirect-to-envoy-port"

# Redirect all inbound traffic to Envoy.
iptables -t nat -A PREROUTING -j EDGEMICRO_REDIRECT                               -m comment --comment "edgemicro/install-edgemicro-prerouting"

# Create a new chain for selectively redirecting outbound packets to
# Envoy.
iptables -t nat -N EDGEMICRO_OUTPUT                                               -m comment --comment "edgemicro/common-output-chain"

# Jump to the EDGEMICRO_OUTPUT chain from OUTPUT chain for all tcp
# traffic. '-j RETURN' bypasses Envoy and '-j EDGEMICRO_REDIRECT'
# redirects to Envoy.
iptables -t nat -A OUTPUT -p tcp -j EDGEMICRO_OUTPUT                              -m comment --comment "edgemicro/install-edgemicro-output"

# Redirect app calls to back itself via Envoy when using the service VIP or endpoint
# address, e.g. appN => Envoy (client) => Envoy (server) => appN.
iptables -t nat -A EDGEMICRO_OUTPUT -o lo ! -d 127.0.0.1/32 -j EDGEMICRO_REDIRECT     -m comment --comment "edgemicro/redirect-implicit-loopback"

# Avoid infinite loops. Don't redirect Envoy traffic directly back to
# Envoy for non-loopback traffic.
iptables -t nat -A EDGEMICRO_OUTPUT -m owner --uid-owner ${EDGEMICRO_UID} -j RETURN   -m comment --comment "edgemicro/bypass-envoy"

# Skip redirection for Envoy-aware applications and
# container-to-container traffic both of which explicitly use
# localhost.
iptables -t nat -A EDGEMICRO_OUTPUT -d 127.0.0.1/32 -j RETURN                     -m comment --comment "edgemicro/bypass-explicit-loopback"

# All outbound traffic will be redirected to Envoy by default. If
# IP_RANGES_INCLUDE is non-empty, only traffic bound for the
# destinations specified in this list will be captured.
IFS=,
if [ "${IP_RANGES_INCLUDE}" != "" ]; then
    for cidr in ${IP_RANGES_INCLUDE}; do
        iptables -t nat -A EDGEMICRO_OUTPUT -d ${cidr} -j EDGEMICRO_REDIRECT          -m comment --comment "edgemicro/redirect-ip-range-${cidr}"
    done
    iptables -t nat -A EDGEMICRO_OUTPUT -j RETURN                                 -m comment --comment "edgemicro/bypass-default-outbound"
else
    iptables -t nat -A EDGEMICRO_OUTPUT -j RETURN                                 -m comment --comment "edgemicro/bypass-default-outbound"
fi


exit 0