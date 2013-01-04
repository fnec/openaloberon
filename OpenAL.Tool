OpenAL Bindings for LinuxAos and WinAos


For LinuxAos:
Compiler.Compile 
	openaloberon/Unix.OpenAL.Mod 
	openaloberon/Unix.OpenALefx.Mod 
	openaloberon/Unix.OpenALext.Mod 
~

For Windows:
Compiler.Compile 
	openaloberon/Win32.OpenAL.Mod 
	openaloberon/Win32.OpenALefx.Mod 
	openaloberon/Win32.OpenALext.Mod
~

Examples:

Compiler.Compile
	openaloberon/OpenALinfo.Mod
	openaloberon/OpenALUtil.Mod
	openaloberon/TestOpenAL0.Mod
	openaloberon/TestOpenALWav.Mod 
	openaloberon/TestOpenALWav3.Mod
~ 


Configuration:
Possibly, there are more then one sound playback and capture devices available in today computers.
If you want to use one of them in openaloberon run this command from 

	A2 window:  OpenALinfo.Do ~
	or 
	command line: aos -x OpenALinfo.Do 
	
This command lists the playback and capture devices available in your computer and saves them 
	to the files: "openalplay.ini" is for playback device names, "openalcap.ini" for capture device names.

If you particularly want to choose one of playback device name in the list, open "openalplay.ini" file with any editor,  
and remove "#" character which is in front of the device name that you would like choose, finally save the file. 
If "#" is available in front of  all device names or if these files are not available, then, openaloberon will use the default device.

 

Useful links for documentation and examples:

http://openal.org
