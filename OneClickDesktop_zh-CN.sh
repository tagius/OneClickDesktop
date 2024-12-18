#!/bin/bash
###########################################################################################
#    One-click Desktop & Browser Access Setup Script v0.2.0                               #
#    Written by shc (https://qing.su) and York (https://144500.xyz)                                                     #
#    Github link: https://github.com/York-Labs/OneClickDesktop                             #
#    Follow me: https://t.me/york_hub   E-mail: york@144500.xyz                                 #
#                                                                                         #
#    This script is distributed in the hope that it will be                               #
#    useful, but ABSOLUTELY WITHOUT ANY WARRANTY.                                         #
#                                                                                         #
#    The author thanks LinuxBabe for providing detailed                                   #
#    instructions on Guacamole setup.                                                     #
#    https://www.linuxbabe.com/debian/apache-guacamole-remote-desktop-debian-10-buster    #
#                                                                                         #
#    Thank you for using this script.                                                     #
###########################################################################################


#您可以在这里修改Guacamole源码下载链接。
#访问https://guacamole.apache.org/releases/获取最新源码。

GUACAMOLE_DOWNLOAD_LINK="https://dlcdn.apache.org/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz"
GUACAMOLE_VERSION="1.5.5"

# UPDATE:你可以在这里更改对RHEL8的特殊依赖的URL
LIBUV_URL="http://repo.almalinux.org/almalinux/8/AppStream/x86_64/os/Packages/libuv-1.41.1-2.el8_10.x86_64.rpm"
SDL2_URL="http://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/s/SDL2-2.30.3-1.fc41.src.rpm"

# UPDATE:你可以在这里更改Apache Tomcat的URL
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz"
TOMCAT_FILENAME="apache-tomcat-9.0.91"

# UPDATE:如果您对脚本做了更改，并公开发布，请记得更改这里的链接，方便后续用户反馈Bug
PROJECT_URL="https://github.com/York-Labs/OneClickDesktop"

#此脚本仅支持Ubuntu 18/20/22/24, Debian 10/11/12, CentOS 7/8，以及AlmaLinux，Rocky Linux.
#如果您试图再其他版本的操作系统中安装，可以在下面禁用OS检查开关。
#请注意，在其他操作系统上安装此脚本可能会导致不可预料的错误。  请在安装前做好备份。

OS_CHECK_ENABLED=ON




#########################################################################
#    Functions start here.                                              #
#    Do not change anything below unless you know what you are doing.   #
#########################################################################

exec > >(tee -i OneClickDesktop.log)
exec 2>&1

function show_feedback
{
        echo "欢迎您在${PROJECT_URL}/issues这里提交错误报告，以便我修复脚本。"
	echo "谢谢"
        echo
	exit 1
}


