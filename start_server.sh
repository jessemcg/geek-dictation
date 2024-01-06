#!/bin/bash
	
# go to the servers
cd $HOME/whisper.cpp

# Retrieve the CPU manufacturer
cpu_manufacturer=$(grep -m 1 'model name' /proc/cpuinfo)

# Check for Intel CPU, and start server for small Whisper model
if [[ $cpu_manufacturer == *"Intel"* ]]; then
    ./server -ng -l en -t 12 -m models/ggml-small.en.bin --convert &

# Check for AMD CPU, and start server for small Whisper model
elif [[ $cpu_manufacturer == *"AMD"* ]]; then
    ./server -ng -l en -t 14 -m models/ggml-small.en.bin --convert &
else
    echo "Unsupported CPU manufacturer."
fi
