MODULE TestOpenAL0; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Math, Strings, Kernel, KernelLog;

VAR
	 timer: Kernel.Timer;

PROCEDURE Open1*;
VAR
  buffer : AL.ALuint;

    source : AL.ALuint;
  device : AL.ALCdevice;
  context : AL.ALCcontext;

  test : ARRAY 1000 OF CHAR;
  z : LONGINT;
  res : AL.ALboolean;
  str: Strings.String;

  
BEGIN

  FOR z := 0 TO 999 DO
    test[z] := CHR(SHORT(ENTIER(100*Math.sin(z*(2*Math.pi)/50.0)+128)));
  END;  
  
     str := AL.ALCGetString(0,  AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String(" ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
   
  device := AL.alcOpenDevice(""); (* use default *)
   str := AL.ALCGetString(device,   AL.ALC_DEFAULT_DEVICE_SPECIFIER);
   KernelLog.String("ALC_DEFAULT_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 



   
  KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  context := AL.alcCreateContext(device, 0);
  KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  res := AL.alcMakeContextCurrent(context);
  KernelLog.String("02-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
KernelLog.String("03-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(test), 1000, 10000(*11024*));
  KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenSources(1, SYSTEM.ADR(source));

  AL.alSourcef(source, AL.AL_PITCH, 1.0);
  AL.alSourcef(source, AL.AL_GAIN, 1.0);
(*  AL.alSourcei(source, AL.AL_BUFFER, buffer); *)
  AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE); 
  AL.alSourcei(source, AL.AL_BUFFER, buffer);
  KernelLog.String("2- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
  

  AL.alSourcePlay(source);
 
  KernelLog.String("3- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
   

   timer.Sleep(2000);
  
  AL.alSourceStop(source);
 
  AL.alDeleteSources(1, SYSTEM.ADR(source));
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
  
  AL.alcDestroyContext(context);
  AL.alcCloseDevice(device);
  KernelLog.String("closed. "); KernelLog.Ln; 	


END Open1;

PROCEDURE Open2*;
CONST  D2R = 0.0174532925;
VAR
  buffer : AL.ALuint;
    source : AL.ALuint;
  device : AL.ALCdevice;
  context : AL.ALCcontext;
  
  data: POINTER TO ARRAY OF CHAR;
  i : LONGINT;
  res : AL.ALboolean;
  x: REAL;
  str: Strings.String;
  samples: LONGINT;
  frequency: LONGINT;
 size,  freq: AL.ALsizei;

 srcPos, lstPos: ARRAY [3] OF REAL;

BEGIN
 
    str := AL.ALCGetString(0, AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String(" ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
   
  device := AL.alcOpenDevice(""); (* use default *)
   str := AL.ALCGetString(device,   AL.ALC_DEFAULT_DEVICE_SPECIFIER);
   KernelLog.String("ALC_DEFAULT_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

  KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  context := AL.alcCreateContext(device, 0);
  KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  res := AL.alcMakeContextCurrent(context);
  KernelLog.String("02-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
KernelLog.String("03-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  
  IF AL.alIsBuffer(buffer) THEN
	  KernelLog.String("isbuffer"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotbuffer"); KernelLog.Ln; 
  END;

 KernelLog.String("Generating sine wave on user parameters"); KernelLog.Ln; 
  (* Generate using math
   We want a note of 440 Hz. 32 samples for each oscillation
   for 1 seconds, means 440*32 bytes  
  *)
  
  frequency := 1000; (* which freaquency *)
  samples := 4; (* How many samples for the wave? [try me between 2 and 16] *)

freq := samples * frequency;
  KernelLog.String("We will use a sampling frequency equal to the signal frequency: sgnFreq * sgnSampl =");
  KernelLog.Int(frequency,0); KernelLog.String("x"); KernelLog.Int(samples,0); KernelLog.String("= "); KernelLog.Int(freq,0); KernelLog.Ln; 
  
  size := freq; (* We don't need an higher frequency than the signal*)

 NEW( data, size);
 
  FOR i := 0 TO size-1 DO
    x := i * 360.0 / samples;
   data[i]  := CHR(SHORT(ENTIER(Math.sin(x * D2R) * 128 + 128))) ; (* Clamp to [0,255] *)

  (* KernelLog.Int(i, 0); KernelLog.Int(ORD(data[i]), 5); KernelLog.Ln; *)
  END;    
 
   
  KernelLog.String("Values: fmt: "); KernelLog.Int(AL.AL_FORMAT_MONO8,0); KernelLog.Ln; 
   KernelLog.String("size= "); KernelLog.Int(size, 0); KernelLog.Ln; 
    KernelLog.String("freq= "); KernelLog.Int(freq, 0); KernelLog.Ln; 
    
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(data), samples, freq);
  
  KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenSources(1, SYSTEM.ADR(source));
  IF AL.alIsSource(source) THEN
	  KernelLog.String("issource"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotsource"); KernelLog.Ln; 
  END;


  srcPos := [-0.3, 0.0, -3.0];

AL.alSourcef(source, AL.AL_PITCH, 1.0);
AL.alSourcef(source, AL.AL_GAIN, 1.0);
 
 AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
 AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE);
 AL.alSourcei(source, AL.AL_BUFFER, buffer);
  
 lstPos := [0.0, 0.0, -3.0];
 AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));

 AL.alSourcePlay(source);

 timer.Sleep(2000);
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

AL.alSourceStop(source);
  (* Clear the things *)
 AL.alDeleteSources(1, SYSTEM.ADR(source));
 AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));

AL.alcDestroyContext(context);
  AL.alcCloseDevice(device);
 KernelLog.String("closed. "); KernelLog.Ln; 	
END Open2;

BEGIN
 NEW(timer);
END TestOpenAL0.


TestOpenAL0.Open1 ~

TestOpenAL0.Open2 ~

SystemTools.Free TestOpenAL0 OpenAL~ 