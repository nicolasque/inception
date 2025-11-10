include srcs/.env
export

COMPOSE_FILE = srcs/docker-compose.yml

all:
	@echo "Creando directorios de datos en el host..."
	@mkdir -p ${DB_DATA_PATH}
	@mkdir -p ${WP_DATA_PATH}
	@echo "Construyendo y lanzando contenedores Inception..."
	@docker-compose -f ${COMPOSE_FILE} up --build -d
	@echo "¡Inception está en marcha!"

down:
	@echo "Deteniendo contenedores Inoception..."
	@docker-compose -f ${COMPOSE_FILE} down

clean:
	@echo "Deteniendo contenedores y eliminando volúmenes..."
	@docker-compose -f ${COMPOSE_FILE} down -v --rmi all --remove-orphans
	@echo "Limpieza completada."

re: clean all

prune:
	@echo "Limpiando todo el sistema Docker..."
	@docker system prune -a --volumes -f
	@echo "Sistema Docker limpiado completamente."

.PHONY: all down clean re prune