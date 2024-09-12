# geek-dictation
Inspired by [nerd-dictation](https://github.com/ideasman42/nerd-dictation), this is a hackable way to implement voice typing on linux. Instead of python, this implementation uses a set of bash scripts. It uses one of Open AI's [Whisper models](https://github.com/openai/whisper) that has been converted and optimized with [whisper.cpp](https://github.com/ggerganov/whisper.cpp). The model is run in server mode, then utilized with a curl command that sends it audio recorded with [pw-cat](https://www.systutorials.com/docs/linux/man/1-pw-cat/) (pipewire) using hotkeys programmed with [ckb-next](https://github.com/ckb-next/ckb-next). The text is pasted using [ydotool](https://github.com/ReimuNotMoe/ydotool) after it has been processed with custom SED commands (all in memory). A similar approach is [voice_typing](https://github.com/themanyone/voice_typing). The advantage with geek-dictation is speed, customization (with the SED commands), and the ability to pause as long as you want while recording your audio.

Note: [pw-cat/pw-record](https://www.systutorials.com/docs/linux/man/1-pw-cat/) is the key to making this work. The second script triggered by releasing the hotkey kills pw-rec and begins sending the resulting wave file to the Whisper model. Doing this with other recording options in linux, such as sox, results in deleting about two seconds from the end of the audio file. This can be fixed by adding a two-second delay in the script, but that defeats the goal of making the entire process fast. When pw-rec is killed, the entire audio file remains intact. I think this has something to do with pw-rec's lower latency recording.

https://github.com/user-attachments/assets/a0f55e21-8c3d-4539-bcc2-da4cadb42620

Note: Two different sets of SED commands are used in this example (one for the main text and one for the citations). Each is tied to a different key.

## Dependencies
* whisper.cpp
* ffmpeg (might already be installed)
* wl-clipboard
* ckb-next
* a keyboard or mouse compatible with ckb-next
* pw-cat/pw-rec (likely already installed)
* curl (almost certainly already installed)

## Getting Started
### Set up a GGML optimized whisper model
The documentation in [whisper.cpp](https://github.com/ggerganov/whisper.cpp) is fairly straight forward. If using a Cuda enabled Nvidia GPU, I recommend the largest model. If using a CPU for inference, I recommend the English small model or the English base model.

#### Compiling for Cuda Enabled GPU

The whisper.cpp documentation describes ways to further accelerate inference speed. If at all possible, I highly recommend compiling for use with a Cuda enabled Nvidia GPU. This will allow you to run the largest whisper model with near-instant speech to text translation. The above example was done with an RTX 4090 (overkill but I am also running a local LLM).

You will need both the Nvidia driver and the Cuda toolkit installed. Your GPU will probably need atleast 6 gigabites of VRAM. If you are on Fedora Linux, you can avoid a lot of headache by using Fedora 39 (not 40) because it is sure to work with the driver and has the older GCC compiler that the Cuda toolkit requires. In addition, only install the Nvidia driver from the [Fusion Nonfree Repository](https://rpmfusion.org/Howto/NVIDIA). The Cuda toolkit can be installed from the Nvidia servers. See [Fedora Cuda Instructions](https://rpmfusion.org/Howto/CUDA).

#### Compiling with Openvino for CPU inference

For CPU inference, you can use [openvino](https://github.com/openvinotoolkit/openvino). Openvino is an Intel project, but it works just fine with AMD CPUs with an x86 architecture. 

I was able to get openvino working with Fedora 40 and openvino toolkit 2023.2.0 (labeled rhel). However, because Fedora 40 changed the packaging for the shared library TBB (Threading Building Blocks), I had to install the development version of tbb and move some of the old tbb files back where they used to be:

    sudo dnf install tbb-doc
    
These files were taken from Fedora 39 and copied to their orginal location to make Fedora 40 work:

    /usr/lib64/libtbb.so.2
    /usr/lib64/libtbbmalloc.so.2
    /usr/lib64/libtbbmalloc_proxy.so.2
    
#### Optionally Use Whisperfile
You can also download a ready-to-go executible from [whiperfile](https://github.com/cjpais/whisperfile), which is based on the work of Mozilla and [llamafile](https://github.com/Mozilla-Ocho/llamafile). They have found a way to "collapses all the complexity of LLMs down to a single-file," and it works on almost any computer.

The performance is probably not quite as good as if you compiled whisper.cpp yourself. When I tested whisperfile with openivo on the CPU, there was about a 30% decrease in speed. One option could be to start using geek-dictation with whisperfile, then if you want that little bit of extra speed, compile your own executible with [whisper.cpp](https://github.com/ggerganov/whisper.cpp) and openvino. This probably only makes sense for CPU inference since compiling for a Cuda enabled GPU is so easy (literally just one command).

### Install ffmpeg if not already installed
ffmpeg is used to convert the recorded audio to a whisper compatible audio file (when starting the server, the -convert flag does this). Although the "record.sh" script uses pw-rec to record a wave file, the whisper model uses a very specific type of wave file.

Fedora/RHEL

	sudo dnf install ffmpeg
	
Ubuntu

	sudo apt install ffmpeg

### Install wl-clipboard

Fedora/RHEL

	sudo dnf install wl-clipboard

Ubuntu

	sudo apt install wl-clipboard

### Get ydotool working

You will need an application that can simulate the keyboard function for pasting the contents of the clipboard into something that is not just a terminal (control+c). I have found that [ydotool](https://github.com/ReimuNotMoe/ydotool) works best for this. Like other projects, I used to use a keyboard simulation app to type all of the converted text. However, because geek-dictation processes all of an audio file at once, it is possible and faster to just paste the converted text into the word processor.
	
* Install [ydotool](https://github.com/ReimuNotMoe/ydotool)

* You will also need to set up a dbus service on linux to give the ydotool deamon ongoing permission to run on start up. I cannot reliably list all the steps. Please ask GPT-4 or Claude to walk you through it.
	
### Place Geek-Dictation in Home folder
All of these instructions assume that geek-dictation scripts are in your home folder. For a quick way to so this:

	git clone https://github.com/jessemcg/geek-dictation.git
	
Make sure the scripts are executable.

	sudo chmod +x /$HOME/geek-dictation/*.sh

### Program hotkeys with ckb-next
Install [ckb-next](https://github.com/ckb-next/ckb-next), which is a GUI based app that allows the user to assign functionality to keys or buttons on supported Corsair keyboards or mice.

Fedora/RHEL

	sudo dnf install ckb-next
	
Ubuntu

	sudo apt install ckb-next
	
* Open ckb-next. Navigate to your keyboard and click on a key to use for general voicetyping. With the "Binding" dialogue open, choose the "Program" sub dialogue. Then type in the command for executing the "record.sh" script for the "on key press" option. Make sure the "Single release" option is unchecked. Then type in the command for executing the "process.sh" script for the "on key release" option. Make sure the "Single release" option is checked.

<img src="ckb-next.png" alt="screenshot" style="width: 600;">

* For in-line voicetyping (like to edit just a few words), choose a different hotkey and follow the same steps. But for the "on key release" option, type in the command for executing the "process_quick_edit.sh" script. This ensures that the first word is not capitalized, and that there is no punctuation at the end.

### Create custom SED commands
Add SED commands to the sed_commands.txt file to make any changes to spelling, grammer, style, etc. To determine whether a SED command is working as intended, you can uncomment the last line in the "process.sh" file and inspect the original whisper output in the resulting log file. Just compare that to the modified output. When creating SED commands, make sure you backslash symbols that could have meaning as bash code or regular expressions unless you intend for that regular expression to be operative. Consult GPT-4 for assistance.

### Optionally use an app or extenstion to launch the frequently used scripts not assigned to hotkeys
You can start and stop the whisper.cpp server with:

Start Server

	bash /$HOME/geek-dictation/start_server.sh
	
Stop Server
	
	bash /$HOME/geek-dictation/stop_server.sh

However, if you use geek-dictation daily, you may want to use a script launching app to start the Whisper.cpp server, to stop the server, and to edit the sed_commands.txt file. For gnome, the [Launcher](https://extensions.gnome.org/extension/5874/launcher/) extension is a good option. 

