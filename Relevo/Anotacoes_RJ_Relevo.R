# -----------------------------------
# ANOTANDO E RECORTANDO NOSSO MAPA
# -----------------------------------

# IMPORTANDO BIBLIOTECAS
library(magick)
library(MetBrewer)
library(colorspace)
library(ggplot2)
library(glue)
library(stringr)

# IMPORTANDO IMAGEM
img <- image_read('Imgs/final_plot.png')

# DEFININDO PALETA DE CORES
colors <- met.brewer('Veronese', direction = -1)
swatchplot(colors)

text_color <- darken(colors[3], .25)
swatchplot(text_color)

text_color2 <- colors[3]
swatchplot(text_color2)

# TEXTO PARA IMAGEM
anot <- glue::glue('Este mapa representa o relevo do estado do Rio de Janeiro. ',
                   'Os pontos mais altos estão coloridos em laranja escuro, ',
                   'já os pontos intermediários possuem tons mais claros, transicionando ',
                   'do laranja para o verde. E os pontos mais baixos estão coloridos em verde escuro.') %>%
  str_wrap(75)

# ANOTANDO
img %>%
  # Recortando imagem
  image_crop(gravity = 'center',
             geometry = '3240x1890') %>%
  # Título
  image_annotate("Mapa de Elevação do Estado do Rio de Janeiro",
                 gravity = 'northwest',
                 location = '+150+200',
                 color = text_color,
                 strokecolor = colors[5],
                 size = 100,
                 weight = 700,
                 font = 'Palatino') %>%
  # Descrição
  image_annotate(anot,
                 gravity = 'west',
                 location = '+250-350',
                 color = text_color2,
                 size = 50,
                 font = 'Palatino') %>%
  # Fonte dos dados e autoria
  image_annotate(glue('Autoria de Camila Totti | ',
                      'Fonte: USGS, 2010; IBGE, 2021'),
                 gravity = 'south',
                 location = "+0+100",
                 font = 'Palatino',
                 color = alpha(text_color, .5),
                 size = 40) %>%
  # Salvamento
  image_write('renders/plot_final_anot.png')
