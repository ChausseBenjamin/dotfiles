#!/bin/bash

# Transmits an image in png format via file-mode transmission.
#   $1 file path
#   $2 image id
transmit_file_png() {
	# Validate file exists and is readable
	if [[ ! -f "$1" || ! -r "$1" ]]; then
		return 1
	fi
	
	local abspath
	abspath="$(realpath -- "$1" 2>/dev/null)" || return 1
	
	# Validate the resolved path
	if [[ -z "$abspath" || ! -f "$abspath" ]]; then
		return 1
	fi
	
	local abspath_b64
	abspath_b64="$(printf "%s" "$abspath" | base64 -w0 2>/dev/null)" || return 1
	
	# Send kitty graphics command with error suppression
	printf "\e_Gt=f,i=$2,f=100,q=2;%s\e\\" "$abspath_b64" >/dev/tty 2>/dev/null
}

# Displays an already transferred image.
#   $1 image id
#   $2 placement id
#   $3 x, $4 y, $5 w, $6 h
display_img() {
	# Validate numeric parameters
	if [[ ! "$1" =~ ^[0-9]+$ ]] || [[ ! "$2" =~ ^[0-9]+$ ]] || 
	   [[ ! "$3" =~ ^[0-9]+$ ]] || [[ ! "$4" =~ ^[0-9]+$ ]] ||
	   [[ ! "$5" =~ ^[0-9]+$ ]] || [[ ! "$6" =~ ^[0-9]+$ ]]; then
		return 1
	fi
	
	printf "\e[s" >/dev/tty 2>/dev/null # save cursor position
	tput cup $4 $3 >/dev/tty 2>/dev/null # move cursor
	printf "\e_Ga=p,i=$1,p=$2,c=$5,r=$6,q=2\e\\" >/dev/tty 2>/dev/null
	printf "\e[u" >/dev/tty 2>/dev/null # restore cursor position
}

# Deletes a displayed image.
#   $1 image id
#   $2 placement id
delete_img() {
	# Validate numeric parameters
	if [[ ! "$1" =~ ^[0-9]+$ ]] || [[ ! "$2" =~ ^[0-9]+$ ]]; then
		return 1
	fi
	printf "\e_Ga=d,d=I,i=$1,p=$2,q=2\e\\" >/dev/tty 2>/dev/null
}

# Combines transmit_file_png and display_img.
#   $1 file path
#   $2 image id
#   $3 placement id
#   $4 x, $5 y, $6 w, $7 h
show() {
	# Validate input file
	if [[ ! -f "$1" || ! -r "$1" ]]; then
		return 1
	fi
	
	# Validate numeric parameters
	if [[ ! "$2" =~ ^[0-9]+$ ]] || [[ ! "$3" =~ ^[0-9]+$ ]] ||
	   [[ ! "$4" =~ ^[0-9]+$ ]] || [[ ! "$5" =~ ^[0-9]+$ ]] ||
	   [[ ! "$6" =~ ^[0-9]+$ ]] || [[ ! "$7" =~ ^[0-9]+$ ]]; then
		return 1
	fi

	local img_width img_height new_width new_height
	
	# Get image dimensions with timeout and error handling
	if ! img_width=$(timeout 2s identify -format "%w" "$1" 2>/dev/null) || [[ ! "$img_width" =~ ^[0-9]+$ ]]; then
		return 1
	fi
	if ! img_height=$(timeout 2s identify -format "%h" "$1" 2>/dev/null) || [[ ! "$img_height" =~ ^[0-9]+$ ]]; then
		return 1
	fi
	
	# Sanity check dimensions
	if [[ $img_width -le 0 || $img_height -le 0 || $img_width -gt 50000 || $img_height -gt 50000 ]]; then
		return 1
	fi
	
	# Calculate scale factors for both dimensions
	local scale_w scale_h
	scale_w=$(awk "BEGIN {if($img_width > 0) print $6 / $img_width; else print 0}" 2>/dev/null) || return 1
	scale_h=$(awk "BEGIN {if($img_height > 0) print $7 / $img_height; else print 0}" 2>/dev/null) || return 1
	
	# Use the smaller scale factor to ensure it fits in both dimensions
	if (( $(awk "BEGIN {print ($scale_w < $scale_h)}" 2>/dev/null) )); then
		new_width=$6
		new_height=$(awk "BEGIN {printf \"%.0f\", $img_height * $scale_w}" 2>/dev/null) || return 1
	else
		new_height=$7
		new_width=$(awk "BEGIN {printf \"%.0f\", $img_width * $scale_h}" 2>/dev/null) || return 1
	fi
	
	# Final sanity check on calculated dimensions
	if [[ ! "$new_width" =~ ^[0-9]+$ ]] || [[ ! "$new_height" =~ ^[0-9]+$ ]] ||
	   [[ $new_width -le 0 || $new_height -le 0 || $new_width -gt 5000 || $new_height -gt 5000 ]]; then
		return 1
	fi
	
	transmit_file_png "$1" "$2" && display_img "$2" "$3" "$4" "$5" "$new_width" "$new_height"
}

"$@"
