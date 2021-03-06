#!/bin/bash
###########
# iconimp: PNG to FavIcon, Mac ICNS, Windows ICO and Web-Clip builder
#
# @author   RuneImp <runeimp@gmail.com>
# @version  0.10.0
# @license  http://opensource.org/licenses/MIT
#
###
# Options:
# --------
# -f = FavIcon ICO size
# -h = Help/Usage
# -i = input file basename
# -k = Keep icon set directories
# -m = Mac ICNS size
# -o = output file basename
# -s = Smartphone Web-Clip size
# -t = Icon type(s) to create
# -w = Windows ICO size
# 
###
# Usage:
# ------
# iconimp my-icon # Creates a FavIcon, Mac ICNS, Windows ICO and Web-Clips using the base input/file name "my-icon"
# iconimp -t f 'my fav icon' # Creates a browser favicon.ico
# iconimp -t fw 'my fav icon' # creates a Windows "my fav icon.ico"
# 
###
# Installation
# ------------
# 1. iconimp must be in your path and executable.
# 2. iconimp*.gif must be in the same directory as iconimp (for now)
# 
###
# Error Codes:
# ------------
#  1 = Missing all dependencies
#
###
# ChangeLog:
# ----------
#   2013-08-24  v0.10.0   Added ability to attach an icon to a file or folder using native OS X tools or the multi-platform osxutils if available.
#                             Fixed files with spaces reference bugs.
#   2013-08-13  v0.9.1    Reinabled 4-bit color support in Windows ICO, and updated error and warning messages.
#   2013-08-01  v0.9.0    Initial script creation
# 
###
# ToDo:
# -----
# [ ] Optimize code reuse and logic.
# [ ] Add resizing of source images to makeup missing icon sizes for FavIcon, ICO and ICNS.
# [ ] Add support for sips. Though it does not yet support multi-image ICO format creation to my knowledge.
# [ ] Add support for GraphicsMagick. Though it does not yet support ICO format creation.
# [ ] Create .iconimp config parser
#

usage()
{
cat << EOF
usage: $0 options

This script takes a collection of

OPTIONS:
  -f    Flag to specify FavIcon size. Must use multiple -f flags to specify multiple values.
  -h    Show this message.
  -i    Input image(s) basename.
  -k    Keep icon set directories. The icon set directories are normally deleted after icon creation.
  -m    Flag to specify ICNS icon size. Must use multiple -m flags to specify multiple values.
  -o    Output basename. The basename is the default output name for all targets. Defaults to the input basename.
  -s    Flag to specify Web-Clip PNG icon size. Must use multiple -s flags to specify multiple values.
  -t    Icon type to create: f=FavIcon, m=Mac ICNS, w=Windows ICO, s=Smartphone Web-Clip.
  -w    Flag to specify ICO icon size. Must use multiple -w flags to specify multiple values.

Create All with Defaults:
  iconimp logo # Will create favicon.ico logo.ico logo.icns web-clips/apple-touch-icon-precomposed.png web-clips/apple-touch-icon.png etc.

Flag Size Examples:
  iconimp -t fm -m 96x96 -m -512x512 -i logo # Will create favicon.ico and logo.icns. The ICNS will add 96x96 to the list of sizes to be produced and 512x512 will be removed from the list.

Dependencies:
	ImageMagick's convert and identify to create Windows and FavIcon ICO files and resize images for Web-Clips.
	Apple's iconutil to create Mac OS X ICNS files

Deployment Notes:
	Please see http://mathiasbynens.be/notes/touch-icons regarding deployment of web-clips.
EOF
}

find_match()
{
	declare -a size_array=("${!2}")

	for value in ${size_array[@]};
	do
		if [[ $1 =~ ([0-9]+x[0-9]+) ]];
		then
			if [[ ${BASH_REMATCH[1]} == $value ]];
			then
				return 0 # Match found
			fi
		fi
	done
	return 1 # No match found
}

i=0
argc=$#
argv=("${@}")
attach_icon=false
base_path=false
build_favicon=false
build_icns=false
build_favicon=false
colormap_path=`dirname $0`
cwd=`pwd`
debug=false
dirname=`basename $cwd`
input_name=false
keep_set_dir=false
output_name=false
make_favicon=false
make_icns=false
make_ico=false
make_icon=false
make_webclip=false
msg=""
re_size="[^0-9]* ([0-9]+x[0-9]+).*"
src_dir="_src"

