#!/usr/bin/env bash
set -C -f -u 
IFS=$'\n'
# ANSI color codes are supported.
# STDIN is disabled, so interactive scripts won't work properly

# This script is considered a configuration file and must be updated manually.

# Meanings of exit codes:
# code | meaning    | action of ranger
# -----+------------+-------------------------------------------
# 0    | success    | Display stdout as preview
# 1    | no preview | Display no preview at all
# 2    | plain text | Display the plain content of the file

# Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER=$(echo ${FILE_EXTENSION} | tr '[:upper:]' '[:lower:]')

# Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH=8
HIGHLIGHT_STYLE='pablo'
PYGMENTIZE_STYLE='monokai'

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        # Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
            atool --list -- "${FILE_PATH}"
            bsdtar --list --file "${FILE_PATH}"
            exit 1;;

        rar)
            # Avoid password prompt by providing empty password
            unrar lt -p- -- "${FILE_PATH}"
            exit 1;;

        7z)
            # Avoid password prompt by providing empty password
            7z l -p -- "${FILE_PATH}"
            exit 1;;

        # PDF
        pdf)
            # Preview as text conversion
            pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" -
            mutool draw -F txt -i -- "${FILE_PATH}" 1-10 
            exiftool "${FILE_PATH}" 
            exit 1;;

        # BitTorrent
        torrent)
            transmission-show -- "${FILE_PATH}"
            exit 1;;

        # OpenDocument
        odt|ods|odp|sxw)
            # Preview as text conversion
            odt2txt "${FILE_PATH}"
            exit 1;;

        # Microoffice
        docx)
            docx2txt "${FILE_PATH}" -
            exit 1;;

        doc)
            antiword -f "${FILE_PATH}"
            exit 1;;

        md)
            if which glow >/dev/null 2>&1; then
                glow -sdark "${FILE_PATH}" | less -R
                exit 1
            fi ;;
        dta)
            if Rscript -e 'library(RStata)' >/dev/null 2>&1; then
                Rscript -e "RStata::stata('des using \"${FILE_PATH}\"')" | sed '1,3d'
                exit 1
            fi ;;

        # HTML
        htm|html|xhtml)
            # Preview as text conversion
            w3m -dump "${FILE_PATH}"
            lynx -dump -- "${FILE_PATH}"
            elinks -dump "${FILE_PATH}" 
            ;; # Continue with next handler on failure
        tsv|csv)
            xsv table -c 20 "${FILE_PATH}"
            exit 1
            ;;
        xlsx)
            ## Preview as csv conversion
            ## Uses: https://github.com/dilshod/xlsx2csv
            xlsx2csv -- "${FILE_PATH}" | head -n 25 | xsv table -c 10 
            exit 1
            ;;
        epub)
            epub2txt "${FILE_PATH}" | head -n 100 
            exit 1
            ;;
    esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
        # Text
        text/* | */xml | */json)
            # Syntax highlight
            if [ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]; then
                exit 2
            fi
            if [ "$( tput colors )" -ge 256 ]; then
                local pygmentize_format='256'
                local highlight_format='ansi'
            else
                local pygmentize_format='terminal'
                local highlight_format='ansi'
            fi
            pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}" -- "${FILE_PATH}" 
            highlight --replace-tabs="${HIGHLIGHT_TABWIDTH}" --out-format="${highlight_format}" --style="${HIGHLIGHT_STYLE}" --force -- "${FILE_PATH}"
            exit 2;;

        # Image
        image/*)
            # Preview as text conversion
            # img2txt --gamma=0.6 -- "${FILE_PATH}" && exit 1
            exiftool "${FILE_PATH}" 
            exit 1;;

        # Video and audio
        video/* | audio/*|application/octet-stream)
            mediainfo "${FILE_PATH}"
            exiftool "${FILE_PATH}"
            exit 1;;
        inode/directory)
            exa -ahl "${FILE_PATH}"
            exit 1;;
    esac
}

handle_fallback() {
    echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}"
    exit 1
}


MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 1
