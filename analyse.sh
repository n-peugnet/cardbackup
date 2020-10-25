#!/bin/bash

TMP_DIR=${TMP_DIR:-$(mktemp -dt cardbackup-XXXXXXXX)}

filename=$(basename "$1")
mediainfo=$(mediainfo --File_TestContinuousFileNames=0 --Inform=file://mediainfotemplate "$1")
FileSize=$(               sed -n 1p <<< $mediainfo)
FileSizeString4=$(        sed -n 2p <<< $mediainfo)
VideoCount=$(             sed -n 3p <<< $mediainfo)
Format=$(                 sed -n 4p <<< $mediainfo)
Duration=$(               sed -n 5p <<< $mediainfo)
DurationString4=$(        sed -n 6p <<< $mediainfo)
VideoFormat=$(            sed -n 7p <<< $mediainfo)
FrameRateString=$(        sed -n 8p <<< $mediainfo)
WidthString=$(            sed -n 9p <<< $mediainfo)
HeightString=$(           sed -n 10p<<< $mediainfo)
BitRateString=$(          sed -n 11p <<< $mediainfo)
AspectRatio=$(            sed -n 12p <<< $mediainfo)
ScanTypeString=$(         sed -n 13p <<< $mediainfo)
ChromaSubsamplingString=$(sed -n 14p <<< $mediainfo)
BitDepthString=$(         sed -n 15p <<< $mediainfo)

echo -e "\n"
echo -e "\e[34m\e[1mfilename           : $filename\e[0m"


echo "\
\\subsection{\\lstinline{$filename}}
\\lstinline{$1}
\\subsubsection{mediainfo}
\\begin{lstlisting}" >> $TMP_DIR/summary.tex

echo "\
size               : $FileSizeString4
size (bytes)       : $FileSize" | tee -a $TMP_DIR/summary.tex



# Check if the file contain video stream

if [[ -n $VideoCount && -n $Duration ]]
then

    echo "\
format             : $Format
videoformat        : $VideoFormat
framerate          : $FrameRateString
width              : $WidthString
height             : $HeightString
duration           : $DurationString4
bitrate            : $BitRateString
aspect ratio       : $AspectRatio
scan type          : $ScanTypeString
chroma subsampling : $ChromaSubsamplingString
bit depth          : $BitDepthString" | tee -a $TMP_DIR/summary.tex


    echo "\\end{lstlisting}" >> $TMP_DIR/summary.tex

    # Screenshots

    screendir="$TMP_DIR/screenshots"
    mkdir -p $screendir

    md5=$(echo $1 | md5sum | cut -d' ' -f1)
    screenquality="-vf scale=1280:-1 -q:v 5"
    echo $md5

    let "d = $Duration"
    let "d = d / 1000"
    let "m = d / 2"
    let "l = d - 1"
    ffmpeg -y -loglevel fatal -ss 1 -i "$1" -vframes 1 $screenquality "$screendir/$md5-screenshot0.jpg"
    ffmpeg -y -loglevel fatal -ss $m -i "$1" -vframes 1 $screenquality "$screendir/$md5-screenshot1.jpg"
    ffmpeg -y -loglevel fatal -ss $l -i "$1" -vframes 1 $screenquality "$screendir/$md5-screenshot2.jpg"

    echo "\
\\subsubsection{screenshots}
\\noindent
\\begin{tabular}{lll}
\\includegraphics[width=0.3\\textwidth]{$screendir/$md5-screenshot0.jpg} &
\\includegraphics[width=0.3\\textwidth]{$screendir/$md5-screenshot1.jpg} &
\\includegraphics[width=0.3\\textwidth]{$screendir/$md5-screenshot2.jpg} \\\\
\\end{tabular}" >> $TMP_DIR/summary.tex


else
    echo "\\end{lstlisting}" >> $TMP_DIR/summary.tex
fi




