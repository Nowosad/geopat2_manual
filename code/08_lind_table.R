library(tidyverse)
library(xtable)

lind = read_csv("data/landscape_indices_list.csv") %>% 
        mutate(No = row_number()) %>% 
        select(No, index, description, landscape_level, class_level) %>% 
        set_names(c("ID", "Name", "Description", "Landscape level", "Class level"))

lind_table = xtable(lind, caption = "Landscape metrics implemented in GeoPAT 2.0", label = "lindtable")

print(lind_table, tabular.environment = "longtable",
      floating = FALSE,
      include.rownames = FALSE,  # because addtorow will substitute the default row names 
      hline.after=c(-1),
      file = "data/lind_table.tex")
