;slope fill, fill bad values of slope with surrounding values

Function slp_fill, in_slp
	;in_slp should be an array of slope values
	out_slp = -100

	missing_val = -100

	index = where(in_slp eq missing_val, count, complement=good_index)

	if((count gt 0) and (count lt n_elements(in_slp)/2)) then out_slp = fix(mean(float(in_slp[good_index])))

	return, out_slp

End
