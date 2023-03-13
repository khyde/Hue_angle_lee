;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;yhlee 2021-05-24 PAR_z.doc
;IN: qaa/a&bb
;OUT: parz

pro main_parz_calc,mainpath=in_mainpath,ncfile=ncfile,z_depth=z,piexl=pt,o_parz=o_parz
	  lon = 8640
	  lat = 4320
	  limit = [-90,-180,90,180]
	  lat_c = 0.0
	  lon_c = 0.0  
	  
;		mainpath=in_mainpath
;		inpath=mainpath+'iop\\'
;		infile=inpath+ncfile
		infile_iop='W:\\modis\\modis_hue_20210407\\iop\\'+ncfile
		idx=STRPOS(ncfile,'_',/reverse_search)
		par_file=STRMID(ncfile,0,idx)+'_PAR_par_4km.nc'
		infile_par='W:\\modis\\modis_hue_20210407\\par\\'+par_file

;;;;;;;;;;;;;;;;
;input & output
		a_490 = fltarr(lon,lat)
		bbp_490 = fltarr(lon,lat);490
		par_data = fltarr(lon,lat)
		n_z=n_elements(z)
		k_parz=fltarr(lon,lat,n_z)
		par_z=fltarr(lon,lat,n_z)
	
;;;;;;;;;;;;;;;;
;read a & bbp & par
    e3=-0.057031686	
    f3=0.183194019
    e4=0.482446284	
    f4=0.702377688
    e5=4.221297004	
    f5=-2.567302752
    e6=1.465447056	
    f6=-0.666620068
    e7=1	
    f7=0.09
    sun_angle=0;5
    band_modis=488.0
    bbw_modis = 0.0038*(400.0/band_modis)^4.3

		print,'start with  ',infile_iop,'#'
		read_nc,nc_file=infile_iop,tag_name='a_488',data=data
		a_490 = TEMPORARY(data)

		read_nc,nc_file=infile_iop,tag_name='bbp_488',data=data
		bb_490 = TEMPORARY(data)+bbw_modis

		read_nc,nc_file=infile_par,tag_name='par',data=data
		par_data = TEMPORARY(data)

    m=pt[0]
    n=pt[1]
    exp_dis=0;10
    print,m,n
    
;    for i=m-exp_dis, m+exp_dis do begin
;		  if i MOD 100 eq 0 then print,i
;		  for j=n-exp_dis, n+exp_dis do begin;[0,45]
;		    if a_490(i,j) le 0.0 then CONTINUE

;        index_inf=where(finite(ed, /INFINITY),count_inf)
;        if count_inf gt 0 then CONTINUE
        
;par_z		
		    k1=(E3+E4*a_490^0.5+E5*bb_490)*(E7+F7*SIN(sun_angle*3.1416/180))
		    k2=(F3+F4*a_490+F5*bb_490)*(E6+F6*COS(sun_angle*3.1416/180))
		    for zi=0,n_z-1 do begin
		      k_parz(*,*,zi)=k1+k2/sqrt(1.0+z(zi))
		      par_z(*,*,zi)=par_data*exp(-1.0*k_parz(*,*,zi)*z(zi))
		    endfor;zi=z-depth
		    
		    tmp_par_z0=par_z(*,*,0)
		    tmp_par_z1=par_z(*,*,1)
		    index_nan=where(finite(a_490, /NAN),count_nan)
		    if count_nan gt 0 then tmp_par_z0(index_nan)=-999.
		    if count_nan gt 0 then tmp_par_z1(index_nan)=-999.
		    index_nan=where(finite(bb_490, /NAN),count_nan)
		    if count_nan gt 0 then tmp_par_z0(index_nan)=-999.
		    if count_nan gt 0 then tmp_par_z1(index_nan)=-999.
		    index_nan=where(par_data lt 0.0,count_nan)
		    if count_nan gt 0 then tmp_par_z0(index_nan)=-999.
		    if count_nan gt 0 then tmp_par_z1(index_nan)=-999.
		    par_z(*,*,0)=tmp_par_z0
		    par_z(*,*,1)=tmp_par_z1
				
;			endfor;j
;		endfor;i
		
    o_parz=par_z(pt[0],pt[1],*)

		print,'end'
end
