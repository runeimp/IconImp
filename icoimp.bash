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
# 2018-10-08  v0.3.0      Added creation of square base_image
# 2017-04-30  v0.2.0      Updated some logic
#
###
# ToDo:
# -----
# [ ] Review https://chrisjean.com/creating-a-php-ico-creator-for-favicons/ and bomstrip BASH script
# [ ] ____
#

#
# APP CONTSTANTS
#
APP_NAME="ICOimp"
CLI_NAME="icoimp"
APP_VERSION="0.3.0"
APP_LABEL="ICOimp v${APP_VERSION}"


#
# CONSTANTS
#
DIM_RE='([0-9]+) ([0-9]+)'


#
# VARIABLES
#
src_img=
ico_name=
favicon=false
test_options=false
win10=false
winxp=false


#
# FUNCTIONS
#
function resize_img()
{
	local img_size=$1
	local img_8bit=$2

	# echo "resize_img() | \$src_img: $src_img"
	# echo "resize_img() | \$base_dir: $base_dir"
	# echo "resize_img() | \$base_img: $base_img | \$img_type: $img_type"
	# echo "resize_img() | \$img_type: $img_type"
	# echo "resize_img() | \$ico_name: $ico_name"
	# echo "resize_img() | \$iconset_dir: $iconset_dir"
	# echo "resize_img() | \$favicon: $favicon"
	# echo "resize_img() | \$win10: $win10"
	# echo "resize_img() | \$img_size: $img_size"
	# echo "resize_img() | \$img_8bit: $img_8bit"
	# echo

	sips "${base_image}" --out "$iconset_dir/icon_${img_size}x${img_size}-24bit.png" --setProperty format png -Z $img_size > /dev/null
	if [[ $img_8bit == true ]]; then
		sips "$base_image" --out "$iconset_dir/icon_${img_size}x${img_size}-8bit.gif" --setProperty format gif -Z $img_size > /dev/null
		sips "$iconset_dir/icon_${img_size}x${img_size}-8bit.gif" --out "$iconset_dir/icon_${img_size}x${img_size}-8bit.png" --setProperty format png > /dev/null
		rm "$iconset_dir/icon_${img_size}x${img_size}-8bit.gif"
	fi
}

show_help()
{
	echo "${APP_LABEL}

  OPTIONS:
    -f, --favicon   Create a favicon 32x32, 24x24, and 16x16 sizes included.
    --win10         Create a 768x768 Windows 10 compatible icon.
    --winxp         Create a 256x256 Windows XP/Vista+ compatible icon.

If you do not specify any options then an ICO with the sizes 48x48, 32x32,
24x24, and 16x16 inside is created.
"
}

show_version()
{
	echo "${APP_LABEL}"
}


#
# OPTION PARSING
#
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
	-x | --winxp)
		winxp=true
		shift
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
	ico_name="${base_img}"
fi

iconset_dir="$base_dir/${ico_name}.icoset"
base_image="${base_img}-icoimp-base.png" # Make a square version of the source image


echo
echo "\$src_img     = $src_img"
echo "\$base_dir    = $base_dir"
echo "\$base_img    = $base_img"
echo "\$base_image  = $base_image"
echo "\$img_type    = $img_type"
echo "\$ico_name    = $ico_name"
echo "\$iconset_dir = $iconset_dir"
echo "\$favicon     = $favicon"
echo "\$winxp       = $winxp"
echo "\$win10       = $win10"
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

dim="$(sips -g pixelHeight -g pixelWidth "$src_img" | awk '/pixelHeight/ {height = $2}; /pixelWidth/ {width = $2}; END {print width" "height}')"
echo "\$dim         = $dim"
echo

