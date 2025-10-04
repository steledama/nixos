# Makefile - versione semplificata con progetto tt
COMPOSE_PROJECT_NAME=tt

# Rete condivisa
create-network:
	docker network inspect shared-network >/dev/null 2>&1 || docker network create shared-network

# Crea i volumi esterni necessari (SOLO servizi base)
create-volumes:
	docker volume inspect toscana_wp_db_data >/dev/null 2>&1 || docker volume create toscana_wp_db_data
	docker volume inspect toscana_wp_content >/dev/null 2>&1 || docker volume create toscana_wp_content
	docker volume inspect flexora_wp_db_data >/dev/null 2>&1 || docker volume create flexora_wp_db_data
	docker volume inspect flexora_wp_content >/dev/null 2>&1 || docker volume create flexora_wp_content
	docker volume inspect baserow_data >/dev/null 2>&1 || docker volume create baserow_data
	docker volume inspect nginx_logs >/dev/null 2>&1 || docker volume create nginx_logs
	docker volume inspect nginx_cache >/dev/null 2>&1 || docker volume create nginx_cache

# ------- COMANDI NGINX PROXY -------
nginx-up: create-network create-volumes
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml up -d

nginx-down:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml down

nginx-restart: nginx-down nginx-up

nginx-logs:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml logs -f nginx-proxy

# ------- COMANDI BASEROW -------
baserow-up: create-network create-volumes
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.baserow.yml up -d

baserow-down:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.baserow.yml down

baserow-restart: baserow-down baserow-up

baserow-backup:
	@echo "⚠️  ATTENZIONE: Il backup da command line crea file molto pesanti (>1GB)"
	@echo "📋 RACCOMANDAZIONE: Usa invece il backup GUI per workspace specifici:"
	@echo "   1. Accedi a Baserow → http://5.89.62.125:8385"
	@echo "   2. Seleziona workspace 'tt' → Menu → 'Export data'"
	@echo "   3. Download ZIP compatto (~7MB vs >1GB)"
	@echo ""
	@echo "🚫 Backup command line DISABILITATO per evitare spreco spazio disco"
	@echo "   Se necessario, decommentare i comandi nel Makefile"
	@echo ""
	# @mkdir -p backup
	# docker exec baserow pg_dump -U baserow baserow > backup/baserow_db_$$(date +%Y%m%d_%H%M%S).sql
	# docker run --rm -v baserow_data:/data -v $$(pwd)/backup:/backup busybox tar czf /backup/baserow_volume_$$(date +%Y%m%d_%H%M%S).tar.gz -C /data .

# ------- COMANDI TOSCANA TRADING -------
toscana-up: create-network create-volumes
	WP_UID=$$(id -u) WP_GID=$$(id -g) docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.toscana.yml up -d

toscana-down:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.toscana.yml down

toscana-restart: toscana-down toscana-up

toscana-backup:
	@mkdir -p backup
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.toscana.yml exec toscana-db \
		mysqldump -u root -p"$$TOSCANA_DB_ROOT_PASSWORD" $$TOSCANA_DB_NAME > backup/toscana_$$(date +%Y%m%d_%H%M%S).sql

# ------- COMANDI FLEXORA -------
flexora-up: create-network create-volumes
	WP_UID=$$(id -u) WP_GID=$$(id -g) docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.flexora.yml up -d

flexora-down:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.flexora.yml down

flexora-restart: flexora-down flexora-up

flexora-backup:
	@mkdir -p backup
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.flexora.yml exec flexora-db \
		mysqldump -u root -p"$$FLEXORA_DB_ROOT_PASSWORD" $$FLEXORA_DB_NAME > backup/flexora_$$(date +%Y%m%d_%H%M%S).sql

# ------- COMANDI GLOBALI -------
down-all:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml down
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.baserow.yml down
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.flexora.yml down
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.toscana.yml down

up-all: create-network create-volumes
	@echo "🚀 === AVVIO SERVIZI IN SEQUENZA (progetto: $(COMPOSE_PROJECT_NAME)) ==="
	@echo "📝 1. Avvio servizi WordPress..."
	WP_UID=$$(id -u) WP_GID=$$(id -g) docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.toscana.yml up -d
	WP_UID=$$(id -u) WP_GID=$$(id -g) docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.flexora.yml up -d
	@echo "📝 2. Avvio Baserow..."
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.baserow.yml up -d
	@echo "⏳ 3. Attesa stabilizzazione servizi (15s)..."
	@sleep 15
	@echo "📝 4. Verifica servizi attivi..."
	@make ps-all
	@echo "📝 5. Avvio nginx proxy..."
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml up -d
	@echo "✅ Deployment completato!"
	@echo ""
	@echo "🌐 === SERVIZI DISPONIBILI ==="
	@echo "🏠 Landing:  https://5.89.62.125"
	@echo "🛍️ Toscana:  https://5.89.62.125:8443"
	@echo "💼 Flexora:  https://5.89.62.125:8444"
	@echo "📊 Baserow:  http://5.89.62.125:8385"

