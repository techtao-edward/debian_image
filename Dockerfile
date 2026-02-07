# 使用轻量级的 Debian 镜像作为基础
FROM debian:stable-slim

# 设置环境变量，避免交互式安装时的提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装 SSH 和哪吒所需的依赖
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    ca-certificates \
    unzip \
    iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置 SSH
# 允许 root 登录（可选，根据 vevc 原仓库逻辑通常支持环境变量修改密码）
RUN mkdir -p /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# 暴露 SSH 端口
EXPOSE 22

# 使用脚本启动，以便在启动时处理密码设置等逻辑
ENTRYPOINT ["/entrypoint.sh"]