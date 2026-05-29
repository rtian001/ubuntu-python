# ====================== 基础镜像 ======================
FROM ubuntu/python:3.13-25.10_stable

# 设置工作目录
WORKDIR /app

# ==================== 系统依赖安装 ====================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 浏览器和 pyppeteer 必需依赖
    chromium \
    chromium-driver \
    xvfb \
    libx11-6 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxtst6 \
    libnss3 \
    libglib2.0-0 \
    libgtk-3-0 \
    libasound2 \
    libxrandr2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcb1 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxshmfence1 \
    libxss1 \
    # 字体支持（避免中文乱码等问题）
    fonts-liberation \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    && rm -rf /var/lib/apt/lists/*

# ==================== Python 依赖安装 ====================
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    pyppeteer \
    pyautogui \
    pillow \
    opencv-python-headless

# 预下载 Chromium（加快后续启动速度）
RUN python -c "
import asyncio
from pyppeteer import launch
async def download_chromium():
    browser = await launch(headless=True, args=['--no-sandbox'])
    await browser.close()
asyncio.run(download_chromium())
print('Chromium downloaded successfully')
"

# ==================== 环境变量 ====================
ENV DISPLAY=:99 \
    PYTHONUNBUFFERED=1 \
    PYPPETEER_CHROMIUM_REVISION=latest \
    # 避免沙箱问题（Docker 常用）
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# ==================== 启动命令 ====================
COPY . .

# 使用 xvfb 启动（支持 pyautogui + pyppeteer）
CMD ["sh", "-c", "xvfb-run -a --server-args='-screen 0 1920x1080x24' python main.py"]
