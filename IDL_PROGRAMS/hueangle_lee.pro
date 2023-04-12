; $ID:	HUEANGLE_LEE.PRO,	2023-03-13-13,	USER-KJWH	$
  FUNCTION HUEANGLE_LEE, A412=A412, A443=A443, A490=A490, A510=A510, A567=A567,$
                         BBP412=BBP142, BBP443=BBP443, BBPY=BBPY, $
                         DEPTHS=DEPTHS, SENSOR=SENSOR, $
                         INIT=INIT
                         

;+
; NAME:
;   HUEANGLE_LEE
;
; PURPOSE:
;   This function calculates the hue angle and color at depth based on work by Zhongping Lee
;
; CATEGORY:
;   PARHUEANGLE_FUNCTIONS
;
; CALLING SEQUENCE:
;   HUEANGLE_LEE, A412=A412, A443=A443, A490=A490, A510=A510, A567=A567,BBP412=BBP142, BBP443=BBP443, BBPY=BBPY, DEPTHS=DEPTHS, SENSOR=SENSOR
;
; REQUIRED INPUTS:
;   A412............ Total absorpation at 412 nm
;   A443............ Total absorpation at 412 nm
;   A490............ Total absorpation at 412 nm
;   A510............ Total absorpation at 412 nm
;   A567............ Total absorpation at 412 nm
;   BBP412.......... Backscattering at 412 nm
;   BBP443.......... Backscattering at 443 nm
;   BBPY............ Backscattering at ???
;   DEPTHS.......... The depth(s) for the output data
;   SENSOR.......... The name of the input data sensor (used to determine wavelength specific coefficients)
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   INIT........... Use INIT to reset the information stored in COMMON memory
;
; OUTPUTS:
;   An array of Hue angle data
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   _HUEANGLE_LEE - Contains the constants stored in huedata_main.csv
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   Lee, Z., S. Shang, Y. Li, K. Luis, M. Dai, and Y. Wang (2022), Three-Dimensional Variation in Light Quality in the Upper Water Column Revealed With a Single Parameter, IEEE Transactions on Geoscience and Remote Sensing, 60, 1-10, doi:10.1109/TGRS.2021.3093014.
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 13, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 13, 2023 - KJWH: Initial code written - adapted from Zhongping Lee's "main_hue_kd3_piexl"
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'HUEANGLE_LEE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up the constants in COMMON memory
  COMMON _HUEANGLE_LEE, CONSTANTS, BAND, ACEOF0, ACEOF1, ACEOF2, ACEOF3, ACEOF4, AW, ES, XINIT, YINIT, ZINIT
  IF KEYWORD_SET(INIT) OR IDLTYPE(CONSTANTS) NE 'STRUCT' THEN CONSTANTS = []
  
  IF CONSTANTS EQ [] THEN BEGIN                                                 ; Add constants to the COMMON memory if they are not already there
    CONSTANT_FILE = !S.HUE_ANGLE_LEE + 'huedata_main.csv'                       ; Read the constants data file
    CONSTANTS = CSV_READ(CONSTANT_FILE)
    BAND = CONSTANTS.BAND
    ACEOF0 = CONSTANTS.ACEOF0
    ACEOF1 = CONSTANTS.ACEOF1
    ACEOF2 = CONSTANTS.ACEOF2
    ACEOF3 = CONSTANTS.ACEOF3
    ACEOF4 = CONSTANTS.ACEOF4
    AW     = CONSTATNS.AW_LEE
    ES     = CONSTANTS.ES
    XINIT  = CONSTANTS.XINIT
    YINIT  = CONSTANTS.YINIT
    ZINIT  = CONSTANTS.ZINIT
  ENDIF
  N_BAND = N_ELEMENTS(BAND)
  
  
  ; ===> Get the wavelengths for the input sensor
  IF ~N_ELEMENTS(SENSOR) THEN MESSAGE, 'ERROR: Must provide input data sensor name in order to determine the wavelength coefficients.'
  CASE SENSOR OF
    'MODISA': BEGIN
      WAVEBANDS = [412.,443.,488.,532.,547.,667.]
      AW_BANDS = [0.0031, 0.0049, 0.0126, 0.0423, 0.0529, 0.4335]
      BBW = 0.0038*(400.0/WAVEBANDS)^4.3
    END  
    'OCCCI': BEGIN
      WAVEBANDS = [412.,443.,488.,510.,560.,665.]
      AW_BANDS = [0.0031, 0.0049, 0.0126, 0.0423, 0.0529, 0.4335]
      BBW = 0.0038*(400.0/WAVEBANDS)^4.3
    END  
  ENDCASE
  
  
  ; ===> Check the input depths
  N_DEPTHS = N_ELEMENTS(DEPTHS)
  IF N_DEPTHS EQ 0 THEN MESSAGE, 'ERROF: Must provide at least one depth.'
  
  
  ; ===> Check the dimensions of the input data 
  IF N_ELEMENTS(A412) NE N_ELEMENTS(A443) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(A490) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(A531) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(A547) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(BBP443) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(BBP488) OR $
     N_ELEMENTS(A412) NE N_ELEMENTS(BBPY) THEN MESSAGE, 'ERROR: Input data arrays must all have the same number of elements and dimensions.'
  
  ; ===> Set up the data arrays
  SZ = SIZE(A412,/STRUCT)                                                  ; Get the size and dimensions of the input data        
  PX = SZ.DIMENSIONS[0] & PY = SZ.DIMENSIONS[1]                                 ; Get the pixel dimensions
  IF SZ.N_DIMENSIONS EQ 1 THEN OUTARR = FLTARR(PX) ELSE OUTARR = FLTARR(PX,PY)  ; Create a blank output array
  OUTARR[*] = MISSINGS(OUTARR)                                                  ; Make the array "missing" data values
  
  A_EXPAND   = REPLICATE(MISSINGS(0.0),N_BAND)
  BBP_EXPAND = REPLICATE(MISSINGS(0.0),N_BAND)
  ETA        = REPLICATE(MISSINGS(0.0),N_BAND)
  KD         = REPLICATE(MISSINGS(0.0),N_BAND)
  ED         = REPLICATE(MISSINGS(0.0),N_BAND,N_DEPTHS)
  XCOLOR     = REPLICATE(MISSINGS(0.0),N_BAND,N_DEPTHS)
  YCOLOR     = REPLICATE(MISSINGS(0.0),N_BAND,N_DEPTHS)
  ZCOLOR     = REPLICATE(MISSINGS(0.0),N_BAND,N_DEPTHS)
  
  ; ===> Loop through the bands
  FOR B=0, N_BAND-1 DO BEGIN
    ; Expand the absorption data to all wavebands
    A_EXPAND[B]=AW[B]+ACOEF0[B]*(A412-AW_BANDS[0])+ $
                      ACOEF1[B]*(A443-AW_BANDS[1])+ $
                      ACOEF2[B]*(A488-AW_BANDS[2])+ $
                      ACOEF3[B]*(A531-AW_BANDS[3])+ $
                      ACOEF4[B]*(A547-AW_BANDS[4])
    
    IF B GE 16 THEN A_EXPAND[B]=AW[B]+0.2*A443   ;yhlee 2022-05-19 a(560)=aw+0.2*a443
      
    ; ===> Expand the backscattering data to all wavebands
    BBP_EXPAND[B]=BBP443*(443.0/BAND[B])^BBPY ;yhlee 2020-06-04
    
    ;eta
    ETA[B]=BBW[B]/(BBW[B]+BBP_EXPAND[B])
    
    ;kd
    KD[B]=(1.0+30.0*0.005)*A_EXPAND[B]+ $
      (1.0-0.265*ETA[B])*4.259*(1.0-0.52*(EXP(-10.8*A_EXPAND[B])))*(BBW[B]+BBP_EXPAND[B])
  
    ; ed ?
    ED[B,*]=ES[B]*EXP(-1.0*KD[B]*Z[*])
    
    ; ===> Get the X,Y,Z "colors" 
    XCOLOR[B,*]=XINIT[B]*ED[B,*]
    YCOLOR[B,*]=YINIT[B]*ED[B,*]
    ZCOLOR[B,*]=ZINIT[B]*ED[B,*]
  ENDFOR ; N_BANDS  
    
  ; ===> Search for missing data
  MISS_SUBS=WHERE(FINITE(ED, /INFINITY),COUNT_INF)
  IF COUNT_INF GT 0 THEN stop ;   CONTINUE
  
  FOR Z=0,N_DEPTHS-1 DO BEGIN
    XTOTAL=TOTAL(XCOLOR[*,Z],/NAN)
    YTOTAL=TOTAL(YCOLOR[*,Z],/NAN)
    ZTOTAL=TOTAL(ZCOLOR[*,Z],/NAN)
    XX=XTOTAL/(XTOTAL+YTOTAL+ZTOTAL)
    YY=YTOTAL/(XTOTAL+YTOTAL+ZTOTAL)
    COLOR_ALPHA[*,Z]=90.0-ATAN(XX-0.333,YY-0.333)*180.0/3.1415926
  ENDFOR ; N_DEPTH
  
  ; ===> Make variable null
  A_EXPAND=[]
  BBP_EXPAND=[]
  ETA=[]
  KD=[]
  ED=[]
  XCOLOR=[]
  YCOLOR=[]
  ZCOLOR=[]          
  
  RETURN, COLOR_ALPHA
  


END ; ***************** End of HUEANGLE_LEE *****************
