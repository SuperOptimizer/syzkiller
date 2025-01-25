#!/bin/bash
set -eux

cd /syzkiller
#sudo nohup ./syzkaller/bin/syz-hub -config hub.cfg &> out_hub.txt &