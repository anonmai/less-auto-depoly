# VPN自动部署程序

## 项目概述

本项目旨在提供一个基于Ubuntu环境的VPN自动部署程序，使用VLESS+REALITY协议提高抗封锁能力，并为Windows和iOS客户端提供详细的配置说明。

## 功能特点

- 服务器端自动脚本部署（支持Ubuntu 18.04+）
- 使用VLESS+REALITY协议，增强抗封锁能力
- 为Windows客户端提供V2RayN配置说明
- 为iOS客户端提供Shadowrocket配置说明
- 一键安装，自动配置所有必要组件

## 部署环境

- Ubuntu 18.04+
- Ubuntu 20.04+（推荐）
- Ubuntu 22.04+（推荐）

## 部署步骤

### 1. 准备服务器

准备一台Ubuntu VPS服务器，确保服务器可以正常访问互联网。

### 2. 连接服务器

使用SSH终端连接到服务器：

**Windows用户**：
- 使用PuTTY或Windows Terminal
- 输入服务器IP地址
- 端口：22
- 用户名：root
- 输入密码或使用SSH密钥

**Mac/Linux用户**：
```bash
ssh root@服务器IP地址
```

### 3. 从仓库下载部署脚本

**方法一：直接下载脚本**
```bash
# 下载脚本
wget https://raw.githubusercontent.com/anonmai/less-auto-depoly/main/scripts/install.sh

# 赋予执行权限
chmod +x install.sh

# 运行脚本
sudo ./install.sh
```

**方法二：克隆整个仓库**
```bash
# 安装git（如果未安装）
apt install git -y

# 克隆仓库
git clone https://github.com/anonmai/less-auto-depoly.git

# 进入目录
cd less-auto-depoly

# 赋予执行权限
chmod +x scripts/install.sh

# 运行脚本
sudo ./scripts/install.sh
```

### 3. 配置参数

根据脚本提示，输入以下参数：
- 服务端口（默认443）
- 伪装域名（默认www.microsoft.com）

### 4. 获取客户端配置

部署完成后，脚本会显示客户端配置信息，包括：
- 服务器地址
- 端口
- UUID
- 公钥
- 短ID
- SNI

### 5. 配置客户端

根据客户端类型，参考相应的配置说明：
- [Windows客户端配置](clients/windows.md)
- [iOS客户端配置](clients/ios.md)

## 技术原理

### VLESS+REALITY协议

VLESS是一种轻量级的代理协议，REALITY是一种基于TLS 1.3的伪装技术，两者结合可以有效规避深度包检测，提高抗封锁能力。

### 加密策略

- 使用AEAD加密算法
- 利用REALITY技术模拟真实网站的TLS握手
- 默认使用443端口（HTTPS），减少被检测的风险

## 安全考虑

- 不记录用户连接日志
- 使用强加密算法
- 定期更新系统和软件
- 配置防火墙规则

## 故障排除

### 常见问题

1. **连接失败**
   - 检查服务器地址、端口是否正确
   - 检查UUID、公钥、短ID是否正确
   - 检查服务器防火墙是否开放相应端口

2. **速度慢**
   - 尝试更换服务器
   - 检查网络带宽
   - 调整客户端设置

3. **无法访问某些网站**
   - 检查代理规则设置
   - 尝试清除浏览器缓存

### 查看日志

```bash
# 查看Xray日志
sudo journalctl -u xray
```

## 后续计划

- 支持更多客户端平台
- 开发Web管理界面
- 实现多服务器负载均衡
- 优化性能和安全性

## 许可证

MIT License

## 免责声明

本项目仅用于学习和研究目的，请勿用于非法用途。使用本项目产生的一切后果由使用者自行承担。