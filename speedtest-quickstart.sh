#!/bin/bash

_INSTALL(){
# 获取系统架构
ARCH=$(uname -m)

# 判断架构并执行
if [[ "$ARCH" == "x86_64" ]]; then
		echo "检测到架构: amd64 (x86_64)"
		cd /usr/local/
		rm -rf /usr/local/speedtest-go
		wget -N --no-check-certificate https://raw.githubusercontent.com/DongfeiSay/Repository/main/speedtest-go.zip && unzip -q speedtest-go.zip && rm -rf speedtest-go.zip
elif [[ "$ARCH" == "aarch64" ]]; then
		echo "检测到架构: arm64 (aarch64)"
		cd /usr/local/
		rm -rf /usr/local/speedtest-go
		wget -N --no-check-certificate https://raw.githubusercontent.com/DongfeiSay/Repository/main/arm64/speedtest-go.zip && unzip -q speedtest-go.zip && rm -rf speedtest-go.zip
else
		echo "未知架构: $ARCH，退出脚本"
		exit 1
fi

while true
	do
	echo -e "请输入 LibreSpeed 服务监听的端口[1-65535]"
	read -e -p "(默认: 80):" server_port_s
	[[ -z "$server_port_s" ]] && server_port_s="80"
	echo $((${server_port_s}+0)) &>/dev/null
	if [[ $? -eq 0 ]]; then
		if [[ ${server_port_s} -ge 1 ]] && [[ ${server_port_s} -le 65535 ]]; then
			echo && echo "	================================================"
			echo -e "	端口: ${server_port_s}"
			echo "	================================================" && echo
			break
		else
			echo "输入错误, 请输入正确的端口。"
		fi
	else
		echo "输入错误, 请输入正确的端口。"
	fi
done

cat > /usr/local/speedtest-go/settings.toml <<-EOF
bind_address="0.0.0.0"
listen_port=${server_port_s}
assets_path="./assets"
EOF

cat > /etc/systemd/system/speedtest-go.service <<-EOF
[Unit]
Description=speedtest-go service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/speedtest-go/
ExecStart=/usr/local/speedtest-go/speedtest-backend
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload
	systemctl restart speedtest-go
	systemctl enable speedtest-go
	echo "LibreSpeed 安装完成并已启动！"
}


_UNINSTALL(){
	systemctl stop speedtest-go
	systemctl disable speedtest-go
	rm -rf /usr/local/speedtest-go
	rm -rf /etc/systemd/system/speedtest-go.service
	systemctl daemon-reload
	echo "LibreSpeed 卸载完成"
}


echo "1.安装 LibreSpeed"
echo "2.卸载 LibreSpeed"
echo
read -e -p "请输入数字：" num
case "$num" in
	1)
	_INSTALL
	;;
	2)
	_UNINSTALL
	;;
	*)
	echo "请输入正确的数字"
	;;
esac
