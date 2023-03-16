# -----------------------------------------------------------
# MAPA DE RELEVO 3D DO RIO DE JANEIRO COM GGPLOT E RAYSHADER
# -----------------------------------------------------------

# Importando bibliotecas
library(sf)
library(raster)
library(magrittr)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(rayshader)


# Importando raster e shapefile
DEM <- raster('dados/rasters/30s060w_20101117_gmted_mea150.tif')
BR <- st_read('dados/shapes/BR_UF_2021.shp')

# VERIFICANDO SISTEMAS DE REFERÊNCIA DE COORDENADAS
# Os sistemas de coordenada são iguais?
crs(BR)
crs(DEM)

# Reprojetando SRC do DEM
s2000 <- CRS("+init=epsg:4674")
DEM_rprj <- DEM %>% projectRaster(crs = s2000, res = 0.004166667, method = 'ngb')

st_crs(BR) == st_crs(DEM_rprj)

# EXTRAINDO RJ DE BR
# Filtramos o estado do RJ com a função da bilbioteca dplyr
RJ <- BR %>%
  filter(SIGLA == 'RJ') 

# CORTANDO A IMAGEM SEM DEIXAR VALORES FORA DA ÁREA DE RECORTE
DEM_crop <- crop(DEM, RJ)

# APLICANDO MÁSCARA DEPOIS DE CORTAR
DEM_msk <- mask(DEM_crop, RJ)

# CONVERTENDO EM DF E CONFIGURANDO
DEM_df <- as.data.frame(DEM_msk, xy = TRUE) %>%
  # remove células com NA
  na.omit() %>%
  # Renomeando coluna
  rename(elevacao = X30s060w_20101117_gmted_mea150)

# VISUALIZANDO DATAFRAME
head(DEM_df)

plot(DEM_df)

# CONFIGURANDO GGPLOT
gplt <- ggplot() +
  geom_raster(aes(x=x, y=y, fill=elevacao), data = DEM_df) +
  geom_sf(fill = 'transparent', data = RJ) +
  scale_fill_viridis_c(name='Elevação', 
                       direction = -1, 
                       option = 'G') +
  theme(legend.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = 'bottom',
        #  legend.text = element_text(angle = 45),
        legend.key.width = unit(2, 'line')) +
  labs(title = 'Mapa de Elevação do Estado do Rio de Janeiro')
gplt

rgl::close3d()

# PLOTANDO GGPLOT EM 3D
plot_gg(gplt, width = 5, height = 4, scale = 75,
        theta = 0, zoom = .7, solid = FALSE)
render_snapshot()

saida <- 'renders/ggplot3d.png'

# 3D DE ALTA RESOLUÇÃO
{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), '\n')
  
  render_highquality(interactive = FALSE,
                     width = 1080,
                     height = 1080,
                     filename = saida,
                     samples = 360,
                     lightdirection = c(200, 200,180),
                     lightaltitude = c(25,15,45),
                     lightcolor = c(c1[5],'yellow','white'),
                     lightintensity = c(150,300,600))
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), '\n')
}
