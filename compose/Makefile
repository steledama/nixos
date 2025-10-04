# Makefile per gestione servizi infrastruttura
# Repository: nixos

.PHONY: help create-network create-volumes up down restart status backup up-nginx down-nginx up-all down-all

# Rete condivisa
create-network:
	docker network inspect shared-network >/dev/null 2>&1 || docker network create shared-network

# Crea i volumi esterni necessari
create-volumes:
	docker volume inspect baserow_data >/dev/null 2>&1 || docker volume create baserow_data
	docker volume inspect nginx_logs >/dev/null 2>&1 || docker volume create nginx_logs
	docker volume inspect nginx_cache >/dev/null 2>&1 || docker volume create nginx_cache

# ------- COMANDI PRINCIPALI -------
up: create-network create-volumes
	@echo "🚀 Avvio Baserow..."
	docker-compose -f baserow.yml up -d
	@echo "✅ Baserow avviato!"
	@echo "📊 Accesso: http://5.89.62.125:8385"

down:
	docker-compose -f baserow.yml down

up-nginx: create-network create-volumes
	@echo "🌐 Avvio Nginx reverse proxy..."
	docker-compose -f nginx.yml up -d
	@echo "✅ Nginx avviato!"
	@echo "🔒 Toscana: https://5.89.62.125:8443"
	@echo "🔒 Flexora: https://5.89.62.125:8444"

down-nginx:
	docker-compose -f nginx.yml down

up-all: up up-nginx
	@echo "✅ Tutti i servizi infrastruttura avviati!"

down-all: down-nginx down
	@echo "✅ Tutti i servizi infrastruttura fermati!"

restart: down up

status:
	@docker ps --filter "name=baserow\|nginx-proxy" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

backup:
	@echo "⚠️  ATTENZIONE: Il backup da command line crea file molto pesanti (>1GB)"
	@echo "📋 RACCOMANDAZIONE: Usa invece il backup GUI per workspace specifici:"
	@echo "   1. Accedi a Baserow → http://5.89.62.125:8385"
	@echo "   2. Seleziona workspace → Menu → 'Export data'"
	@echo "   3. Download ZIP compatto (~7MB vs >1GB)"
	@echo ""
	@echo "🚫 Backup command line DISABILITATO per evitare spreco spazio disco"

help:
	@echo "SERVIZI INFRASTRUTTURA NIXOS"
	@echo ""
	@echo "Comandi disponibili:"
	@echo "  make up        - Avvia Baserow"
	@echo "  make down      - Ferma Baserow"
	@echo "  make up-nginx  - Avvia Nginx reverse proxy"
	@echo "  make down-nginx- Ferma Nginx"
	@echo "  make up-all    - Avvia tutti i servizi (Baserow + Nginx)"
	@echo "  make down-all  - Ferma tutti i servizi"
	@echo "  make restart   - Riavvia Baserow"
	@echo "  make status    - Stato container"
	@echo "  make backup    - Istruzioni backup Baserow"
	@echo ""
	@echo "Note:"
	@echo "  - Servizi WordPress: repository 'ecomm'"
	@echo "  - Servizi BI/automation: repository 'bi'"
	@echo "  - Accesso Baserow: http://5.89.62.125:8385"
	@echo "  - Toscana Trading: https://5.89.62.125:8443"
	@echo "  - Flexora: https://5.89.62.125:8444"
