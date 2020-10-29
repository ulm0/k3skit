#!/usr/bin/env bash

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
  eval "$(jq -r '@sh "export HOST=\(.server) PRIVATE_KEY=\(.private_key)"')"
  # eval "$(jq -r '@sh "export PRIVATE_KEY=\(.private_key)"')"
  if [[ -z "${HOST}" ]]; then export HOST=none; fi
  if [[ -z "${PRIVATE_KEY}" ]]; then export PRIVATE_KEY=none; fi
}

function return_kubeconfig() {
  KUBECONFIG=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PRIVATE_KEY  root@$HOST "cat /etc/rancher/k3s/k3s.yaml")
  jq -n \
    --arg kubeconfig "$KUBECONFIG" \
    '{"kubeconfig":$kubeconfig}'
}

check_deps
parse_input
return_kubeconfig
