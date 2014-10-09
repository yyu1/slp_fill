;Procedure to fill slope image.
;assumes values are integers with -100 being missing value
;use moving window to avoid visible lines of value change

;this version is for large files, and can only do 1 iteration at a time

Pro fill_slope_image_lrg, in_file, out_file, xdim, ydim

	missing_val = -100
	
	win_size = 5ULL  ; 5 pixels on each side, so win_size=5 is 11x11 window

	cur_win = intarr(win_size*2+1,win_size*2+1)

	print, 'allocating memory...'
	in_image = intarr(xdim,win_size*2+1)
	out_line = intarr(xdim)

	openr, in_lun, in_file, /get_lun
	openw, out_lun, out_file, /get_lun


	;copy first win_size lines, pixel may not be in center of window
	readu, in_lun, in_image
	for j=0ULL, win_size-1 do begin
		out_line[*] = in_image[*,j]

		index = where(out_line eq missing_val, count)
		if (count gt 0) then begin
			for i=0ULL, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				cur_win[*] = in_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = slp_fill(cur_win)
			endfor
		endif
		writeu, out_lun, out_line
	endfor

	for j=win_size, ydim-win_size-1 do begin
		if (j mod 10000 eq 0) then print, j
		;set file pointer to the right place
		point_lun, in_lun, (j-win_size)*xdim*2ULL
		readu, in_lun, in_image

		out_line[*] = in_image[*,win_size]
		cur_row[*] = out_line[win_size:xdim-win_size-1]

		index = where(out_line eq missing_val, count)

		if(count gt 0) then begin
			for i=0ULL, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				cur_win[*] = in_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = slp_fill(cur_win)
			endfor
		endif

		writeu, out_lun, out_line
	endfor

	;copy last win_size lines
	for j=0ULL, win_size-1 do begin
		out_line[*] = in_image[*,win_size+j+1]

		index = where(out_line eq missing_val, count)

		if(count gt 0) then begin
			for i=0ULL, count-1 do begin
				i_ind = index[i]
				i_ind_min = ((i_ind-win_size > 0) < (xdim-win_size*2-1))
				i_ind_max = ((i_ind+win_size > win_size*2) < (xdim-1))
				cur_win[*] = in_image[i_ind_min:i_ind_max,*]

				out_line[i_ind] = slp_fill(cur_win)
			endfor
		endif
		writeu, out_lun, out_line
	endfor


	free_lun, out_lun
	free_lun, in_lun

End