declare -a favicon_sizes=('16x16' '24x24' '32x32' '48x48' '64x64');
declare -a icns_sizes=('16x16' '32x32' '64x64' '128x128' '256x256' '512x512' '1024x1024');
declare -a ico_sizes=('16x16' '24x24' '32x32' '48x48' '256x256' '16x16_8bit' '48x48_8bit' '32x32_8bit' '24x24_8bit' '32x32_4bit' '24x24_4bit' '16x16_4bit');
declare -a webclip_sizes=('57x57' '72x72' '114x114' '120x120' '144x144');

##
# Testing for Dependencies
#
if [[  -z `which iconutil` && -z `which convert` &&  -z `which identify` ]]
then
	echo
	echo "ERROR: Apple's iconutil, and ImageMagick's convert or identify commands are missing"
	exit 1
fi
if [[ -z `which iconutil` ]]
then
	echo
	echo "WARNING: Apple's iconutil missing. ICNS files can not be created."
fi
if [[ -z `which convert` &&  -z `which identify` ]]
then
	echo
	echo "WARNING: ImageMagick's convert or identify commands missing"
fi

##
# Setting the Base Path
#
if [[ $dirname == $src_dir ]];
then
	base_path=`dirname $cwd`
else
	base_path="$cwd"
fi

##
# Setting the Source Path
#
src_path="$base_path/$src_dir"

##
# Processing Command Line Options
#
while getopts “a:df:hi:km:o:s:t:w:” OPTION
do
	case $OPTION in
		a)	attach_icon="$OPTARG" ;;
		d)	debug=true ;;
		f)
			if [[ ${OPTARG:0:1} == '-' ]];
				then
					favicon_sizes=( ${favicon_sizes[@]/${OPTARG:1}/} )
				else
					favicon_sizes=( ${favicon_sizes[@]} $OPTARG )
			fi

			if [[ "$OPTARG" =~ (^rec.*) ]];
			then
				declare -a favicon_sizes=('16x16' '32x32' '48x48');
			elif [[ "$OPTARG" =~ (^opt.*) ]];
			then
				declare -a favicon_sizes=('16x16' '24x24' '32x32' '64x64');
			fi
			;;
		h)
			usage
			exit 1
			;;
		i)
			input_name="$OPTARG"
			# echo "-i \${OPTARG: ${OPTARG}"
			;;
		k)
			keep_set_dir=true
			;;
		m)
			if [[ ${OPTARG:0:1} == '-' ]];
				then
					icns_sizes=( ${icns_sizes[@]/${OPTARG:1}/} )
				else
					icns_sizes=( ${icns_sizes[@]} $OPTARG )
			fi
			# echo "-m \${icns_sizes[@]}: ${icns_sizes[@]}"
			;;
		o)
			output_name="$OPTARG"
			;;
		s)
			make_webclip=true
			;;
		t)
			if [[ $OPTARG =~ f ]]; then make_favicon=true; fi
			if [[ $OPTARG =~ m ]]; then make_icns=true; fi
			if [[ $OPTARG =~ s ]]; then make_webclip=true; fi
			if [[ $OPTARG =~ w ]]; then make_ico=true; fi
			;;
		w)
			if [[ ${OPTARG:0:1} == '-' ]];
				then
					ico_sizes=( ${ico_sizes[@]/${OPTARG:1}/} )
				else
					ico_sizes=( ${ico_sizes[@]} $OPTARG )
			fi
			# echo "-w \${ico_sizes[@]}: ${ico_sizes[@]}"
			;;
		?)
			usage
			exit
			;;
	esac
done

