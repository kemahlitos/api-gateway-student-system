tail -f /tmp/kong_logs.log | \
while read line; do
  method=$(echo "$line" | grep -o '"method":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  uri=$(echo "$line" | grep -o '"uri":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  status=$(echo "$line" | grep -o '"status":[0-9]*' | cut -d':' -f2)
  ip=$(echo "$line" | grep -o '"client_ip":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  latency=$(echo "$line" | grep -o '"proxy":[0-9]*' | grep -o '[0-9]*')
  consumer=$(echo "$line" | grep -o '"consumer_id":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  user_agent=$(echo "$line" | grep -o '"user-agent":"[^"]*"' | cut -d':' -f2- | tr -d '"')
  timestamp=$(echo "$line" | grep -o '"started_at":[0-9]*' | cut -d':' -f2)

  time_fmt=$(date -d "@$(((timestamp + 7200000) / 1000))" +"%H:%M:%S" 2>/dev/null)

  info=""
  [ -n "$ip" ] && info+=" | ip: $ip"
  [ -n "$latency" ] && info+=" | latency: ${latency}ms"
  [ -n "$consumer" ] && info+=" | consumer_id: ${consumer:0:8}..."
  [ -n "$user_agent" ] && info+=" | ua: ${user_agent:0:30}"

  printf "[%s] %-5s %-30s | status: %-3s%s\n" \
    "${time_fmt:---:--:--}" "$method" "$uri" "$status" "$info"
done