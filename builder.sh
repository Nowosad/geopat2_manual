# setup

file_name="GeoPAT2_Manual"

# build

pdflatex $file_name
biber $file_name
pdflatex $file_name
pdflatex $file_name

# move pdf

mv $file_name.pdf output/

# clean temporary files

rm $file_name.dvi
rm $file_name.ps
rm $file_name.aux
rm $file_name.log
rm $file_name.bbl
rm $file_name.blg
rm $file_name.toc
rm $file_name.out
rm $file_name.bcf
rm $file_name.run.xml