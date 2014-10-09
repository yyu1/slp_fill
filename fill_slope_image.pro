;Procedure to fill slope image.
;assumes values are integers with -100 being missing value
;use moving window to avoid visible lines of value change

Pro fill_slope_image, in_file, out_file, xdim, ydim, max_iter

	missing_val = -100
	
	win_size = 5  ; 5 pixels on each side, so win_size=5 is 11x11 window

	cur_win = intarr(win_size*2+1,win_size*2+1)

	print, 'allocating memory...'
	in_image = intarr(xdim,ydim)
	out_image = intarr(xdim,ydim)

	print, 'reading input file...'
	openr, in_lun, in_file, /get_lun
	readu, in_lun, in_image
	free_lun, in_lun

	has_missing = 0B
	cur_row = intarr(xdim-win_size*2)
	for iter=1, max_iter do begin
		print, 'iteration ', iter

		out_image[*,0:win_size] = in_image[*,0:win_size]
		out_image[*,ydim-win_size-1:ydim-1] = in_image[*,ydim-win_size-1:ydim-1]
		for j=win_size, ydim-win_size-1 do begin
			out_image[*,j] = in_image[*,j]
			cur_row[*] = in_image[win_size:xdim-win_size-1,j]

			index = where(cur_row eq missing_val, count)

			if(count gt 0) then begin
				for i=0, count-1 do begin
					i_ind = index[i]

					cur_win[*] = in_image[i_ind-win_size:i_ind+win_size,j-win_size:j+win_size]

					cur_row[i_ind] = slp_fill(cur_win)

					if (cur_row[i_ind] eq missing_val) then has_missing = 1B
				endfor

				out_image[win_size:xdim-win_size-1,j] = cur_row[*]
			endif

		endfor

		if (~has_missing) then break

		in_image[*] = out_image[*]

	endfor

	openw, out_lun, out_file, /get_lun

	writeu, out_lun, out_image

	free_lun, out_lun

End
