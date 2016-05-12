#!/bin/bash
. ~/.profile

echo "Checking for existing izzybotrun screen."
screen -S izzybotrun -X quit || true; sleep 1;
echo "Starting izzybotrun screen."
screen -d -m -S izzybotrun; sleep 1;
echo "Sending commands to izzybotrun screen."
screen -S izzybotrun -X stuff ". ~/.profile
cd ~/iglvzx_ebooks/
ebooks start
"; sleep 1;

echo ""

echo "Checking for existing izzybotupdate screen."
screen -S izzybotupdate -X quit || true; sleep 1;
echo "Starting izzybotupdate screen."
screen -d -m -S izzybotupdate; sleep 1;
echo "Sending commands to izzybotupdate screen."
screen -S izzybotupdate -X stuff ". ~/.profile
cd ~/iglvzx_ebooks/
nodejs update.js
"; sleep 1;

echo ""

echo "Checking for existing izzybotyoyo screen."
screen -S izzybotyoyo -X quit || true; sleep 1;
echo "Starting izzybotyoyo screen."
screen -d -m -S izzybotyoyo; sleep 1;
echo "Sending commands to izzybotyoyo screen."
screen -S izzybotyoyo -X stuff ". ~/.profile
cd ~/yoyo/
nodejs bot-yoyo.js
"; sleep 1;