##
# Check for required arguments
#
if [[ $# -eq 0 ]];
then
	usage
	exit 0
elif [[ $# -eq 1 ]] # Default to making all icon types base on single input value
then
	input_name="$1"
	make_favicon=true
	make_icns=true
	make_ico=true
	make_webclip=true
elif [[ "$input_name" == false ]];
then
	for arg in "${@}";
	do
		input_name="$arg"
	done
fi

if [[ $output_name == false ]];
then
	output_name="$input_name"
fi

##
# Debug Info
#
if $debug;
then
	echo "Command Arguments: $@"
	echo "Input Name: $input_name"
	echo "Output Name: $output_name"
	if $make_favicon; then echo "FavIcon Sizes: ${favicon_sizes[@]}"; fi
	if $make_icns; then echo "Mac ICNS Sizes: ${icns_sizes[@]}"; fi
	if $make_ico; then echo "Windows ICO Sizes: ${ico_sizes[@]}"; fi
	if $make_webclip; then echo "Web-Clip Sizes: ${webclip_sizes[@]}"; fi
	exit 69
fi

##
# Attach Icon to Target
if [[ $attach_icon != false ]]; then
	echo "Attach Icon: $attach_icon"
	echo "Target Folder: $cwd"

	if [[ `which seticon` ]]; then # if statement broken on purpose. seticon seemed to be having issues in my last tests.
		echo "osxiconutils seticon"
		if [[ `seticon -d "$attach_icon" "$cwd"` ]]; then  # Attempt to use osxutils' seticon via ICNS data
			echo "seticon success"
		else
			echo "seticon failure. Must not be an ICNS file. Workaround..."
			cp "$attach_icon" ./temp_icon
			sips -i ./temp_icon                                # Giving an icon it's own custom icon resource
			seticon ./temp_icon "$cwd"                         # Use osxutils' seticon via resource fork       
			rm ./temp_icon                                     # Cleanup copy
		fi
		setfile -a V ./$'Icon\r'                           # Hide the Icon\r file from Finder
	else
		echo "SIPS, DeRez, Rez, and SetFile"
		len=${#attach_icon}
		let len-=5
		icon_rsrc="${attach_icon:0:len}.rsrc"
		# echo "\$icon_rsrc: $icon_rsrc"

		cp "$attach_icon" ./temp_icon                    # Copy custom icon source
		sips -i ./temp_icon                              # Giving an icon it's own custom icon resource
		derez -only icns ./temp_icon > "$icon_rsrc"      # Extracting that custom icon resource
		rm ./temp_icon                                   # Cleanup copy

		# sips -i "$attach_icon"                           # Giving an icon it's own custom icon resource
		# derez -only icns "$attach_icon" > "$icon_rsrc"   # Extracting that custom icon resource

		rez -a "$icon_rsrc" -o ./$'Icon\r'               # Applying the custom icon resource to a folder
		# echo rez -a -ov "$icon_rsrc" -o ./$'Icon\r'      # Forcing (overwriting) the custom icon resource of a folder
		setfile -a C .                                   # Enable custom icon display
		setfile -a V ./$'Icon\r'                         # Hide the Icon\r file from Finder
		rm "$icon_rsrc"
	fi
	exit 0
fi

##
# If making icons move images into $src_path if we aren't already there
#
if [[ $make_favicon || $make_icns || $make_ico || $make_webclip ]]
then
	echo "DEBUG: Line $LINENO"
	if [[ ! -z $base_path ]];
	then
		echo "DEBUG: Line $LINENO"

		dir_name=`basename "$cwd"`

		if [[ "$dir_name" == "$src_dir" ]];
		then
			base_path=`dirname "$cwd"`
			src_path="$base_path/$src_dir"
			# echo "Going to '$base_path'"
			cd "$base_path"
		else
			echo
			echo "  Building $src_dir and moving images to it..."
			mkdir -p "$src_path"
			mv "$input_name"*.png "$src_path"
		fi
	else
		echo "ERROR: $base_path note defined"
	fi
fi


##
# Make FavIcon ICO
#
if [[ $make_favicon == true ]];
then
	echo
	echo "  Make FavIcon ICO";

	build_favicon=false
	eight_bit=false

	cd "$base_path"
	mkdir "favicon.ico-set" > /dev/null
	cd "$src_path"

	for file in "$input_name"*.png;
	do
		# echo "\$file: $file"
		img="$src_path/$file"
		img_data=`identify "$img"`

		if ( find_match "$img_data" favicon_sizes[@] );
		then
			if [[ "$img_data" =~ ([0-9]+x[0-9]+) ]];
			then
				# echo "Size Match \${BASH_REMATCH[1]}: ${BASH_REMATCH[1]}"
				eight_bit=false
				case "${BASH_REMATCH[1]}" in
					'32x32') eight_bit=true ;;
					'24x24') eight_bit=true ;;
					'16x16') eight_bit=true ;;
				esac

				cp "$img" "$base_path/favicon.ico-set/icon_${BASH_REMATCH[1]}.png"
				# eight_bit=false
				if ( $eight_bit );
				then
					# convert -depth 4 -colors 16 "$img" -remap "$colormap_path/iconimp-ega.gif" "$base_path/favicon.ico-set/icon_${BASH_REMATCH[1]}_4-bit.ico"
					convert -depth 8 -colors 256 "$img" +dither -remap "$colormap_path/iconimp-winxp.gif" "$base_path/favicon.ico-set/icon_${BASH_REMATCH[1]}_8-bit.png"
				fi
				build_favicon=true
			fi
		fi
	done

	if [[ $build_favicon == true ]];
	then
		cd "../favicon.ico-set"
		images=`ls -S`
		convert $images "../favicon.ico"
		test_img="/Users/runeimp/Projects/vhost/dev/testbed/assets/img/_src/tiaga-icon-01_256x256.png"
	fi

	if [[ $keep_set_dir == false ]]
	then
		cd "$base_path"
		rm -Rf "favicon.ico-set"
	fi
fi


##
# Make Mac OS X ICNS
#
if [[ $make_icns == true ]];
then
	echo
	echo "  Make Mac OS X ICNS";

	build_icns=false

	cd "$base_path"
	mkdir "$output_name.iconset"
	cd "$src_path"
	
	for file in "$input_name"*.png;
	do
		# echo "\$file: $file"
		img="$src_path/$file"
		img_data=`identify "$img"`

		if ( find_match "$img_data" icns_sizes[@] );
		then
			if [[ "$img_data" =~ ([0-9]+x[0-9]+) ]];
			then
				# echo "\$file: $file"
				size=${BASH_REMATCH[1]}
				# echo "Size $size"
				case $size in
					'1024x1024')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_512x512@2x.png"
						;;
					'512x512')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_${size}.png"
						cp "${img}" "${base_path}/${output_name}.iconset/icon_256x256@2x.png"
						;;
					'256x256')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_${size}.png"
						cp "${img}" "${base_path}/${output_name}.iconset/icon_128x128@2x.png"
						;;
					'128x128')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_${size}.png"
						;;
					'64x64')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_32x32@2x.png"
						;;
					'32x32')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_${size}.png"
						cp "${img}" "${base_path}/${output_name}.iconset/icon_16x16@2x.png"
						;;
					'16x16')
						cp "${img}" "${base_path}/${output_name}.iconset/icon_${size}.png"
						;;
				esac
				build_icns=true
			fi
		fi
	done

	if [[ $build_icns == true ]];
	then
		cd ".."
		iconutil -c icns -o "$output_name.icns" "$output_name.iconset" > /dev/null
	fi

	if [[ $keep_set_dir == false ]]
	then
		cd "$base_path"
		rm -Rf "$output_name.iconset"
	fi
