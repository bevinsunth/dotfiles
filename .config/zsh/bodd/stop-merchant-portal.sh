#!/bin/bash

echo "🛑 Stopping Merchant Portal Services..."

# Function to stop a service by PID file
stop_service() {
    local service_name=$1
    local pid_file="/tmp/${service_name}.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping $service_name (PID: $pid)..."
            kill "$pid"
            rm "$pid_file"
        else
            echo "$service_name was not running"
            rm "$pid_file"
        fi
    else
        echo "No PID file found for $service_name"
    fi
}

# Define services and ports
SERVICES=("Integration.Api" "InventoryService.Api" "MerchantAdmin.Api" "ScanService.Api" "MerchantPortal" "MerchantPortal-frontend")
PORTS=(5003 5195 5173 5067 5178 3000)

# Stop all services
for service in "${SERVICES[@]}"; do
    stop_service "$service"
done

# Also kill any remaining dotnet processes
echo "Cleaning up any remaining processes..."
for service in "${SERVICES[@]%%-*}"; do
    [[ "$service" != "MerchantPortal" ]] && pkill -f "dotnet.*$service" 2>/dev/null || true
done

# Kill processes on specific ports
for port in "${PORTS[@]}"; do
    lsof -ti:$port | xargs kill -9 2>/dev/null || true
done

echo "✅ All services stopped!"
