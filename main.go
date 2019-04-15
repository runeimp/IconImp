//
// PACKAGES
//
// @see http://www.jonathantneal.com/blog/understand-the-favicon/
// @see https://mathiasbynens.be/notes/touch-icons
// @see https://github.com/abrkn/icon
// @see https://web.archive.org/web/20120608074941/http://miniapps.co.uk/blog/post/ios-startup-images-using-css-media-queries/
//
package main

//
// IMPORTS
//
import (
	"bufio"
	"bytes"
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"io"
	"log"
	"os"
	"path"
	"path/filepath"
	"strings"
	"time"

	arg "github.com/alexflint/go-arg"
	ico "github.com/biessek/golang-ico"
	"github.com/h2non/filetype"
	"github.com/jackmordaunt/icns"
	"github.com/spf13/afero"
	// "github.com/wrfly/ecp"
)

/*
 * CONSTANTS
 */
const (
	AppName    AppMetaData = "IconImp"
	AppDesc    AppMetaData = "A cross-platform ICO, ICNS, and Web Icons generator."
	AppVersion AppMetaData = "0.1.0"
	CLIName    AppMetaData = "iconimp"
)

/*
 * DERIVED CONSTANTS
 */
var (
	AppLabel = AppMetaData(fmt.Sprintf("%s v%s", string(AppName), string(AppVersion)))
)

/*
 * TYPES
 */
type (
	// AppMetaData defines meta-data about an application
	AppMetaData string

	appArgs struct {
		Images   []string `arg:"positional"`
		Browser  bool     `help:"Create Browser Icons in sizes 16x16, 32x32, 48x48, 64x64, and 128x128 PNG"`
		Debug    bool     `arg:"-D" help:"output debug info"`
		FavIcon  bool     `arg:"-f" help:"Create a Windows 32x32 favicon.ico"`
		MacOS    bool     `arg:"-m" help:"Create a macOS/OS X 1024x1024 ICNS with the normal sub-sizes."`
		Name     string   `arg:"-n" help:"Specify the base name of the generated files."`
		Touch    bool     `help:"Create Touch Icons in 57x57 "`
		WebIcons bool     `arg:"-w" help:"Create Web Icons (browser, tile, and touch) in sizes from 57x57 to 558×558 PNG"`
		Win10    bool     `arg:"-x" help:"Create a Windows 10 768x768, 256x256, 64x64, 32x32, 24x24, and 16x16 PNG compressed ICO"`
		WinVista bool     `arg:"-v" help:"Create a Windows Vista 256x256 PNG compressed ICO"`
		// Verbose uint8    `arg:"-v" help:"Increase verbosity"`
		// Help  bool `arg:"-h" help:"Output this help info."`
	}

	encoderFunc func(io.Writer, image.Image) error
)

func (appArgs) Description() string {
	return fmt.Sprintln(AppDesc)
}

func (appArgs) Version() string {
	return string(AppLabel)
}

// ICNS Type definition for filetype library
var icnsType = filetype.NewType("icns", "image/icns")

func icnsMatcher(buf []byte) bool {
	return len(buf) > 3 && buf[0] == 0x69 && buf[1] == 0x63 && buf[2] == 0x6E && buf[3] == 0x73
}

/*
 * VARIABLES
 */
var (
	args     appArgs
	encoders = map[string]encoderFunc{
		".png":  png.Encode,
		".jpg":  encodeJPEG,
		".jpeg": encodeJPEG,
	}
	fs = afero.NewOsFs()
)

/*
 * FUNCTIONS
 */

func changeExtensionTo(path, ext string) string {
	if !strings.HasPrefix(ext, ".") {
		ext = "." + ext
	}
	return filepath.Base(path[:len(path)-len(filepath.Ext(path))] + ext)
}

func encodeJPEG(w io.Writer, m image.Image) error {
	return jpeg.Encode(w, m, &jpeg.Options{Quality: 100})
}

