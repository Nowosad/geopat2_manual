library(tidyverse)
library(xtable)

lind1 = read_csv("data/landscape_indices_list.csv") %>% 
        set_names(c("ID", "Name", "Description", "Class level", "Landscape level")) %>% 
        filter(Name != "pland")

lind2 = read_csv("data/landscape_indices_list.csv") %>% 
        set_names(c("ID", "Name", "Description", "Class level", "Landscape level")) %>% 
        filter(Name == "pland")


lind = bind_rows(lind1, lind2) %>% 
        mutate(ID = row_number())

lind_table = xtable(lind, caption = "Landscape metrics implemented in GeoPAT 2.0", label = "lindtable")

print(lind_table, tabular.environment = "longtable",
      floating = FALSE,
      include.rownames = FALSE,  # because addtorow will substitute the default row names 
      hline.after=c(-1),
      file = "data/lind_table.tex")
