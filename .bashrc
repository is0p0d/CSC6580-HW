# ~/.bashrc: extensions for use with the shell
# Source this from the end of your .bashrc or .zshrc
#
# Copyright (c) 2021 by Stacy Prowell (sprowell@gmail.com).
#
# license: 0BSD
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# Write a debugging message.
function _debug () {
    local esc=$'\e'
    echo "$esc[35m[debug] $(date +'%F %T'): $esc[0m $@"
}

# Write an error message.
function _error () {
    local esc=$'\e'
    echo "$esc[31m$esc[1m[ERROR]$esc[0m $@"
}

# Build a program in assembly, using the first line as the build instructions.
# Run this with -h to find out more about how to use it.
function mk () {
    local assembler
    local linker
    local dynlinker
    local compiler
    # Supported platforms: 64-bit Intel and 64-bit ARM.
    # TODO: Get this working on the new Apple M1 chip.
    case "$(uname -m)/$(uname -s)" in
        armv7l*)
            assembler=as
            linker=ld
            dynlinker="ld -dynamic-linker /lib/ld-linux-armhf.so.3"
            compiler=gcc
            ;;
        aarch64*)
            assembler=as
            linker=ld
            dynlinker="ld -dynamic-linker /lib/ld-linux-aarch64.so.1"
            compiler=gcc
            ;;
        x86_64/Linux*)
            assembler="nasm -f elf64"
            linker=ld
            dynlinker="ld -dynamic-linker /lib64/ld-linux-x86-64.so.2"
            compiler=gcc
            ;;
        x86_64/Darwin*)
            assembler="nasm -fmacho64"
            linker="ld -static"
            dynlinker="ld -dynamic"
            compiler=gcc
            ;;
        *)
            _error "Unsupported platform/OS: $(uname -m)/$(uname -s)"
            return 1
            ;;
    esac
    local debug
    local file
    for opt in "${@}" ; do
        case "$opt" in
            -h*|--help)
                cat <<ENDHELP
usage: mk [options] [assembly file]

Options:
  -d | --debug ....... Print debugging information and exit.
  -h | --help ........ Print this help information.

If the first line of a file contains the character sequence "mk:" then
interpret everything after on the line as build instructions and execute those
instructions.

Example 1:
;mk: nasm -felf64 hello.asm && ld -o hello hello.o

In the above example we can use some variable substitutions.  For instance,
\$mkFILE expands to the input file, and \$mkBASE expands to the filename without
any extension.  We can rewrite the above as follows.

Example 2:
;mk: nasm -felf64 \$mkFILE && ld -o \$mkBASE \$mkBASE.o

There are some additional variables that encode the above, with a few extra
options.

  - \$mkAS ....... expands to the "usual" assembly command
  - \$mkLD ....... expands to the "usual" link command with the linker
  - \$mkDYN ...... expands to the "usual" dynamic link command with the linker
  - \$mkGCC ...... expands to the "usual" link command with gcc

Options can be passed to each of the commands using the environment variables
\$ASOPTS, \$LDOPTS, and \$GCCOPTS. These are treated as the empty string if not set.

We can rewrite the prior example as follows.

Example 3:
;mk: \$mkAS && \$mkLD

To specify the options, set them prior to the command.  For example, the
following will produce a listing file (for AS) and link statically (for
LD).

ASOPTS=-lout.lst LDOPTS=-static mk hello.asm

ENDHELP
                return 0
                ;;
            -d*|--debug)
                _debug "Debugging enabled."
                debug=echo
                ;;
            -*)
                _error "Unrecognized command line switch $opt"
                return 1
                ;;
            *)
                file="$opt"
                ;;
        esac
        shift
    done
    [ -z $file ] && {
        _error "Missing file name."
        return 1
    }
    [ -z "$ASOPTS" ] && export ASOPTS=""
    [ -z "$LDOPTS" ] && export LDOPTS=""
    [ -z "$GCCOPTS" ] && export GCCOPTS=""
    (
        export \
            mkFILE="$file" \
            mkBASE="${file%.*}"
        export \
            mkAS="$assembler $ASOPTS \"$file\" -o \"$mkBASE.o\"" \
            mkNASM="$assembler $ASOPTS \"$file\" -o \"$mkBASE.o\"" \
            mkLD="$linker $LDOPTS -o \"$mkBASE\" \"$mkBASE.o\"" \
            mkDYN="$dynlinker $LDOPTS -o \"$mkBASE\" \"$mkBASE.o\"" \
            mkGCC="$compiler $GCCOPTS -o \"$mkBASE\" \"$mkBASE.o\""
        # Replaced use of shopt -s lastpipe here to support zsh and MacOS.
        read mkCMD < <(head -1 "$mkFILE" | sed -ne "s/^.*mk:\(.*\)$/\1/p" | tr -d '\r' | envsubst)
        [ -z "$mkCMD" ] && {
            _error "Did not find mk: line; no build instructions."
            return 2
        }
        [ -z "$debug" ] || {
            _debug "assembler = $assembler"
            _debug "linker    = $linker"
            _debug "compiler  = $compiler"
            _debug "mkFILE    = $mkFILE"
            _debug "mkBASE    = $mkBASE"
            _debug "ASOPTS    = $ASOPTS"
            _debug "LDOPTS    = $LDOPTS"
            _debug "GCCOPTS   = $GCCOPTS"
            _debug "mkAS      = $mkAS"
            _debug "mkLD      = $mkLD"
            _debug "mkGCC     = $mkGCC"
            _debug "mkCMD     = $mkCMD"
            return 0
        }
        echo $mkCMD
        eval $mkCMD
    )
}

alias dis="objdump -d -Mintel"
alias vdis="objdump -d -Mintel --no-show-raw-insn --visualize-jumps"
function dism () {
    dis $* | $(which most || which less || which more)
}
function vdism () {
    vdis $* | $(which most || which less || which more)
}

# Transcode video to mp4.
function mp4 () {
    ffmpeg -i "$1" -vcodec h264 -acodec aac "${1%.*}.mp4"
}

# Open a file, location, or URL in the appropriate way.
alias xopen=xdg-open
