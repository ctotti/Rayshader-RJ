#install.packages('tigris')
#install.packages('stars')
#install.packages('rgl')
devtools::install_github("tylermorganwall/rayshader")
devtools::install_github("BlakeRMills/MetBrewer")

library(devtools)
library(magrittr)
library(sf)
library(tigris)
library(tidyverse)
library(stars)
library(rayrender)
library(rayshader)
library(rgl)
library(MetBrewer)
library(colorspace)
library(crayon)

# carregar dados do Kontur para o Brasil
data <- st_read('data/kontur_population_BR_20220630.gpkg')

# carregar estados brasileiros
estados_br <- st_read('data/BR_UF_2021.shp')

# filtrar para o Rio de Janeiro
rio <- estados_br |>
  filter(SIGLA == 'RJ') |>
  st_transform(crs = st_crs(data))


# Exportando dataframe 'rio' como Shapefile ----------------------------
st_write(rio,                             # dataframe que deseja exportar
         'data/RJ_kontur_epsg3857.shp')   # nome e formato do arquivo que queremos exportar

#-------------------
# Na próxima da para importar de uma vez o arquivo shapefile 'florida_kontur.shp' ao invés de usar `states()`
rio <- st_read('data/RJ_kontur_epsg3857.shp')

#-------------------
# Plot inicial de `rio`
rio |>
  ggplot()+
  geom_sf()

ggplot(data = rio, aes(colour=pop))
# SRC é igual?
st_crs(rio) == st_crs(data)  # If FALSE, set crs on line 14

# interseccionar `data` limite de `rio`
# !!! DEMORADO
estado_rio <- st_intersection(data, rio)

# exportando estado_rio -------------------------------
st_write(estado_rio, 'data/RJ_intersec.gpkg')

# importando o florida_intersec.gpkg
estado_rio <- st_read('data/RJ_intersec.gpkg')

st_crs(estado_rio) == st_crs(data)

# Plot inicial de estado_rio
estado_rio |>
  ggplot(aes(colour=population))+
  geom_sf()

# DEFININDO PROPORÇÃO BASEDA NOS LIMITES DA IMAGEM -----------------
bb <- st_bbox(estado_rio)
# Extraindo point coordinates da base da imagem
bottom_left <- st_point(c(bb[['xmin']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(data))
bottom_right <- st_point(c(bb[['xmax']], bb[['ymin']])) |>
  st_sfc(crs = st_crs(data))

# Verificando o que fizemos com o bottom_left e o bottom_right
estado_rio |>
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color= 'red')

# Calculando distância de bottom_left até bottom_right (largura da imagem)
width <- st_distance(bottom_left, bottom_right)

# Extraindo point coordinate da lateral da imagem
top_left <- st_point(c(bb[['xmin']], bb[['ymax']])) |>
  st_sfc(crs = st_crs(data))
# Calculando distância de bottom_left até top_left (altura da imagem)
height <- st_distance(bottom_left, top_left)

width == height  # quick check if they're the same
width - height   # simple easy manual way to calculate the difference between them (in meters)

# Este passo para descobrir a proporção exata da imagem
# Lida com condições de largura ou altura maior em um dos lados
# Nota: a parte 'else' da função lida com altura ser maior que largura e também altura e largura serem iguais
if (width > height) {
  w_ratio <- 1                     # width ratio
  h_ratio <- height / width        # height ratio
} else {
  h_ratio <- 1                     # height ratio
  w_ratio <- width / height        # width ratio
}

# CONVERTENDO DADOS GPKG PARA RASTER PARA PODER CONVERTER EM MATRIZ ------------- 
size <- 2000

rio_rast <- st_rasterize(estado_rio,
                              nx = floor(size * w_ratio),
                              ny = floor(size * h_ratio))

mat <- matrix(rio_rast$population,
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))


# Agora podemos excluir todos as variáveis com exceção de 'mat', 'rio_rast', 'size', 'estado_rio'
remove(data)
remove(bottom_right)
remove(bottom_left)
remove(top_left)
remove(bb)
remove(h_ratio)
remove(w_ratio)
remove(height)
remove(width)

# PLOT THAT 3D THING ! ------------------------------------------------------------

# Cria paleta de cores
c1 <- met.brewer('Tiepolo', direction = -1)
swatchplot(c1)

texture <- colorRampPalette(c1, bias = 3)(256)
swatchplot(texture)

# Plotting
rgl::close3d()    # comando para fechar a janela interativa do mapa

mat %>%
  height_shade(texture = texture) %>%
  plot_3d(heightmap = mat,
          zscale = 200 / 2,            # quanto maior o valor, menor será o exagero vertical
          solid = FALSE,
          shadowdepth = 0,
          theta = 0, 
          phi = 33, 
          zoom = .8)

outfile <- "Images_render_br/final_plot2.png"

# ATENÇÃO! Essa etapa pode levar até mais de uma hora dependendo das configurações
{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(width = 3240,
                     height = 3240,
                     filename = outfile,
                     samples = 360,
                     interactive = FALSE,
                     lightdirection = c(225,135),
                     lightaltitude = c(20, 80),
                     lightcolor = c(c1[5], "white"),
                     lightintensity = c(600, 300))
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
  }