# UPDATE：检查OS类型及版本
# UPDATE：由于Ubuntu过于商业化，我会考虑剔除对Ubuntu的支持。
function check_OS
{
	if [ -f /etc/lsb-release ] ; then
		cat /etc/lsb-release | grep "DISTRIB_RELEASE=18." >/dev/null
		if [ $? = 0 ] ; then
			OS=UBUNTU
		else
			cat /etc/lsb-release | grep "DISTRIB_RELEASE=20." >/dev/null
			if [ $? = 0 ] ; then
				OS=UBUNTU # Ubuntu和Debian依赖不同。
			else
				cat /etc/lsb-release | grep "DISTRIB_RELEASE=24." >/dev/null
				if [ $? = 0 ] ; then
					OS=UBUNTU
				else
					say "很抱歉，此脚本仅支持Ubuntu 18/20/24, Debian 10/11/12, 以及CentOS 7/8, AlmaLinux 和 Rocky Linux操作系统。" red
					echo 
					exit 1
				fi
			fi
		fi
	elif [ -f /etc/debian_version ] ; then
		cat /etc/debian_version | grep "^10." >/dev/null
		if [ $? = 0 ] ; then
			OS=DEBIAN10
		else
			cat /etc/debian_version | grep "^11." >/dev/null
			if [ $? = 0 ] ; then
				OS=DEBIAN10
			else
				cat /etc/debian_version | grep "^12." >/dev/null
				if [ $? = 0 ] ; then
					OS=DEBIAN10
				else
					say "很抱歉，此脚本仅支持Ubuntu 18/20/24, Debian 10/11/12, 以及CentOS 7/8, AlmaLinux 和 Rocky Linux操作系统。" red
					echo 
					exit 1
				fi
			fi
		fi
	elif [ -f /etc/redhat-release ] ; then
		cat /etc/redhat-release | grep " 8." >/dev/null
		if [ $? = 0 ] ; then
			OS=RHEL8
			say @B"CentOS 8的支持目前还处于测试阶段，如果有bug欢迎提出。" yellow
			say @B"如果安装好后无法访问您的服务器桌面，请考虑禁用firewalld或者selinux." yellow
			echo 
		else
			cat /etc/redhat-release | grep " 7." >/dev/null
			if [ $? = 0 ] ; then
				OS=CENTOS7
				say @B"CentOS 7的支持目前还处于测试阶段，如果有bug欢迎提出。" yellow
				say @B"如果安装好后无法访问您的服务器桌面，请考虑禁用firewalld或者selinux." yellow
				echo 
			else
				cat /etc/redhat-release | grep "AlmaLinux" >/dev/null
				if [ $? = 0 ] ; then
					OS=RHEL8
                                        say @B"AlmaLinux的支持目前还处于测试阶段，如果有bug欢迎提出。" yellow
			                say @B"如果安装好后无法访问您的服务器桌面，请考虑禁用firewalld或者selinux." yellow
			                echo
				else
					cat /etc/redhat-release | grep "Rocky Linux" >/dev/null
					if [ $? = 0 ] ; then
						OS=RHEL8
                                                say @B"Rocky Linux的支持目前还处于测试阶段，如果有bug欢迎提出。" yellow
						say @B"如果安装好后无法访问您的服务器桌面，请考虑禁用firewalld或者selinux." yellow
						echo
					else
						say "很抱歉，此脚本仅支持Ubuntu 18/20/24, Debian 10/11/12, 以及CentOS 7/8, AlmaLinux 和 Rocky Linux操作系统。" red
						echo
						exit 1
					fi
				fi
			fi
		fi
	else
		say "很抱歉，此脚本仅支持Ubuntu 18/20/24, Debian 10/11/12, 以及CentOS 7/8, AlmaLinux 和 Rocky Linux操作系统。" red
		echo 
		exit 1
	fi
}

function say
{
#This function is a colored version of the built-in "echo".
#https://github.com/Har-Kuun/useful-shell-functions/blob/master/colored-echo.sh
	echo_content=$1
	case $2 in
		black | k ) colorf=0 ;;
		red | r ) colorf=1 ;;
		green | g ) colorf=2 ;;
		yellow | y ) colorf=3 ;;
		blue | b ) colorf=4 ;;
		magenta | m ) colorf=5 ;;
		cyan | c ) colorf=6 ;;
		white | w ) colorf=7 ;;
		* ) colorf=N ;;
	esac
	case $3 in
		black | k ) colorb=0 ;;
		red | r ) colorb=1 ;;
		green | g ) colorb=2 ;;
		yellow | y ) colorb=3 ;;
		blue | b ) colorb=4 ;;
		magenta | m ) colorb=5 ;;
		cyan | c ) colorb=6 ;;
		white | w ) colorb=7 ;;
		* ) colorb=N ;;
	esac
	if [ "x${colorf}" != "xN" ] ; then
		tput setaf $colorf
	fi
	if [ "x${colorb}" != "xN" ] ; then
		tput setab $colorb
	fi
	printf "${echo_content}" | sed -e "s/@B/$(tput bold)/g"
	tput sgr 0
	printf "\n"
}

