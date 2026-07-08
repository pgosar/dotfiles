#!/bin/bash
rsync -av --delete -e ssh ~/.local/share/gdlauncher_carbon/data/instances/ chilly@192.168.1.196:/data/replicas/minecraft/
