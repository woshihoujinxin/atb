#!/bin/bash
##############################################################################
### 			没有任何修饰符参数 : 原生参数
### 			<>  : 占位参数
### 			[]  : 可选组合
### 			()  : 必选组合
### 			|   : 互斥参数
### 			... : 可重复指定前一个参数
### 			--  : 标记后续参数类型
##############################################################################

##############################################################################
###    打印 banner
##############################################################################
function show_banner(){
	echo "##################################################################################################"
	echo "#                                                                                                #"
	echo "#   █████╗ ████████╗██████╗     ██████╗ ██╗   ██╗         ██╗██╗███╗   ██╗██╗  ██╗██╗███╗   ██╗  #"
	echo "#  ██╔══██╗╚══██╔══╝██╔══██╗    ██╔══██╗╚██╗ ██╔╝         ██║██║████╗  ██║╚██╗██╔╝██║████╗  ██║  #"
	echo "#  ███████║   ██║   ██████╔╝    ██████╔╝ ╚████╔╝          ██║██║██╔██╗ ██║ ╚███╔╝ ██║██╔██╗ ██║  #"
	echo "#  ██╔══██║   ██║   ██╔══██╗    ██╔══██╗  ╚██╔╝      ██   ██║██║██║╚██╗██║ ██╔██╗ ██║██║╚██╗██║  #"
	echo "#  ██║  ██║   ██║   ██████╔╝    ██████╔╝   ██║       ╚█████╔╝██║██║ ╚████║██╔╝ ██╗██║██║ ╚████║  #"
	echo "#  ╚═╝  ╚═╝   ╚═╝   ╚═════╝     ╚═════╝    ╚═╝        ╚════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  #"                                                                                          
	echo "#                                                                                                #"
	echo "##################################################################################################"
}

##############################################################################
###    显示帮助
##############################################################################
function show_help(){
	echo
	echo "usage: atb [Options]"
	echo
	echo "Options："
	echo " -c                                    clean 工程"
	echo " -du  [ -l ]                           跳过编译步骤直接上传已存在war包到本地服务器"
	echo " -du -r <server_flag>                  跳过编译步骤直接上传已存在war包到指定的远程服务器"
	echo " -h                                    帮助"
	echo " -l                                    自动编译打包本地部署"
	echo " -r <server_flag>                      自动编译打包远程部署到指定的远程服务器"
	echo " -his -r <server_flag>                 查看指定的远程服务器上备份历史"
	echo " -r -rb <server_flag> <backup_version> 将指定服务器web应用回滚到指定版本"
}

##############################################################################
###    变量声明 var=value 等号必须前后紧挨着
##############################################################################

#以下参数代表服务器配置信息有多少机器配置多少个,这里的配置用于取值
#远程服务器路径
remote_server_paths=()
#远程服务器用户
remote_users=()
#远程服务器ip
remote_ips=()
#远程服务器端口
remote_ports=()
#远程服务器密码 可以不设置
remote_pwds=()
#maven打包用的远程profiles
remote_profiles=()
#远程server_flags
remote_server_flags=()
#本地profile
local_profile=""
#本地tomcat webapps目录
local_server_path=""
#项目远程build路径
remote_project_basepath=""
#maven本地路径
maven_home=""
#项目本地路径
local_project_basepath=""
#项目名称
project_name=""
#war包所在的maven子模块,只支持一个war包的工程 为空时代表在父及目录下的target中存在war包
war_sub_project_name=""
#war包名
war_name=""
#远程重启shell目录 将restart脚本放到远程服务器指定的目录下，即可远程重启tomcat
remote_shell_dir=""
#项目git地址
repository_url=""
#本地tocmat进程唯一筛选条件，本地多实例部署时根据这一个条件杀死指定进程
local_tomcat_process_name=""

