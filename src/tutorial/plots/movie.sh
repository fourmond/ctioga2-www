#! /bin/sh

size=400x400
(
    for i in $(seq 1 100); do
        name=$(printf "Diffusion_%04d" $i)
        ctioga2 -r 6cmx6cm --math /xrange -5:5 \
            --yrange 0:1.1 \
            "1/(0.1*${i}+1)**0.5 * exp(-x**2/(0.1*${i}+1))" \
            --name $name;
        convert -density 150 $name.pdf -alpha Remove \
            -resize $size \
            -depth 8 YUV:- 
    done
) | ffmpeg -f rawvideo -r 25 -s $size -i - Diffusion.avi