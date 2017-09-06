#!/bin/bash

## motifel level

### spatial

gpat_pointshis -i Augusta2011.tif -o Augusta2011_sign.txt
gpat_distmx -i Augusta2011_sign.txt -o Augusta2011_matrix.csv
# R part (simple dendrogram)

### temporal

## grid of motifels level

### spatial 

gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50
gpat_grd2txt -i Augusta2011_grid50 -o Augusta2011_grid50.txt
gpat_distmtx -i Augusta2011_grid50.txt -o Augusta2011_matrix2.csv

## irregular regions