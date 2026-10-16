#sysinfo-dashboard 

A bash script that shows system info, CPU, memory, disk usage and top 
process in the terminal, with colored usage bars. Runs on linux and  in 
Docker.

## Usage 

``bash 
.sysinfo.sh           # print Once 
.sysinfo.sh --watch   #refresh every 5 seconds
`` 

## Run with Docker 

``bash 
docker build -t sysinfo .
docker run --rm sysinfo
``

## How it works

- Reads CPU counters from `/proc/stat` twice, 1 second apart
- Uses `free` (available memory) for RAM usage
- Uses `df` for disk usage
- Colors: green < 70%, yellow >= 70%, red >= 90%

##Example Output 
=== SYSTEM ===
Hostname : 9123991a18d2
OS       : Ubuntu 24.04.5 LTS
Kernel   : 6.18.40.1-microsoft-standard-WSL2
Date     : 2026-10-16 08:02:57
Uptime   : up 54 minutes

=== CPU ===
Model    : 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
Cores    : 8
Load avg : 0.17 (1m)  0.09 (5m)  0.05 (15m)
Usage    : [#-------------------] 7%

=== MEMORY ===
RAM      : [###-----------------] 19%  (752 MB of 3786 MB)
Swap     : 0 MB of 1024 MB

=== DISK ===
Mounted on              Size    Used
/                      1007G    3.6G [--------------------] 1%
/etc/hosts             1007G    3.6G [--------------------] 1%

=== TOP 5 PROCESSES BY MEMORY ===
    PID COMMAND         %CPU %MEM
     37 ps               0.0  0.1
      1 sysinfo          3.5  0.0
     38 head             0.0  0.0
