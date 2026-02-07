#!/bin/bash
set -e

# --- 1. 处理 SSH 密码 ---
if [ -n "$SSH_PASSWORD" ]; then
    echo "root:$SSH_PASSWORD" | chpasswd
    echo "SSH password set."
else
    # 如果没设变量，默认密码为 debian
    echo "root:debian" | chpasswd
    echo "No SSH_PASSWORD set, using default: debian"
fi

# --- 2. 处理 SSH 公钥 (新增) ---
if [ -n "$SSH_PUBKEY" ]; then
    mkdir -p /root/.ssh
    echo "$SSH_PUBKEY" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    # 确保文件属主正确
    chown -R root:root /root/.ssh
    echo "SSH Public Key imported from environment variable."
fi

# --- 3. 哪吒 Agent 启动逻辑 ---
if [ -n "$NZ_SERVER" ] && [ -n "$NZ_CLIENT_SECRET" ]; then
    echo "Installing Nezha Agent..."
    curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh
    
    if [ "$NZ_TLS" = "true" ]; then
        echo "Starting Agent with TLS..."
        env NZ_SERVER="$NZ_SERVER" NZ_TLS=true NZ_CLIENT_SECRET="$NZ_CLIENT_SECRET" ./agent.sh install_run &
    else
        echo "Starting Agent without TLS..."
        env NZ_SERVER="$NZ_SERVER" NZ_CLIENT_SECRET="$NZ_CLIENT_SECRET" ./agent.sh install_run &
    fi
    echo "Nezha Agent is running in background."
fi

# 启动 SSH 服务
echo "Starting SSH server..."
exec /usr/sbin/sshd -D