fi


##
# Make Windows ICO
#
if [[ $make_ico == true ]];
then
	echo
	echo "  Make Windows ICO";

	build_ico=false
	eight_bit=false

	cd "$base_path"
	mkdir "$output_name.ico-set" > /dev/null
	cd "$src_path"
	
	for file in "$input_name"*.png;
	do
		# echo "\$file: $file"
		img="$src_path/$file"
		img_data=`identify "$img"`

		if ( find_match "$img_data" ico_sizes[@] );
		then
			if [[ "$img_data" =~ ([0-9]+x[0-9]+) ]];
			then
				# echo "\$file: $file"
				eight_bit=false
				case "${BASH_REMATCH[1]}" in
					'32x32') eight_bit=true ;;
					'24x24') eight_bit=true ;;
					'16x16') eight_bit=true ;;
				esac

				cp "$img" "$base_path/$output_name.ico-set/icon_${BASH_REMATCH[1]}.png"
				if ( $eight_bit );
				then
					convert -depth 4 -colors 16 "$img" -remap "$colormap_path/iconimp-ega.gif" "$base_path/$output_name.ico-set/icon_${BASH_REMATCH[1]}_4-bit.ico"
					convert -depth 8 -colors 256 "$img" +dither -remap "$colormap_path/iconimp-winxp.gif" "$base_path/$output_name.ico-set/icon_${BASH_REMATCH[1]}_8-bit.png"
				fi
				build_ico=true
			fi
		fi
	done

	if [[ $build_ico == true ]];
	then
		# echo "cd $base_path/$output_name.ico-set"
		cd "$base_path/$output_name.ico-set"
		# images=`ls -S`
		images=`ls`
		# echo "\$images: $images"
		convert $images "../$output_name.ico"
	fi

	if [[ $keep_set_dir == false ]]
	then
		cd "$base_path"
		rm -Rf "$output_name.ico-set"
	fi
