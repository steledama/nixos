#!/usr/bin/env bash

# Script per mostrare le scorciatoie con formattazione compatta

# Crea un file temporaneo per le scorciatoie
TEMP_FILE=$(mktemp)

# Popola il file con il contenuto delle scorciatoie
cat > "$TEMP_FILE" << 'EOF'
__SHORTCUTS_CONTENT__
EOF

# Mostra il menu utilizzando lo stile centralizzato e le dimensioni standard definite in wofi/config
cat "$TEMP_FILE" | wofi \
  --dmenu \
  --prompt "Shortcuts" \
  --cache-file /dev/null \
  --insensitive \
  --no-actions

# Pulizia
rm -f "$TEMP_FILE"