#-------------------------------------------------
# MAPA 3D DE RELEVO DO RIO DE JANEIRO
#-------------------------------------------------

# Importando bibliotecas
library(sf)
library(raster)
library(magrittr)
library(tidyverse)
library(mapview)
library(MetBrewer)
library(colorspace)
library(rayshader)
library(crayon)

# Importando raster e shapefile
DEM <- raster('dados/rasters/30s060w_20101117_gmted_mea150.tif')
BR <- st_read('dados/shapes/BR_UF_2021.shp')

# Analisando nosso DEM
DEM

plot(DEM)

# VERIFICANDO SISTEMAS DE REFERÊNCIA DE COORDENADAS
# Os sistemas de coordenada são iguais?
st_crs(BR) == st_crs(DEM)

crs(BR)
crs(DEM)

# Reprojetando SRC do DEM
s2000 <- CRS("+init=epsg:4674")
DEM_rprj <- DEM %>% projectRaster(crs = s2000, res = 0.004166667, method = 'ngb')

st_crs(BR) == st_crs(DEM_rprj)

plot(DEM_rprj)

# EXTRAINDO RJ DE BR
# Filtramos o estado do RJ com a função da bilbioteca dplyr
RJ <- BR %>%
  filter(SIGLA == 'RJ') 

# CORTANDO A IMAGEM SEM DEIXAR VALORES FORA DA ÁREA DE RECORTE
DEM_crop <- crop(DEM, RJ)

plot(DEM)
plot(DEM_crop)

extent(DEM) == extent(DEM_crop)

# APLICANDO MÁSCARA DEPOIS DE CORTAR
DEM_msk <- mask(DEM_crop, RJ)

plot(DEM_msk)

# Visualização interativa
mapview::mapview(DEM_msk)


# CONVERTENDO RASTER PARA MATRIZ
DEM_mtrx <- raster_to_matrix(DEM_msk)


# PLOTANDO !
# Paleta de cores
c1 <- met.brewer("Tiepolo", direction = -1)
swatchplot(c1)

textura <- grDevices::colorRampPalette(c1, bias = 3)(256)
swatchplot(textura)

outfile <- 'renders/final_plot2.png'

rgl::close3d()

# Botando pra plotar
DEM_mtrx %>%
  height_shade(texture = textura) %>%
  plot_3d(DEM_mtrx,
          solid = TRUE,
          shadowdepth = 0,
          zscale = 50,
          theta = 0,
          phi = 36,
          zoom = .8)

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), '\n')
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(interactive = FALSE,
                     width = 3240,
                     height = 3240,
                     filename = outfile,
                     samples = 360,
                     lightdirection = c(200, 200,180),
                     lightaltitude = c(25,15,45),
                     lightcolor = c(c1[5],'yellow','white'),
                     lightintensity = c(150,300,600))
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), '\n')
  }
