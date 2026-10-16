#!/bin/bash
set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'          

WARN=70
CRIT=90


# Print a section title
header() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Pick a color based on a percentage
color_for() {
  local p=$1
  if (( p >= CRIT )); then
    echo -ne "$RED"
  elif (( p >= WARN )); then
    echo -ne "$YELLOW"
  else
    echo -ne "$GREEN"
  fi
}

# Draw a bar like [########------------]
bar() {
  local p=$1 width=20 filled i
  filled=$(( p * width / 100 ))
  printf '['
  for (( i = 0; i < width; i++ )); do
    if (( i < filled )); then printf '#'; else printf '-'; fi
  done
  printf ']'
}


show_system() {
  header "SYSTEM"
  echo "Hostname : $(hostname)"
  echo "OS       : $(. /etc/os-release && echo "$PRETTY_NAME")"
  echo "Kernel   : $(uname -r)"
  echo "Date     : $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Uptime   : $(uptime -p)"
}


show_cpu() {
  header "CPU"

  local model cores load1 load5 load15
  model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^ *//')
  cores=$(nproc)
  read -r load1 load5 load15 _ < /proc/loadavg

  echo "Model    : ${model:-unknown}"
  echo "Cores    : $cores"
  echo "Load avg : $load1 (1m)  $load5 (5m)  $load15 (15m)"

  # CPU usage: read /proc/stat twice, one second apart, and compare
  local u n s i io irq sirq st idle1 total1 idle2 total2 usage
  read -r _ u n s i io irq sirq st _ < /proc/stat
  idle1=$(( i + io ));  total1=$(( u + n + s + i + io + irq + sirq + st ))
  sleep 1
  read -r _ u n s i io irq sirq st _ < /proc/stat
  idle2=$(( i + io ));  total2=$(( u + n + s + i + io + irq + sirq + st ))

  usage=$(( 100 * ( (total2 - total1) - (idle2 - idle1) ) / (total2 - total1) ))
  echo -e "Usage    : $(color_for "$usage")$(bar "$usage") ${usage}%${NC}"
}


show_memory() {
  header "MEMORY"

  local total avail used pct
  read -r total avail <<< "$(free -m | awk '/^Mem:/ {print $2, $7}')"
  used=$(( total - avail ))
  pct=$(( used * 100 / total ))

  echo -e "RAM      : $(color_for "$pct")$(bar "$pct") ${pct}%${NC}  (${used} MB of ${total} MB)"

  local swap_total swap_used
  read -r swap_total swap_used <<< "$(free -m | awk '/^Swap:/ {print $2, $3}')"
  if (( swap_total > 0 )); then
    echo "Swap     : ${swap_used} MB of ${swap_total} MB"
  else
    echo "Swap     : none"
  fi
}


show_disk() {
  header "DISK"
  printf "%-20s %7s %7s\n" "Mounted on" "Size" "Used"

  df -hP -x tmpfs -x devtmpfs -x squashfs | tail -n +2 | while read -r fs size used avail pct mount; do
    local p=${pct%\%}
    echo -e "$(printf '%-20s %7s %7s' "$mount" "$size" "$used") $(color_for "$p")$(bar "$p") ${pct}${NC}"
  done
}

show_top() {
  header "TOP 5 PROCESSES BY MEMORY"
  ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
}


run_all() {
  show_system
  show_cpu
  show_memory
  show_disk
  show_top
  echo
}

usage() {
  echo "Usage: $0 [--watch | --help]"
  echo "  (no option)  print the dashboard once"
  echo "  --watch      refresh every 5 seconds (Ctrl+C to quit)"
}

case "${1:-}" in
  --watch)
    while true; do
      clear
      run_all
      sleep 5
    done
    ;;
  -h|--help)
    usage
    ;;
  "")
    run_all
    ;;
  *)
    usage
    exit 1
    ;;
esac
