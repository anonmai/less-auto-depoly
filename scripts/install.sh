#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}    VPN自动部署脚本 (VLESS+REALITY)${NC}"
echo -e "${GREEN}==============================================${NC}"

# 检查操作系统
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        echo -e "${RED}错误: 无法检测操作系统${NC}"
        exit 1
    fi

    if [ "$OS" != "ubuntu" ]; then
        echo -e "${RED}错误: 仅支持Ubuntu操作系统${NC}"
        exit 1
    fi

    if (( $(echo "$VER < 18.04" | bc -l) )); then
        echo -e "${RED}错误: Ubuntu版本需要18.04或更高${NC}"
        exit 1
    fi

    echo -e "${GREEN}检测到Ubuntu $VER，符合要求${NC}"
}

# 检查硬件资源
check_hardware() {
    echo -e "${YELLOW}检查硬件资源...${NC}"
    
    # 检查内存
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    if [ "$MEM_TOTAL" -lt 512 ]; then
        echo -e "${YELLOW}警告: 内存不足512MB，可能影响性能${NC}"
    else
        echo -e "${GREEN}内存: ${MEM_TOTAL}MB，符合要求${NC}"
    fi
    
    # 检查CPU
    CPU_CORES=$(nproc)
    echo -e "${GREEN}CPU核心数: ${CPU_CORES}${NC}"
    
    # 检查磁盘
    DISK_FREE=$(df -h / | awk '/\// {print $4}')
    echo -e "${GREEN}磁盘可用空间: ${DISK_FREE}${NC}"
}

# 检查网络
check_network() {
    echo -e "${YELLOW}检查网络连接...${NC}"
    if ping -c 1 google.com > /dev/null 2>&1; then
        echo -e "${GREEN}网络连接正常${NC}"
    else
        echo -e "${RED}错误: 网络连接失败${NC}"
        exit 1
    fi
}

# 安装依赖
install_dependencies() {
    echo -e "${YELLOW}安装依赖包...${NC}"
    apt update && apt install -y curl wget unzip uuid-runtime qrencode
}

# 安装Xray
install_xray() {
    echo -e "${YELLOW}安装Xray-core...${NC}"
    # 使用官方推荐的安装脚本
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    # 如果上面的命令失败，尝试手动安装
    if [ ! -f "/usr/local/bin/xray" ]; then
        echo -e "${YELLOW}尝试手动安装Xray-core...${NC}"
        TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"
        
        # 下载最新版本的Xray
        wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
        
        # 解压
        unzip Xray-linux-64.zip
        
        # 安装
        cp xray /usr/local/bin/
        chmod +x /usr/local/bin/xray
        
        # 创建配置目录
        mkdir -p /usr/local/etc/xray
        
        # 清理
        cd /
        rm -rf "$TMP_DIR"
    fi
}

# 生成配置
generate_config() {
    echo -e "${YELLOW}生成配置文件...${NC}"
    
    # 生成UUID
    UUID=$(uuidgen)
    
    # 生成REALITY密钥
    XRAY_BIN=$(which xray)
    if [ -z "$XRAY_BIN" ]; then
        XRAY_BIN="/usr/local/bin/xray"
    fi
    REALITY_KEYS=$($XRAY_BIN x25519)
    # 提取密钥（支持不同版本的输出格式）
    PRIVATE_KEY=$(echo "$REALITY_KEYS" | grep -E "PrivateKey:|Private key:" | awk '{print $2}')
    PUBLIC_KEY=$(echo "$REALITY_KEYS" | grep -E "Password \(PublicKey\):|Public key:" | awk '{print $3}')
    
    # 生成短ID
    SHORT_ID=$(openssl rand -hex 8)
    
    # 配置端口
    read -p "请输入服务端口 (默认443): " PORT
    PORT=${PORT:-443}
    
    # 配置伪装域名
    read -p "请输入伪装域名 (默认www.microsoft.com): " SNI
    SNI=${SNI:-www.microsoft.com}
    
    # 生成配置文件
    CONFIG_FILE="/usr/local/etc/xray/config.json"
    cat > $CONFIG_FILE << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": ""
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$SNI:443",
          "xver": 0,
          "serverNames": ["$SNI"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["$SHORT_ID"],
          "fingerprint": "chrome"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
    
    echo -e "${GREEN}配置文件生成成功${NC}"
    
    # 配置防火墙
    echo -e "${YELLOW}配置防火墙...${NC}"
    ufw allow $PORT/tcp || echo -e "${YELLOW}警告: 防火墙配置失败，可能需要手动配置${NC}"
    
    # 重启Xray服务
    echo -e "${YELLOW}重启Xray服务...${NC}"
    systemctl restart xray || echo -e "${YELLOW}警告: Xray服务重启失败，可能需要手动启动${NC}"
    
    # 显示客户端配置信息
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}        客户端配置信息${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${YELLOW}协议:${NC} VLESS"
    echo -e "${YELLOW}地址:${NC} $(curl -s ifconfig.me)"
    echo -e "${YELLOW}端口:${NC} $PORT"
    echo -e "${YELLOW}UUID:${NC} $UUID"
    echo -e "${YELLOW}传输:${NC} tcp"
    echo -e "${YELLOW}TLS:${NC} 开启"
    echo -e "${YELLOW}SNI:${NC} $SNI"
    echo -e "${YELLOW}ALPN:${NC} h2,http/1.1"
    echo -e "${YELLOW}REALITY:${NC} 开启"
    echo -e "${YELLOW}公钥:${NC} $PUBLIC_KEY"
    echo -e "${YELLOW}短ID:${NC} $SHORT_ID"
    echo -e "${GREEN}==============================================${NC}"
    
    # 生成VLESS链接
    VLESS_LINK="vless://$UUID@$(curl -s ifconfig.me):$PORT?security=reality&encryption=none&type=tcp&sni=$SNI&alpn=h2%2Chttp%2F1.1&reality-pubkey=$PUBLIC_KEY&reality-shortId=$SHORT_ID"
    echo -e "${YELLOW}VLESS链接:${NC}"
    echo -e "$VLESS_LINK"
    echo -e "${GREEN}==============================================${NC}"
    
    # 生成二维码
    echo -e "${YELLOW}二维码:${NC}"
    echo -e "$VLESS_LINK" | qrencode -t ANSI
}

# 主函数
main() {
    check_os
    check_hardware
    check_network
    install_dependencies
    install_xray
    generate_config
    
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${GREEN}    部署完成！${NC}"
    echo -e "${GREEN}==============================================${NC}"
    echo -e "${YELLOW}请使用上述配置信息在客户端添加服务器${NC}"
}

# 执行主函数
main