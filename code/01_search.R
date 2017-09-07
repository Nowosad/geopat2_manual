dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/coordinates.txt", to = "tmp")

system("gpat_gridhis -i Augusta2011.tif -o grid -s cooc -z 50 -f 50 -n pdf")
system("gpat_pointshis -i Augusta2011.tif -o query_signatures.txt -s cooc -z 50 -n pdf --xy_file=coordinates.txt")
system("gpat_search -i grid -r query_signatures.txt")



# gpat_pointsts -i grid -o query_signatures.txt --xy_file=coordinates.txt


# unlink("tmp", recursive = TRUE, force = TRUE)