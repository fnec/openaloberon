MODULE TestOpenALWav; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Math, Strings, Kernel, KernelLog,
	Streams, SoundDevices, WAVCodec, Codecs, Files;


VAR  timer: Kernel.Timer;

PROCEDURE Open*;
VAR
	buffer : AL.ALuint;
	source : AL.ALuint;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
  
	i : LONGINT;
	res : AL.ALboolean;
	str: Strings.String;
 
 	frequency: LONGINT;
	size,  freq: AL.ALsizei;
	loop: AL.ALboolean;
	srcPos, lstPos: ARRAY [3] OF REAL;

	dres: LONGINT;
	file: Files.File;
	in: Files.Reader;
 	 
	decoder : Codecs.AudioDecoder;
	
	bufferPool : SoundDevices.BufferPool;
	sbuffer : SoundDevices.Buffer;
	
	nofChannels, samplePerSecond, bitsPerSample, samples : LONGINT;
		
BEGIN
	(* load sound file *)
	decoder := Codecs.GetAudioDecoder("WAV");
	IF decoder = NIL THEN
		KernelLog.String( "WAV decoder not installed"); KernelLog.Ln; 
		RETURN
	END;
	file := Files.Old("test.wav");
	IF file = NIL THEN
		KernelLog.String( "WAV file Open Error. "); KernelLog.Ln; 
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
	
(*    str := AL.ALCGetString(0, AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String(" ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
*)   
  device := AL.alcOpenDevice(""); (* use default *)
(*   str := AL.ALCGetString(device,   AL.ALC_DEFAULT_DEVICE_SPECIFIER);
   KernelLog.String("ALC_DEFAULT_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

  KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
*)
  context := AL.alcCreateContext(device, 0);

(*  KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
*)
  res := AL.alcMakeContextCurrent(context);
(*  KernelLog.String("02-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
KernelLog.String("03-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
*)
  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  
(*  IF AL.alIsBuffer(buffer) THEN
	  KernelLog.String("isbuffer"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotbuffer"); KernelLog.Ln; 
  END;
*)



  
    
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(sbuffer.data), samples, samplePerSecond);
  
(*  KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; *)

  AL.alGenSources(1, SYSTEM.ADR(source));
(*  IF AL.alIsSource(source) THEN
	  KernelLog.String("issource"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotsource"); KernelLog.Ln; 
  END;
*)

  srcPos := [3.0, 0.0, -3.0];

(* AL.alSourcef(source, AL.AL_PITCH, 1.0);
AL.alSourcef(source, AL.AL_GAIN, 1.0); *)
 AL.alSourcei(source, AL.AL_BUFFER, buffer);
 AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
 AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE);
 
  
 lstPos := [0.0, 0.0, 0.0];
 AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));

AL.alSourcePlay(source);

  timer.Sleep(2000);  
 
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

  (* Clear the things *)
(*  AL.alDeleteSources(1, SYSTEM.ADR(source));
  KernelLog.String("Deleted Source"); KernelLog.Ln; 
 AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
  KernelLog.String("Deleted Buffers"); KernelLog.Ln; 
*)  
  res := AL.alcMakeContextCurrent(0);
    KernelLog.String("Context 0"); KernelLog.Ln; 
AL.alcDestroyContext(context);
  AL.alcCloseDevice(device);
 KernelLog.String("closed. "); KernelLog.Ln; 	
END Open;

BEGIN
 NEW(timer);
END TestOpenALWav.


TestOpenALWav.Open ~

SystemTools.Free TestOpenALWav OpenAL~ 