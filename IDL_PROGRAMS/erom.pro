;+
; NAME:
;
;      EROM
;
; PURPOSE:
;
;       Read up to ten columns of data from a text file.
;
;       This program can be used to read data written by the MORE
;       program.
;
;       The file to be read must be such that if the data are
;       space-separated, then all variables are numeric; String
;       variables are allowed only if the data are separated by tabs,
;       colons, etc.
;
;       The file may contain any number of comment lines - which MUST
;       begin with a semicolon, and MUST be positioned before all data
;       lines.
;
; CATEGORY:
;       File I/O
;
; CALLING SEQUENCE:
;
;	EROM,V0[,V1,V2,...V9]
;
; KEYWORD PARAMETERS:
;
;   FILE - String specifying the name of a file; if not supplied, the
;          user is queried.
;
;   SKIP - The number of lines at the beginning of the file that
;          should be skipped.
;
;   TAB - Specify /TAB for tab-separated data.  (The default is space-
;         separated data.)  It is only necessary to specify this
;         keyword if the file contains any string data columns.
;
;   SEPARATOR - A string specifiying the character separating the data
;               columns.
;
; OUTPUTS:
;
;	V0, V1, V2, ... variables to hold the data.  There must be as many
;       v's specified in the call to EROM as there are columns of
;       data.  The V's are floating point arrays, unless the TAB
;       keyword is specified in which case they are all string arrays.
;
; MODIFICATION HISTORY:
;
;	David L. Windt, Bell Labs, March 1990
;
;	January, 1997 - DLW
;         Modified to ignore lines beginning with semicolons, and to
;         accept data separated by tabs, etc.; Removed the notitle and
;         comment keyword; included pickfile to prompt for filenames
;         when not specified.
;
;       June, 1997 - DLW
;         Returned numeric variables are now double-precision instead
;         of floating-point.
;
;	windt@bell-labs.com
;-
pro erom,v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,$
		v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,$
		v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,$
		v30,v31,v32,v33,v34,v35,v36,v37,v38,v39,$
		file=file,tab=tab,skip=skip, $
         separator=separator

on_error,2
on_ioerror,err
if n_params() eq 0 then	message,'usage - erom,v0[,v1,....v9]'

; open the file:
if keyword_set(file) eq '' then file=pickfile(/read)
if file eq '' then return
openr,lun,file,/get_lun

; determine number of lines of data and number of comment lines:
dum=''
n_pts=0
n_com=0
while not eof(lun) do begin
    readf,lun,dum
    if strmid(dum,0,1) eq ';' then n_com=n_com+1 else n_pts=n_pts+1
endwhile
if n_elements(skip) eq 1 then begin
    n_com=n_com+skip
    n_pts=n_pts-skip
endif

point_lun,lun,0                 ; position pointer to beginning of file.
for i=0,n_com-1 do readf,lun,dum ; read comments.
n_vars=n_params()               ; number of columns to read.

if keyword_set(tab) then separator=string(9B)
if keyword_set(separator) then begin
    var=strarr(n_vars,n_pts)    ; create string array to store data.
    dum=''                      ; create dummy string to read line.
                                ; read in data:
    for j=0,n_pts-1 do begin    ; loop through each line
        readf,lun,dum           ; read line
        for i=0,n_vars-1 do begin ; loop through each var.
            p1=0                ; initialize position ctr.
            p2=strpos(dum,separator,p1) ; get next tab.
            if p2 eq -1 then p2=strlen(dum) ;
            var(i,j)=strmid(dum,p1,p2) ; extract field.
            dum=strmid(dum,p2+1,strlen(dum)-p2) ; shorten dum.
        endfor
    endfor
endif else begin
    dum=strarr(n_pts)
    readf,lun,dum
    var=dblarr(n_vars,n_pts)
    reads,dum,var
endelse
if n_params() ge 1 then v0=reform(var(0,*))
if n_params() ge 2 then v1=reform(var(1,*))
if n_params() ge 3 then v2=reform(var(2,*))
if n_params() ge 4 then v3=reform(var(3,*))
if n_params() ge 5 then v4=reform(var(4,*))
if n_params() ge 6 then v5=reform(var(5,*))
if n_params() ge 7 then v6=reform(var(6,*))
if n_params() ge 8 then v7=reform(var(7,*))
if n_params() ge 9 then v8=reform(var(8,*))
if n_params() ge 10 then v9=reform(var(9,*))
if n_params() ge 11 then v10=reform(var(10,*))
if n_params() ge 12 then v11=reform(var(11,*))
if n_params() ge 13 then v12=reform(var(12,*))
if n_params() ge 14 then v13=reform(var(13,*))
if n_params() ge 15 then v14=reform(var(14,*))
if n_params() ge 16 then v15=reform(var(15,*))
if n_params() ge 17 then v16=reform(var(16,*))
if n_params() ge 18 then v17=reform(var(17,*))
if n_params() ge 19 then v18=reform(var(18,*))
if n_params() ge 20 then v19=reform(var(19,*))
if n_params() ge 21 then v20=reform(var(20,*))
if n_params() ge 22 then v21=reform(var(21,*))
if n_params() ge 23 then v22=reform(var(22,*))
if n_params() ge 24 then v23=reform(var(23,*))
if n_params() ge 25 then v24=reform(var(24,*))
if n_params() ge 26 then v25=reform(var(25,*))
if n_params() ge 27 then v26=reform(var(26,*))
if n_params() ge 28 then v27=reform(var(27,*))
if n_params() ge 29 then v28=reform(var(28,*))
if n_params() ge 30 then v29=reform(var(29,*))
if n_params() ge 31 then v30=reform(var(30,*))
if n_params() ge 32 then v31=reform(var(31,*))
if n_params() ge 33 then v32=reform(var(32,*))
if n_params() ge 34 then v33=reform(var(33,*))
if n_params() ge 35 then v34=reform(var(34,*))
if n_params() ge 36 then v35=reform(var(35,*))
if n_params() ge 37 then v36=reform(var(36,*))
if n_params() ge 38 then v37=reform(var(37,*))
if n_params() ge 39 then v38=reform(var(38,*))
if n_params() gt 39 then v39=reform(var(39,*))
free_lun,lun
return
err: message,'Error reading file '+file,/info
return
end
