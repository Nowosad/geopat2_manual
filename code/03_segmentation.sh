#!/bin/bash

gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50
gpat_segment -i Augusta2011_grid50 -o Augusta2011_seg50.tif -v Augusta2011_seg50.shp
gpat_segquality -i Augusta2011_grid50 -s Augusta2011_seg50.tif -g Augusta2011_seg50_inh.tif -o Augusta2011_seg50_ins.tif