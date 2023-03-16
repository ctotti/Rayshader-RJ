library(magick) # annotate images
library(MetBrewer)
library(colorspace)
library(ggplot2)
library(glue)
library(stringr)

img <- image_read('Images_render_br/final_plot2.png')

colors <- met.brewer('Tiepolo', direction = -1)
swatchplot(colors)

text_color <- darken(colors[7], .25)
swatchplot(text_color)

annot <- glue("This map shows population density of the state of Rio de Janeiro, Brazil. ",
              "Population estimates are bucketed into 400 meter (about 1/4 mile) ",
              "hexagons.") %>%
  str_wrap(45)

img %>%
  # Cortar imagem
  image_crop(gravity = "center",
             geometry = "3240x1890+0-50") %>%
  # Título
  image_annotate("Rio de Janeiro Population Density", 
                 gravity = "northwest",            
                 location = "+150+200",
                 color = text_color,
                 size = 100,
                 weight = 700,
                 font = "Palatino") %>% 
  # Descrição
  image_annotate(annot,
                 gravity = "west",
                 location = "+300-150",
                 color = text_color,
                 size = 60,
                 font = "Palatino") %>%
  # Fonte dos dados e autoria
  image_annotate(glue("Graphic by Camila Totti | ",
                      "Data: Kontur Population (Released 2022-06-30)"),
                 gravity = "south",
                 location = "+0+100",
                 font = "Palatino",
                 color = alpha(text_color, .5),
                 size = 40) %>%
  # Salva imagem
  image_write("Images_render_br//titled_final_plot.png")

## VERSÃO EM PORTUGUÊS ------------------------------------------------------------------------

img <- image_read('Images_render_br/final_plot2.png')

annot_pt <- glue("Este mapa mostra a densidade populacional do estado do Rio de Janeiro, Brasil. ", 
              "As estimativas populacionais estão agrupadas em hexágonos de 400 metros.") %>%
  str_wrap(45)

img %>%
  # Corta a imagem
  image_crop(gravity = "center",
             geometry = "3240x1890+0-50") %>%
  # Título
  image_annotate("Densidade Populacional do Estado do Rio de Janeiro", 
                 gravity = "northwest",            
                 location = "+150+200",
                 color = text_color,
                 size = 100,
                 weight = 700,
                 font = "Palatino") %>% 
  # Descrição
  image_annotate(annot_pt,
                 gravity = "west",
                 location = "+300-150",
                 color = text_color,
                 size = 60,
                 font = "Palatino") %>%
  # Fonte dos dados e autoria
  image_annotate(glue("Gráfico por Camila Totti | ",
                      "Fonte: Kontur Population (Lançado 2022-06-30)"),
                 gravity = "south",
                 location = "+0+100",
                 font = "Palatino",
                 color = alpha(text_color, .5),
                 size = 40) %>%
  # Salva imagem
  image_write("Images_render_br//titled_final_plot_PT.png")
