MODULE OpenALUtil; (** AUTHOR "fnecati"; PURPOSE "OpenAL utilities"; *)

IMPORT  AL:=OpenAL, SYSTEM, KernelLog, SoundDevices, Codecs, Streams, Files, Modules, Strings;

CONST 
	debug = TRUE;
	
	openalPlayFile ="openalplay.ini"; (* configuration file for available list of play playdevices *) 
	openalCapFile ="openalcap.ini";    (* configuration file for available list of capture playdevices *) 
	
VAR
	playdevice, capturedevice: AL.ALCdevice;
	playcontext , capturecontext : AL.ALCcontext;
	
	sbuffer  : SoundDevices.Buffer;	
	wavdecoder : Codecs.AudioDecoder;
	
(** get device name from ini file *)
PROCEDURE LoadDeviceName(CONST fname: ARRAY OF CHAR; VAR sdev: ARRAY OF CHAR);
VAR file: Files.File;
	rd: Files.Reader;
	found: BOOLEAN;
BEGIN
	sdev := ""; (* default playdevice*)
	file := Files.Old(fname);
	IF file = NIL THEN RETURN ; END;
	Files.OpenReader(rd, file, 0);
	rd.SkipWhitespace();
	found := FALSE ;
	WHILE  (~found) & (rd.res = Streams.Ok)  DO
		rd.Ln(sdev);
		Strings.Trim(sdev, " ");
		found := sdev[0] # "#";
		rd.SkipWhitespace();
	END;	
END LoadDeviceName;

(** clear and write al device error *)	
PROCEDURE ALWriteError*(CONST tit: ARRAY OF CHAR);
VAR s: Strings.String;
	err: AL.ALuint;
BEGIN
	err := AL.alGetError();
	IF ~ debug THEN RETURN END;
	s := AL.ALGetString(err);
	IF s # NIL THEN
		KernelLog.String(tit);  KernelLog.String(s^); KernelLog.Ln; 
	END;
END ALWriteError;

(** clear and write alc device error *)
PROCEDURE ALCWriteError*(d: AL.ALCdevice; CONST tit: ARRAY OF CHAR);
VAR s: Strings.String;
	err: AL.ALuint;
BEGIN
	err := AL.alcGetError(d);
	IF ~ debug THEN RETURN END;
	s := AL.ALCGetString(d, err);
	IF s # NIL THEN
		KernelLog.String(tit); KernelLog.String(s^); KernelLog.Ln; 
	END;
END ALCWriteError;


(** load wave file to the created buffer buf*)
PROCEDURE LoadWavFile*(VAR buf: AL.ALuint; CONST fname: ARRAY OF CHAR);
VAR
	fmt: AL.ALuint; 
	dres: LONGINT;
	file: Files.File;
	in: Files.Reader;
	nofChannels, samplePerSecond, bitsPerSample, samples, sizeBytes : LONGINT;
BEGIN 
	
	file := Files.Old(fname);
	IF file = NIL THEN
		KernelLog.String(fname);  KernelLog.String( ": WAV file Open Error. "); KernelLog.Ln; 
		RETURN 
	END;

	Files.OpenReader( in, file, 0);
	wavdecoder.Open(in, dres);
	IF dres # Codecs.ResOk THEN 
		KernelLog.String( "WAV decoder Open Error. "); KernelLog.Ln; 
		RETURN 
	END;
	
	wavdecoder.GetAudioInfo(nofChannels, samplePerSecond, bitsPerSample);
	samples := wavdecoder.GetTotalSamples();
	(* data size in bytes *)
	sizeBytes := samples*(bitsPerSample DIV 8)*nofChannels;
	
	IF debug THEN
		KernelLog.String("nofChannels= "); KernelLog.Int(nofChannels, 0); KernelLog.Ln; 
		KernelLog.String("samplePerSecond = "); KernelLog.Int(samplePerSecond, 0); KernelLog.Ln; 
		KernelLog.String("bitsPerSample= "); KernelLog.Int(bitsPerSample, 0); KernelLog.Ln; 
		KernelLog.String("samples= "); KernelLog.Int(samples, 0); KernelLog.Ln; 
		KernelLog.String("sizeBytes= "); KernelLog.Int(sizeBytes, 0); KernelLog.Ln; 		
	END;

	
	NEW(sbuffer);
	sbuffer.len := sizeBytes;
	NEW(sbuffer.data, sbuffer.len);
	
	wavdecoder.FillBuffer(sbuffer);
	
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

	IF debug THEN
		KernelLog.String("fmt= "); KernelLog.Hex(fmt, 8); KernelLog.Ln; 
	END;
	
	AL.alBufferData(buf, fmt, SYSTEM.ADR(sbuffer.data[0]), sizeBytes, samplePerSecond); 
	
	ALWriteError("LoadWavFile :  ");
END LoadWavFile;


(** set source to looping mode *)
PROCEDURE SetLoop*(source: AL.ALuint; loop: BOOLEAN);
BEGIN
IF loop THEN
	AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE); 
ELSE
	AL.alSourcei(source, AL.AL_LOOPING, AL.AL_FALSE); 
END
END SetLoop;

(** set gain of source *)
PROCEDURE SetGain*(source: AL.ALuint; gain: AL.ALfloat);
VAR g: AL.ALfloat;
BEGIN
	g := gain;
	IF g > 1.0 THEN g := 1.0;
	ELSIF g < 0 THEN g := 0.0;
	END;
	AL.alSourcef(source, AL.AL_GAIN, g);
