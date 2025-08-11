#!/usr/bin/env sh

exec ansible-vault edit --vault-password-file ./ansible-vault-pass.txt ./group_vars/all/vault.yaml
