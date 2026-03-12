#!/bin/bash

# 爱家影视 - macOS 12 完全兼容版安装脚本
# 使用系统兼容的Java版本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

PROJECT_DIR="/Users/ace/WorkBuddy/20260312162941/Selene-Source"

# 安装 Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
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

# 安装兼容的 Java 11 (macOS 12 更兼容)
install_java() {
    log_info "检查 Java 环境..."
    
    # 尝试安装 Java 11（更兼容的版本）
    if ! command -v java &> /dev/null 2>&1 || ! java -version 2>&1 | grep -q "11\|17"; then
        log_info "正在安装 OpenJDK 11（macOS 12 兼容版本）..."
        
        # 先尝试卸载可能冲突的版本
        brew uninstall openjdk@17 2>/dev/null || true
        
        # 安装 Java 11
        brew install openjdk@11 || {
            log_warning "Homebrew 安装失败，尝试手动安装..."
            install_java_manual
            return
        }
        
        # 链接到系统
        if [[ "$(uname -m)" == "arm64" ]]; then
            sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk \
                /Library/Java/JavaVirtualMachines/openjdk-11.jdk 2>/dev/null || true
            
            echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
            echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@11"' >> ~/.zshrc
        else
            sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk \
                /Library/Java/JavaVirtualMachines/openjdk-11.jdk 2>/dev/null || true
            
            echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
            echo 'export JAVA_HOME="/usr/local/opt/openjdk@11"' >> ~/.zshrc
        fi
        
        source ~/.zshrc 2>/dev/null || true
        log_success "Java 11 安装完成"
    else
        log_success "Java 已安装"
        java -version 2>&1 | head -n 1
    fi
}

# 手动安装 Java（备用方案）
install_java_manual() {
    log_info "手动下载安装 Java 11..."
    
    local java_url="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_x64_mac_hotspot_11.0.21_9.pkg"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        java_url="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_aarch64_mac_hotspot_11.0.21_9.pkg"
    fi
    
    cd /tmp
    curl -L -o OpenJDK11.pkg "$java_url"
    sudo installer -pkg OpenJDK11.pkg -target /
    rm OpenJDK11.pkg
    
    log_success "Java 11 手动安装完成"
}

# 使用系统自带的 Java（如果可用）
use_system_java() {
    log_info "尝试使用系统 Java..."
    
    # 检查是否有系统 Java
    if /usr/libexec/java_home -V 2>&1 | grep -q "Java"; then
        local java_home=$(/usr/libexec/java_home -v 11 2>/dev/null || /usr/libexec/java_home -v 1.8 2>/dev/null || /usr/libexec/java_home)
        echo "export JAVA_HOME=\"$java_home\"" >> ~/.zshrc
        echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
        log_success "已配置系统 Java: $java_home"
    else
        log_warning "未找到系统 Java"
    fi
}

# 安装 Flutter 3.16.9
install_flutter() {
    log_info "检查 Flutter..."
    if ! command -v flutter &> /dev/null; then
        log_info "正在安装 Flutter 3.16.9..."
        
        mkdir -p ~/development
        cd ~/development
        
        # 下载 Flutter
        log_info "下载 Flutter SDK（约 1GB）..."
        curl -L -o flutter.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.9-stable.zip"
        
        log_info "解压 Flutter..."
        unzip -q flutter.zip
        rm flutter.zip
        
        echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
        
        log_success "Flutter 安装完成"
    else
        log_success "Flutter 已安装"
    fi
}

# 配置 Android SDK（不依赖 Android Studio）
setup_android_sdk() {
    log_info "设置 Android SDK..."
    
    local sdk_dir="$HOME/Library/Android/sdk"
    mkdir -p "$sdk_dir"
    
    # 下载命令行工具
    if [ ! -d "$sdk_dir/cmdline-tools" ]; then
        log_info "下载 Android SDK 命令行工具..."
        cd /tmp
        curl -L -o commandlinetools.zip "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
        unzip -q commandlinetools.zip
        mkdir -p "$sdk_dir/cmdline-tools"
        mv cmdline-tools "$sdk_dir/cmdline-tools/latest"
        rm commandlinetools.zip
    fi
    
    # 设置环境变量
    echo 'export ANDROID_HOME="'$sdk_dir'"' >> ~/.zshrc
    echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
    source ~/.zshrc 2>/dev/null || true
    
    # 创建 local.properties
    echo "sdk.dir=$sdk_dir" > "$PROJECT_DIR/android/local.properties"
    
    log_success "Android SDK 配置完成"
}

# 安装必要的 SDK 组件
install_sdk_components() {
    log_info "安装 Android SDK 组件..."
    
    # 接受许可
    yes | sdkmanager --licenses 2>/dev/null || true
    
    # 安装必要组件
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" 2>/dev/null || {
        log_warning "sdkmanager 执行失败，可能需要手动安装"
    }
    
    log_success "SDK 组件安装完成"
}

# 预下载依赖
precache_deps() {
    log_info "预下载依赖..."
    cd "$PROJECT_DIR"
    flutter pub get
    log_success "依赖下载完成"
}

# 构建 APK
build_apk() {
    log_info "构建 APK..."
    cd "$PROJECT_DIR"
    
    flutter clean
    flutter pub get
    
    log_warning "首次构建可能需要 10-20 分钟..."
    flutter build apk --release \
        --target-platform android-arm64,android-arm \
        --split-per-abi
    
    log_success "构建完成！"
}

# 显示结果
show_results() {
    local apk_dir="$PROJECT_DIR/build/app/outputs/flutter-apk"
    mkdir -p "$PROJECT_DIR/dist"
    
    if [ -d "$apk_dir" ]; then
        cp "$apk_dir"/*-arm64-v8a-release.apk "$PROJECT_DIR/dist/爱家影视-arm64.apk" 2>/dev/null || true
        cp "$apk_dir"/*-armeabi-v7a-release.apk "$PROJECT_DIR/dist/爱家影视-armv7a.apk" 2>/dev/null || true
        
        log_success "APK 已生成！"
        ls -lh "$PROJECT_DIR/dist/"
        
        # 打开目录
        open "$PROJECT_DIR/dist"
    fi
}

# 主函数
main() {
    echo "🚀 爱家影视 - macOS 12 兼容安装脚本"
    echo "===================================="
    echo ""
    
    read -p "开始安装？(y/n) " -n 1 -r
    echo ""
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    
    install_homebrew
    install_java || use_system_java
    install_flutter
    setup_android_sdk
    install_sdk_components
    precache_deps
    build_apk
    show_results
    
    echo ""
    echo "===================================="
    log_success "完成！APK 在 dist/ 目录中"
}

main "$@"
