#!/bin/bash
#获取脚本所在路径
IPATH=`pwd`
echo $IPATH

SHPATH=`echo ${0%/*}`
echo $SHPATH

IDX=`echo $SHPATH|awk '{i=match($0,/\//);print i}'`
echo $IDX
if [ $IDX = 1 ];then
	IPATH=$SHPATH
else
	IPATH=$IPATH/$SHPATH
fi

export LD_LIBRARY_PATH=$IPATH/lib
NGX_CMD=$IPATH/../nginx_bin/nginx

if [ $1 == "start" ]; then
	$NGX_CMD -c $IPATH/conf/nginx.conf -p $IPATH
	nohup $IPATH/shell/cron_send_pay_status.sh start >/dev/null 2>&1 &
	nohup $IPATH/shell/cron_send_online_num.sh start >/dev/null 2>&1 &
fi

if [ $1 == "stop" ]; then
	$NGX_CMD -s stop -c $IPATH/conf/nginx.conf -p $IPATH
	$IPATH/shell/cron_send_pay_status.sh stop
	$IPATH/shell/cron_send_online_num.sh stop
fi

if [ $1 == "reload" ]; then
	$NGX_CMD -s reload -c $IPATH/conf/nginx.conf -p $IPATH
fi
