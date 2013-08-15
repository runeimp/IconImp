IconImp Docs
============

Usage Examples
--------------

Create a FavIcon, Mac ICNS, Windows ICO and Web-Clips using the base input/file name "logo".

So based on a directory of source images...

	$ cd /path/to/logo/pngs
	$ ls -lhS
	-rw-r--r--  1 runeimp  staff   785K Aug 14 22:24 logo_1024x1024.png
	-rw-r--r--  1 runeimp  staff   217K Aug 14 22:24 logo_512x512.png
	-rw-r--r--  1 runeimp  staff    62K Aug 14 22:24 logo_256x256.png
	-rw-r--r--  1 runeimp  staff    18K Aug 14 22:24 logo_128x128.png
	-rw-r--r--  1 runeimp  staff   5.4K Aug 14 22:24 logo_64x64.png
	-rw-r--r--  1 runeimp  staff   3.3K Aug 14 22:24 logo_48x48.png
	-rw-r--r--  1 runeimp  staff   1.7K Aug 14 22:24 logo_32x32.png
	-rw-r--r--  1 runeimp  staff   1.1K Aug 14 22:24 logo_24x24.png
	-rw-r--r--  1 runeimp  staff   640B Aug 14 22:24 logo_16x16.png

You can create all icon options available.

	$ iconimp logo
	$ ls -lhS
	-rw-r--r--   1 runeimp  staff   1.7M Aug 14 23:40 logo.icns
	-rw-r--r--   1 runeimp  staff    86K Aug 14 23:40 logo.ico
	-rw-r--r--   1 runeimp  staff    41K Aug 14 23:40 favicon.ico
	drwxr-xr-x  14 runeimp  staff   476B Aug 14 23:40 web-clips
	drwxr-xr-x  11 runeimp  staff   374B Aug 14 23:40 _src

The entries `logo.icns`, `logo.ico`, and `favicon.ico` are all single file icons with multiple image sizes within.

The web-clips directory contains all versions needed for all smart phones. Please see [Mathias Bynens: Everything you always wanted to know about touch icons](http://mathiasbynens.be/notes/touch-icons)

	$ cd web-clips/
	$ ls -lhS
	-rw-r--r--  1 runeimp  staff    16K Aug 14 23:40 apple-touch-icon-144x144-precomposed.png
	-rw-r--r--  1 runeimp  staff    16K Aug 14 23:40 apple-touch-icon-144x144.png
	-rw-r--r--  1 runeimp  staff    13K Aug 14 23:40 apple-touch-icon-120x120-precomposed.png
	-rw-r--r--  1 runeimp  staff    13K Aug 14 23:40 apple-touch-icon-120x120.png
	-rw-r--r--  1 runeimp  staff    12K Aug 14 23:40 apple-touch-icon-114x114-precomposed.png
	-rw-r--r--  1 runeimp  staff    12K Aug 14 23:40 apple-touch-icon-114x114.png
	-rw-r--r--  1 runeimp  staff   5.7K Aug 14 23:40 apple-touch-icon-72x72-precomposed.png
	-rw-r--r--  1 runeimp  staff   5.7K Aug 14 23:40 apple-touch-icon-72x72.png
	-rw-r--r--  1 runeimp  staff   4.0K Aug 14 23:40 apple-touch-icon-57x57-precomposed.png
	-rw-r--r--  1 runeimp  staff   4.0K Aug 14 23:40 apple-touch-icon-57x57.png
	-rw-r--r--  1 runeimp  staff   4.0K Aug 14 23:40 apple-touch-icon-precomposed.png
	-rw-r--r--  1 runeimp  staff   4.0K Aug 14 23:40 apple-touch-icon.png

All source images are moved to their own `_src` directory to keep the base directory clean. This is hard coded but may become a configurable option in later versions of IconImp.

	$ cd ../_src
	$ ls -lhS
	-rw-r--r--  1 runeimp  staff   785K Aug 14 22:24 logo_1024x1024.png
	-rw-r--r--  1 runeimp  staff   217K Aug 14 22:24 logo_512x512.png
	-rw-r--r--  1 runeimp  staff    62K Aug 14 22:24 logo_256x256.png
	-rw-r--r--  1 runeimp  staff    18K Aug 14 22:24 logo_128x128.png
	-rw-r--r--  1 runeimp  staff   5.4K Aug 14 22:24 logo_64x64.png
	-rw-r--r--  1 runeimp  staff   3.3K Aug 14 22:24 logo_48x48.png
	-rw-r--r--  1 runeimp  staff   1.7K Aug 14 22:24 logo_32x32.png
	-rw-r--r--  1 runeimp  staff   1.1K Aug 14 22:24 logo_24x24.png
	-rw-r--r--  1 runeimp  staff   640B Aug 14 22:24 logo_16x16.png