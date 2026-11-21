#!/usr/bin/env bash
# Genera un report hardware completo (scheda madre, CPU, RAM, storage + benchmark).
# Richiede sudo per dmidecode, hdparm e nvme.

HOST=$(hostname)
OUT="/tmp/hw-report-${HOST}.txt"

storage_info() {
  local dev="$1"
  if [[ "$dev" == nvme* ]]; then
    sudo nvme id-ctrl "/dev/${dev}" 2>/dev/null | grep -E "mn |sn |fr " | sed 's/^/  /'
  else
    sudo hdparm -I "/dev/${dev}" 2>/dev/null | grep -E "Model|Serial|device size|Form Factor|Rotation"
  fi
}

storage_benchmark() {
  local dev="$1"
  sudo hdparm -tT --direct "/dev/${dev}" 2>/dev/null
}

{
  echo "=== HARDWARE REPORT: ${HOST} ==="
  echo "Data: $(date '+%Y-%m-%d %H:%M')"
  echo ""

  echo "=== SYSTEM ==="
  sudo dmidecode -t system 2>/dev/null
  echo ""

  echo "=== BASEBOARD ==="
  sudo dmidecode -t baseboard 2>/dev/null
  echo ""

  echo "=== PROCESSOR ==="
  sudo dmidecode -t processor 2>/dev/null
  echo ""

  echo "=== MEMORY ==="
  sudo dmidecode -t memory 2>/dev/null
  echo ""

  echo "=== BLOCK DEVICES ==="
  lsblk -o NAME,SIZE,TYPE,ROTA,MOUNTPOINTS
  echo ""

  echo "=== STORAGE MODELS ==="
  for dev in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
    echo "--- /dev/${dev} ---"
    storage_info "$dev"
    echo ""
  done

  echo "=== STORAGE BENCHMARK (hdparm -tT --direct) ==="
  for dev in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
    echo "--- /dev/${dev} ---"
    storage_benchmark "$dev"
    echo ""
  done

} > "${OUT}" 2>&1

echo "Report salvato in: ${OUT}"