fi


##
# Make Web-Clip Collection
#
if [[ $make_webclip == true ]];
then
	echo
	echo "  Make Smartphone Web-Clips:";

	cd "$base_path"
	rm -Rf "web-clips"
	mkdir "web-clips"
	cd "$src_path"

	len=${#webclip_sizes[@]}

	for (( i=0; i<len; i++ ))
	do
		webclip_size=${webclip_sizes[$i]}
		if [[ "$webclip_size" =~ ([0-9]+)x([0-9]+) ]]
		then
			webclip_size=${BASH_REMATCH[1]}
			if [[ -z webclip_size ]]; then webclip_size="empty"; fi
		fi
		exact_size=$webclip_size
		loose_size=$(( exact_size + 80 ))
		close_size=$(( exact_size + 40 ))
		very_close_size=$(( exact_size + 20 ))
		# echo "\$exact_size: $exact_size | \$max_size: $max_size"

		exact_match=''
		very_close_size_match=''
		close_size_match=''
		loose_size_match=''
		max_size_match=''

		for file in "$input_name"*.png;
		do
			# echo "\$file: $file"
			img="$src_path/$file"
			img_data=`identify "$img"`

			if [[ "$img_data" =~ ([0-9]+)x[0-9]+ ]];
			then
				img_size=${BASH_REMATCH[1]}
				# echo "\$img_size: $img_size"
			fi
			
			if [[ $img_size -ge $webclip_size ]]
			then
				if [[ $img_size -eq $exact_size ]]
				then
					exact_match=$img
					break
				elif [[ $img_size -le $very_close_size ]]
				then
					very_close_size_match=$img
				elif [[ $img_size -le $close_size ]]
				then
					close_size_match=$img
				elif [[ $img_size -le $loose_size ]]
				then
					loose_size_match=$img
				else
					max_size_match=$img
				fi
			fi
		done

		height=${img_size}
		while [[ "${#img_size}" < 3 ]]
		do
			img_size=" ${img_size}"
		done
		img_size="${img_size}x${height}"
		while [[ "${#img_size}" < 7 ]]
		do
			img_size="${img_size} "
		done


		if [[ -n $exact_match ]]
		then
				echo "${img_size} Exact Match: (copy)        "`basename $exact_match`
			cp "$img" "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}.png"
			cp "$img" "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}-precomposed.png"
			if [[ $webclip_size == "57" ]]
			then
				cp "$img" "${base_path}/web-clips/apple-touch-icon.png"
				cp "$img" "${base_path}/web-clips/apple-touch-icon-precomposed.png"
			fi
		else
			if [[ -n $very_close_size_match ]]
			then
				echo "${img_size} Very Close Match: (resize) "`basename $very_close_size_match`
				img="$very_close_size_match"
			elif [[ -n $close_size_match ]]
			then
				echo "${img_size} Close Match: (resize)      "`basename  $close_size_match`
				img="$close_size_match"
			elif [[ -n $loose_size_match ]]
			then
				echo "${img_size} Loose Match: (resize)      "`basename $loose_size_match`
				img="$loose_size_match"
			elif [[ -n $max_size_match ]]
			then
				echo "${img_size} Max Size Match: (resize)   "`basename $max_size_match`
				img="$max_size_match"
			fi
			convert "$img" -resize $webclip_size "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}.png"
			cp "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}.png" "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}-precomposed.png"
			if [[ $webclip_size == "57" ]]
			then
				cp "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}.png" "${base_path}/web-clips/apple-touch-icon.png"
				cp "${base_path}/web-clips/apple-touch-icon-${webclip_size}x${webclip_size}.png" "${base_path}/web-clips/apple-touch-icon-precomposed.png"
			fi
		fi
	done
fi
# End: Make Web-Clip Collection

echo

exit 0
