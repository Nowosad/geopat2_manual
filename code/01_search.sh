#!/bin/bash

gpat_gridhis -i Augusta2011.tif -o grid -s cooc -z 50 -f 50 -n pdf

gpat_pointshis -i Augusta2011.tif -o query_signatures.txt -s cooc -z 50 -n pdf --xy_file=coordinates.txt

gpat_search -i grid -r quesry_signatures.txt

gpat_pointsts -i grid -o query_signatures.txt --xy_file=coordinates.txt