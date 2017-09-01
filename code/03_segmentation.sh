#!/bin/bash

gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100
gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.shp
gpat_segquality -i Augusta2011_grid100 -s Augusta2011_seg100.tif -g Augusta2011_seg100_inh.tif -o Augusta2011_seg100_ins.tif