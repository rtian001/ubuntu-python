# ====================== 基础镜像 ======================
FROM ubuntu/python:3.13-25.10_stable

# 设置工作目录
WORKDIR /app

# ==================== 系统依赖安装（去除 chromium 包）===================
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    libx11-6 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
    libxfixes3 libxi6 libxtst6 libnss3 libglib2.0-0 libgtk-3-0 \
    libasound2 libxrandr2 libpangocairo-1.0-0 libatk1.0-0 \
    libatk-bridge2.0-0 libdrm2 libxcb1 libxkbcommon0 libatspi2.0-0 \
    libxshmfence1 libxss1 \
    ca-certificates \
    fonts-liberation fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei \
    && rm -rf /var/lib/apt/lists/*
    
# ==================== Python 依赖安装 ====================
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    pyppeteer \
    pyautogui \
    pillow \
    opencv-python-headless


# ==================== 环境变量 ====================
ENV DISPLAY=:99 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PYPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
    PYPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# ==================== 启动命令 ====================
COPY . .

# 使用 xvfb 启动（支持 pyautogui + pyppeteer）
CMD ["sh", "-c", "xvfb-run -a --server-args='-screen 0 1920x1080x24' python main.py"]