##############################################################################
###    打印配置参数
##############################################################################
function print_config_param(){
	echo "config Param: remote_server_paths = ${config_remote_server_paths}"
	echo "config Param: remote_users = ${config_remote_users}"
	echo "config Param: remote_ips = ${config_remote_ips}"
	echo "config Param: remote_ports = ${config_remote_ports}"
	echo "config Param: remote_pwds = ${config_remote_pwds}"
	echo "config Param: remote_profiles = ${config_remote_profiles}"
	echo "config Param: remote_server_flags = ${config_remote_server_flags}"
	echo "config Param: local_profile = ${config_local_profile}"
	echo "config Param: local_server_path = ${config_local_server_path}"
	echo "config Param: remote_project_basepath = ${config_remote_project_basepath}"
	echo "config Param: maven_home = ${config_maven_home}"
	echo "config Param: local_project_basepath = ${config_local_project_basepath}"
	echo "config Param: project_name = ${config_project_name}"
	echo "config Param: war_sub_project_name = ${config_war_sub_project_name}"
	echo "config Param: war_name = ${config_war_name}"
	echo "config Param: remote_shell_dir = ${config_remote_shell_dir}"
	echo "config Param: repository_url = ${config_repository_url}"
	echo "config Param: local_tomcat_process_name = ${config_local_tomcat_process_name}"
	echo ""
}

##############################################################################
###    读取配置文件
##############################################################################
function read_conf(){
	# echo "#################读取配置文件开始#################"
	while read -r line;do  
    	eval "$line"  
	done < ~/config
	# echo "#################读取配置文件结束#################"
	# print_config_param

	remote_server_paths=${config_remote_server_paths}
	remote_users=${config_remote_users}
	remote_ips=${config_remote_ips}
	remote_ports=${config_remote_ports}
	remote_pwds=${config_remote_pwds}
	remote_profiles=${config_remote_profiles}
	remote_server_flags=${config_remote_server_flags}
	local_profile=${config_local_profile}
	local_server_path=${config_local_server_path}
	remote_project_basepath=${config_remote_project_basepath}
	maven_home=${config_maven_home}
	local_project_basepath=${config_local_project_basepath}
	project_name=${config_project_name}
	war_sub_project_name=${config_war_sub_project_name}
	war_name=${config_war_name}
	remote_shell_dir=${config_remote_shell_dir}
	repository_url=${config_repository_url}
	local_tomcat_process_name=${config_local_tomcat_process_name}
	return 0
}

##############################################################################
###	   查看历史版本
##############################################################################
function show_deploy_history(){
	echo "↓                                         备份列表                                               ↓"
	# echo ssh -t -T -p $remote_port $remote_user@$remote_ip "cd ${remote_backup_path} && ls -l"
	ssh -t -T -p $remote_port $remote_user@$remote_ip "cd ${remote_backup_path} && ls -lhG"
	
}

##############################################################################
###	   检出代码
##############################################################################
function checkout_code(){
	echo "正在从资源库[ $repository_url ]检出代码"
	git s; git pull;git sp
	return 0
}

##############################################################################
###	   maven clean
##############################################################################
function clear_project(){
	echo "${maven_shell} clean"
	${maven_shell} clean
	return 0
}

##############################################################################
###	   编译打包
##############################################################################
function package(){
	if [[ "${profile}" = "" ]]; then
		echo "mvn clean package -DskipTests=true"
		${maven_shell} clean package -DskipTests=true
		return 0
	fi
	echo "mvn clean package -DskipTests=true -P$profile"
	${maven_shell} clean package -DskipTests=true -P${profile}
	return 0
}

##############################################################################
###    检查war是否已存在，不存在退出 返回值 0-存在，1-不存在
##############################################################################
function check_war(){
	if [ -e "$war_path" ]; then
		return 0
	fi
	echo "$war_path 下面 war包不存在"
	return 1
}

