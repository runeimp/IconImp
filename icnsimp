#!/usr/bin/env bash
###
# icnsimp: Mac ICNS builder
#
# @author   RuneImp <runeimp@gmail.com>
# @version  0.1.0
# @license  http://opensource.org/licenses/MIT
#/
###
# Usage:
# ------
# icnsimp source.img
#
# Source image may be a JPEG or PNG.
#/
###
# Installation
# ------------
# 1. icnsimp must be in your path and executable.
#/
###
# Error Codes:
# ------------
#  1 = No arguments supplied
#  2 = Bad argument supplied
#  3 = Functionality not supported on this OS
#/
###
# ChangeLog:
# ----------
#   2015-06-18  v0.2.0      Implimented BASHimp v0.8.0
#	2015-05-09  v0.1.0      Initial Node version of the script
#/ 
###
# ToDo:
# -----
# [ ] ____
# [ ] ____
#/

#
# Setup Version Info
#
APP_NAME='ICNSimp'
APP_VERSION_NUMBER='0.1.0'
APP_VERSION_LABEL="$APP_NAME v$APP_VERSION_NUMBER"

if [[ $# -eq 0 ]]; then
	echo "  No JPEG or PNG image specified to convert to ICNS." 1>&2
	exit 1
elif [[ $# -gt 1 ]]; then
	echo "  Only one JPEG or PNG image can be specified to convert to ICNS." 1>&2
	exit 2
fi

src_img="$1"
icns_name="$2"
base_dir=`dirname "$src_img"`
base_img=`basename "$src_img"`
if [ "$base_dir" == '.' ]; then
	base_dir=`pwd`
	src_img="$base_dir/$base_img"
fi

img_type=`file -b --mime-type "$src_img"`
case "$img_type" in
	image/jpeg )
		jpeg_img=`basename -s .jpg "$src_img"`
		if [[ "$base_img" == "$jpeg_img" ]]; then
			base_img=`basename -s .jpeg "$src_img"`
		fi
		;;
	image/png )
		base_img=`basename -s .png "$src_img"`
		;;
	* )
		echo "  Only a JPEG or PNG image can be specified to convert to ICNS." 1>&2
		exit 2
		;;
esac

if [ -z "$icns_name" ]; then
	icns_name="$base_img"
fi

iconset_dir="$base_dir/${icns_name}.iconset"

# echo
# echo "\$#: $#"
# echo "\$@: $@"
# echo "\$src_img: $src_img"
# echo "\$base_dir: $base_dir"
# echo "\$base_img: $base_img"
# echo "\$img_type: $img_type"
# echo "\$iconset_dir: $iconset_dir"
# exit 69


# Create IconSet Directory
mkdir "$iconset_dir"

# Create IconSet Images
echo "  Building IconSet..."
result="$(sips "$src_img" --out "$iconset_dir/icon_512x512@2x.png" --setProperty format png -Z 1024)"
result="$(sips "$src_img" --out "$iconset_dir/icon_512x512.png" --setProperty format png -Z 512)"
result="$(sips "$src_img" --out "$iconset_dir/icon_256x256@2x.png" --setProperty format png -Z 512)"
result="$(sips "$src_img" --out "$iconset_dir/icon_256x256.png" --setProperty format png -Z 256)"
result="$(sips "$src_img" --out "$iconset_dir/icon_128x128@2x.png" --setProperty format png -Z 256)"
result="$(sips "$src_img" --out "$iconset_dir/icon_128x128.png" --setProperty format png -Z 128)"
result="$(sips "$src_img" --out "$iconset_dir/icon_32x32@2x.png" --setProperty format png -Z 64)"
result="$(sips "$src_img" --out "$iconset_dir/icon_32x32.png" --setProperty format png -Z 32)"
result="$(sips "$src_img" --out "$iconset_dir/icon_16x16@2x.png" --setProperty format png -Z 32)"
result="$(sips "$src_img" --out "$iconset_dir/icon_16x16.png" --setProperty format png -Z 16)"


# Create ICNS
echo "  Creating ${base_img}.icns icon..."
iconutil -c icns "$iconset_dir"
# sips "$1" --out "${icns_name}.icns" --setProperty format icns
