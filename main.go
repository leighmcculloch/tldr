package main // import "4d63.com/tldr"

import (
	"flag"
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/fatih/color"
)

var version = "<not set>"

func main() {
	flagPrintVersion := flag.Bool("version", false, "")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Tldr provides simplified and community-driven man pages.\n")
		fmt.Fprintf(os.Stderr, "Usage: tldr <command>\n")
		fmt.Fprintf(os.Stderr, "Example: tldr tar\n")
	}
	flag.Parse()

	if *flagPrintVersion {
		fmt.Println("tldr", "v"+version)
		return
	}

	args := flag.Args()
	if len(args) == 0 {
		flag.Usage()
		return
	}
	if len(args) > 1 {
		fmt.Fprintf(os.Stderr, "A single command must be specified.\n")
		return
	}

	command := strings.ToLower(args[0])

	raw, ok := files[command]
	if !ok {
		fmt.Fprintf(os.Stderr, "Command %s is not known.\n", command)
		return
	}
	text := string(raw)

	fmt.Fprint(color.Output, pretty(text))
}

func pretty(s string) string {
	sep := "\n"
	lines := strings.Split(s, sep)
	lastLine := ""
	prettyLines := []string{}
	for _, l := range lines {
		if len(lastLine) > 0 && lastLine[0] == '-' && len(l) == 0 {
			continue
		}
		lastLine = l
		if len(l) > 0 {
			switch l[0] {
			case '#':
				l = strings.TrimSpace(l[1:])
			case '>':
				l = strings.TrimSpace(l[1:])
			case '-':
				l = "-" + color.YellowString(l[1:])
			case '`':
				l = strings.Trim(l, "`")
				r := regexp.MustCompile(`{{|}}`)
				parts := r.Split(l, -1)
				for i := 0; i < len(parts); i += 2 {
					parts[i] = color.GreenString(parts[i])
				}
				l = "  " + strings.Join(parts, "")
			}
		}
		prettyLines = append(prettyLines, l)
	}
	return strings.Join(prettyLines, sep)
}
