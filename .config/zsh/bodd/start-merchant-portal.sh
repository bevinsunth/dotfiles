#!/bin/bash

# Start Merchant Portal Services
# This script starts all the services required for the Merchant Portal

echo "🚀 Starting Merchant Portal Services..."

# Base path for all projects
BASE_PATH="Projects/bodd-platform/src"

# Function to start a .NET service in the background
start_dotnet_service() {
    local service_name=$1
    local project_path=$2
    local port=$3

    echo "Starting $service_name on port $port..."
    cd "$BASE_PATH/$project_path"
    dotnet run --environment Development &
    echo "$!" > "/tmp/${service_name}.pid"
    cd - > /dev/null
}

# Start all .NET API services
start_dotnet_service "Integration.Api" "Integration/Integration.Api" "5003"
start_dotnet_service "InventoryService.Api" "Inventory/InventoryService.Api" "5195"
start_dotnet_service "MerchantAdmin.Api" "MerchantAdmin/MerchantAdmin.Api" "5173"
start_dotnet_service "ScanService.Api" "Scan/ScanService.Api" "5067"
start_dotnet_service "MerchantPortal" "MerchantPortal" "5178"

echo "⏳ Waiting for services to start..."
sleep 10

# Start the React frontend
echo "Starting MerchantPortal frontend on port 3000..."
cd "$BASE_PATH/MerchantPortal/merchant-portal"
npm start &
echo "$!" > "/tmp/MerchantPortal-frontend.pid"
cd - > /dev/null

echo "✅ All services started!"
echo ""
echo "Services running on:"
echo "  - Integration.Api: http://localhost:5003"
echo "  - InventoryService.Api: http://localhost:5195"
echo "  - MerchantAdmin.Api: http://localhost:5173"
echo "  - ScanService.Api: http://localhost:5067"
echo "  - MerchantPortal Backend: http://localhost:5178"
echo "  - MerchantPortal Frontend: http://localhost:3000"
echo ""
