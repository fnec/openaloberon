MODULE TestOpenALWav; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Kernel, KernelLog, SoundDevices, Codecs, Files, Strings,Commands;


VAR  timer: Kernel.Timer;
	mtimer: Kernel.MilliTimer;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	
PROCEDURE PlayWav*(cmd: Commands.Context);
VAR
	buffer : AL.ALuint;
	source : AL.ALuint;
	fmt: AL.ALuint;

	srcPos, lstPos: ARRAY [3] OF REAL;

	dres: LONGINT;
	file: Files.File;
	in: Files.Reader;
 	 
	decoder : Codecs.AudioDecoder;
	sbuffer : SoundDevices.Buffer;
	
	nofChannels, samplePerSecond, bitsPerSample, samples : LONGINT;
	istate: AL.ALint;
	fname: ARRAY 256 OF CHAR;
		
BEGIN
	IF ~cmd.arg.GetString(fname) THEN
		KernelLog.String("invalid filename"); KernelLog.Ln; 
		RETURN;
	END;
	KernelLog.String("arg.in fname= "); KernelLog.String(fname); KernelLog.Ln; 
	(* load sound file *)
	decoder := Codecs.GetAudioDecoder("WAV");
	IF decoder = NIL THEN
		KernelLog.String( "WAV decoder not installed"); KernelLog.Ln; 
		RETURN
	END;
	file := Files.Old(fname);
	IF file = NIL THEN
		KernelLog.String(fname);  KernelLog.String( ": WAV file Open Error. "); KernelLog.Ln; 
		RETURN 
	END;

	Files.OpenReader( in, file, 0);
	decoder.Open(in, dres);
	IF dres # Codecs.ResOk THEN 
		KernelLog.String( "WAV decoder Open Error. "); KernelLog.Ln; 
		RETURN 
	END;
	
	decoder.GetAudioInfo(nofChannels, samplePerSecond, bitsPerSample);
	samples := decoder.GetTotalSamples();

	KernelLog.String("nofChannels= "); KernelLog.Int(nofChannels, 0); KernelLog.Ln; 
	KernelLog.String("samplePerSecond = "); KernelLog.Int(samplePerSecond, 0); KernelLog.Ln; 
	KernelLog.String("bitsPerSample= "); KernelLog.Int(bitsPerSample, 0); KernelLog.Ln; 
	KernelLog.String("samples= "); KernelLog.Int(samples, 0); KernelLog.Ln; 
	
	NEW(sbuffer);
	sbuffer.len := samples;
	NEW(sbuffer.data, sbuffer.len);
	
	decoder.FillBuffer(sbuffer);
	

	
	(*! ************************** *)
	IF nofChannels = 1 THEN
	  	CASE bitsPerSample OF
	  		8:  fmt := AL.AL_FORMAT_MONO8
	  		|16: fmt := AL.AL_FORMAT_MONO16
	  	ELSE fmt:= AL.AL_FORMAT_MONO8;	
	  	END;
	ELSIF nofChannels = 2 THEN
	  	CASE bitsPerSample OF
	  		8:  fmt := AL.AL_FORMAT_STEREO8
	  		|16: fmt := AL.AL_FORMAT_STEREO16
	  	ELSE fmt:= AL.AL_FORMAT_STEREO8;	
	  	END;
	ELSE 
		fmt := AL.AL_FORMAT_MONO8
	END;
	
	KernelLog.String("fmt= "); KernelLog.Hex(fmt, 8); KernelLog.Ln; 
		
	AL.alGenBuffers(1, SYSTEM.ADR(buffer));      
	(*AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(sbuffer.data[0]), samples, samplePerSecond);*)
	AL.alBufferData(buffer, fmt, SYSTEM.ADR(sbuffer.data), samples, samplePerSecond); 
	 AL.alGenSources(1, SYSTEM.ADR(source));
	AL.alSourcei(source, AL.AL_BUFFER, buffer);

	 AL.alSourcef(source, AL.AL_PITCH, 1.0);
	AL.alSourcef(source, AL.AL_GAIN, 1.0); 
	srcPos := [3.0, 0.0, -3.0];
	AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
	AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE);
 
  
	lstPos := [0.0, 0.0, 0.0];
	AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));
	
	
	AL.alSourcePlay(source);
	KernelLog.String("-------- Playing ------- "); KernelLog.Ln; 


END PlayWav;

(** *)
PROCEDURE OpenDevice*;
VAR
  str: Strings.String;
    res : AL.ALboolean;
BEGIN
  device := AL.alcOpenDevice(""); (* use default *)
   str := AL.ALCGetString(device,   AL.ALC_DEFAULT_DEVICE_SPECIFIER);
   KernelLog.String("ALC_DEFAULT_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

  KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  context := AL.alcCreateContext(device, 0);
  KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  res := AL.alcMakeContextCurrent(context);
  KernelLog.String("02-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
KernelLog.String("03-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
 KernelLog.String("Device Opened" ); KernelLog.Ln; 	
END OpenDevice;

(** *)
PROCEDURE CloseDevice*;
VAR
 	res : AL.ALboolean;
BEGIN
	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(context);
	AL.alcCloseDevice(device);
	
  KernelLog.String("Device Closed. "); KernelLog.Ln; 		
END CloseDevice;

BEGIN
 NEW(timer);
END TestOpenALWav.

TestOpenALWav.OpenDevice ~      TestOpenALWav.CloseDevice ~ 

TestOpenAL0.Open1 ~
TestOpenAL0.Open2 ~
TestOpenAL0.Open3 ~

TestOpenALWav.PlayWav "test.wav" ~



SystemTools.FreeDownTo  OpenAL~ 