MODULE TestOpenALWav; (** AUTHOR "fnecati"; PURPOSE "test WAV file playing using OpenAL"; *)

IMPORT  AL:=OpenAL, SYSTEM, KernelLog, SoundDevices, Codecs, Files, Strings,Commands;

VAR
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	buffer : AL.ALuint;
	source : AL.ALuint;
	pitch, gain: AL.ALfloat;

			
PROCEDURE LoadWav*(cmd: Commands.Context);
VAR
	fmt: AL.ALuint; 
	srcPos, lstPos: ARRAY [3] OF AL.ALfloat;

	dres: LONGINT;
	
	file: Files.File;
	in: Files.Reader;
 	 
	decoder : Codecs.AudioDecoder;
	sbuffer : SoundDevices.Buffer;
	
	nofChannels, samplePerSecond, bitsPerSample, samples, sizeBytes : LONGINT;
	fname: ARRAY 256 OF CHAR;
		
BEGIN 
	IF ~cmd.arg.GetString(fname) THEN
		KernelLog.String("invalid filename"); KernelLog.Ln; 
		RETURN;
	END;
	KernelLog.String("arg fname= "); KernelLog.String(fname); KernelLog.Ln; 
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

	(* data size in bytes *)
	sizeBytes := samples*(bitsPerSample DIV 8);
	
	NEW(sbuffer);
	sbuffer.len := sizeBytes;
	NEW(sbuffer.data, sbuffer.len);
	
	decoder.FillBuffer(sbuffer);
	
	(* format of wav  *)
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
	
	
  (* Clear the source and buffers if they are not empty *)
	 IF source # 0 THEN AL.alDeleteSources(1, SYSTEM.ADR(source)); source := 0; END;
	 IF buffer # 0 THEN AL.alDeleteBuffers(1, SYSTEM.ADR(buffer)); buffer := 0; END;
		
	AL.alGenBuffers(1, SYSTEM.ADR(buffer));      
	KernelLog.String("00- loadwav alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
	
	AL.alBufferData(buffer, fmt, SYSTEM.ADR(sbuffer.data), sizeBytes, samplePerSecond); 
	KernelLog.String("0- loadwav alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
	
	 AL.alGenSources(1, SYSTEM.ADR(source));
	 	
	pitch := 1.0;
	gain := 1.0;
	 AL.alSourcef(source, AL.AL_PITCH, pitch);
	AL.alSourcef(source, AL.AL_GAIN, gain); 
	srcPos := [0.0, 0.0, 0.0];
	AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
	AL.alSourcei(source, AL.AL_LOOPING, AL.AL_FALSE);
	 AL.alSourcei(source, AL.AL_BUFFER, buffer);
 
	lstPos := [0.0, 0.0, 0.0];
	AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));
	KernelLog.String("x- loadwav alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
END LoadWav;

(** *)
PROCEDURE Play*;
BEGIN
	AL.alSourcePlay(source);
		KernelLog.String("Playing alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
END Play;

PROCEDURE IncGain*;
BEGIN
	gain := gain + 0.1;
	IF gain > 1.0 THEN gain := 1.0; END;
	AL.alSourcef(source, AL.AL_GAIN, gain);
END IncGain;

PROCEDURE DecGain*;
BEGIN
	gain := gain - 0.1;
	IF gain < 0.0 THEN gain := 0.0; END;
	AL.alSourcef(source, AL.AL_GAIN, gain);
END DecGain;

PROCEDURE IncPitch*;
BEGIN
	pitch := pitch + 0.1;
	IF pitch > 1.0 THEN pitch := 1.0; END;
	AL.alSourcef(source, AL.AL_PITCH, pitch);
END IncPitch;

PROCEDURE DecPitch*;
BEGIN
	pitch := pitch - 0.1;
	IF pitch < 0 THEN pitch := 0.0; END;
	AL.alSourcef(source, AL.AL_PITCH, pitch);
END DecPitch;

(** *)
PROCEDURE OpenDevice*;
VAR
	str: Strings.String;
	res : AL.ALboolean;
BEGIN
	IF device # 0 THEN 
		KernelLog.String("Device already Open" ); KernelLog.Ln;
		RETURN 
	END;
	device := AL.alcOpenDevice(""); (* use default *)
	str := AL.ALCGetString(device,   AL.ALC_DEVICE_SPECIFIER);
		KernelLog.String("ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
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
	IF device = 0 THEN 
		KernelLog.String("Device already Closed" ); KernelLog.Ln;
		RETURN 
	END;
  (* Clear the source and buffers if they are not empty *)  	
	 IF source # 0 THEN AL.alDeleteSources(1, SYSTEM.ADR(source)); source := 0;  END;
	 IF buffer # 0 THEN AL.alDeleteBuffers(1, SYSTEM.ADR(buffer)); buffer := 0;  END;
	 
	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(context); context := 0;
	AL.alcCloseDevice(device); device :=0; 
	
  KernelLog.String("Device Closed. "); KernelLog.Ln; 		
END CloseDevice;

BEGIN

END TestOpenALWav.

TestOpenALWav.OpenDevice ~      TestOpenALWav.CloseDevice ~ 

TestOpenALWav.LoadWav "test.wav" ~
TestOpenALWav.LoadWav "rugby.wav" ~
TestOpenALWav.LoadWav "s11k16bitpcm.wav" ~
TestOpenALWav.LoadWav "s11k8bitpcm.wav" ~
TestOpenALWav.LoadWav "s11kulaw.wav" ~
 TestOpenALWav.LoadWav "s8k16bitpcm.wav" ~
TestOpenALWav.LoadWav "s8k8bitpcm.wav" ~
TestOpenALWav.LoadWav "s8kulaw.wav" ~


TestOpenALWav.Play ~  


TestOpenALWav.DecGain ~  TestOpenALWav.IncGain~  

TestOpenALWav.DecPitch ~  TestOpenALWav.IncPitch~  


SystemTools.FreeDownTo  OpenAL~ 

OpenALinfo.Do~ 