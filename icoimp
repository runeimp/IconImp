#!/usr/bin/env bash
###
# ICOimp: PNG to FavIcon or Windows ICO builder. Including Windows 10 ICO support.
#
# Windows ICO specific version of my iconimp script
#
# @author   RuneImp <runeimp@gmail.com>
# @version  0.2.0
# @license  http://opensource.org/licenses/MIT
#
# @see http://www.nongnu.org/icoutils/
# @see http://linux.die.net/man/1/icotool
# @see http://www.winterdrache.de/freeware/png2ico/
# @see brew info png2ico
# 
# @see http://icofx.ro
#
# @see https://www.creativefreedom.co.uk/icon-designers-blog/windows-7-icon-sizes/
# @see https://msdn.microsoft.com/en-us/library/ms997636.aspx
# @see https://msdn.microsoft.com/en-us/library/windows/desktop/dn742485(v=vs.85).aspx
#
###
# Usage:
# ------
# icoimp source.img
#
###
# Installation
# ------------
# 1. icoimp must be in your path and executable.
# 2. icoimp*.gif must be in the same directory as icoimp (for now)
#
###
# Error Codes:
# ------------
#  1 = No input basename provided
#  2 = No arguments supplied
#  3 = Bad argument supplied
#  4 = Functionality not supported on this OS
#
###
# ChangeLog:
# ----------
# 2017-04-30  v0.2.0      Updated some logic
#
###
# ToDo:
# -----
# [ ] Review https://chrisjean.com/creating-a-php-ico-creator-for-favicons/ and bomstrip BASH script
# [ ] ____
#

src_img=
ico_name=
favicon=false
test_options=false
ICOIMP_VERSION_NUMBER="0.2.0"
ICOIMP_VERSION_LABEL="ICOimp v${ICOIMP_VERSION_NUMBER}"
win10=false

##
# Processing Command Line Options
#

show_help()
{
	echo "${ICOIMP_VERSION_LABEL}

  Commands:
    -f, --favicon	Create a favicon
    --win10         Create a 768x768 Windows 10 compatible icon
"
}

show_version()
{
	echo "${ICOIMP_VERSION_LABEL}"
}

if [ $# -eq 0 ]; then
	echo "You must specify at least a source image to use icoimp" 1>&2
	exit 1
fi

until [ -z "$1" ];
do
	case "$1" in
	-f | --favicon)
		favicon=true
		shift
		;;
	-h | --help)
		show_help
		exit 0
		;;
	--win10)
		win10=true
		shift
		;;
	-v | --version)
		show_version
		exit 0
		;;
	*)
		if [ -z "$src_img" ]; then
			src_img="$1"
		elif [ -z "$ico_name" ]; then
			ico_name="$1"
		else
			"Unknown option: $1"
		fi
		shift
		;;
	esac
done


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
esac
# base_img="${src_img%.*}"

if [ -z "$ico_name" ]; then
	ico_name="$base_img"
fi

iconset_dir="$base_dir/${ico_name}.icoset"


# echo
# echo "\$src_img: $src_img"
# echo "\$base_dir: $base_dir"
# echo "\$base_img: $base_img"
# echo "\$img_type: $img_type"
# echo "\$ico_name: $ico_name"
# echo "\$iconset_dir: $iconset_dir"
# echo "\$favicon: $favicon"
# echo "\$win10: $win10"
# echo
# exit 69

##
# Cleanup
#
if [ -d "$iconset_dir" ]; then
	rm -Rf "$iconset_dir"
	# rm *.ico
fi

##
# Setup
#
mkdir "$iconset_dir"


function create_favicon()
{
	echo "  Creating favicon.ico icon..."

	if [[ `which icotool` ]]; then
		echo "Using icotool (from icoutils)"
		icotool --create --output="${base_dir}/favicon.ico" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png"
	elif [[ `which convert` ]]; then
		echo "Using ImageMagick"
		convert "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/favicon.ico"
	elif [[ `which png2ico` ]]; then
		echo "Using png2ico"
		png2ico "${base_dir}/favicon.ico" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
	else
		echo "Using SIPS (single image ICO only)"
		sips "$src_img" --out "${base_dir}/favicon.ico" --setProperty format ico -Z 48
	fi
}

function create_winicon()
{
	if [[ `which icotool` ]]; then
		echo "Using icotool (from icoutils)"
		if [[ $win10 == true ]]; then
			echo "  Creating ${ico_name}.ico Win10 icon..."
			icotool --create --output="${base_dir}/${ico_name}.ico" --raw="$iconset_dir/icon_768x768-24bit.png" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
		else
			echo "  Creating ${ico_name}.ico WinXP icon..."
			icotool --create --output="${base_dir}/${ico_name}.ico" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
		fi
	elif [[ `which convert` ]]; then
		echo "Using ImageMagick"
		if [[ $win10 == true ]]; then
			echo "  Creating ${ico_name}.ico Win10 icon..."
			convert "$iconset_dir/icon_768x768-24bit.png" "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
		else
			echo "  Creating ${ico_name}.ico WinXP icon..."
			convert "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
		fi
	elif [[ `which png2ico` ]]; then
		echo "Using png2ico (max image 128x128 with 256 colors)"
		echo "  Creating ${ico_name}.ico WinXP icon..."
		png2ico "${base_dir}/${ico_name}.ico" "$iconset_dir/icon_128x128.png" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
	else
		echo "Using SIPS (single image ICO only)"
		if [[ $win10 == true ]]; then
			echo "  Creating ${ico_name}.ico Win10 icon..."
			sips "$src_img" --out "${base_dir}/${ico_name}.ico" --setProperty format ico -Z 768
		else
			echo "  Creating ${ico_name}.ico WinXP icon..."
			sips "$src_img" --out "${base_dir}/${ico_name}.ico" --setProperty format ico -Z 256
		fi
	fi
}