##############################################################################
###    本地拷贝
##############################################################################
function local_copy(){
	# echo "进入war包目录：$sub_project_path/target"
	# echo "开始传输war包到本地服务器目录：$server_path/webapps"
	cd "$sub_project_path/target"
	cp $war_name "$server_path/webapps/$war_name"
}

##############################################################################
###	   远程拷贝
##############################################################################
function remote_copy(){
	# echo "Param: remote_user = $remote_user" 
	# echo "Param: remote_ip = $remote_ip" 
	# echo "Param: remote_port = $remote_port" 
	# echo "Param: remote_pwd = $remote_pwd" 
	echo "进入war包目录：$sub_project_path/target"
	cd "$sub_project_path/target"
	#打印密码方便拷贝
	echo "开始传输 [ $war_name ] 到 $remote_user@$remote_ip:$server_path/webapps 密码：$remote_pwd"
	scp $war_name "$remote_user@$remote_ip:$server_path/webapps"
}

##############################################################################
###	   重启远程服务器
##############################################################################
function restart_remote_server() {
    # echo "ssh -t -T -p $remote_port $remote_user@$remote_ip nohup $remote_shell_dir/restart.sh &"
    # 执行服务器重启脚本
    # -T 	Disable pseudo-terminal allocation.
    # -t 	Force pseudo-terminal allocation.  T
    # 		his can be used to execute arbitrary screen-based programs on a remote machine, 
    # 		which can be very useful, e.g.
    #   	when implementing menu services.  
    #   	Multiple -t options force tty allocation, even if ssh has no local tty.
    # -p 指定端口号
    echo "重启服务中..."
	ssh -t -T -p $remote_port $remote_user@$remote_ip "nohup $remote_shell_dir/restart.sh ${war_name} &"
}

##############################################################################
###	   回滚到某个版本
##############################################################################
function rollback_backup_version() {
    echo "回滚中..."
	ssh -t -T -p $remote_port $remote_user@$remote_ip "nohup $remote_shell_dir/restart.sh ${backup_version} &"
}

##############################################################################
###	   重启本地服务器
##############################################################################
function restart_local_server() {
	cd "$server_path"
	# ./bin/shutdown.sh
	# 根据程唯一筛选条件杀死进程
	ps -ef | grep ${local_tomcat_process_name} | grep -v grep | awk '{print $2}'  | sed -e "s/^/kill -9 /g" | sh -
	./bin/startup.sh
	tail -f ./logs/catalina.out
}

##############################################################################
###	   发布流程 return 0 正常 return 1 不正常
##############################################################################
function deploy_flow(){

	#不直接上传，检出代码，打包
	if [[ "$dirct_upload" != "-du" ]]; then
		#检出代码
		checkout_code
		#编译代码
		package
	fi

	#检查war包是否存在
	check_war
	war_exist=$?
	#war包不存在, 检出代码并打包
	if [[ "$war_exist" = "1" ]]; then
		#检出代码
		checkout_code
		#编译代码
		package

		#二次检查war包是否存在，war包不存在退出
		check_war
		war_exist=$?
		#war包不存在, 检出代码并打包
		if [[ "$war_exist" = "1" ]]; then
			echo "发布失败：war包不存在"
			return 1
		fi
	fi

	#上传代码到服务器,并重启服务
	if [[ "$local_or_remote" = "-l" ]]; then
		local_copy
		restart_local_server
	elif [[ "$local_or_remote" = "-r" ]]; then
		remote_copy
		restart_remote_server
	else
		local_copy
		restart_local_server
	fi
	return 0
}

##############################################################################
###	   检查入参是否是数字 如果输出是空那么就证明是数字
##############################################################################
function check_num(){
	echo $1 | sed 's/[0-9]//g'
}

##############################################################################
###	   检查版本号格式 版本号格式为${war_name}_20170415211120
##############################################################################
function check_version(){
	echo $1 | sed 's/_//' | sed 's/[0-9]//g'
}

