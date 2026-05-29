# ====================== 基础镜像 ======================
FROM ubuntu/python:3.13-25.10_stable

# 设置工作目录
WORKDIR /app

# ==================== 系统依赖安装 ====================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 浏览器和 pyppeteer 必需依赖
    chromium  nss freetype harfbuzz ca-certificates ttf-freefont font-noto-cjk

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
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# ==================== 启动命令 ====================
COPY . .

# 使用 xvfb 启动（支持 pyautogui + pyppeteer）
CMD ["sh", "-c", "xvfb-run -a --server-args='-screen 0 1920x1080x24' python main.py"]
