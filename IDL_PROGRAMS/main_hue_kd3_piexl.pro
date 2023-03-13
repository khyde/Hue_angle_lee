;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;yhlee 2021-04-21 NMFS_TOW_COORDS_modis.csv
;yhlee 2020-09-26 IOP_2_Z-light.xlsx
;yhlee 2020-06-04 MODIS_2_Hyper-Kd-20200602.docx Hue_MODIS-angle_yhlee.xlsx
;yhlee 2020-03-06
;IN: qaa/a&bb
;OUT: hue/color_alpha_kd2.hdf

pro main_hue_kd3_piexl,mainpath=in_mainpath,ncfile=ncfile,z_depth=z,piexl=pt,o_angle=o_alpha,idx=pt_idx
	  lon = 8640
	  lat = 4320
	  limit = [-90,-180,90,180]
	  lat_c = 0.0
	  lon_c = 0.0  
	  
		MAINPATH = !S.PARHUEANGLE_FUNCTIONS + 'annxillary_data/' ;mainpath=in_mainpath
		inpath=mainpath+'iop\\'
;		infile=inpath+ncfile
;		infile='W:\\modis\\modis_hue_20210407\\iop\\'+ncfile
;		outpath='W:\\modis\\modis_hue_20210407\\hue\\'  ;mainpath+'hue\\'
;		outpath1=mainpath+'hue\\'
;    write_files = outpath+ncfile+'.color_alpha_kd3_'+string(pt_idx,'(i5.5)')+'.hdf';A20191212019151
;    writeZeu_files = outpath1+ncfile+'.zeu_'+string(pt_idx,'(i5.5)')+'.hdf';A20191212019151

;;;;;;;;;;;;;;;;
;read consts
		erom,band,file=mainpath+'band.txt'
	 ;erom,aw,file=mainpath+'aw.txt'
		erom,aw,file=mainpath+'aw_Lee.txt' ;yhlee 2020-06-04
	 ;erom,bbw,file=mainpath+'bbw.txt'
		bbw = 0.0038*(400.0/band)^4.3 ;yhlee 2020-06-04
		erom,es,file=mainpath+'es.txt'
		erom,acoef0,acoef1,acoef2,acoef3,acoef4,file=mainpath+'acoef.txt',separator=','
		erom,xinit,yinit,zinit,file=mainpath+'initxyz.txt',separator=','
		
		n_band=n_elements(band);'band.txt'
		band_modis = [412., 443., 488., 531., 547., 667.]
	 ;aw_modis = [0.0046, 0.0070, 0.0143, 0.0438, 0.0532, 0.4336]
		aw_modis = [0.0031, 0.0049, 0.0126, 0.0423, 0.0529, 0.4335] ;yhlee 2020-06-04
	 ;bbw_modis = [0.00332, 0.00244, 0.00162, 0.00115, 0.00098, 0.00047]
		bbw_modis = 0.0038*(400.0/band_modis)^4.3 ;yhlee 2020-06-04 [0.00334644   0.00244966   0.00161598   0.00112392  0.000989227  0.000421600]
	
;;;;;;;;;;;;;;;;
;input & output
		a_data = fltarr(lon,lat,5);412,443,488,531,547
		bbp_data = fltarr(lon,lat);547 ->443 yhlee 06-04
		bbp_490 = fltarr(lon,lat);490
		bbp_Y = fltarr(lon,lat)
		;z=[1,2,5,10,20,50]
		;tag_z=['alpha1','alpha2','alpha5','alpha10','alpha20','alpha50']
		;z=[0.01,1,4.6]
		;tag_z=['alpha0.01','alpha1','alpha4.6']
		n_z=n_elements(z)
		tag_z='alpha'+string(z,'(i3.3)')
		zeu_z=fltarr(lon,lat,n_z)
		tag_zeu='zeu'+string(z,'(i3.3)')
		color_alpha=fltarr(lon,lat,n_z)
	
;;;;;;;;;;;;;;;;
;read a & bbp & bbpY
		print,'start with  ',infile,'#'
		read_nc,nc_file=infile,tag_name='a_412',data=data
		a_data(*,*,0) = TEMPORARY(data)
		read_nc,nc_file=infile,tag_name='a_443',data=data
		a_data(*,*,1) = TEMPORARY(data)
		read_nc,nc_file=infile,tag_name='a_488',data=data
		a_data(*,*,2) = TEMPORARY(data)
		a490=a_data(*,*,2)
		read_nc,nc_file=infile,tag_name='a_531',data=data
		a_data(*,*,3) = TEMPORARY(data)
		read_nc,nc_file=infile,tag_name='a_547',data=data
		a_data(*,*,4) = TEMPORARY(data)

;		read_hdf,bbpfilename,'bbp_547',data=data
		read_nc,nc_file=infile,tag_name='bbp_443',data=data ;yhlee 2020-06-04
		bbp_data = TEMPORARY(data)
		read_nc,nc_file=infile,tag_name='bbp_488',data=data
		bbp_490 = TEMPORARY(data)
		read_nc,nc_file=infile,tag_name='bbp_Y',data=data
		bbp_Y = TEMPORARY(data)

