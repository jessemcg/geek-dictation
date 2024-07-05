#!/bin/bash

# Define file path variables (the "/dev/shm" direcory is in RAM, making file creation temporary and fast)
AUDIO_FILE="/dev/shm/speech.wav"
SED_COMMANDS="$HOME/geek-dictation/sed_commands.txt"
LOG_FILE="$HOME/geek-dictation/log_file.txt"

# Stop recording the audio file
pkill pw-record

# Send curl request to running Whisper server and store text information in variable
curl_output=$(curl 127.0.0.1:8080/inference -H "Content-Type: multipart/form-data" -F file=@"$AUDIO_FILE" -F response_format="text")

# Use SED to remove all line breaks
modified_output=$(echo "$curl_output" | sed ':a;N;$!ba;s/\n//g')

# Use SED to further modify text by referencing list of SED commands in a separate text file
super_modified_output=$(echo "$modified_output" | sed -f "$SED_COMMANDS")

# Load contents of final variable onto clipboard
echo -n "$super_modified_output" | wl-copy

# Use ydotool to paste the contents of the clipboard
ydotool key 29:1 47:1 47:0 29:0

# Optional debugging to see what the default Whisper output looks like (and see whether the SED tweaks had their intended effect)
#echo "$curl_output" >> "$LOG_FILE"
