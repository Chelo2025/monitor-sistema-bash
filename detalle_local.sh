#!/bin/bash

# Script: detalles_sistema.sh
# Info general del sistema + usuarios por SSH + intentos fallidos + MACs en red

echo "📋 INFORMACIÓN DEL SISTEMA - $(date '+%Y-%m-%d %H:%M:%S')"
echo "---------------------------------------------------------"

# Información del sistema
echo -e "\n🖥️  HOSTNAME: $(hostname)"
echo "🧠 CPU: $(lscpu | grep 'Model name' | sed 's/Model name:[ \t]*//')"
echo "💾 RAM total: $(free -h | awk '/Mem:/ {print $2}')"
echo "💽 Disco total: $(df -h --total | grep total | awk '{print $2}')"
echo "🖥️ SO: $(lsb_release -d | cut -f2)"
echo "🧮 Kernel: $(uname -r)"

# IP y Red
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

# Dispositivos conocidos en la red local (ARP)
echo -e "\n📡 Dispositivos en red detectados por ARP:"
ip neigh | grep -i "lladdr" | awk '{printf "IP: %-16s MAC: %s\n", $1, $5}'

# Procesos activos
echo -e "\n🔍 Procesos activos: $(ps aux --no-heading | wc -l)"

# Espacio en disco
echo -e "\n📂 Espacio en disco:"
df -h | grep -v tmpfs

echo -e "\n✅ Fin del reporte\n"
