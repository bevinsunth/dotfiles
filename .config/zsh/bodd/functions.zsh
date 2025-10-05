# BODD Portal Management Functions
# Manages Consumer and Merchant portal services

BASE_PATH="$HOME/Projects/bodd-platform/src/"

# Consumer Portal Services
typeset -A CONSUMER_SERVICES
CONSUMER_SERVICES=(
    [ConsumerPortal.Api]="$BASE_PATH/ConsumerPortal/ConsumerPortal.Api:5110"
    [Integration.Api]="$BASE_PATH/Integration/Integration.Api:5003"
    [ScanService.Api]="$BASE_PATH/Scan/ScanService.Api:5067"
)
CONSUMER_FRONTEND="$BASE_PATH/ConsumerPortal/ConsumerPortal.Api/consumer-portal:3013:npm run dev"

# Merchant Portal Services
typeset -A MERCHANT_SERVICES
MERCHANT_SERVICES=(
    [Integration.Api]="$BASE_PATH/Integration/Integration.Api:5003"
    [InventoryService.Api]="$BASE_PATH/Inventory/InventoryService.Api:5195"
    [MerchantAdmin.Api]="$BASE_PATH/MerchantAdmin/MerchantAdmin.Api:5173"
)
MERCHANT_FRONTEND="$BASE_PATH/MerchantPortal/merchant-portal:3000:npm run start"

# Kill process on port
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    [[ -n "$pid" ]] && kill -9 $pid 2>/dev/null
}

# Start .NET service
start_service() {
    local name=$1 path=$2 port=$3
    echo "Starting $name on port $port..."
    kill_port $port
    cd "$path" && dotnet run --urls="http://localhost:$port" &>/dev/null &
}

# Start frontend
start_frontend() {
    local path=$1 port=$2 command=$3
    echo "Starting frontend on port $port..."
    kill_port $port
    cd "$path" && eval "$command" &>/dev/null &
}

# Start Consumer Portal
start_consumer() {
    echo "🚀 Starting Consumer Portal..."

    for service in ${(k)CONSUMER_SERVICES}; do
        local service_info=$CONSUMER_SERVICES[$service]
        local path=${service_info%:*}
        local port=${service_info##*:}
        start_service "$service" "$path" "$port"
    done

    local frontend_parts=(${(s/:/)CONSUMER_FRONTEND})
    start_frontend "$frontend_parts[1]" "$frontend_parts[2]" "$frontend_parts[3]"

    echo "✅ Consumer Portal started!"
}

# Start Merchant Portal
start_merchant() {
    echo "🚀 Starting Merchant Portal..."

    for service in ${(k)MERCHANT_SERVICES}; do
        local service_info=$MERCHANT_SERVICES[$service]
        local path=${service_info%:*}
        local port=${service_info##*:}
        start_service "$service" "$path" "$port"
    done

    local frontend_parts=(${(s/:/)MERCHANT_FRONTEND})
    start_frontend "$frontend_parts[1]" "$frontend_parts[2]" "$frontend_parts[3]"

    echo "✅ Merchant Portal started!"
}

# Stop Consumer Portal
stop_consumer() {
    echo "🛑 Stopping Consumer Portal..."
    for service in ${(k)CONSUMER_SERVICES}; do
        local port=${CONSUMER_SERVICES[$service]##*:}
        kill_port $port
    done
    local frontend_port=${CONSUMER_FRONTEND#*:}
    kill_port ${frontend_port%:*}
    echo "✅ Consumer Portal stopped!"
}

# Stop Merchant Portal
stop_merchant() {
    echo "🛑 Stopping Merchant Portal..."
    for service in ${(k)MERCHANT_SERVICES}; do
        local port=${MERCHANT_SERVICES[$service]##*:}
        kill_port $port
    done
    local frontend_port=${MERCHANT_FRONTEND#*:}
    kill_port ${frontend_port%:*}
    echo "✅ Merchant Portal stopped!"
}

# Restart portals
restart_consumer() { stop_consumer && sleep 2 && start_consumer }
restart_merchant() { stop_merchant && sleep 2 && start_merchant }

# Stop all
stop_all() { stop_consumer && stop_merchant }