if [[ "$dim" =~ $DIM_RE ]]; then
	# echo "\${BASH_REMATCH[@]}: ${BASH_REMATCH[@]}"
	# echo "\${BASH_REMATCH[1]}: ${BASH_REMATCH[1]}"
	# echo "\${BASH_REMATCH[2]}: ${BASH_REMATCH[2]}"
	declare -i dim_width=${BASH_REMATCH[1]}
	declare -i dim_height=${BASH_REMATCH[2]}

	if [[ $dim_width -lt 1024 ]] || [[ $dim_height -lt 1024 ]]; then
		if [[ -f "$(which convert)" ]]; then
			convert "$src_img" -background transparent -gravity center -extent 1024x1024 "$base_image"
		elif [[ -f "$(which gm)" ]]; then
			gm convert "$src_img" -background transparent -gravity center -extent 1024x1024 "$base_image"
		else
			echo "Could not find ImageMagick or GraphicsMagick to make a square reference image." 1>&2
			echo "Please manually make the reference image square or install one of either" 1>&2
			echo "ImageMagick or GraphicsMagick" 1>&2
			echo "Continuing on with non-square image"
		fi
	else
		echo "Source image is already 1024 square."
		cp "$src_img" "$base_image"
		echo
	fi
else
	cp "$src_img" "$base_image"
fi



# Create 768x768 image
if [[ $win10 == true ]]; then
	resize_img 768 # Win10 Standard
fi

# Create 128x128 256x256 images
if [[ $winxp == true ]] || [[ $win10 == true ]]; then
	resize_img 256 true # Standard (PNG in Vista+)
	# resize_img 180 true # Rarely used
	resize_img 128 true
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
		icotool --create --output="${base_dir}/${ico_name}-icotool-favicon.ico" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png"
	fi
	if [[ $win10 == true ]]; then
		icotool --create --output="${base_dir}/${ico_name}-icotool-win10.ico" --raw="$iconset_dir/icon_768x768-24bit.png" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_128x128-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	fi
	if [[ $winxp == true ]]; then
		icotool --create --output="${base_dir}/${ico_name}-icotool-winxp.ico" --raw="$iconset_dir/icon_256x256-24bit.png" --raw="$iconset_dir/icon_128x128-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png"
	fi
	icotool --create --output="${base_dir}/${ico_name}-icotool.ico" "$iconset_dir/icon_48x48-24bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_16x16-24bit.png"
elif [[ `which convert` ]]; then
	echo "Using ImageMagick"
	if [ $favicon == true ]; then
		convert "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick-favicon.ico"
	fi
	if [[ $win10 == true ]]; then
		convert "$iconset_dir/icon_768x768-24bit.png" "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_128x128-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick-win10.ico"
	fi
	if [[ $winxp == true ]]; then
		convert "$iconset_dir/icon_256x256-24bit.png" "$iconset_dir/icon_128x128-24bit.png" "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick-winxp.ico"
	fi
	convert "$iconset_dir/icon_48x48-8bit.png" "$iconset_dir/icon_32x32-24bit.png" "$iconset_dir/icon_32x32-8bit.png" "$iconset_dir/icon_24x24-24bit.png" "$iconset_dir/icon_24x24-8bit.png" "$iconset_dir/icon_16x16-24bit.png" "$iconset_dir/icon_16x16-8bit.png" "${base_dir}/${ico_name}-imagemagick.ico"
elif [[ `which png2ico` ]]; then
	echo "Using png2ico (max image 128x128 with 256 colors)"
	if [ $favicon == true ]; then
		png2ico "${base_dir}/${ico_name}-png2ico-favicon.ico" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
	fi
	png2ico "${base_dir}/${ico_name}-png2ico.ico" "$iconset_dir/icon_128x128.png" "$iconset_dir/icon_48x48.png" "$iconset_dir/icon_32x32.png" "$iconset_dir/icon_24x24.png" "$iconset_dir/icon_16x16.png"
else
	echo "Using SIPS (single image ICO only)"
	if [ $favicon == true ]; then
		sips "$base_image" --out "${base_dir}/${ico_name}-sips-favicon.ico" --setProperty format ico -Z 32
	fi
	if [[ $win10 == true ]]; then
		sips "$base_image" --out "${base_dir}/${ico_name}-sips-win10.ico" --setProperty format ico -Z 768
	fi
	if [[ $winxp == true ]]; then
		sips "$base_image" --out "${base_dir}/${ico_name}-sips-winxp.ico" --setProperty format ico -Z 256
	fi
	sips "$base_image" --out "${base_dir}/${ico_name}-sips.ico" --setProperty format ico -Z 48
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

