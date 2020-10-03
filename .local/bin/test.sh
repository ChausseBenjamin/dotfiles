#!/usr/bin

for i in $(ls ~/manjaro-dotfiles/.scripts/) 
do
	for j in $(ls ~/manjaro-dotfiles/.scripts/$i)
	do
		cp ~/manjaro-dotfiles/.scripts/$i/$j ~/.local/bin/
	done
done
