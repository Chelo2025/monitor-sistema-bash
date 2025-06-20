#!/bin/bash

# Script: detalles_sistema.sh
# Información del sistema + SSH + intentos fallidos + chequeo básico de MITM

echo "📋 INFORMACIÓN DEL SISTEMA - $(date '+%Y-%m-%d %H:%M:%S')"
echo "---------------------------------------------------------"

# Información general
echo -e "\n🖥️  HOSTNAME: $(hostname)"
echo "🧠 CPU: $(lscpu | grep 'Model name' | sed 's/Model name:[ \t]*//')"
echo "💾 RAM total: $(free -h | awk '/Mem:/ {print $2}')"
echo "💽 Disco total: $(df -h --total | grep total | awk '{print $2}')"
echo "🖥️ SO: $(lsb_release -d | cut -f2)"
echo "🧮 Kernel: $(uname -r)"

# Red e IP
echo -e "\n🌐 RED"
ip -o -4 addr show | awk '{print $2 ": " $4}'

# Uptime
echo -e "\n⏳ Tiempo encendido:"
uptime -p

# Usuarios conectados
echo -e "\n👥 Usuarios conectados (todas las sesiones):"
who

# Usuarios conectados por SSH
echo -e "\n🔐 Usuarios conectados por SSH:"
sshd_sessions=$(who | grep -i 'ssh')
if [ -z "$sshd_sessions" ]; then
  echo "Ningún usuario conectado por SSH en este momento."
else
  echo "$sshd_sessions"
fi

# Intentos fallidos de login SSH
echo -e "\n❌ Intentos fallidos de conexión SSH (últimas 10 entradas):"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -n 10 | awk '{print "Fecha: "$1, $2, $3, "Usuario:", $9, "Desde IP:", $11}'

# Detección básica de posible MITM
echo -e "\n⚠️ Verificación básica de MITM en red local:"
gateway_ip=$(ip route | awk '/default/ {print $3}')
gateway_mac=$(arp -an | grep "$gateway_ip" | awk '{print $4}')

if [ -z "$gateway_mac" ]; then
  echo "No se pudo obtener la MAC del gateway ($gateway_ip) — ¿ARP spoofing posible?"
else
  echo "Gateway: $gateway_ip"
  echo "MAC del gateway detectada: $gateway_mac"
fi

# Mostrar entradas duplicadas en la tabla ARP (posible indicio de MITM)
echo -e "\n🔎 Entradas duplicadas o sospechosas en la tabla ARP:"
ip neigh | grep -i "lladdr" | sort | uniq -c | awk '$1 > 1 {print $0}'

# Procesos activos
echo -e "\n🔍 Procesos activos: $(ps aux --no-heading | wc -l)"

# Disco
echo -e "\n📂 Espacio en disco:"
df -h | grep -v tmpfs

echo -e "\n✅ Fin del reporte\n"
