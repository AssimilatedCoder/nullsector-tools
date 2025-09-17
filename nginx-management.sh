#!/bin/bash
# nginx management script for SEV-1 Dashboard

case "$1" in
    start)
        echo "🚀 Starting nginx..."
        
        # Fix permissions for nginx to access files
        echo "🔧 Fixing permissions..."
        PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Make directories readable by nginx
        chmod 755 "$HOME" 2>/dev/null || true
        chmod 755 "$HOME/Projects" 2>/dev/null || true
        chmod 755 "$PROJECT_ROOT"
        
        # Make files readable
        chmod 644 "$PROJECT_ROOT/sev1-warroom-dashboard.html"
        chmod 644 "$PROJECT_ROOT/dashboard-data-loader.js"
        chmod 644 "$PROJECT_ROOT"/*.html 2>/dev/null || true
        chmod 644 "$PROJECT_ROOT"/*.js 2>/dev/null || true
        chmod 644 "$PROJECT_ROOT"/*.css 2>/dev/null || true
        
        # Fix telemetry data permissions
        if [ -d "$PROJECT_ROOT/superpod_sev1_fake_telemetry" ]; then
            chmod 755 "$PROJECT_ROOT/superpod_sev1_fake_telemetry"
            chmod 644 "$PROJECT_ROOT/superpod_sev1_fake_telemetry"/*
        fi
        
        echo "✅ Permissions fixed"
        
        # Start nginx
        sudo systemctl start nginx
        sudo systemctl status nginx --no-pager -l
        ;;
    stop)
        echo "🛑 Stopping nginx..."
        sudo systemctl stop nginx
        echo "✅ nginx stopped"
        ;;
    restart)
        echo "🔄 Restarting nginx..."
        
        # Fix permissions for nginx to access files
        echo "🔧 Fixing permissions..."
        PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Make directories readable by nginx
        chmod 755 "$HOME" 2>/dev/null || true
        chmod 755 "$HOME/Projects" 2>/dev/null || true
        chmod 755 "$PROJECT_ROOT"
        
        # Make files readable
        chmod 644 "$PROJECT_ROOT/sev1-warroom-dashboard.html"
        chmod 644 "$PROJECT_ROOT/dashboard-data-loader.js"
        chmod 644 "$PROJECT_ROOT"/*.html 2>/dev/null || true
        chmod 644 "$PROJECT_ROOT"/*.js 2>/dev/null || true
        chmod 644 "$PROJECT_ROOT"/*.css 2>/dev/null || true
        
        # Fix telemetry data permissions
        if [ -d "$PROJECT_ROOT/superpod_sev1_fake_telemetry" ]; then
            chmod 755 "$PROJECT_ROOT/superpod_sev1_fake_telemetry"
            chmod 644 "$PROJECT_ROOT/superpod_sev1_fake_telemetry"/*
        fi
        
        echo "✅ Permissions fixed"
        
        # Restart nginx
        sudo systemctl restart nginx
        sudo systemctl status nginx --no-pager -l
        ;;
    status)
        echo "📊 nginx status:"
        sudo systemctl status nginx --no-pager -l
        echo ""
        echo "🌐 Port 7777 status:"
        sudo netstat -tlnp | grep 7777 || echo "Port 7777 not in use"
        ;;
    logs)
        echo "📋 Recent access logs:"
        sudo tail -20 /var/log/nginx/sev1-dashboard.access.log 2>/dev/null || echo "No access logs yet"
        echo ""
        echo "📋 Recent error logs:"
        sudo tail -20 /var/log/nginx/sev1-dashboard.error.log 2>/dev/null || echo "No error logs"
        ;;
    test)
        echo "🧪 Testing dashboard..."
        SERVER_IP=$(hostname -I | awk '{print $1}')
        
        echo "Testing local access..."
        if curl -s http://localhost:7777 | grep -q "SEV-1"; then
            echo "✅ Dashboard accessible locally"
        else
            echo "❌ Dashboard not accessible locally"
        fi
        
        echo "Testing CSV files..."
        if curl -s http://localhost:7777/superpod_sev1_fake_telemetry/gpu_utilization.csv | head -1 | grep -q "timestamp"; then
            echo "✅ CSV files accessible"
        else
            echo "❌ CSV files not accessible"
        fi
        
        echo ""
        echo "📊 Dashboard URLs:"
        echo "   Local:    http://localhost:7777"
        echo "   Network:  http://$SERVER_IP:7777"
        ;;
    setup)
        echo "🔧 Running full setup..."
        ./setup-nginx.sh
        ;;
    *)
        echo "nginx Management Script for SEV-1 Dashboard"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|logs|test|setup}"
        echo ""
        echo "Commands:"
        echo "  start    - Start nginx"
        echo "  stop     - Stop nginx"
        echo "  restart  - Restart nginx"
        echo "  status   - Show nginx status and port info"
        echo "  logs     - Show recent access and error logs"
        echo "  test     - Test dashboard accessibility"
        echo "  setup    - Run full nginx setup"
        echo ""
        echo "Examples:"
        echo "  $0 setup     # Initial setup"
        echo "  $0 start     # Start server"
        echo "  $0 test      # Test if working"
        echo "  $0 logs      # View logs"
        echo ""
        exit 1
        ;;
esac
