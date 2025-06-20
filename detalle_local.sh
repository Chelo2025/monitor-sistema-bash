#!/bin/bash
fecha=$(date "+%Y-%m-%d %H:%M:%S")
log="/opt/monitoreo/logs/monitoreo_$(date +%F).log"

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
ram=$(free -m | awk '/Mem:/ {print $3"/"$2"MB"}')

{
  echo "[$fecha] 🔍 Monitoreo del sistema"
  echo "CPU usada: $cpu%"
  echo "RAM usada: $ram"
  echo "-----------------------------------"
} >> "$log"
