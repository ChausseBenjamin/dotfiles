#!/bin/bash

# Transmits an image in png format via file-mode transmission.
#   $1 file path
#   $2 image id
transmit_file_png() {
	abspath_b64="$(printf -- "$(realpath -- "$1")" | base64 -w0)"
	printf "\e_Gt=f,i=$2,f=100,q=1;$abspath_b64\e\\" >/dev/tty
}

# Displays an already transferred image.
#   $1 image id
#   $2 placement id
#   $3 x, $4 y, $5 w, $6 h
display_img() {
    printf "\e[s" >/dev/tty # save cursor position
    tput cup $4 $3 >/dev/tty # move cursor
    printf "\e_Ga=p,i=$1,p=$2,q=1\e\\" >/dev/tty
    printf "\e[u" >/dev/tty # restore cursor position
}

# Deletes a displayed image.
#   $1 image id
#   $2 placement id
delete_img() {
	printf "\e_Ga=d,d=I,i=$1,p=$2,q=1\e\\" >/dev/tty
}

# Combines transmit_file_png and display_img.
#   $1 file path
#   $2 image id
#   $3 placement id
#   $4 x, $5 y, $6 w, $7 h
show() {
    local img_width img_height new_width new_height
    img_width=$(identify -format "%w" "$1")
    img_height=$(identify -format "%h" "$1")
    new_width=$6
    new_height=$7
    transmit_file_png "$1" "$2"
    display_img "$2" "$3" "$4" "$5" "$new_width" "$new_height"
}

"$@"
