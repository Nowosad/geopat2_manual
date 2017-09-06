#!/bin/bash

gpat_gridhis -i Augusta2006.tif -o Augusta2006_grid50 -z 50 -f 50
gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50
gpat_compare -i Augusta2006_grid50 -i Augusta2011_grid50 -o Augusta0611_compared.tif