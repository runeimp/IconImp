IconImp, ICOimp, and ICNSimp
============================

This is a collection of command line tools to create Windows and OS X/macOS icons.

ICOimp
------

The `icoimp` BASH script is a simplified version of the IconImp script. This is a much more stable implimentation but doesn't support Apple ICNS or Web-Clips creation.


### Basic Usage Examples

```
# Create a Windows Vista+ icon
$ icoimp logo.png

# Create a browser favicon.ico
$ icoimp -f logo.png

# Creates a favicon.ico, and Windows 10 ICO named logo.ico
$ icoimp -f --win10 logo.png
```

ICNSimp
-------

The `icnsimp` BASH script is a helper script for the `iconutil` tool on newer versions of OS X (Snow Leopard+ ?) and macOS. It takes as input a single image filename and creates an `iconset` directory and populates it with correctly sized and named versions of the source image and then uses `iconutil` on the `iconset` to create the final Apple ICNS icon.


### Basic Usage Examples

```
# Create Apple ICNS icon
$ icnsimp logo.png
  Building IconSet...
  Creating logo.icns icon...
```

Windows ICO Spec
----------------

The following data is illustrative but should not be considered de facto standard information.

| Win            | Max Dim | Max Bits | Max Colors         | Compression |
| :-:            | :-----: | :------: | ----:              | :---------: |
| Win10          | 768×768 | 32       | 16,777,216 + alpha | PNG         |
| WinVista       | 256×256 | 32       | 16,777,216 + alpha | PNG         |
| WinXP          | 48×48   | 24       | 16,777,216         | ?           |
| Win95+MS Plus! | 256×256 | 16       | 65,536             | none        |
| Win95          | 32×32   | 8        | 256                | none        |
| Win32          | 256×256 | 24       | 16,777,216         | none        |
| 3.0            | 32×32   | 4        | 16                 | none        |
| 1.0            | 32×32   | 2        | B&W                | none        |



Installation
------------

**Option 1:** Copy the files `icoimp`, `icnsimp`, `iconimp`, `iconimp-ega.gif`, and `iconimp-winxp.gif` to your personal `bin` directory. Good for single user or restricted systems.

	$ git clone https://github.com/runeimp/IconImp.git
	$ cd IconImp
	$ cp ic* ~/bin/

**Option 2:** Copy the files `icoimp`, `icnsimp`, `iconimp`, `iconimp-ega.gif`, and `iconimp-winxp.gif` to your local `bin` directory. Good for easy access by all system users.

	$ git clone https://github.com/runeimp/IconImp.git
	$ cd IconImp
	$ cp ic* /usr/local/bin/

**Option 3:** Copy the files `icoimp`, `icnsimp`, `iconimp`, `iconimp-ega.gif`, and `iconimp-winxp.gif` to your global `bin` directory. *Not recommended.* But provided for completeness.

	$ git clone https://github.com/runeimp/IconImp.git
	$ cd IconImp
	$ cp ic* /usr/bin/

**Note:** The two GIF files must exist in the same directory as `iconimp` so that the script file can find them to create the full featured Windows ICO file.

OS Support
----------

### Mac

Currently the script reliese on ImageMagick for image resizing and source image size info. But in the near future will use the native program `sips` to be used for source image size info and image resizing when ImageMagick is not present. Though ImageMagick must still be present to create FavIcon and Windows ICO files. As well as producing generally higher quality icons in any format. Note that depending on your version of OS X you may need to install `iconutil` to support ICNS creation by installing Xcode and then check Xcode Preferences > Downloads > Components and download the "Command Line Tools".

### Linux

This script has not been tested on Linux yet but is expected to work normally given that ImageMagick is installed where `iconimp` can access both the `convert` and `identify` commands. To my knowledge there is no Linux version of `iconutil`. Thus Mac ICNS file creation is not possible on Linux. Though if I can find a way I will add such support.

### Windows

This script has not been tested in Windows yet but is expected to work via MSYS or Cygwin as long as ImageMagick is installed where it is accessible by BASH in those environments. To my knowledge there is no Windows version of `iconutil`. Thus Mac ICNS file creation is not possible on Windows. Though if I can find a way I will add such support.

Image Formats Supported
-----------------------

### Source Images

Only the PNG format is supported for source images at this time. Though other image formats are likely to be added, formats that don't support 8-bit alpha transparency (JPEG & GIF) will not be able to produce high quality images without a background color.

### Output Formats

#### FavIcon

By default this is a standard Windows ICO file with the sizes 16&times;16, 24&times;24, 32&times;32, 48&times;48, 64&times;64 stored internally. ICO is the only format at this time that is supported by all browsers that support the FavIcon concept.

#### Windows ICO

By default `iconimp` creates a standard Windows ICO file with the sizes 16&times;16, 24&times;24, 32&times;32, 48&times;48, 256&times;256 in 24-bit true color with alpha (if present) format. 8-bit (256 color) versions are also included for the sizes: 16&times;16, 24&times;24, 32&times;32, 48&times;48. 4-bit (16 color) versions are also included for 16&times;16, 24&times;24, and 32&times;32 sizes. The 256&times;256 HQ Windows XP (also Win7 and Win8) is PNG compressed by all newer versions of ImageMagick's `convert` program.

#### Mac OS X ICNS

By default `iconimp` uses iconutil (on the Mac only) to create a High Quality ICNS file that supports both normal and Retina icon sizes. The source images should be in the sizes: 16&times;16, 32&times;32, 64&times;64, 128&times;128, 256&times;256, 512&times;512, 1024&times;1024.

#### Smartphone Web-Clips

The default web-clips sizes and names use the standards that Apple created which seem to be the most broadly supported by the Android Browser, Chrome for Android, and the latest Blackberry Browsers. The sizes are: 57&times;57, 72&times;72, 114&times;114, 120&times;120, 144&times;144. Be sure to check-out [Mathias Bynens: Everything you always wanted to know about touch icons](http://mathiasbynens.be/notes/touch-icons)



IconImp
-------

The iconimp BASH script is a PNG to FavIcon, Mac ICNS, Windows ICO and Web-Clip builder. It was created on a Mac but should also work on Linux and Windows given the proper system support. Currently broken though...  :-(

Note the API will change soon.

### Basic Usage Examples

```
# Creates a FavIcon, Mac ICNS, Windows ICO and Web-Clips using the base input/file name "logo"
$ iconimp logo

# Creates a browser favicon.ico and specifying the input base name explicitly
$ iconimp -t f -i 'my fav icon.png'

# creates a favicon.ico and Windows "my fav icon.ico"
$ iconimp -t fw 'my fav icon.jpg'

# Apply an image or ICNS file to a file or folder
$ iconimp -a logo.icns
or
$ iconimp -a "Company Logo.png"
```

