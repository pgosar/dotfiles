#!/bin/bash
rsync -av -e ssh --delete ~/.local/share/gdlauncher_carbon/data/instances/ chilly@192.168.1.184:~/Replicas/Minecraft/
