MODULE TestOpenALWav; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Kernel, KernelLog, SoundDevices, Codecs, Files;


VAR  timer: Kernel.Timer;

PROCEDURE Open*;
VAR
	buffer : AL.ALuint;
	source : AL.ALuint;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
  	res : AL.ALboolean;
	srcPos, lstPos: ARRAY [3] OF REAL;

	dres: LONGINT;
	file: Files.File;
	in: Files.Reader;
 	 
	decoder : Codecs.AudioDecoder;
	sbuffer : SoundDevices.Buffer;
	
	nofChannels, samplePerSecond, bitsPerSample, samples : LONGINT;
	istate: AL.ALint;
		
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
	
	device := AL.alcOpenDevice(""); (* use default *)
  
	context := AL.alcCreateContext(device, 0);
	res := AL.alcMakeContextCurrent(context);
  
	AL.alGenBuffers(1, SYSTEM.ADR(buffer));      
	AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(sbuffer.data), samples, samplePerSecond);

	 AL.alGenSources(1, SYSTEM.ADR(source));
	AL.alSourcei(source, AL.AL_BUFFER, buffer);

	(* AL.alSourcef(source, AL.AL_PITCH, 1.0);
	AL.alSourcef(source, AL.AL_GAIN, 1.0); *)
	srcPos := [3.0, 0.0, -3.0];
	AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
	(* AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE);*)
 
  
	lstPos := [0.0, 0.0, 0.0];
	AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));
	
	KernelLog.String("-------- Playing ------- "); KernelLog.Ln; 
	AL.alSourcePlay(source);

	AL.alGetSourcei(source, AL.AL_SOURCE_STATE, istate);
	KernelLog.String("source state= "); KernelLog.Hex(istate, 4); KernelLog.Ln; 
 
	REPEAT
		timer.Sleep(10); 
		KernelLog.Char("x");
		AL.alGetSourcei(source, AL.AL_SOURCE_STATE, istate);
	UNTIL  istate # AL.AL_PLAYING;
 	KernelLog.Ln; 
	KernelLog.String("-------- Finished ------- "); KernelLog.Ln; 

	(* Clear the things *)
	AL.alDeleteSources(1, SYSTEM.ADR(source));
	AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
 
	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(context);
	AL.alcCloseDevice(device);

	KernelLog.String("closed. "); KernelLog.Ln; 	
END Open;

BEGIN
 NEW(timer);
END TestOpenALWav.


TestOpenALWav.Open ~

SystemTools.Free TestOpenALWav OpenAL~ 