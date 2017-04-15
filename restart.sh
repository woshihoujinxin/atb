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
###    备份
##############################################################################
function backup(){
    if [[ ! -d "${backup_path}" ]]; then
        mkdir -p ${backup_path}
    fi
    # 按日期备份
	current_time=`date +%Y%m%d%H%M%S`
	backup_filename=$1
    echo "备份中 ${server_path}/webapps/${backup_filename} ${backup_path}/${backup_filename%.*}_${current_time}"
    cp ${server_path}/webapps/${backup_filename} ${backup_path}/${backup_filename%.*}_${current_time}
}

##############################################################################
###    删除异常版本
##############################################################################
function del_exception_version(){
    #删除当前问题版本 包扩war包和解压文件夹
    filename=`echo $1 | sed 's/_//' | sed 's/[0-9]//g'`
    echo "删除当前问题版本："${server_path}/webapps/${filename}*""    
    rm -rf "${server_path}/webapps/${filename}*"
}

##############################################################################
###    回滚
##############################################################################
function rollback(){
    echo "还原版本：$1"
    filename=`echo $1 | sed 's/_//' | sed 's/[0-9]//g'`
    cp ${backup_path}/$1 ${server_path}/webapps/${filename}.war
}

##############################################################################
###    回滚或备份判断
###        接受一个参数：格式为[ maiev.war | maiev_20170415211120 ] 
###        前者为备份用后者，后者回滚用
##############################################################################
function rollback_or_backup(){
        #参数为war包名称时 备份
	# extension=${1##*.}
	#echo "扩展名：${extension}"
	if [[ "${1##*.}" == "war" && $backup_switch == "on" ]]; then
	    #开始备份 将restart命令参数作为backup参数
	    backup $1
	else #其他情况为回滚
		del_exception_version $1
		rollback $1
	fi
}

##############################################################################
###    启动
##############################################################################
function tomcat_start(){
        cd "$server_path"
        ./bin/startup.sh
        tail -f logs/catalina.out
}

##############################################################################
###    kill tomcat
##############################################################################
function kill_tomcat(){
        # kill tomcat process 
        ps -ef | grep ${process_flag} | grep -v grep | awk '{print $2}' | sed -e "s/^/kill -9 /g" | sh -
}


##############################################################################
###    主流程
##############################################################################
#杀进程
kill_tomcat
#备份或回滚
if [[ "$1" != "" ]]; then
	rollback_or_backup $1
fi
#启动tomcat
tomcat_start


