;program to read a .nc file
;currenly only tested on Landsat 8 images created using acolite
;   but theoretically should work on any .nc file
;modify by yhlee
;for modis 4km monthly
;2019-02-19
pro read_nc,nc_file=nc_file,tag_name=tag_name,data=data,iostat=iostat

iostat=0
fileid=ncdf_open(nc_file,/NOWRITE)
varid=ncdf_varid(fileid,tag_name)
if varid gt -1 then begin
	iostat=1
	ncdf_varget,fileID,varID,data
endif
;yhlee
result=ncdf_attinq(fileid,varid,'add_offset')
if result.datatype ne 'UNKNOWN' then begin
  ncdf_attget,fileid,varid,'scale_factor',scale_factor
  ncdf_attget,fileid,varid,'add_offset',add_offset
  index=where(data gt 65530,count);where(data le -32767,count)
  data=data*scale_factor+add_offset
  if count gt 0 then data(index)=-32767
endif
ncdf_close,fileid
end

