# ------------------------------------------------
# RECORTANDO O MAPA DE RELEVO DO RJ COM GGPLOT2
# ------------------------------------------------

# IMPORTANDO BIBLIOTECAS
library(magick)

# IMPORTANDO IMAGEM
img <- image_read('Imgs/ggplot3d.png')

img %>%
  # CORTANDO IMAGEM
  image_crop(gravity = 'center',
             geometry = '1080x660') %>%
  # Salvamento
  image_write('Imgs/ggplot3d_annot.png')
