# build

pdflatex GeoPAT2_Manual
# bibtex GeoPAT2_Manual
pdflatex GeoPAT2_Manual
pdflatex GeoPAT2_Manual

# move pdf

mv GeoPAT2_Manual.pdf output/

# clean temporary files

rm GeoPAT2_Manual.dvi
rm GeoPAT2_Manual.ps
rm GeoPAT2_Manual.aux
rm GeoPAT2_Manual.log
rm GeoPAT2_Manual.bbl
rm GeoPAT2_Manual.blg
rm GeoPAT2_Manual.toc