END SetGain;

(** set pitch of the sound *)
PROCEDURE SetPitch*(source: AL.ALuint; pitch: AL.ALfloat);
VAR p: AL.ALfloat;
BEGIN
	p := pitch;
	IF p > 5.0 THEN p := 5.0;
	ELSIF  p< 0 THEN p := 0.0;
	END;
	AL.alSourcef(source, AL.AL_PITCH, p);
END SetPitch;


PROCEDURE MakeContextCurrent*;
VAR res: AL.ALboolean;
BEGIN
	res := AL.alcMakeContextCurrent(playcontext);  
	ALCWriteError(playdevice, "Device alcMakeContextCurrent Error: ");				
END MakeContextCurrent;

PROCEDURE MakeContextCurrentNil*;
VAR res: AL.ALboolean;
BEGIN
	res := AL.alcMakeContextCurrent(0);  
	ALCWriteError(playdevice, "Device alcMakeContextCurrentNil Error: ");				
END MakeContextCurrentNil;


(** open play device, read configuration from ini file *)
PROCEDURE OpenPlayDevice*;
VAR
	str: Strings.String;
	res : AL.ALboolean;
	s: ARRAY 128 OF CHAR;
BEGIN
	 LoadDeviceName(openalPlayFile, s);
	 KernelLog.String("Device from configuration file: ");  KernelLog.String(s); KernelLog.Ln; 
	playdevice := AL.alcOpenDevice(s);
	ALCWriteError(playdevice, "Device Open Error: ");	
	KernelLog.String("opened dev= "); KernelLog.Int(playdevice, 0); KernelLog.Ln;
	
	IF playdevice = 0 THEN RETURN END;
	
	str := AL.ALCGetString(playdevice,   AL.ALC_DEVICE_SPECIFIER);
		ALCWriteError(playdevice, "Device Specifier Error: ");	
		KernelLog.String("ALC_DEVICE_SPECIFIER: "); KernelLog.String(str^); KernelLog.Ln; 
		
	playcontext := AL.alcCreateContext(playdevice, 0);
			ALCWriteError(playdevice, "Device alcCreateContext Error: ");	

	res := AL.alcMakeContextCurrent(playcontext);  
			ALCWriteError(playdevice, "Device alcMakeContextCurrent Error: ");
			ALWriteError("x-OpenDevice: ");

	(* load sound decoder *)
	wavdecoder := Codecs.GetAudioDecoder("WAV");
	IF wavdecoder = NIL THEN
		KernelLog.String( "WAV decoder not installed"); KernelLog.Ln; 
	END;
			
	KernelLog.String("Device Opened" ); KernelLog.Ln; 	
END OpenPlayDevice;

(** close playing device *)
PROCEDURE ClosePlayDevice*;
VAR
 	res : AL.ALboolean;
BEGIN 
	IF playdevice = 0 THEN 
		KernelLog.String("Device already Closed" ); KernelLog.Ln;
		RETURN 
	END;
 
	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(playcontext);  
	res := AL.alcCloseDevice(playdevice); 

	KernelLog.String("closed dev= "); KernelLog.Int(playdevice, 0); KernelLog.Ln;
	KernelLog.String("close res: ");  KernelLog.Boolean(res); KernelLog.Ln; 		
	KernelLog.String("Device Closed. "); KernelLog.Ln; 		
END ClosePlayDevice;

(* not tested, open capture device, read from configuration file *)
PROCEDURE OpenCaptureDevice*(freq: LONGINT; fmt: AL.ALenum; samples: LONGINT);
VAR
	str: Strings.String;
	res : AL.ALboolean;
	s: ARRAY 128 OF CHAR;
BEGIN 
	 LoadDeviceName(openalCapFile, s);
	 KernelLog.String("Device from configuration file: ");  KernelLog.String(s); KernelLog.Ln; 
	 
	capturedevice := AL.alcCaptureOpenDevice(s, freq, fmt, samples); (* use default *)
	str := AL.ALCGetString(capturedevice,   AL.ALC_CAPTURE_DEVICE_SPECIFIER);
	KernelLog.String("ALC_CAPTURE_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

	KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(capturedevice), 4); KernelLog.Ln; 
	capturecontext := AL.alcCreateContext(capturedevice, 0);
	KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(capturedevice), 4); KernelLog.Ln; 
	res := AL.alcMakeContextCurrent(capturecontext);
			
	KernelLog.String("Capture Device Opened" ); KernelLog.Ln; 	
END OpenCaptureDevice;

(** close the capture device *)
PROCEDURE CloseCaptureDevice*;
VAR
 	res : AL.ALboolean;
BEGIN 
	IF capturedevice = 0 THEN 
		KernelLog.String("Capture Device already Closed" ); KernelLog.Ln;
		RETURN 
	END;
 
 	AL.alcDestroyContext(capturecontext);  
 	res := AL.alcCaptureCloseDevice(capturedevice);
	 
  KernelLog.String("Capture Device Closed. "); KernelLog.Ln; 		
END CloseCaptureDevice;


PROCEDURE OnClose;
BEGIN 
IF playdevice # 0 THEN ClosePlayDevice; END;
IF capturedevice # 0 THEN CloseCaptureDevice; END;
END OnClose;

BEGIN
	(* load sound decoder *)
		NEW(wavdecoder);
		OpenPlayDevice;
		Modules.InstallTermHandler(OnClose) ;
END OpenALUtil.
