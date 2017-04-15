#!/bin/bash
#tomcat根目录
server_path="/home/product/installed/apache-tomcat-8.5.9"
#进程标志杀进程用的请保证唯一
process_flag="apache-tomcat-8.5.9"
#备份文件路径
backup_path="${server_path}/backup"
#备份功能开关 [ on| off ]
backup_switch="on"

##############################################################################
###                     备份
##############################################################################
function backup(){
        if [[ ! -d "${backup_path}" ]]; then
                #statements
                mkdir -p ${backup_path}
        fi
        # 按日期备份
        echo "备份中 ${server_path}/webapps/$1 ${backup_path}/$1`date +%Y%m%d%H%M%S`"
        cp ${server_path}/webapps/$1 ${backup_path}/$1`date +%Y%m%d%H%M%S`
}

##############################################################################
###                     启动
##############################################################################
function tomcat_start(){
        cd "$server_path"
        ./bin/startup.sh
        tail -f logs/catalina.out
}

##############################################################################
###                     kill tomcat
##############################################################################
function kill_tomcat(){
        # kill tomcat process 
        ps -ef | grep ${process_flag} | grep -v grep | awk '{print $2}' | sed -e "s/^/kill -9 /g" | sh -
}

# 只有当$1和$2不为空时才执行备份
if [[ $1 != "" -a $backup_switch == "on" ]]; then
        #开始备份 将restart命令参数作为backup参数
        backup $1
fi

kill_tomcat
tomcat_start


