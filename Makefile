# Incluimos el .env para que 'make' conozca las rutas de los volúmenes
include srcs/.env
export

# Variable para el archivo de compose
COMPOSE_FILE = srcs/docker-compose.yml

# La regla por defecto: crea las carpetas y levanta los contenedores
all:
	@echo "Creando directorios de datos en el host..."
	@mkdir -p ${DB_DATA_PATH}
	@mkdir -p ${WP_DATA_PATH}
	@echo "Construyendo y lanzando contenedores Inception..."
	@docker-compose -f ${COMPOSE_FILE} up --build -d
	@echo "¡Inception está en marcha!"

# Regla para detener los contenedores
down:
	@echo "Deteniendo contenedores Inoception..."
	@docker-compose -f ${COMPOSE_FILE} down

# Regla para limpiar todo (contenedores, redes y volúmenes)
clean:
	@echo "Deteniendo contenedores y eliminando volúmenes..."
	@docker-compose -f ${COMPOSE_FILE} down -v --rmi all --remove-orphans
	@echo "Limpieza completada."

# Regla para reiniciar y reconstruir todo
re: clean all

# Regla para limpiar todo el sistema Docker (contenedores, imágenes, volúmenes, redes)
prune:
	@echo "Limpiando todo el sistema Docker..."
	@docker system prune -a --volumes -f
	@echo "Sistema Docker limpiado completamente."

# Indica a 'make' que estas no son carpetas
.PHONY: all down clean re prune