#!/bin/bash

# 爱家影视 环境安装和构建脚本
# 一键安装 Flutter 环境并构建 APK

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否已安装 Homebrew
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加 Homebrew 到 PATH
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        log_success "Homebrew 安装完成"
    else
        log_success "Homebrew 已安装"
    fi
}

# 安装 Java
install_java() {
    log_info "检查 Java 环境..."
    if ! command -v java &> /dev/null; then
        log_info "正在安装 OpenJDK 17..."
        brew install openjdk@17
        
        # 链接 Java
        sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk \
            /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
        
        # 添加到环境变量
        echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
        echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
        
        log_success "Java 安装完成"
    else
        log_success "Java 已安装: $(java -version 2>&1 | head -n 1)"
    fi
}

# 安装 Flutter
install_flutter() {
    log_info "检查 Flutter 环境..."
    if ! command -v flutter &> /dev/null; then
        log_info "正在安装 Flutter..."
        brew install flutter
        
        # 添加到环境变量（如果还没有）
        if ! grep -q "flutter/bin" ~/.zshrc; then
            echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
        fi
        
        source ~/.zshrc 2>/dev/null || true
        log_success "Flutter 安装完成"
    else
        log_success "Flutter 已安装: $(flutter --version | head -n 1)"
    fi
}

# 安装 Android Studio
install_android_studio() {
    log_info "检查 Android Studio..."
    if [ ! -d "/Applications/Android Studio.app" ]; then
        log_info "正在安装 Android Studio..."
        log_warning "这可能需要一些时间，请耐心等待..."
        brew install --cask android-studio
        log_success "Android Studio 安装完成"
        log_warning "请手动打开 Android Studio 完成初始配置"
        log_warning "配置完成后按回车键继续..."
        read
    else
        log_success "Android Studio 已安装"
    fi
}

# 配置 Android SDK
configure_android_sdk() {
    log_info "配置 Android SDK..."
    
    # 设置环境变量
    if ! grep -q "ANDROID_HOME" ~/.zshrc; then
        echo 'export ANDROID_HOME="$HOME/Library/Android/sdk"' >> ~/.zshrc
        echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
    fi
    
    # 创建 local.properties 文件
    if [ ! -f "android/local.properties" ]; then
        echo "sdk.dir=$HOME/Library/Android/sdk" > android/local.properties
        log_success "已创建 android/local.properties"
    fi
    
    log_success "Android SDK 配置完成"
}

# 运行 Flutter doctor
check_flutter_doctor() {
    log_info "运行 Flutter 环境检查..."
    flutter doctor
    
    log_info "接受 Android SDK 许可..."
    flutter doctor --android-licenses || true
    
    log_success "Flutter 环境检查完成"
}

# 获取项目依赖
get_dependencies() {
    log_info "获取项目依赖..."
    flutter pub get
    log_success "依赖获取完成"
}

# 构建 APK
build_apk() {
    log_info "开始构建 Android APK..."
    log_warning "这可能需要 5-15 分钟，请耐心等待..."
    
    # 清理之前的构建
    flutter clean
    
    # 获取依赖
    flutter pub get
    
    # 构建 APK
    flutter build apk --release \
        --target-platform android-arm64,android-arm \
        --split-per-abi
    
    log_success "APK 构建完成！"
}

# 显示构建结果
show_results() {
    log_info "构建结果："
    echo ""
    
    if [ -d "build/app/outputs/flutter-apk" ]; then
        echo "📁 APK 文件位置："
        ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "未找到 APK 文件"
        echo ""
        
        # 复制到项目根目录
        mkdir -p dist
        cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk dist/爱家影视-arm64.apk 2>/dev/null || true
        cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk dist/爱家影视-armv7a.apk 2>/dev/null || true
        
        log_success "APK 文件已复制到 dist/ 目录"
    else
        log_error "未找到构建产物"
    fi
}

# 主函数
main() {
    echo "🚀 爱家影视 环境安装和构建脚本"
    echo "=================================="
    echo ""
    
    # 检查是否在项目目录
    if [ ! -f "pubspec.yaml" ]; then
        log_error "请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 询问用户
    echo "此脚本将："
    echo "1. 安装 Homebrew（如未安装）"
    echo "2. 安装 Java JDK"
    echo "3. 安装 Flutter SDK"
    echo "4. 安装 Android Studio"
    echo "5. 配置 Android SDK"
    echo "6. 构建 Android APK"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "已取消"
        exit 0
    fi
    
    # 执行安装和构建
    check_homebrew
    install_java
    install_flutter
    install_android_studio
    configure_android_sdk
    check_flutter_doctor
    get_dependencies
    build_apk
    show_results
    
    echo ""
    echo "=================================="
    log_success "全部完成！"
    echo ""
    echo "📱 APK 文件位置："
    echo "   - dist/爱家影视-arm64.apk (64位设备)"
    echo "   - dist/爱家影视-armv7a.apk (32位设备)"
    echo ""
    echo "💡 提示：首次安装可能需要重启终端使环境变量生效"
}

# 运行主函数
main "$@"