##############################################################################
###	   输出参数详情
##############################################################################
function echo_params(){

	echo "Param: remote_server_paths = $remote_server_paths"
	echo "Param: remote_users = $remote_users"
	echo "Param: remote_ips = $remote_ips"
	echo "Param: remote_ports = $remote_ports"
	echo "Param: remote_pwds = $remote_pwds"
	echo "Param: remote_profiles = $remote_profiles"
	echo "Param: remote_server_flags = $remote_server_flags"
	echo "Param: local_profile = $local_profile"
	echo "Param: local_server_path = $local_server_path"
	echo "Param: remote_project_basepath = $remote_project_basepath"
	echo "Param: maven_home = $maven_home"
	echo "Param: local_project_basepath = $local_project_basepath"
	echo "Param: project_name = $project_name"
	echo "Param: war_sub_project_name = $war_sub_project_name"
	echo "Param: war_name = $war_name"
	echo "Param: remote_shell_dir = $remote_shell_dir"
	echo "Param: repository_url = $repository_url"
	echo "Param: parent_project_path = $parent_project_path"
	echo "Param: sub_project_path = $sub_project_path"	
	echo "Param: war_path = $war_path"
	echo "Param: local_tomcat_process_name = $local_tomcat_process_name"

	echo "Param: profile = $profile"
	echo "Param: server_flag = $server_flag" 
	echo "Param: server_path = $server_path" 
	echo "Param: local_or_remote = $local_or_remote" 
	echo "Param: dirct_upload = $dirct_upload" 
	echo "Param: clean_project = $clean_project" 
	echo "Param: show_help_flag = $show_help_flag" 
	echo "Param: maven_shell = $maven_shell"
	echo "Param: remote_server_path = $remote_server_path"
	echo "Param: remote_backup_path = $remote_backup_path"
	echo "Param: backup_version = $backup_version"
	echo "Param: remote_user = $remote_user" 
	echo "Param: remote_ip = $remote_ip" 
	echo "Param: remote_port = $remote_port" 
	echo "Param: remote_pwd = $remote_pwd" 
	echo ""
}

show_banner
#读取配置文件
read_conf

#父工程路径
parent_project_path="$local_project_basepath/$project_name"
#子工程路径
sub_project_path="$parent_project_path/$war_sub_project_name"
#war包路径
war_path="$sub_project_path/target/$war_name"

#maven打包使用的profile
profile=""
#远程服务器标识,用于区分多台机器
server_flag=""
#最终server_path
server_path=""

#本地或远程部署
local_or_remote=""
#直接上传
dirct_upload=""
#clean工程
clean_project=""
#帮助标志
show_help_flag=""
#maven_shell
maven_shell=""

#远程tomcat webapps目录
remote_server_path=""
#远程服务器用户
remote_user=""
#远程服务器ip
remote_ip=""
#远程服务器端口
remote_port=""
#远程服务器密码 可以不设置
remote_pwd=""

#远程服务器上备份存储路径 默认为tomcat目录下的backup
remote_backup_path=""
#远程服务器上备份历史
remote_backup_history=""
#备份版本号
backup_version=""


##############################################################################
###    参数预处理
##############################################################################

# 命令及参数显示
# for i in "$*"; do
# 	echo "Command: `basename $0`" $i "Param Count: $#"
# done

