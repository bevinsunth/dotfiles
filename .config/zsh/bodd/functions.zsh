: <<'Notes'
Service										HTTP 	HTTPS
Integration.Api						5003	7003
ScanService.Api						5067	7067
InventoryService.Api			5195	7195
MerchantAdmin.Api					5173	7173
MerchantPortal						5178	7178
ConsumerPortal.Api				5110	7177
Notes


function start-merchant {
  local BASE_PATH="${1:-$HOME/Projects/bodd-platform}"

  echo "🚀 Starting Merchant Portal..."

  # Kill existing processes on all merchant portal ports
  # Backend: 5003, 5067, 5173, 5178, 5195, 7003, 7067, 7173, 7178, 7195
  # Frontend: 3000
  for port in 5003 5067 5173 5178 5195 7003 7067 7173 7178 7195; do
    lsof -ti:$port | xargs kill -9 2>/dev/null
  done

  echo "📦 Starting backend services..."
  # Launch all .NET backend services
  dotnet run --project "$BASE_PATH/src/Integration/Integration.Api/Integration.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/Scan/ScanService.Api/ScanService.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/Inventory/InventoryService.Api/InventoryService.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/MerchantAdmin/MerchantAdmin.Api/MerchantAdmin.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/MerchantPortal/MerchantPortal.csproj" --no-build &
}

function stop-merchant {
  local BASE_PATH="${1:-$HOME/Projects/bodd-platform}"

  echo "🛑 Stopping Merchant Portal..."

  # Kill all merchant portal ports (both HTTP and HTTPS)
  for port in 5003 5067 5173 5178 5195 7003 7067 7173 7178 7195; do
    lsof -ti:$port | xargs kill -9 2>/dev/null
  done

  echo "✅ Merchant Portal stopped!"
}

function start-consumer {
  local BASE_PATH="${1:-$HOME/Projects/bodd-platform}"

  echo "🚀 Starting Consumer Portal..."

  # Kill existing processes on all consumer portal ports
  # Backend: 5003, 5067, 5110, 7003, 7067, 7177
  # Frontend: 3013
  for port in 5003 5067 5110 7003 7067 7177; do
    lsof -ti:$port | xargs kill -9 2>/dev/null
  done

  echo "📦 Starting backend services..."
  # Launch all .NET backend services
  dotnet run --project "$BASE_PATH/src/Integration/Integration.Api/Integration.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/Scan/ScanService.Api/ScanService.Api.csproj" --no-build &
  dotnet run --project "$BASE_PATH/src/ConsumerPortal/ConsumerPortal.Api/ConsumerPortal.csproj" --no-build &
}

function stop-consumer {
  local BASE_PATH="${1:-$HOME/Projects/bodd-platform}"

  echo "🛑 Stopping Consumer Portal..."

  # Kill all consumer portal ports (both HTTP and HTTPS)
  for port in 5003 5067 5110 7003 7067 7177; do
    lsof -ti:$port | xargs kill -9 2>/dev/null
  done

  echo "✅ Consumer Portal stopped!"
}