function determine_system_variables
{
	CurrentUser="$(id -u -n)"
	CurrentDir=$(pwd)
	HomeDir=$HOME
}

function get_user_options
{
	echo 
	say @B"请输入您的Guacamole用户名:" yellow
	read guacamole_username
	echo 
	say @B"请输入您的Guacamole密码:" yellow
	read guacamole_password_prehash
	read guacamole_password_md5 <<< $(echo -n $guacamole_password_prehash | md5sum | awk '{print $1}')
	echo 
	if [ "x$OS" != "xRHEL8" ] && [ "x$OS" != "xCENTOS7" ] ; then
		say @B"您想让Guacamole通过RDP还是VNC连接Linux桌面？" yellow
		say @B"RDP请输入1, VNC请输入2. 如果您不清楚这是什么，请输入1." yellow
		read choice_rdpvnc
	else 
		say @B"Guacamole将通过RDP与桌面环境通信。" yellow
		choice_rdpvnc=1
	fi
	echo 
	if [ $choice_rdpvnc = 1 ] ; then
		say @B"请选择屏幕分辨率。" yellow
		echo "默认分辨率1280x800请输入1, 自适应分辨率请输入2, 手动设置分辨率请输入3."
		read rdp_resolution_options
		if [ $rdp_resolution_options = 2 ] ; then
			set_rdp_resolution=0;
		else
			set_rdp_resolution=1;
			if [ $rdp_resolution_options = 3 ] ; then
				echo 
				echo "请输入屏幕宽度（默认为1280）:"
				read rdp_screen_width_input
				echo "请输入屏幕高度（默认为800）:"
				read rdp_screen_height_input
				if [ $rdp_screen_width_input -gt 1 ] && [ $rdp_screen_height_input -gt 1 ] ; then
					rdp_screen_width=$rdp_screen_width_input
					rdp_screen_height=$rdp_screen_height_input
				else
					say "屏幕分辨率设置无效。" red
					echo 
					exit 1
				fi
			else
				rdp_screen_width=1280
				rdp_screen_height=800
			fi
		fi
		say @B"屏幕分辨率设置成功。" green
	else
		echo 
		while [ ${#vnc_password} != 8 ] ; do
			say @B"请输入一个长度为8位的VNC密码:" yellow
		read vnc_password
		done
		say @B"VNC密码成功设置." green
		echo "通过浏览器方式访问远程桌面时，您将无需使用此VNC密码。"
		sleep 1
	fi
        # 从这里开始，是配置反代的部分
	# 相比原版本，将使用caddy来反代
	echo 
	say @B"请问您是否想要设置Caddy反代？" yellow
	say @B"请注意，如果您想在本地电脑和服务器之间复制粘贴文本，您必须启用反代并设置SSL. 不过，您也可以暂时先不设置反代，以后再手动设置。" yellow
	echo "请输入 [Y/n]:"
	read install_caddy
	if [ "x$install_caddy" != "xn" ] && [ "x$install_caddy" != "xN" ] ; then
		echo 
		say @B"请输入您的域名（比如desktop.qing.su）:" yellow
		read guacamole_hostname
		echo 
		echo 
		echo "是否为域名${guacamole_hostname}申请免费的Let's Encrypt SSL证书？ [Y/N]"
		say @B"设置证书之前，您必须将您的域名指向本服务器的IP地址！" yellow
		echo "如果您确认了您的域名已经指向了本服务器的IP地址，请输入Y开始证书申请。"
		read confirm_le
		echo 
		if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
			echo "请输入一个邮箱地址:"
			read le_email
		fi
	else
		say @B"好的，将跳过Caddy安装。" yellow
	fi
	echo 
	say @B"开始安装桌面环境，请稍后。" green
	sleep 3
}	

function install_guacamole_ubuntu_debian
{
	echo 
	say @B"安装依赖环境..." yellow
	echo 
	apt-get update && apt-get upgrade -y
        apt-get install build-essential -y
	apt-get install perl expect build-essential -y
        apt-get install libcairo2-dev libpng-dev libtool-bin -y 
	apt-get install uuid-dev  -y
        # 以下是针对协议的依赖
        apt-get install libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev 
	# 字体依赖
        apt-get install fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core -y
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install libjpeg62-turbo-dev -y
        else 
	        if [ "$OS" = "UBUNTU" ] ; then
	                apt-get install libjpeg-turbo8-dev language-pack-ja language-pack-zh* language-pack-ko -y
		fi
	fi
        # 安装jdk
	apt-get install openjdk-17-jdk -y
        # 安装Tomcat
	install_tomcat9
	wget $GUACAMOLE_DOWNLOAD_LINK
	tar zxf guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	rm -f guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	cd $CurrentDir/guacamole-server-$GUACAMOLE_VERSION
	echo "开始安装Guacamole服务器..."
	./configure --with-init-dir=/etc/init.d
	if [ -f $CurrentDir/guacamole-server-$GUACAMOLE_VERSION/config.status ] ; then
		say @B"编译条件已满足！" green
		say @B"开始编译源码..." green
		echo
	else
		echo 
		say "依赖环境缺失。" red
		echo "请核查日志，安装必要的依赖环境，并再次运行此脚本。"
		show_feedback
	fi
	sleep 2
	make
	make install
	ldconfig
	echo "第一次启动Guacamole服务器可能需要较长时间..."
	echo "请耐心等待..."
	echo 
	systemctl daemon-reload
	systemctl start guacd
	systemctl enable guacd
	ss -lnpt | grep guacd >/dev/null
	if [ $? = 0 ] ; then
		say @B"Guacamole服务器安装成功！" green
		echo 
	else 
		say "Guacamole服务器安装失败。" red
		say @B"请检查上面的日志。" yellow
		show_feedback
	fi
}

function install_guacamole_centos
{
	echo 
	say @B"安装依赖环境..." yellow
	echo 
        # UPDATE：下面的链接都更新了，基于Alma源，放心食用
	# 我估计作者也没料到有一天centos源会关闭，哈哈。
	if [ "$OS" = "RHEL8" ] ; then
		dnf -y update
		dnf -y group install "Development Tools"
		dnf -y install --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
		dnf -y install ${SDL2_URL}
		dnf -y install ${LIBUV_URL}
		dnf -y --enablerepo=PowerTools install perl expect cairo cairo-devel libpng-devel libtool uuid libjpeg-devel libjpeg-turbo-devel freerdp freerdp-devel pango-devel libssh2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libwebp-devel libwebsockets-devel libvorbis-devel ffmpeg-devel uuid-devel ffmpeg ffmpeg-devel mingw64-filesystem
		yum -y groupinstall Fonts
		dnf -y install java-11-openjdk-devel
	else
		yum update -y
		yum -y install epel-release
		yum -y install wget curl vim tar sudo zip unzip perl git cairo-devel freerdp-devel freerdp-plugins gcc gnu-free-mono-fonts libjpeg-turbo-devel libjpeg-turbo-official libpng-devel libssh2-devel libtelnet-devel libvncserver-devel libvorbis-devel libwebp-devel libwebsockets-devel openssl-devel pango-devel policycoreutils-python pulseaudio-libs-devel setroubleshoot uuid-devel
		yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
		yum -y install ffmpeg ffmpeg-devel
		yum -y groupinstall Fonts
		yum -y install java-11-openjdk-devel
	fi
	install_tomcat9
	wget $GUACAMOLE_DOWNLOAD_LINK
	tar zxf guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	rm -f guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	cd $CurrentDir/guacamole-server-$GUACAMOLE_VERSION
	echo "开始安装Guacamole服务器..."
	./configure --with-init-dir=/etc/init.d
	if [ -f $CurrentDir/guacamole-server-$GUACAMOLE_VERSION/config.status ] ; then
		say @B"编译条件已满足！" green
		say @B"开始编译源码..." green
		echo
	else
		echo 
		say "依赖环境缺失。" red
		echo "请核查日志，安装必要的依赖环境，并再次运行此脚本。"
		show_feedback
	fi
	sleep 2
	make
	make install
	ldconfig
	echo "第一次启动Guacamole服务器可能需要较长时间..."
	echo "请耐心等待..."
	echo 
	service guacd start
	chkconfig guacd on
	ss -lnpt | grep guacd >/dev/null
	if [ $? = 0 ] ; then
		say @B"Guacamole服务器安装成功！" green
		echo 
	else 
		say "Guacamole服务器安装失败。" red
		say @B"请检查上面的日志。" yellow
		show_feedback
	fi
}

function install_tomcat9
{
	curl -s $TOMCAT_URL | tar -xz
	mv $TOMCAT_FILENAME /etc/tomcat9
	echo "export CATALINA_HOME="/etc/tomcat9"" >> ~/.bashrc
	source ~/.bashrc
	useradd -r tomcat
	chown -R tomcat:tomcat /etc/tomcat9
	cat > /etc/systemd/system/tomcat9.service <<END
[Unit]
Description=Apache Tomcat Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=CATALINA_PID=/etc/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/etc/tomcat9
Environment=CATALINA_BASE=/etc/tomcat9

ExecStart=/etc/tomcat9/bin/catalina.sh start
ExecStop=/etc/tomcat9/bin/catalina.sh stop

RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
END
	systemctl daemon-reload
	systemctl start tomcat9
	systemctl enable tomcat9
}
	
function install_guacamole_web
{
	echo 
	echo "开始安装Guacamole Web应用..."
	cd $CurrentDir
	wget https://dlcdn.apache.org/guacamole/$GUACAMOLE_VERSION/binary/guacamole-$GUACAMOLE_VERSION.war
	mv guacamole-$GUACAMOLE_VERSION.war /etc/tomcat9/webapps/guacamole.war
	systemctl restart tomcat9 guacd
	echo 
	say @B"Guacamole Web应用成功安装！" green
	echo 
}

function configure_guacamole_ubuntu_debian
{
	echo 
	mkdir /etc/guacamole/
	cat > /etc/guacamole/guacamole.properties <<END
guacd-hostname: localhost
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
END
	if [ $choice_rdpvnc = 1 ] ; then
		if [ $set_rdp_resolution = 0 ] ; then
			cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
       </connection>
    </authorize>
</user-mapping>
END
		else
			cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="width">$rdp_screen_width</param>
		 <param name="height">$rdp_screen_height</param>
       </connection>
    </authorize>
</user-mapping>
END
		fi
	else
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>vnc</protocol>
         <param name="hostname">localhost</param>
         <param name="port">5901</param>
         <param name="password">$vnc_password</param>
       </connection>
    </authorize>
</user-mapping>
END
	fi
        cat > /etc/hosts << END
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts

# ::1     localhost ip6-localhost ip6-loopback
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
END
	systemctl restart tomcat9 guacd
	say @B"Guacamole配置成功！" green
	echo 
}

function configure_guacamole_centos
{
	echo 
	mkdir /etc/guacamole/
	cat > /etc/guacamole/guacamole.properties <<END
guacd-hostname: 127.0.0.1
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
END
	if [ $set_rdp_resolution = 0 ] ; then
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="security">rdp</param>
       </connection>
    </authorize>
</user-mapping>
END
	else
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="width">$rdp_screen_width</param>
		 <param name="height">$rdp_screen_height</param>
		 <param name="security">rdp</param>
       </connection>
    </authorize>
</user-mapping>
END
	fi
        cat > /etc/hosts << END
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts

# ::1     localhost ip6-localhost ip6-loopback
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
END
	systemctl restart tomcat9 guacd
	say @B"Guacamole配置成功！" green
	echo 
}

function install_vnc
{
	echo 
	echo "开始安装桌面环境，Firefox浏览器，以及VNC服务器..."
	say @B"如果系统提示您配置LightDM，您可以直接按回车键。" yellow
	echo 
	echo "请按回车键继续。"
	read catch_all
	echo 
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr tigervnc-standalone-server tigervnc-common -y
	else 
		apt-get install xfce4 xfce4-goodies firefox tigervnc-standalone-server tigervnc-common -y
	fi
	say @B"桌面环境，浏览器，以及VNC服务器安装成功。" green
	echo "开始配置VNC服务器..."
	sleep 2
	echo 
	mkdir $HomeDir/.vnc
	cat > $HomeDir/.vnc/xstartup <<END
#!/bin/bash

xrdb $HomeDir/.Xresources
startxfce4 &
END
	cat > /etc/systemd/system/vncserver@.service <<END
[Unit]
Description=a wrapper to launch an X server for VNC
After=syslog.target network.target

[Service]
Type=forking
User=$CurrentUser
Group=$CurrentUser
WorkingDirectory=$HomeDir

ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
END
	vncpassbinpath=/usr/bin/vncpasswd
	/usr/bin/expect <<END
spawn "$vncpassbinpath"
expect "Password:"
send "$vnc_password\r"
expect "Verify:"
send "$vnc_password\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
exit
END
	vncserver
	sleep 2
	vncserver -kill :1
	systemctl start vncserver@1.service
	systemctl enable vncserver@1.service
	/usr/bin/vncconfig -display :1 &
	cat > $HomeDir/Desktop/EnableCopyPaste.sh <<END
#!/bin/bash
/usr/bin/vncconfig -display :1 &
END
	chmod +x $HomeDir/Desktop/EnableCopyPaste.sh
	echo 
	ss -lnpt | grep vnc > /dev/null
	if [ $? = 0 ] ; then
		say @B"VNC与远程桌面配置成功！" green
		echo 
	else
		say "VNC安装失败！" red
		say @B"请检查上面的日志。" yellow
		show_feedback
	fi
}

function install_rdp
{
	echo 
	echo "开始安装桌面环境，Firefox浏览器，以及XRDP服务器..."
	if [ "$OS" = "UBUNTU18" ] || [ "$OS" = "DEBIAN" ] ; then
		say @B"如果系统提示您配置LightDM，您可以直接按回车键。" yellow
		echo 
		echo "请按回车键继续。"
		read catch_all
		echo
	fi
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr xrdp -y
	elif [ "$OS" = "RHEL8" ] || [ "$OS" = "CENTOS7" ] ; then
		yum -y groupinstall "Server with GUI"
		yum -y install firefox
		compile_xrdp_centos
		yum -y install xorgxrdp
		echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
	else
		apt-get install xfce4 xfce4-goodies firefox xrdp -y
	fi
	say @B"桌面环境，浏览器，以及XRDP服务器安装成功。" green
	echo "开始配置XRDP服务器..."
	sleep 2
	echo 
	if [ "$OS" != "CENTOS7" ] && [ "$OS" != "RHEL8" ] ; then
		mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.backup
		cat > /etc/xrdp/startwm.sh <<END
#!/bin/sh
# xrdp X session start script (c) 2015, 2017 mirabilos
# published under The MirOS Licence

if test -r /etc/profile; then
        . /etc/profile
fi

if test -r /etc/default/locale; then
        . /etc/default/locale
        test -z "${LANG+x}" || export LANG
        test -z "${LANGUAGE+x}" || export LANGUAGE
        test -z "${LC_ADDRESS+x}" || export LC_ADDRESS
        test -z "${LC_ALL+x}" || export LC_ALL
        test -z "${LC_COLLATE+x}" || export LC_COLLATE
        test -z "${LC_CTYPE+x}" || export LC_CTYPE
        test -z "${LC_IDENTIFICATION+x}" || export LC_IDENTIFICATION
        test -z "${LC_MEASUREMENT+x}" || export LC_MEASUREMENT
        test -z "${LC_MESSAGES+x}" || export LC_MESSAGES
        test -z "${LC_MONETARY+x}" || export LC_MONETARY
        test -z "${LC_NAME+x}" || export LC_NAME
        test -z "${LC_NUMERIC+x}" || export LC_NUMERIC
        test -z "${LC_PAPER+x}" || export LC_PAPER
        test -z "${LC_TELEPHONE+x}" || export LC_TELEPHONE
        test -z "${LC_TIME+x}" || export LC_TIME
        test -z "${LOCPATH+x}" || export LOCPATH
fi

if test -r /etc/profile; then
        . /etc/profile
fi

 xfce4-session

test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession

END
		chmod +x /etc/xrdp/startwm.sh
	fi
	systemctl enable xrdp
	systemctl restart xrdp
	sleep 5
	echo "等待启动XRDP服务器..."
	systemctl restart guacd
	cat > /etc/systemd/system/restartguacd.service <<END
[Unit]
Descript=Restart GUACD

[Service]
ExecStart=/etc/init.d/guacd start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

END
	systemctl daemon-reload
	systemctl enable restartguacd
	ss -lnpt | grep xrdp > /dev/null
	if [ $? = 0 ] ; then
		ss -lnpt | grep guacd > /dev/null
		if [ $? = 0 ] ; then
			say @B"XRDP与桌面环境配置成功!" green
		else 
			say @B"XRDP与桌面环境配置成功!" green
			sleep 3
			systemctl start guacd
		fi
		echo 
	else
		say "XRDP安装失败!" red
		say @B"请检查上面的日志。" yellow
		show_feedback
	fi
}

function compile_xrdp_centos
{
	if [ "$OS" = "CENTOS7" ] ; then
		yum -y install firefox finger cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file pam-devel libX11-devel libXfixes-devel libjpeg-devel libXrandr-devel nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils xmlto-tex
	else
		dnf -y --enablerepo=PowerTools install firefox cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file pam-devel libX11-devel libXfixes-devel libjpeg-devel libXrandr-devel nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils
	fi
	echo 
	say @B"开始编译安装xrdp..." yellow
	sleep 2
	cd $CurrentDir
	git clone --recursive https://github.com/neutrinolabs/xrdp.git
	cd xrdp
	./bootstrap
	./configure
	if [ -f $CurrentDir/xrdp/config.status ] ; then
		say @B"编译条件已满足！" green
		say @B"开始编译源码..." green
		echo
	else
		echo 
		say "依赖环境缺失。" red
		echo "请核查日志，安装必要的依赖环境，并再次运行此脚本。"
		show_feedback
	fi
	sleep 2
	make
	make install
	systemctl start xrdp
	echo 
	ss -lnpt | grep xrdp >/dev/null
	if [ $? = 0 ] ; then
		say @B"XRDP安装成功！" green
		echo 
	else 
		say "XRDP安装失败!" red
		say @B"请检查上面的日志。" yellow
		show_feedback
	fi
}

function display_license
{
	echo 
	echo '*******************************************************************'
	echo '*       One-click Desktop & Browser Access Setup Script           *'
	echo '*       Version 0.2.0                                             *'
	echo '*       Author: shc (Har-Kuun) https://qing.su                    *'
	echo '*       https://github.com/Har-Kuun/OneClickDesktop               *'
	echo '*       Thank you for using this script.  E-mail: hi@qing.su      *'
	echo '*******************************************************************'
	echo 
}

function install_reverse_proxy
{
	echo 
	say @B"安装Caddy反代..." yellow
	sleep 2
	if [ "$OS" = "RHEL8" ] ; then
		dnf install -y 'dnf-command(copr)'
		dnf copr enable @caddy/caddy -y
		dnf install caddy -y
	elif [ "$OS" = "CENTOS7" ] ; then
		yum install -y yum-plugin-copr
		yum copr enable @caddy/caddy -y
		yum install caddy -y
	else
		sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
                curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
                apt-get install -y caddy
	fi
                systemctl stop caddy
		say @B"Caddy安装成功！" green
	if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
	   cat > /etc/caddy/Caddyfile << END
{
     
 	# TLS options
     email $le_email
}
$guacamole_hostname {
     reverse_proxy http://localhost:8080
     rewrite / /guacamole
}
END
	   systemctl start caddy
           echo 
           if [ -f /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/$guacamole_hostname/$guacamole_hostname.crt ] ; then
	        say @B"恭喜！Let's Encrypt SSL证书安装成功！" green
		say @B"开始使用您的远程桌面，请在浏览器中访问 https://${guacamole_hostname}!" green
	   else
		say "Let's Encrypt SSL证书安装失败。" red
		say @B"请查看caddy 日志" yellow
		say @B"开始使用您的远程桌面，请在浏览器中访问 http://${guacamole_hostname}!" green
	   fi
        else
 		cat > /etc/caddy/Caddyfile << END
{
     
 	# TLS options
     email $le_email
     auto_https off
}
$guacamole_hostname {
    reverse_proxy http://localhost:8080
    rewrite / /guacamole
}
END
                say @B"Let's Encrypt证书未安装，如果您之后需要安装Let's Encrypt证书，请手动更改Caddyfile，位于/etc/caddy/Caddyfile" yellow
		say @B"开始使用您的远程桌面，请在浏览器中访问 http://${guacamole_hostname}!" green
	fi
	say @B"您的Guacamole用户名是$guacamole_username，您的Guacamole密码是$guacamole_password_prehash." green
}

function main
{
	display_license
	if [ "x$OS_CHECK_ENABLED" != "xOFF" ] ; then
		check_OS
	fi
	echo "此脚本将在本服务器上安装一个桌面环境。您可以随时随地在浏览器上使用这个桌面环境。"
	echo 
	if [ "$OS" = "CENTOS7" ] || [ "$OS" = "RHEL8" ] ; then
		say @B"此桌面环境需要至少1.5 GB内存。" yellow
	else
		say @B"此桌面环境需要至少1 GB内存。" yellow
	fi
	echo 
	echo "请问是否继续？ [Y/N]"
	read confirm_installation
	if [ "x$confirm_installation" = "xY" ] || [ "x$confirm_installation" = "xy" ] ; then
		determine_system_variables
		get_user_options
		if [ "$OS" = "CENTOS7" ] || [ "$OS" = "RHEL8" ] ; then
			install_guacamole_centos
		else
			install_guacamole_ubuntu_debian
		fi
		install_guacamole_web
		if [ "$OS" = "CENTOS7" ] || [ "$OS" = "RHEL8" ] ; then
			configure_guacamole_centos
		else
			configure_guacamole_ubuntu_debian
		fi
		if [ $choice_rdpvnc = 1 ] ; then
			install_rdp
		else
			install_vnc
		fi
		if [ "x$install_caddy" != "xn" ] && [ "x$install_caddy" != "xN" ] ; then
			install_reverse_proxy
		else
			say @B"开始使用您的远程桌面，请在浏览器中访问 http://$(curl -s icanhazip.com):8080/guacamole!" green
			say @B"您的Guacamole用户名是$guacamole_username，密码是 $guacamole_password_prehash。" green
		fi
		if [ $choice_rdpvnc = 1 ] ; then
			echo 
			say @B"请注意，使用上述用户名与密码登录Guacamole后，您还会需要在XRDP登录界面输入Linux系统用户名与密码,比如root用户。Session Type请选择默认的Xorg。" yellow
		fi
	fi
	echo 
	echo "感谢您的使用！此脚本作者为https://qing.su,现维护者 https://github.com/york618"
	echo "祝您生活愉快！"
}

###############################################################
#                                                             #
#               The main function starts here.                #
#                                                             #
###############################################################

main
exit 0