;;;;;;;;;;;;;;;;
;calc zeu
;    bb490=bbp_490+bbw_modis(2)
;    for zi=0,n_z-1 do begin
;      calc_zeu,oz=z(zi),a490=a490,bb490=bb490,zeu=zeu_tmp
;      zeu_z(*,*,zi) = TEMPORARY(zeu_tmp)
;    endfor;z-depth

;    append=0
;    for zi=0,n_z-1 do begin
;      write_hdf,writeZeu_files,tag_zeu(zi),lon,lat,limit,zeu_z(*,*,zi),'m',append
;      append=1
;    endfor;z-depth
        
;	  for i=2450, 2750 do begin;[-180,0]
;   for i=0, lon-1 do begin
    m=pt[0]
    n=pt[1]
    exp_dis=0;10
    print,m,n
    for i=m-exp_dis, m+exp_dis do begin
		  if i MOD 100 eq 0 then print,i
		  for j=n-exp_dis, n+exp_dis do begin;[0,45]
;	    for j=1050, 1350 do begin;[0,45]
;		  for j=0, lat-1 do begin
		    if a_data(i,j,4) eq 0.0 then CONTINUE
;define 
				a_expand=replicate(-999.,n_band)
				bbp_expand=replicate(-999.,n_band)
				eta=replicate(-999.,n_band)
				kd=replicate(-999.,n_band)
				ed=replicate(-999.,n_band,n_z);1,2,5,10,20,50
				xcolor=replicate(-999.,n_band,n_z)
				ycolor=replicate(-999.,n_band,n_z)
				zcolor=replicate(-999.,n_band,n_z)

				for x=0,n_band-1 do begin
	;expand a
					a_expand(x)=aw(x)+acoef0(x)*(a_data(i,j,0)-aw_modis(0))+ $
					acoef1(x)*(a_data(i,j,1)-aw_modis(1))+ $
					acoef2(x)*(a_data(i,j,2)-aw_modis(2))+ $
					acoef3(x)*(a_data(i,j,3)-aw_modis(3))+ $
					acoef4(x)*(a_data(i,j,4)-aw_modis(4))
  ;yhlee 2022-05-19 a(560)=aw+0.2*a443
          if x ge 16 then a_expand(x)=aw(x)+0.2*a_data(i,j,1)
	;expand bbp
	;				bbp_expand(x)=bbp_data(i,j)*(547.0/band(x))^bbp_Y(i,j)
					bbp_expand(x)=bbp_data(i,j)*(443.0/band(x))^bbp_Y(i,j) ;yhlee 2020-06-04
	;eta
					eta(x)=bbw(x)/(bbw(x)+bbp_expand(x))
	;kd				
					kd(x)=(1.0+30.0*0.005)*a_expand(x)+ $
						(1.0-0.265*eta(x))*4.259*(1.0-0.52*(exp(-10.8*a_expand(x))))*(bbw(x)+bbp_expand(x))    
	;ed xyz_color
	;				for zi=0,n_z-1 do begin
	;					ed(x,zi)=es(x)*exp(-1.0*kd(x)*z(zi))
	;					xcolor(x,zi)=xinit(x)*ed(x,zi)
	;					ycolor(x,zi)=yinit(x)*ed(x,zi)
	;					zcolor(x,zi)=zinit(x)*ed(x,zi)
	;				endfor;z-depth
          ed(x,*)=es(x)*exp(-1.0*kd(x)*z(*))
;	        ed(x,*)=es(x)*exp(-1.0*kd(x)*zeu_z(i,j,*))
	        xcolor(x,*)=xinit(x)*ed(x,*)
	        ycolor(x,*)=yinit(x)*ed(x,*)
	        zcolor(x,*)=zinit(x)*ed(x,*)
				endfor;x=n_band
        
        index_inf=where(finite(ed, /INFINITY),count_inf)
        if count_inf gt 0 then CONTINUE
        
	;color_alpha			
				for zi=0,n_z-1 do begin
					xtotal=total(xcolor(*,zi),/nan)
					ytotal=total(ycolor(*,zi),/nan)
					ztotal=total(zcolor(*,zi),/nan)
					xx=xtotal/(xtotal+ytotal+ztotal)
					yy=ytotal/(xtotal+ytotal+ztotal)
					color_alpha(i,j,zi)=90.0-atan(xx-0.333,yy-0.333)*180.0/3.1415926
					if zi eq 0 and color_alpha(i,j,zi) lt 0.0 then begin
;					  print,i,j
					endif
				endfor;zi=z-depth
				
				a_expand=-1
				bbp_expand=-1
				eta=-1
				kd=-1
				ed=-1
				xcolor=-1
				ycolor=-1
				zcolor=-1
			endfor;j
		endfor;i
		
;write color_alpha
;    append=0
;    for zi=0,n_z-1 do begin
;      write_hdf,write_files,tag_z(zi),lon,lat,limit,color_alpha(*,*,zi),'degree',append
;      append=1
;    endfor;z-depth
    
    o_alpha=color_alpha(pt[0],pt[1],*)

		print,'end'
end
