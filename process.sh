#!/bin/bash

# Define file path variables (the "/dev/shm" direcory is in RAM, making file creation temporary and fast)
AUDIO_FILE="/dev/shm/speech.wav"
SED_COMMANDS="$HOME/sed_commands.txt"
LOG_FILE="$HOME/log_file.txt"

# Stop recording the audio file
pkill pw-record

# Send curl request to running Whisper server and store text information in variable
curl_output=$(curl 127.0.0.1:8080/inference -H "Content-Type: multipart/form-data" -F file=@"$AUDIO_FILE" -F response-format="text")

# Use SED to remove all line breaks
modified_output=$(echo "$curl_output" | sed ':a;N;$!ba;s/\n//g')

# Use SED to further modify text by referencing list of SED commands in a separate text file
super_modified_output=$(echo "$modified_output" | sed -f "$SED_COMMANDS")

# Type the modified output with dotool using 5 millisecond delay to ensure accuracy
{ echo typedelay 5; echo type "$super_modified_output"; } | dotool

# Optional debugging to see what the default Whisper output looks like (and see whether the SED tweaks had their intended effect)
#echo "$curl_output" >> "$LOG_FILE"
