#!/bin/bash

gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid15 -z 15 -f 15
gpat_segment -i Augusta2011_grid15 -o Augusta2011_seg15.tif -v Augusta2011_seg15.shp
gpat_segquality -i Augusta2011_grid15 -s Augusta2011_seg15.tif -g Augusta2011_seg15_inh.tif -o Augusta2011_seg15_ins.tif