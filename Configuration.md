# openaloberon configuration #

Possibly, there are more then one sound playback and capture devices available in today computers.
If you want to use one of them in openaloberon run this command from

> A2 window:  _OpenALinfo.Do ~_

> or

> command line: _aos -x OpenALinfo.Do_

This command lists the playback and capture devices available in your computer and saves them to the files: "**openalplay.ini**" is for playback device names, "**openalcap.ini**" for capture device names.

If you particularly want to choose one of playback device name in the list, open "openalplay.ini" file with any editor,
and remove "#" character which is in front of the device name that you would like choose, finally save the file.
If "#" is available in front of  all device names or if these files are not available, then, openaloberon will use the default device.

As an example for openalplay.ini, ALSA device selected.
```
#PulseAudio Default

#Internal Audio Analog Stereo via PulseAudio

 ALSA Default

#ATI IXP [ATI IXP AC97] (hw:0,0) via ALSA

#ATI IXP Modem [ATI IXP MC97] (hw:1,0) via ALSA

#OSS Default

#No Output 

```

# Details #

will be added ...