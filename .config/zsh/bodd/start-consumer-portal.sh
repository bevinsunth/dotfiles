#!/bin/bash

# Start Consumer Portal Services
# This script starts all the services required for the Consumer Portal

echo "🚀 Starting Consumer Portal Services..."

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
start_dotnet_service "ScanService.Api" "Scan/ScanService.Api" "5067"
start_dotnet_service "ConsumerPortal" "ConsumerPortal/ConsumerPortal.Api" "5110"

echo "⏳ Waiting for services to start..."
sleep 10

# Start the React frontend (using react-router dev instead of npm start)
echo "Starting ConsumerPortal frontend on port 3013..."
cd "$BASE_PATH/ConsumerPortal/ConsumerPortal.Api/consumer-portal"
npm run dev &
echo "$!" > "/tmp/ConsumerPortal-frontend.pid"
cd - > /dev/null

echo "✅ All services started!"
echo ""
echo "Services running on:"
echo "  - Integration.Api: http://localhost:5003"
echo "  - ScanService.Api: http://localhost:5067"
echo "  - ConsumerPortal Backend: http://localhost:5110"
echo "  - ConsumerPortal Frontend: http://localhost:3013"
echo ""
echo "To stop all services, run: ./stop-consumer-portal-services.sh"
