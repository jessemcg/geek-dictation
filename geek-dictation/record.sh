#!/bin/bash

# Define file path variable (the "/dev/shm" direcory is in RAM, making file creation temporary and fast)
AUDIO_FILE="/dev/shm/speech.wav"

# Start recording audio file with pw-record (AKA pw-cat) and keep the process running in the background
pw-record "$AUDIO_FILE" &
