MODULE OpenALinfo; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  Commands, AL:=OpenAL, EFX:=OpenALefx, SYSTEM, Math, Strings,  KernelLog, Streams;

VAR 
	str: Strings.String;
	err: AL.ALCenum;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	res: AL.ALboolean;
	
PROCEDURE checkALErrors(linenum: LONGINT): AL.ALenum;
BEGIN
     err := AL.alGetError();
    IF (err # AL.AL_NO_ERROR) THEN
       KernelLog.String("OpenAL Error: ");
       str := AL.ALGetString(err);
       KernelLog.String(str^); KernelLog.String(",  @ "); KernelLog.Int(linenum, 0); KernelLog.Ln; 
    END;    
    RETURN err;
END checkALErrors;


PROCEDURE  checkALCErrors( device: AL.ALCdevice): AL.ALCenum;
BEGIN
     err := AL.alcGetError(device);
    IF err # AL.ALC_NO_ERROR THEN
       KernelLog.String("ALC Error: ");
       str := AL.ALCGetString(device, err);
       KernelLog.String(str^);  KernelLog.Ln; 
    END;          
    RETURN err;
END checkALCErrors;     

PROCEDURE printALCInfo(device: AL.ALCdevice );
VAR
    major, minor: AL.ALCint;    
BEGIN
    AL.alcGetIntegerv(device, AL.ALC_MAJOR_VERSION, 1, SYSTEM.ADR(major));
    AL.alcGetIntegerv(device, AL.ALC_MINOR_VERSION, 1, SYSTEM.ADR(minor));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("ALC version: "); KernelLog.Int(major, 0); KernelLog.String(".");  KernelLog.Int(minor, 0); KernelLog.Ln; 
    END;
        
    IF device # 0 THEN   
        KernelLog.String("ALC extensions: "); 
        str := AL.ALCGetString(device, AL.ALC_EXTENSIONS);
        KernelLog.String(str^); KernelLog.Ln; 
        err := checkALCErrors(device);
   END;
   KernelLog.Ln; 
END printALCInfo;

PROCEDURE printALInfo();
BEGIN

    KernelLog.String("OpenAL vendor string: ");  str := AL.ALGetString(AL.AL_VENDOR); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL renderer string: "); str := AL.ALGetString(AL.AL_RENDERER); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL version string: "); str := AL.ALGetString(AL.AL_VERSION); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL extensions:  "); str := AL.ALGetString(AL.AL_EXTENSIONS); KernelLog.String(str^); KernelLog.Ln; 
     
    err := checkALErrors(1);
    KernelLog.Ln; 
END printALInfo;

PROCEDURE printEFXInfo(device: AL.ALCdevice );
VAR
    major, minor, sends: AL.ALCint;
    obj: AL.ALuint ;
    i:LONGINT;
    filters, effects : ARRAY [*] OF AL.ALenum;
    
BEGIN    
    filters :=[
        EFX.AL_FILTER_LOWPASS, EFX.AL_FILTER_HIGHPASS, EFX.AL_FILTER_BANDPASS,
        EFX.AL_FILTER_NULL];
   
   (* char filterNames[] = "Low-pass,High-pass,Band-pass,";*)
    effects := [
        EFX.AL_EFFECT_EAXREVERB, EFX.AL_EFFECT_REVERB, EFX.AL_EFFECT_CHORUS,
        EFX.AL_EFFECT_DISTORTION, EFX.AL_EFFECT_ECHO, EFX.AL_EFFECT_FLANGER,
        EFX.AL_EFFECT_FREQUENCY_SHIFTER, EFX.AL_EFFECT_VOCAL_MORPHER,
        EFX.AL_EFFECT_PITCH_SHIFTER, EFX.AL_EFFECT_RING_MODULATOR, EFX.AL_EFFECT_AUTOWAH,
        EFX.AL_EFFECT_COMPRESSOR, EFX.AL_EFFECT_EQUALIZER, EFX.AL_EFFECT_NULL
    ];
(*    char effectNames[] = "EAX Reverb,Reverb,Chorus,Distortion,Echo,Flanger,"
                         "Frequency Shifter,Vocal Morpher,Pitch Shifter,"
                         "Ring Modulator,Autowah,Compressor,Equalizer,"; *)
 (*   char *current;*)

    IF ~AL.alcIsExtensionPresent(device, "ALC_EXT_EFX") THEN   
        KernelLog.String("EFX not available"); KernelLog.Ln; 
        RETURN;
   END;

    AL.alcGetIntegerv(device, EFX.ALC_EFX_MAJOR_VERSION, 1, SYSTEM.ADR(major));
    AL.alcGetIntegerv(device, EFX.ALC_EFX_MINOR_VERSION, 1, SYSTEM.ADR(minor));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("EFX version: "); KernelLog.Int(major, 0); KernelLog.String("."); KernelLog.Int(minor, 0); KernelLog.Ln; 
    END;    

    AL.alcGetIntegerv(device, EFX.ALC_MAX_AUXILIARY_SENDS, 1, SYSTEM.ADR(sends));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("Max auxiliary sends: "); KernelLog.Int(sends, 0); KernelLog.Ln; 
    END;
 