#如果参数为0，各个参数取默认值
if [[ $# -eq 0 ]]; then
	dirct_upload=""
	# echo "handle dirct_upload : $dirct_upload"
	local_or_remote="-l"
	# echo "handle local_or_remote : $local_or_remote"
	clean_project=""
	# echo "handle clean_project : $clean_project"
fi

#如果参数大于等于1，通过循环处理参数
count=1
while [ $# -ge 1 ];do
	# echo "Current param: $1"
	numcheck=$(check_num $1)
	versioncheck=$(check_version $1)
	if [[ "$numcheck" = "" ]]; then #如果参数为数字，则表示代表服务器的ip标识
		server_flag=$1
		# echo "handle server_flag : $server_flag"
	elif [[ "$versioncheck" = "${war_name%.*}" ]]; then
		backup_version=$1
		# echo "handle backup_version : $backup_version"
	elif [[ "$1" = "-du" ]]; then
		dirct_upload="-du"
		# echo "handle dirct_upload : $dirct_upload"
	elif [[ "$1" = "-h" ]]; then
		show_help_flag="-h"
		# echo "handle show_help_flag : $show_help_flag"
	elif [[ "$1" = "-r" ]]; then		
		local_or_remote="-r"
		# echo "handle local_or_remote : $local_or_remote"
	elif [[ "$1" = "-l" ]]; then #-r和-l同时存在取最后一个
		local_or_remote="-l"
		# echo "handle local_or_remote : $local_or_remote"
	elif [[ "$1" = "-c" ]]; then #-r和-l同时存在取最后一个
		clean_project="-c"
		# echo "handle clean_project : $clean_project"
	elif [[ "$1" = "-his" ]]; then #查看历史
		remote_backup_history="-his"
		# echo "handle remote_backup_history : $remote_backup_history"
	elif [[ "$1" = "-rb" ]]; then #回滚备份
		remote_rollback="-rb"
		# echo "handle remote_rollback : $remote_rollback"
	fi
    # echo "参数序号： $count = $1"
    let count=count+1
    shift
done

#server_path以及profile配置
if [[ "$local_or_remote" = "-l" ]]; then
	server_path="$local_server_path"
	profile="$local_profile"
elif [[ "$local_or_remote" = "-r" ]]; then
	parent_project_path="$remote_project_basepath/$project_name"
	sub_project_path="$parent_project_path/$war_sub_project_name"
	war_path="$sub_project_path/target/$war_name"
	if [[ "$server_flag" = "" ]]; then
		echo "server_flag没有指定，请指定后再执行"
		exit 0
	fi

	#远程服务器服务器配置信息控制
	arr_index=0
	for i in "${!remote_server_flags[@]}"; do
		if [[ $server_flag = ${remote_server_flags[$i]} ]]; then
		 	#statements
		 	arr_index=$i
		fi 
	done
	# echo "服务器配置索引 $arr_index"
	remote_user="${remote_users[$arr_index]}"
	remote_ip="${remote_ips[$arr_index]}"
	remote_port="${remote_ports[$arr_index]}"
	remote_pwd="${remote_pwds[$arr_index]}"
	remote_server_path="${remote_server_paths[$arr_index]}"

	server_path="$remote_server_path"
	remote_backup_path="${server_path}/backup"
	profile="${remote_profiles[$arr_index]}"
else
	server_path="$local_server_path"
	profile="$local_profile"
fi

if [[ "$maven_home" != "" ]]; then
	maven_shell="$maven_home/bin/mvn"
else
	maven_shell="mvn"
fi

#debug时查看参数输出
echo_params

if [[ "$clean_project" = "-c" ]]; then
	echo "工程clean开始，进入工程目录 $parent_project_path"
	cd "$parent_project_path"
	#如果是clean工程命令，执行完直接退出
	clear_project
	echo "工程clean结束"
	exit 0
elif [[ "$show_help_flag" = "-h" ]]; then
	#如果是help命令，显示帮助直接退出
	show_help
	exit 0
elif [[ "$remote_backup_history" = "-his" ]]; then
	#显示备份历史
	show_deploy_history
	exit 0
elif [[ "$remote_rollback" = "-rb" ]]; then
	if [[ "$backup_version" = "" ]]; then
		echo "backup_version没有指定，请指定后再执行"
		exit 0
	fi
	#回滚
	rollback_backup_version
	exit 0
else
	echo "工程自动化构建开始，进入工程目录 $parent_project_path"
	cd "$parent_project_path"
	#其他情况执行发布流程
	deploy_flow
	echo "工程自动化构建结束"
	exit 0
fi