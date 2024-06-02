#Nginx Service Control Script
NGINX="${NGINX_DIR}/sbin/nginx"
NGINX_PID="${NGINX_DIR}/logs/nginx.pid"
case "$1" in
    start)
        $NGINX
        ;;
    stop)
        kill -s QUIT $(cat $NGINX_PID)
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    reload)
        kill -s HUP $(cat $NGINX_PID)
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|reload}"
        exit 1
        ;;
esac
