#!/usr/bin/env sh

exec ansible-playbook -i ./hosts.yaml --vault-password-file ./ansible-vault-pass.txt ./root-play.yaml
