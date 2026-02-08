#!/bin/bash

echo "Kong Prometheus Metrics Summary"
echo "-----------------------------------"

metrics=$(curl -s http://localhost:8001/metrics)

# Datastore reachability
reachable=$(echo "$metrics" | grep '^kong_datastore_reachable ' | awk '{print $2}')
echo "Database Connection     : $([ "$reachable" -eq 1 ] && echo 'Reachable' || echo 'Unavailable')"

# Active connections
active_conn=$(echo "$metrics" | grep 'kong_nginx_connections_total.*state="active"' | awk '{print $2}')
echo "Active Connections      : $active_conn"

# Total HTTP requests handled
total_req=$(echo "$metrics" | grep '^kong_nginx_requests_total' | grep -v '^#' | awk '{print $2}')
echo "Total Requests          : $total_req"

# Shared memory usage (Kong dict)
mem_bytes=$(echo "$metrics" | grep 'kong_memory_lua_shared_dict_bytes.*shared_dict="kong"' | awk '{print $2}')
mem_kb=$((mem_bytes / 1024))
echo "Memory Used (shared)    : ${mem_kb} KB"

# Rate limit memory
rate_limit_used=$(echo "$metrics" | grep 'kong_memory_lua_shared_dict_bytes.*shared_dict="kong_rate_limiting_counters"' | awk '{print $2}')
rate_kb=$((rate_limit_used / 1024))
echo "Rate Limit Memory       : ${rate_kb} KB"

# Timers (async NGINX operations)
timers_running=$(echo "$metrics" | grep 'kong_nginx_timers{state="running"}' | awk '{print $2}')
echo "Running Timers          : $timers_running"

echo "-----------------------------------"