IF (checkALErrors(2) # AL.AL_NO_ERROR)       OR 
       (EFX.alGenFilters = NIL) OR (EFX.alDeleteFilters = NIL) OR (EFX.alFilteri= NIL)  OR
       (EFX.alGenEffects= NIL) OR (EFX.alDeleteEffects= NIL) OR (EFX.alEffecti= NIL) THEN
    
        KernelLog.String("!!! Missing EFX functions !!!"); KernelLog.Ln; 
        RETURN
 END;   
(*
    EFX.alGenFilters(1, SYSTEM.ADR(obj));
    IF (checkALErrors() = AL.AL_NO_ERROR) THEN
    
        current = filterNames;
        for(i = 0;filters[i] != AL_FILTER_NULL;i++)
        {
            char *next = strchr(current, ',');

            EFX.alFilteri(obj, AL_FILTER_TYPE, filters[i]);
            if(AL.alGetError() = AL.AL_NO_ERROR)
                current = next+1;
            else
                memmove(current, next+1, strlen(next));
        }
        EFX.alDeleteFilters(1, SYSTEM.ADR(obj));
        checkALErrors();

        printf("Supported filters:");
        printList(filterNames, ',');
    }

    EFX.alGenEffects(1, &obj);
    if(checkALErrors() = AL.AL_NO_ERROR)
    {
        current = effectNames;
        for(i = 0;effects[i] != AL_EFFECT_NULL;i++)
        {
            char *next = strchr(current, ',');

            EFX.alEffecti(obj, AL_EFFECT_TYPE, effects[i]);
            if(AL.alGetError() = AL.AL_NO_ERROR)
                current = next+1;
            else
                memmove(current, next+1, strlen(next));
        }
        EFX.alDeleteEffects(1, SYSTEM.ADR(obj));
        checkALErrors();

        printf("Supported effects:");
        printList(effectNames, ',');
    }
    *)
END printEFXInfo;



PROCEDURE Open*(cmd: Commands.Context);
VAR  
  i : LONGINT;
  dname: ARRAY 64 OF CHAR;	
BEGIN
 
 IF ~ cmd.arg.GetString(dname) THEN dname := "" END;
 
 KernelLog.String("Available playback devices: "); 
 
  IF AL.alcIsExtensionPresent(0, "ALC_ENUMERATE_ALL_EXT")  THEN
  	str :=AL.ALCGetString(0, AL.ALC_ALL_DEVICES_SPECIFIER);
       KernelLog.String(str^); KernelLog.Ln;  
  ELSE
  	str := AL.ALCGetString(0, AL.ALC_DEVICE_SPECIFIER);
       KernelLog.String(str^); KernelLog.Ln;    	
  END;

  KernelLog.String("Available capture devices: ");
  str := AL.ALCGetString(0, AL.ALC_CAPTURE_DEVICE_SPECIFIER);
  KernelLog.String(str^); KernelLog.Ln; 
   
 KernelLog.String("Default playback device:");
 str := AL.ALCGetString(0, AL.ALC_DEFAULT_DEVICE_SPECIFIER);
 KernelLog.String(str^); KernelLog.Ln;
 
 KernelLog.String("Default capture device: ");
 str := AL.ALCGetString(0, AL.ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
 KernelLog.String(str^); KernelLog.Ln;
 
  device := AL.alcOpenDevice(dname); (* use default *)
  IF device = 0 THEN 
	KernelLog.String("!!! Failed to open ");
	KernelLog.String(dname); KernelLog.String("default device !!!"); KernelLog.Ln; 
	RETURN
  END;
  
  

   str := AL.ALCGetString(device,   AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String("** Info for device "); KernelLog.String(str^); KernelLog.String(" **"); KernelLog.Ln; 
   
  
  
    printALCInfo(device);

    context := AL.alcCreateContext(device, 0);
    
    IF (context = 0) OR  (~ AL.alcMakeContextCurrent(context) ) THEN    
	        IF context # 0 THEN   AL.alcDestroyContext(context); END;
        AL.alcCloseDevice(device);
        KernelLog.String("!!! Failed to set a context !!!"); KernelLog.Ln; KernelLog.Ln; 
        RETURN;
   END;

    printALInfo();
    
   printEFXInfo(device); 
    
   

    res := AL.alcMakeContextCurrent(0);
    AL.alcDestroyContext(context);
    AL.alcCloseDevice(device);




END Open;

BEGIN

END OpenALinfo.


OpenALinfo.Open "" ~

SystemTools.Free OpenALinfo OpenALefx OpenAL~ 