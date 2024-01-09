#!/bin/bash
	
# go to the ggml optimized models
cd $HOME/whisper.cpp

# Start the optimized ggml small Whisper model in server mode and keep it running in the background
./server -ng -l en -t 12 -m models/ggml-small.en.bin --convert &
#./server -ng -l en -m models/ggml-small.en.bin --convert &