function resize_img()
{
	local img_size=$1
	local img_8bit=$2
	local img_dim="${img_size}x${img_size}"

	if [[ `which sips` ]]; then
		sips "$src_img" --out "$iconset_dir/icon_${img_dim}-24bit.png" --setProperty format png -Z $img_size > /dev/null
		if [[ $img_8bit == true ]]; then
			sips "$src_img" --out "$iconset_dir/icon_${img_dim}-8bit.gif" --setProperty format gif -Z $img_size > /dev/null
			sips "$iconset_dir/icon_${img_dim}-8bit.gif" --out "$iconset_dir/icon_${img_dim}-8bit.png" --setProperty format png > /dev/null
			rm "$iconset_dir/icon_${img_dim}-8bit.gif"
		fi
	elif [[ `which gm` ]]; then
		gm convert -size "$img_dim" "$src_img" -resize "$img_dim" +profile "*" "$iconset_dir/icon_${img_dim}-24bit.png"
	else
		convert -size "$img_dim" "$src_img" -resize "$img_dim" +profile "*" "$iconset_dir/icon_${img_dim}-24bit.png"
	fi
}

# Create 768x768 image
if [[ $win10 == true ]]; then
	resize_img 768 # Win10 Standard
fi

# Create 128x128 256x256 images
resize_img 256 true # Standard (PNG in Vista+)
# resize_img 180 true # Rarely used
resize_img 128 true



if [ $favicon == false ]; then
	killerror=true
	# resize_img 96 true # Rarely used
	# resize_img 72 true # Rarely used
	# resize_img 64 true # Rarely used. WinXP Classic Mode.
fi

# Create 48x48 image
resize_img 48 true

# Create 32x32 image
resize_img 32 true

# Create 24x24 image
resize_img 24 true

# Create 16x16 image
resize_img 16 true


if [[ `which icotool` ]]; then
	echo "Using icotool (from icoutils)"
	if [[ $favicon == true ]]; then
		echo "  Creating favicon.ico icon..."
		icotool --create --output="${base_dir}/favicon.ico" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png"
	fi
	if [[ $win10 == true ]]; then
		icotool --create --output="${base_dir}/${ico_name}.ico" --raw="$iconset_dir/icon_768x768-24bit.png" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	else
		icotool --create --output="${base_dir}/${ico_name}.ico" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	fi
elif [[ `which convert` ]]; then
	echo "Using ImageMagick"
	if [ $favicon == true ]; then
		echo "  Creating favicon.ico icon..."
		convert "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/favicon.ico"
	fi
	if [[ $win10 == true ]]; then
		convert "$iconset_dir/icon_768x768-24bit.png" "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
	else
		convert "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
	fi
elif [[ `which png2ico` ]]; then
	echo "Using png2ico (max image 128x128 with 256 colors)"
	if [ $favicon == true ]; then
		echo "  Creating favicon.ico icon..."
		png2ico "${base_dir}/favicon.ico" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
	fi
	png2ico "${base_dir}/${ico_name}.ico" "$iconset_dir/icon_128x128.png" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
else
	echo "Using SIPS (single image ICO only)"
	if [ $favicon == true ]; then
		echo "  Creating favicon.ico icon..."
		sips "$src_img" --out "${base_dir}/favicon.ico" --setProperty format ico -Z 48
	fi
	if [[ $win10 == true ]]; then
		echo "  Creating ${ico_name}.ico Win10 icon..."
		sips "$src_img" --out "${base_dir}/${ico_name}.ico" --setProperty format ico -Z 768
	else
		sips "$src_img" --out "${base_dir}/${ico_name}.ico" --setProperty format ico -Z 256
	fi
fi

if [ $test_options == true ]; then
	icotool --create --output="${base_dir}/${ico_name}-icotool.ico" "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png"
	icotool --create --output="${base_dir}/${ico_name}-icotool-png256.ico" --raw="$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png"
	icotool --create --output="${base_dir}/${ico_name}-icotool-png48.ico" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png"


	icotool --create --bit-depth=8 --output="${base_dir}/${ico_name}-icotool-8bit.ico" "$iconset_dir/icon_256x256-8bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	icotool --create --bit-depth=8 --output="${base_dir}/${ico_name}-icotool-png8bit-8bit.ico" --raw="$iconset_dir/icon_256x256-8bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	icotool --create --bit-depth=8 --output="${base_dir}/${ico_name}-icotool-png24bit-8bit.ico" --raw="$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	icotool --create --bit-depth=8 --output="${base_dir}/${ico_name}-icotool-fullset.ico" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" --raw="$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" --raw="$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" --raw="$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png"
	icotool --create --output="${base_dir}/${ico_name}-icotool-png24bit.ico" --raw="$iconset_dir/icon_256x256-24bit.png"


	png2ico "${base_dir}/${ico_name}-png2ico-8bit.ico" "$iconset_dir/icon_128x128-8bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"


	convert "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
	convert "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png" -colors 256 "${base_dir}/${ico_name}-imagemagick-24bit-colors256.ico"
	convert "$iconset_dir/icon_256x256-8bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png" -colors 256 "${base_dir}/${ico_name}-imagemagick-8bit-colors256.ico"
	# gm convert "$iconset_dir/icon_256x256.png" "$iconset_dir/icon_128x128.png" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png" "${base_dir}/${ico_name}-graphicsmagick.ico"
fi

