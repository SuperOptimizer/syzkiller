#!/bin/bash
set -eux

cd /syzkiller
cd hubworkdir
wget https://github.com/cmu-pasta/linux-kernel-enriched-corpus/releases/download/latest/corpus.db
./syzkaller/bin/syz-hub -config hub.cfg &> out_hub.txt