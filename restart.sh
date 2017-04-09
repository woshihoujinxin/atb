#!/bin/bash
#tomcat根目录
server_path="/Users/houjinxin/Documents/apache-tomcat-8.5.9"
#server_path="/app/appuser/apps/TAS/tomcat7-TaskCenter-8072"
#进程标志杀进程用的
process_flag="apache-tomcat-8.5.9"
cd "$server_path"
# restart tomcat
#./bin/shutdown.sh
# kill tomcat process
ps -ef | grep ${process_flag} | grep -v grep | awk '{print $2}'  | sed -e "s/^/kill -9 /g" | sh -
./bin/startup.sh
tail -f logs/catalina.out