func init() {
	// ecp.Default(&args)
	arg.MustParse(&args)
	log.Printf("args.Images = %v\n", args.Images)
	log.Printf("args.Debug = %v\n", args.Debug)
	log.Printf("args.FavIcon = %v\n", args.FavIcon)
	log.Printf("args.MacOS = %v\n", args.MacOS)
	// log.Printf("args.Name = %q\n", args.Name)
	log.Printf("args.WebIcons = %v\n", args.WebIcons)
	log.Printf("args.Win10 = %v\n", args.Win10)
	log.Printf("args.WinVista = %v\n", args.WinVista)
	// log.Printf("args.Verbose = %v\n", args.Verbose)
	log.Printf("os.Args[1:] = %v\n", os.Args[1:])
	if len(args.Name) == 0 {
		if len(args.Images) == 0 {
			// fmt.Println("Warning: No images specified to create icons with")
			fmt.Println("...")
		} else {
			filename := args.Images[0]
			end := len(path.Base(filename)) - len(path.Ext(filename))
			args.Name = path.Base(filename)[:end]
		}
	}
	log.Printf("args.Name = %q\n", args.Name)

	// Register the new matcher and its type
	filetype.AddMatcher(icnsType, icnsMatcher)

	// Check if the new type is supported by extension
	// if filetype.IsSupported("icns") {
	// 	fmt.Println("New supported type: icns")
	// }

	// Check if the new type is supported by MIME
	// if filetype.IsMIMESupported("image/icns") {
	// 	fmt.Println("New supported MIME type: image/icns")
	// }
}

func sanitiseInputs(inputPath, outputPath string, resize int) (string, string, icns.InterpolationFunction) {
	if filepath.Ext(inputPath) == ".icns" {
		if outputPath == "" {
			outputPath = changeExtensionTo(inputPath, "png")
		}
		if filepath.Ext(outputPath) == "" {
			outputPath += ".png"
		}
	} else {
		if outputPath == "" {
			outputPath = changeExtensionTo(inputPath, "icns")
		}
		if filepath.Ext(outputPath) == "" {
			outputPath += ".icns"
		}
	}

	if resize < 0 {
		resize = 0
	} else if resize > 5 {
		resize = 5
	}

	return inputPath, outputPath, icns.InterpolationFunction(resize)
}

type fileData struct {
	Bytes     []byte
	Image     image.Image
	Extension string
	Kind      string
	Size      uint
}

var inputFile *fileData

func getInput(input chan byte) {
	in := bufio.NewReader(os.Stdin)
	var i uint
	for {
		result, err := in.ReadByte()
		// result, err := in.ReadBytes()
		if err != nil {
			if err == io.EOF {
				// log.Printf("getInput() | EOF | %s\n", err)
				break
			} else {
				log.Fatalf("getInput() | %s\n", err)
			}
		}
		if i < 0 {
			fmt.Printf("getInput() | result = 0x%0.2X\n", result)
		}
		i++
		input <- result
	}
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func icoWrite(imgName string, imgData *fileData) error {
	imgName = fmt.Sprintf("%s.ico", imgName)
	f, err := os.Create(imgName)
	check(err)
	err = ico.Encode(f, imgData.Image)
	check(err)
	return err
}

func pngRead(imgData *fileData) *fileData {
	var err error
	reader := bytes.NewReader(imgData.Bytes)
	imgData.Image, err = png.Decode(reader)
	check(err)
	return imgData
}

/*
 * MAIN ENTRYPOINT
 */
func main() {
	log.Printf("%s\n", AppLabel)

	inputFile = &fileData{}

	input := make(chan byte, 1)
	go getInput(input)

InputTest:
	for {
		select {
		case aByte := <-input:
			if inputFile.Bytes == nil {
				inputFile.Bytes = []byte{aByte}
			} else {
				inputFile.Bytes = append(inputFile.Bytes, aByte)
			}
			if inputFile.Kind == "" {
				kind, _ := filetype.Match(inputFile.Bytes)
				if kind != filetype.Unknown {
					inputFile.Kind = kind.MIME.Value
					inputFile.Extension = kind.Extension
					fmt.Printf("File type: %s  MIME: %s\n", strings.ToUpper(inputFile.Extension), inputFile.Kind)
				}
			}
		case <-time.After(1000 * time.Millisecond):
			break InputTest
		}
	}
	inputFile.Size = uint(len(inputFile.Bytes))
	log.Printf("%d Bytes", inputFile.Size)

	switch inputFile.Extension {
	case "png":
		inputFile = pngRead(inputFile)
	}

	if args.WinVista {
		if len(args.Name) > 0 && inputFile.Size > 0 {
			icoWrite(args.Name, inputFile)
		}
	}

	// in, out, algorithm := sanitiseInputs(*inputPath, *outputPath, *resize)
}
