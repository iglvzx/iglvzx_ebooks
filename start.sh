#!/bin/bash
. ~/.profile

echo "Checking for existing izzybotrun screen."
screen -S izzybotrun -X quit || true; sleep 1;
echo "Starting izzybotrun screen."
screen -d -m -S izzybotrun; sleep 1;
echo "Sending commands to izzybotrun screen."
screen -S izzybotrun -X stuff ". ~/.profile
cd ~/ebooks/
ebooks start
"; sleep 1;

echo ""

echo "Checking for existing izzybotupdate screen."
screen -S izzybotupdate -X quit || true; sleep 1;
echo "Starting izzybotupdate screen."
screen -d -m -S izzybotupdate; sleep 1;
echo "Sending commands to izzybotupdate screen."
screen -S izzybotupdate -X stuff ". ~/.profile
cd ~/ebooks/
nodejs update.js
"; sleep 1;
