IconImp v0.9.0
==============

The iconimp BASH script is a PNG to FavIcon, Mac ICNS, Windows ICO and Web-Clip builder. It was created on a Mac but should also work on Linux and Windows given the proper system support.

Mac Support
-----------

Currently the script reliese on ImageMagick for image resizing and source image size info. But in the near future will use the native program `sips` to be used for source image size info and image resizing when ImageMagick is not present. Though ImageMagick must still be present to create FavIcon and Windows ICO files. As well as producing generally higher quality icons in any format. Note that depending on your version of OS X you may need to install `iconutil` to support ICNS creation by installing Xcode and then check Xcode Preferences > Downloads > Components and download the "Command Line Tools".

Linux Support
-------------

This script has not been tested on Linux yet but is expected to work normally given that ImageMagick is installed where iconimp can access both the `convert` and `identify` commands. To my knowledge there is no Linux version of `iconutil`. Thus Mac ICNS file creation is not possible on Linux. Though if I can find a way I will add such support.

Windows Support
---------------

This script has not been tested in Windows yet but is expected to work via MSYS or Cygwin as long as ImageMagick is installed where it is accessible by those environments. To my knowledge there is no Windows version of `iconutil`. Thus Mac ICNS file creation is not possible on Windows. Though if I can find a way I will add such support.

Formats Supported
-----------------

### Source Images

Only the PNG format is supported for source images at this time. Though other image formats are likely to be added, formats that don't support 8-bit alpha transparency (JPEG & GIF) will not be able to produce high quality images without a background color.

### Output Formats

### FavIcon

By default this is a standard Windows ICO file with the sizes 16x16, 24x24, 32x32, 48x48, 64x64 stored internally. ICO is the only format at this time that is supported by all browsers that support the FavIcon concept.

### Windows ICO

By default iconimp creates a standard Windows ICO file with the sizes 16x16, 24x24, 32x32, 48x48, 256x256 in 24-bit true color with alpha (if present) format. 8-bit (256 color) versions are also included for the sizes: 16x16, 24x24, 32x32, 48x48. 4-bit (16 color) versions are also included for 16x16, 24x24, and 32x32 sizes. The 256x256 HQ Windows XP (also Win7 and Win8) is PNG compressed by all newer versions of ImageMagick's `convert` program.

### Mac OS X ICNS

By default iconimp uses iconutil (on the Mac only) to create a High Quality ICNS file that supports both normal and Retina icon sizes. The source images should be in the sizes: 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024.

### Smartphone Web-Clips

The default web-clips sizes and names use the standards that Apple created which seem to be the most broadly supported by the Android Browser, Chrome for Android, and the latest Blackberry Browsers. The sizes are: 57x57, 72x72, 114x114, 120x120, 144x144.