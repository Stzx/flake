#!/usr/bin/env bash

chmod 644 /etc/nixos/configuration.nix && \
sed -i '$ s/}/  nix.settings.substituters = [ "https:\/\/mirrors.ustc.edu.cn\/nix-channels\/store" "https:\/\/mirror.sjtu.edu.cn\/nix-channels\/store" ];\n}/g' /etc/nixos/configuration.nix && \
nixos-rebuild switch

nix-env -i git