#!/bin/bash
. ~/.profile

cd ~/iglvzx_ebooks

ebooks archive iglvzx corpus/iglvzx.json
ebooks consume corpus/iglvzx.json
