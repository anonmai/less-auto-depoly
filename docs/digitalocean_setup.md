# DigitalOcean服务器购买与配置指南

## 1. 注册DigitalOcean账号

1. 访问 [DigitalOcean官网](https://www.digitalocean.com/)
2. 点击右上角的「Sign Up」按钮
3. 填写邮箱地址、创建密码，或使用Google/GitHub账号登录
4. 验证邮箱地址
5. 填写个人信息并添加支付方式（信用卡或PayPal）

## 2. 创建Droplet（VPS服务器）

1. 登录DigitalOcean控制台
2. 点击「Create」按钮，选择「Droplets」

### 2.1 选择操作系统

- 在「Choose an Image」部分，选择「Ubuntu」
- 推荐选择最新的LTS版本（如Ubuntu 22.04 LTS）

### 2.2 选择计划

- 根据需求选择合适的计划：
  - **Basic**：适合个人使用，最低配置即可
  - **Premium CPU**：适合更高性能需求
  - **Storage Optimized**：适合存储密集型应用

### 2.3 选择配置

- **CPU/内存**：推荐至少1GB内存
- **存储**：默认25GB SSD足够使用
- **流量**：默认1TB/月足够使用

### 2.4 选择数据中心

- 选择距离您最近的数据中心，以获得更低的延迟
- 常用选项：
  - 亚洲：Singapore (sgp1)、Tokyo (nrt1)
  - 欧洲：Frankfurt (fra1)、London (lon1)
  - 美国：New York (nyc1-3)、San Francisco (sfo1-3)

### 2.5 认证方式

- **SSH Keys**：推荐使用SSH密钥认证，更安全
  - 点击「New SSH Key」
  - 输入SSH密钥名称
  - 粘贴您的公钥（通常在`~/.ssh/id_rsa.pub`）
  - 点击「Add SSH Key」
- **Password**：也可以设置密码认证，但安全性较低

### 2.6 其他选项

- **Hostname**：为服务器设置一个名称
- **Tags**：可选，用于分类和管理服务器
- **VPC Network**：使用默认设置即可
- **Backups**：可选，建议启用自动备份
- **Monitoring**：建议启用，可监控服务器状态
- **IPV6**：建议启用

### 2.7 创建Droplet

- 点击「Create Droplet」按钮
- 等待服务器创建完成（通常需要1-2分钟）

## 3. 连接到服务器

### 3.1 获取服务器IP地址

- 在DigitalOcean控制台的Droplets页面，找到您刚创建的服务器
- 记录服务器的公共IP地址

### 3.2 使用SSH连接

**Windows用户**：
1. 使用PuTTY或Windows Terminal
2. 输入服务器IP地址
3. 端口：22
4. 连接类型：SSH
5. 点击「Open」
6. 用户名：root
7. 如果使用SSH密钥，PuTTY会自动使用您的私钥
8. 如果使用密码，输入您设置的密码

**Mac/Linux用户**：
1. 打开终端
2. 运行命令：`ssh root@服务器IP地址`
3. 如果使用SSH密钥，会自动使用您的私钥
4. 如果使用密码，输入您设置的密码

## 4. 服务器初始配置

### 4.1 更新系统

连接到服务器后，首先更新系统：

```bash
apt update && apt upgrade -y
```

### 4.2 创建非root用户（推荐）

为了安全起见，创建一个非root用户：

```bash
# 创建用户
adduser yourusername

# 添加到sudo组
usermod -aG sudo yourusername

# 复制SSH密钥到新用户
mkdir -p /home/yourusername/.ssh
cp /root/.ssh/authorized_keys /home/yourusername/.ssh/
chown -R yourusername:yourusername /home/yourusername/.ssh
chmod 700 /home/yourusername/.ssh
chmod 600 /home/yourusername/.ssh/authorized_keys
```

### 4.3 配置防火墙

```bash
# 安装ufw
apt install ufw -y

# 允许SSH
ufw allow ssh

# 允许HTTP/HTTPS（如果需要）
ufw allow 80/tcp
ufw allow 443/tcp

# 启用防火墙
ufw enable

# 查看状态
ufw status
```

## 5. 部署VPN服务

现在服务器已经准备就绪，可以部署我们的VPN服务了：

1. 下载部署脚本：
   ```bash
   wget https://raw.githubusercontent.com/yourusername/vpn-autodeploy/main/scripts/install.sh
   ```

2. 赋予执行权限：
   ```bash
   chmod +x install.sh
   ```

3. 运行部署脚本：
   ```bash
   sudo ./install.sh
   ```

4. 按照脚本提示完成配置

## 6. 管理服务器

### 6.1 查看服务器状态

在DigitalOcean控制台，您可以：
- 查看服务器CPU、内存、磁盘使用情况
- 查看网络流量
- 重启/关闭服务器
- 调整服务器配置
- 创建快照

### 6.2 常见操作

**重启服务器**：
```bash
reboot
```

**关闭服务器**：
```bash
shutdown -h now
```

**查看系统负载**：
```bash
uptime
```

**查看磁盘使用情况**：
```bash
df -h
```

## 7. 故障排除

### 7.1 无法连接到服务器

- 检查服务器状态是否为「Active」
- 检查防火墙是否允许SSH连接
- 检查本地网络连接
- 尝试使用DigitalOcean控制台的「Access」选项卡中的「Launch Droplet Console」

### 7.2 服务器性能问题

- 检查系统负载：`uptime`
- 检查内存使用：`free -m`
- 检查进程：`top`
- 考虑升级服务器配置

### 7.3 网络问题

- 检查网络连接：`ping google.com`
- 检查防火墙规则：`ufw status`
- 检查端口是否开放：`netstat -tuln`

## 8. 费用管理

- DigitalOcean采用按小时计费方式
- 您可以在控制台的「Billing」部分查看费用
- 建议设置预算提醒，避免意外费用
- 当不使用服务器时，可以关闭或删除Droplet以节省费用

## 9. 总结

通过以上步骤，您可以在DigitalOcean上成功购买并配置服务器，为部署VPN服务做好准备。如果您遇到任何问题，可以参考DigitalOcean的官方文档或联系他们的支持团队。