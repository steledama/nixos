# Makefile per gestione servizi infrastruttura
# Repository: nixos

.PHONY: help create-network create-volumes up-all down-all restart-all status

# Rete condivisa
create-network:
	docker network inspect shared-network >/dev/null 2>&1 || docker network create shared-network

# Crea i volumi esterni necessari (solo servizi infrastruttura)
create-volumes:
	docker volume inspect baserow_data >/dev/null 2>&1 || docker volume create baserow_data

# ------- COMANDI BASEROW -------
baserow-up: create-network create-volumes
	docker-compose -p tt -f compose.baserow.yml up -d

baserow-down:
	docker-compose -p tt -f compose.baserow.yml down

baserow-restart: baserow-down baserow-up

baserow-backup:
	@echo "⚠️  ATTENZIONE: Il backup da command line crea file molto pesanti (>1GB)"
	@echo "📋 RACCOMANDAZIONE: Usa invece il backup GUI per workspace specifici:"
	@echo "   1. Accedi a Baserow → http://5.89.62.125:8385"
	@echo "   2. Seleziona workspace 'tt' → Menu → 'Export data'"
	@echo "   3. Download ZIP compatto (~7MB vs >1GB)"
	@echo ""
	@echo "🚫 Backup command line DISABILITATO per evitare spreco spazio disco"

# ------- COMANDI N8N -------
n8n-up: create-network
	docker-compose -p tt -f compose.n8n.yml up -d

n8n-down:
	docker-compose -p tt -f compose.n8n.yml down

n8n-restart: n8n-down n8n-up

# ------- COMANDI LIBRECHAT -------
librechat-up: create-network
	docker-compose -p tt -f compose.librechat.yml up -d

librechat-down:
	docker-compose -p tt -f compose.librechat.yml down

librechat-restart: librechat-down librechat-up

# ------- COMANDI GLOBALI -------
up-all: create-network create-volumes
	@echo "🚀 Avvio servizi infrastruttura..."
	docker-compose -p tt -f compose.baserow.yml up -d
	docker-compose -p tt -f compose.n8n.yml up -d
	docker-compose -p tt -f compose.librechat.yml up -d
	@echo "✅ Servizi avviati!"

down-all:
	docker-compose -p tt -f compose.librechat.yml down
	docker-compose -p tt -f compose.n8n.yml down
	docker-compose -p tt -f compose.baserow.yml down

restart-all: down-all up-all

# ------- COMANDI UTILITY -------
status:
	@docker ps --filter "label=com.docker.compose.project=tt" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

help:
	@echo "SERVIZI INFRASTRUTTURA NIXOS"
	@echo ""
	@echo "Comandi disponibili:"
	@echo "  make up-all         - Avvia tutti i servizi"
	@echo "  make down-all       - Ferma tutti i servizi"
	@echo "  make restart-all    - Riavvia tutti i servizi"
	@echo "  make status         - Stato container"
	@echo ""
	@echo "Servizi individuali:"
	@echo "  make baserow-up/down    - Baserow (database low-code)"
	@echo "  make n8n-up/down        - n8n (automation)"
	@echo "  make librechat-up/down  - LibreChat (AI chat)"
	@echo ""
	@echo "Backup:"
	@echo "  make baserow-backup     - Istruzioni backup Baserow"
	@echo ""
	@echo "Note:"
	@echo "  - Servizi WordPress gestiti in repository 'ecomm'"
	@echo "  - Accesso Baserow: http://5.89.62.125:8385"
