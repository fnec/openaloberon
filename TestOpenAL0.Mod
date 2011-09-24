MODULE TestOpenAL0; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Math, Strings, Kernel, KernelLog;

VAR
	 timer: Kernel.Timer;
	 mtimer: Kernel.MilliTimer;
  device : AL.ALCdevice;
  context : AL.ALCcontext;

	 
PROCEDURE Open1*;
VAR
  buffer : AL.ALuint;

    source : AL.ALuint;

 (* test : ARRAY 1000 OF CHAR;*)
 test : POINTER TO ARRAY OF CHAR;
  z : LONGINT;


istate: AL.ALint;
  
BEGIN
  


NEW(test, 1000);
  
  FOR z := 0 TO 999 DO
    test[z] := CHR(SHORT(ENTIER(128*Math.sin(z*(2*Math.pi)/9.0)+128)));
  END;  
  

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(test[0]), 1000, 11024);
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
   

(*  AL.alSourceStop(source); *)
 
  AL.alDeleteSources(1, SYSTEM.ADR(source));
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
  KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

END Open1;

PROCEDURE Open2*;
CONST  D2R = 0.0174532925;
VAR
  buffer : AL.ALuint;
    source : AL.ALuint;
  
  data: POINTER TO ARRAY OF CHAR;
  i : LONGINT;

  x: REAL;
  str: Strings.String;
  samples: LONGINT;
  frequency: LONGINT;
 size,  freq: AL.ALsizei;

 srcPos, lstPos: ARRAY [3] OF REAL;
istate: AL.ALint;

BEGIN
 
(*    str := AL.ALCGetString(0, AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String(" ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
*)   
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
 
  size := freq; (* We don't need an higher frequency than the signal*)

 NEW( data, size);
 
  FOR i := 0 TO size-1 DO
    x := i * 360.0 / samples;
   data[i]  := CHR(SHORT(ENTIER(128*Math.sin(x * D2R)  + 128))) ; (* Clamp to [0,255] *)
  END;    
    
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


(* AL.alSourceStop(source); *)
  (* Clear the things *)
 AL.alDeleteSources(1, SYSTEM.ADR(source));
 AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 
END Open2;


(* 16 bit data *)
PROCEDURE Open3*;
VAR
  buffer : AL.ALuint;

    source : AL.ALuint;

 test : POINTER TO ARRAY OF INTEGER;
  z : LONGINT;

istate: AL.ALint;
  
BEGIN
 
NEW(test, 1000);
  
  FOR z := 0 TO 999 DO
    test[z] := SHORT(ENTIER(30000*Math.sin(z*(2*Math.pi)/9.0)+32768));
  END;  
  

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO16, SYSTEM.ADR(test[0]), 1000, 11024);
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

(*   Kernel.SetTimer(mtimer,2000);

   WHILE ~ Kernel.Expired(mtimer) DO
	END;
*)	
   timer.Sleep(2000);
   
 (* AL.alSourceStop(source);*)
 
  AL.alDeleteSources(1, SYSTEM.ADR(source));
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
    
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

END Open3;

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

BEGIN
	
  AL.alcDestroyContext(context);
  AL.alcCloseDevice(device);
  KernelLog.String("Device Closed. "); KernelLog.Ln; 		
END CloseDevice;

BEGIN
 NEW(timer);
END TestOpenAL0.

TestOpenAL0.OpenDevice ~ TestOpenAL0.CloseDevice ~ 

TestOpenAL0.Open1 ~

TestOpenAL0.Open2 ~

TestOpenAL0.Open3 ~

SystemTools.FreeDownTo OpenAL~ 