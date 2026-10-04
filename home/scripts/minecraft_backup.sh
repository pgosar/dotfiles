#!/bin/bash
rsync -av --delete -e "ssh -i ~/.ssh/id_ed25519_nas" ~/.local/share/gdlauncher_carbon/data/instances/ chilly@100.126.218.82:/data/replicas/minecraft/
