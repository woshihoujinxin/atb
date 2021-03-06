#!/bin/bash
#tomcat根目录
server_path=$2

##############################################################################
###    从备份文件夹拷贝最新版war包
##############################################################################
function deploy(){
    echo "删除旧版[ ${server_path}/webapps/${1%.*}* ]"
    #删除webapps下的war以及解压文件夹
    rm -rf "${server_path}/webapps/${1%.*}*"
    cp ${server_path}/backup/$(cd ${server_path}/backup; ls -rt|tail -1) ${server_path}/webapps/$1
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
    cp ${server_path}/backup/$1 ${server_path}/webapps/${filename}.war
}

##############################################################################
###    回滚或备份判断
###        接受一个参数：格式为[ maiev.war | maiev_20170415211120 ] 
###        前者为备份用后者，后者回滚用
##############################################################################
function rollback_or_deploy(){
    # 参数为war包名称时 备份
	# extension=${1##*.}
	# echo "扩展名：${extension}"
	if [[ "${1##*.}" == "war"  ]]; then
	    #开始备份 将restart命令参数作为backup参数
	    deploy $1
	else # 其他情况为回滚
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
    # kill tomcat process awk和shell同时使用了$2那么在awk前需要将shell的$2改名
    # pid="`ps -ef | grep tomcat | grep -v grep | awk '{print $2 }'`"
    # 迷之grep 第一次把所有的含tomcat路径的进程返回 包含 这个当前命令的进程本身因为参数中含tomcat路径 第二个grep去掉grep命令进程 第三个才是真正的tomcat进程
    ps -ef | grep ${server_path##*/} | grep -v grep | grep ${server_path}/conf/logging.properties | awk '{print $2 }' | sed -e "s/^/kill -9 /g" | sh -
    echo "tomcat 进程已杀死"
}

##############################################################################
###    主流程
##############################################################################
#杀进程
kill_tomcat
#备份或回滚
if [[ "$1" != "" ]]; then
	rollback_or_deploy $1
fi
#启动tomcat
tomcat_start
