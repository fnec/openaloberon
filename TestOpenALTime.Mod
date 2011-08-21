MODULE TestOpenALTime; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, SYSTEM, Math, Strings, Kernel, KernelLog;

VAR  timer: Kernel.MilliTimer;

PROCEDURE Open*;
VAR
  buffer : AL.ALuint;

    source : AL.ALuint;
  device : AL.ALCdevice;
  context : AL.ALCcontext;

  test : ARRAY 1000 OF CHAR;
  z : LONGINT;
  res : BOOLEAN;
  x: REAL;
  str: Strings.String;

 freq, bits: LONGINT;
 
BEGIN

  FOR z := 0 TO 999 DO
    test[z] := CHR(SHORT(ENTIER(100*Math.sin(z*(2*Math.pi)/50.0)+128)));
  END;  
  device := AL.alcOpenDevice(""); (* use default *)
   str := AL.ALCGetString(device,   AL.ALC_DEFAULT_DEVICE_SPECIFIER);
   KernelLog.String("ALC_DEFAULT_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

   str := AL.ALCGetString(device,    AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String(" ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 

   
  KernelLog.String("0-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  context := AL.alcCreateContext(device, 0);
  KernelLog.String("01-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
  res := AL.alcMakeContextCurrent(context);
  KernelLog.String("02-- alcGetError= "); KernelLog.Hex(AL.alcGetError(device), 4); KernelLog.Ln; 
KernelLog.String("03-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  str := AL.ALGetString(AL.AL_VERSION); KernelLog.String("AL_VERSION: "); KernelLog.String(str^); KernelLog.Ln; 
  str := AL.ALGetString(AL.AL_RENDERER); KernelLog.String("AL_RENDERER: ");  KernelLog.String(str^); KernelLog.Ln; 
  str := AL.ALGetString(AL.AL_VENDOR); KernelLog.String("AL_VENDOR: ");  KernelLog.String(str^); KernelLog.Ln; 
  str := AL.ALGetString(AL.AL_EXTENSIONS); KernelLog.String("AL_EXTENSIONS: ");  KernelLog.String(str^); KernelLog.Ln; 

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(test), 1000, 40000);
  KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

 AL.alGetBufferi(buffer, AL.AL_FREQUENCY, freq);
 KernelLog.String("freq= "); KernelLog.Int(freq, 0); KernelLog.Ln; 
  AL.alGetBufferi(buffer, AL.AL_BITS, bits);	
  KernelLog.String("bits= "); KernelLog.Int(bits, 0); KernelLog.Ln; 
 AL.alGetBufferi(buffer, AL.AL_SIZE, bits);	
  KernelLog.String("size= "); KernelLog.Int(bits, 0); KernelLog.Ln; 
   AL.alGetBufferi(buffer, AL.AL_CHANNELS, bits);	
  KernelLog.String("channels= "); KernelLog.Int(bits, 0); KernelLog.Ln; 

	
  AL.alGenSources(1, SYSTEM.ADR(source));

  AL.alSourcef(source, AL.AL_PITCH, 1.0);
  AL.alSourcef(source, AL.AL_GAIN, 1.0);
(*  AL.alSourcei(source, AL.AL_BUFFER, buffer); *)
  AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE); 
  AL.alSourcei(source, AL.AL_BUFFER, buffer);
  KernelLog.String("2- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
  
  AL.alGetSourcei(source, AL.AL_SOURCE_STATE, bits);
  KernelLog.String("SOURCE_STATE: "); KernelLog.Hex(bits, 4); KernelLog.Ln; 
  
   AL.alGetSourcei(source, AL.AL_BUFFER, bits);
  KernelLog.String("BUFFER: "); KernelLog.Int(bits, 0); KernelLog.Int(buffer, 15);  KernelLog.Ln; 
  
  
  AL.alSourcePlay(source);
  KernelLog.String("3- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  Kernel.SetTimer(timer, 2000);	
  
  WHILE ~ Kernel.Expired(timer) DO END;
(*  timer.Sleep(2000);*)
  
 AL.alSourceStop(source); 
 AL.alDeleteSources(1, SYSTEM.ADR(source));
 
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));

  AL.alcDestroyContext(context);
  AL.alcCloseDevice(device);
  KernelLog.String("closed. "); KernelLog.Ln; 	


END Open;


BEGIN

END TestOpenALTime.


TestOpenALTime.Open ~


SystemTools.Free TestOpenALTime OpenAL~ 