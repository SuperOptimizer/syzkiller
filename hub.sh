#!/bin/bash
set -eux

cd /syzkiller
cd hubworkdir
wget https://github.com/cmu-pasta/linux-kernel-enriched-corpus/releases/download/latest/corpus.db
screen -dmS syzhub ./syzkaller/bin/syz-hub -config hub.cfg
echo "Hub started in screen session 'syzhub'"