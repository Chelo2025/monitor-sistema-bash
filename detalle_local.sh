#!/bin/bash

# Script: nagios_local.sh
# Simula un chequeo completo al estilo Nagios en una máquina local

check_cpu() {
  load=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
  echo "🔧 Carga de CPU: $load"
}

check_mem() {
  mem=$(free -m | awk '/Mem:/ {printf("Memoria usada: %dMB / %dMB (%.1f%%)", $3, $2, $3/$2*100)}')
  echo "💾 $mem"
}

check_swap() {
  swap=$(free -m | awk '/Swap:/ {printf("Swap usada: %dMB / %dMB (%.1f%%)", $3, $2, ($3/$2)*100)}')
  echo "🔁 $swap"
}

check_disk() {
  echo "🗃️ Espacio en disco:"
  df -h --output=source,pcent,target | grep -v tmpfs
}

check_services() {
  echo "🧩 Servicios esenciales:"
  for s in ssh nginx mysql apache2 docker; do
    systemctl is-active --quiet $s && echo "✔️ $s está activo" || echo "❌ $s NO está activo"
  done
}

check_network() {
  echo "🌐 Ping a Google:"
  ping -c 1 8.8.8.8 &>/dev/null && echo "✅ Conectividad OK" || echo "❌ SIN conexión"
}

check_users() {
  echo "👥 Usuarios conectados: $(who | wc -l)"
}

check_logs() {
  echo "🧪 Últimos errores del sistema (dmesg):"
  dmesg --level=err | tail -n 3
}

check_uptime() {
  echo "⏳ Uptime: $(uptime -p)"
}

# Ejecutar todas las funciones
check_cpu
check_mem
check_swap
check_disk
check_services
check_network
check_users
check_logs
check_uptime