restart-all: down-all up-all

# ------- COMANDI UTILITY -------
ps-all:
	@echo "🐳 === STATO CONTAINERS (progetto: $(COMPOSE_PROJECT_NAME)) ==="
	@docker ps --filter "label=com.docker.compose.project=$(COMPOSE_PROJECT_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

status:
	@echo "🌐 === SERVIZI ATTIVI ==="
	@echo "🏠 Landing Page: https://5.89.62.125"
	@echo "🛍️ Toscana Trading: https://5.89.62.125:8443"
	@echo "💼 Flexora: https://5.89.62.125:8444"
	@echo "🔄 Syncthing: https://5.89.62.125/syncthing/"
	@echo "📊 Baserow: http://5.89.62.125:8385"
	@echo ""
	@echo "📁 === ACCESSO DATABASE ==="
	@echo "🗄️ Toscana PHPMyAdmin: http://5.89.62.125:8181"
	@echo "🗄️ Flexora PHPMyAdmin: http://5.89.62.125:8182"

backup-all:
	@mkdir -p backup
	@echo "🔄 Avvio backup completo..."
	make toscana-backup
	make flexora-backup
	make baserow-backup
	@echo "✅ Backup completato"

# Rebuild nginx (per aggiornare landing page)
nginx-rebuild:
	@echo "🔄 Rebuild nginx container..."
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml down
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml build --no-cache
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f compose.nginx.yml up -d
	@echo "✅ Nginx ricostruito e riavviato"

# ------- PULIZIA -------
clean-orphans:
	@echo "🧹 Rimozione container orfani del progetto bi..."
	docker ps -a --filter "label=com.docker.compose.project=bi" -q | xargs -r docker rm -f
	@echo "✅ Container orfani rimossi"

clean-all: clean-orphans
	@echo "🧹 === PULIZIA COMPLETA ==="
	@echo "⚠️  Questo comando rimuoverà tutti i container del progetto $(COMPOSE_PROJECT_NAME)!"
	@read -p "Continuare? (y/N): " confirm && [ "$$confirm" = "y" ]
	make down-all
	docker system prune -f
	@echo "✅ Pulizia completata"

# ------- HELP -------
help:
	@echo "🛠️  === COMANDI DISPONIBILI (progetto: $(COMPOSE_PROJECT_NAME)) ==="
	@echo ""
	@echo "📦 Setup Iniziale:"
	@echo "  make create-network    - Crea la rete condivisa Docker"
	@echo "  make create-volumes    - Crea tutti i volumi esterni necessari"
	@echo ""
	@echo "🚀 Gestione Servizi:"
	@echo "  make up-all           - Avvia tutti i servizi in ordine"
	@echo "  make down-all         - Ferma tutti i servizi"
	@echo "  make restart-all      - Riavvia tutti i servizi"
	@echo ""
	@echo "🔧 Servizi Individuali:"
	@echo "  make nginx-up/down    - Nginx proxy (reverse proxy)"
	@echo "  make toscana-up/down  - Toscana Trading (WordPress)"
	@echo "  make flexora-up/down  - Flexora (WordPress)"
	@echo "  make baserow-up/down  - Baserow (database low-code)"
	@echo ""
	@echo "📊 Monitoraggio:"
	@echo "  make ps-all          - Mostra stato di tutti i container"
	@echo "  make status          - Mostra URL dei servizi attivi"
	@echo "  make nginx-logs      - Mostra log del proxy nginx"
	@echo ""
	@echo "💾 Backup:"
	@echo "  make backup-all      - Backup completo di tutti i database"
	@echo "  make toscana-backup  - Backup solo database Toscana"
	@echo "  make flexora-backup  - Backup solo database Flexora"
	@echo "  make baserow-backup  - Backup solo database Baserow"
	@echo ""
	@echo "🧹 Pulizia:"
	@echo "  make clean-orphans   - Rimuove container orfani del progetto bi"
	@echo "  make clean-all       - Pulizia completa ambiente Docker"
	@echo ""
	@echo "💡 Flusso di lavoro tipico:"
	@echo "  1. make clean-orphans (se necessario)"
	@echo "  2. make create-network"
	@echo "  3. make create-volumes"
	@echo "  4. make up-all"
	@echo "  5. make status (per vedere i servizi attivi)"
	@echo ""
	@echo "🆘 Help:"
	@echo "  make help            - Mostra questa guida"

.PHONY: create-network create-volumes nginx-up nginx-down nginx-restart nginx-logs \
        baserow-up baserow-down baserow-restart baserow-backup \
        toscana-up toscana-down toscana-restart toscana-backup \
        flexora-up flexora-down flexora-restart flexora-backup \
        up-all down-all restart-all ps-all status backup-all nginx-rebuild \
        clean-orphans clean-all help
