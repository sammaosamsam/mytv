#!/bin/bash

# 爱家影视 - macOS 12 兼容版安装脚本
# 适用于 macOS 12.x 及更早版本

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

# 检查 macOS 版本
check_macos_version() {
    local version=$(sw_vers -productVersion)
    log_info "当前 macOS 版本: $version"
    
    local major=$(echo $version | cut -d. -f1)
    if [ "$major" -lt "12" ]; then
        log_error "此脚本需要 macOS 12 或更高版本"
        exit 1
    fi
}

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

# 安装兼容的 Java 版本
install_java() {
    log_info "检查 Java 环境..."
    if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "17"; then
        log_info "正在安装 OpenJDK 17（兼容版）..."
        brew install openjdk@17
        
        # 链接到系统
        if [[ "$(uname -m)" == "arm64" ]]; then
            sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk \
                /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
        else
            sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk \
                /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
        fi
        
        # 添加到环境变量
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
            echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
        else
            echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
            echo 'export JAVA_HOME="/usr/local/opt/openjdk@17"' >> ~/.zshrc
        fi
        
        source ~/.zshrc 2>/dev/null || true
        log_success "Java 17 安装完成"
    else
        log_success "Java 已安装"
    fi
}

# 安装兼容的 Flutter 版本 (3.16.9 支持 macOS 12+)
install_flutter() {
    log_info "检查 Flutter 环境..."
    if ! command -v flutter &> /dev/null; then
        log_info "正在安装 Flutter 3.16.9（兼容 macOS 12）..."
        
        # 创建开发目录
        mkdir -p ~/development
        cd ~/development
        
        # 下载兼容的 Flutter 版本
        local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.9-stable.zip"
        
        log_info "下载 Flutter SDK（约 1GB，请耐心等待）..."
        curl -L -o flutter_macos_3.16.9-stable.zip "$flutter_url"
        
        log_info "解压 Flutter SDK..."
        unzip -q flutter_macos_3.16.9-stable.zip
        rm flutter_macos_3.16.9-stable.zip
        
        # 添加到环境变量
        echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
        
        log_success "Flutter 3.16.9 安装完成"
    else
        log_success "Flutter 已安装: $(flutter --version 2>/dev/null | head -n 1 || echo '版本未知')"
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
        log_warning "配置完成后返回此处继续"
        read -p "按回车键继续..."
    else
        log_success "Android Studio 已安装"
    fi
}

# 配置 Android SDK
configure_android_sdk() {
    log_info "配置 Android SDK..."
    
    local sdk_path="$HOME/Library/Android/sdk"
    
    # 设置环境变量
    if ! grep -q "ANDROID_HOME" ~/.zshrc; then
        echo 'export ANDROID_HOME="'$sdk_path'"' >> ~/.zshrc
        echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
        source ~/.zshrc 2>/dev/null || true
    fi
    
    # 创建 local.properties
    cd "$PROJECT_DIR"
    if [ ! -f "android/local.properties" ]; then
        echo "sdk.dir=$sdk_path" > android/local.properties
        log_success "已创建 android/local.properties"
    fi
    
    log_success "Android SDK 配置完成"
}

# 预下载 Gradle 和依赖
precache_dependencies() {
    log_info "预下载构建依赖（这可能需要几分钟）..."
    
    cd "$PROJECT_DIR"
    
    # 获取 Flutter 依赖
    flutter pub get
    
    # 预下载 Android 构建工具
    flutter precache --android
    
    log_success "依赖预下载完成"
}

# 运行 Flutter doctor
check_flutter_doctor() {
    log_info "运行 Flutter 环境检查..."
    flutter doctor
    
    log_info "接受 Android SDK 许可..."
    yes | flutter doctor --android-licenses 2>/dev/null || true
    
    log_success "Flutter 环境检查完成"
}

# 构建 APK
build_apk() {
    log_info "开始构建 Android APK..."
    log_warning "首次构建可能需要 10-20 分钟，请耐心等待..."
    
    cd "$PROJECT_DIR"
    
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

# 显示结果
show_results() {
    log_info "构建结果："
    echo ""
    
    local apk_dir="$PROJECT_DIR/build/app/outputs/flutter-apk"
    
    if [ -d "$apk_dir" ]; then
        echo "📁 APK 文件："
        ls -lh "$apk_dir"/*.apk 2>/dev/null || echo "未找到 APK 文件"
        echo ""
        
        # 复制到 dist 目录
        mkdir -p "$PROJECT_DIR/dist"
        cp "$apk_dir"/*-arm64-v8a-release.apk "$PROJECT_DIR/dist/爱家影视-arm64.apk" 2>/dev/null || true
        cp "$apk_dir"/*-armeabi-v7a-release.apk "$PROJECT_DIR/dist/爱家影视-armv7a.apk" 2>/dev/null || true
        
        log_success "APK 文件已复制到: $PROJECT_DIR/dist/"
        
        # 打开目录
        log_info "正在打开存放目录..."
        open "$PROJECT_DIR/dist"
    else
        log_error "未找到构建产物"
    fi
}

# 主函数
main() {
    PROJECT_DIR="/Users/ace/WorkBuddy/20260312162941/Selene-Source"
    
    echo "🚀 爱家影视 - macOS 12 兼容版安装和构建脚本"
    echo "=============================================="
    echo ""
    
    # 检查是否在项目目录
    if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
        log_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    check_macos_version
    
    echo ""
    echo "此脚本将："
    echo "1. 安装 Homebrew"
    echo "2. 安装 Java 17"
    echo "3. 安装 Flutter 3.16.9（兼容 macOS 12）"
    echo "4. 安装 Android Studio"
    echo "5. 配置 Android SDK"
    echo "6. 构建 Android APK"
    echo "7. 打开存放目录"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "已取消"
        exit 0
    fi
    
    # 执行安装
    install_homebrew
    install_java
    install_flutter
    install_android_studio
    configure_android_sdk
    check_flutter_doctor
    precache_dependencies
    build_apk
    show_results
    
    echo ""
    echo "=============================================="
    log_success "全部完成！"
    echo ""
    echo "📱 APK 文件位置："
    echo "   - $PROJECT_DIR/dist/爱家影视-arm64.apk"
    echo "   - $PROJECT_DIR/dist/爱家影视-armv7a.apk"
    echo ""
    echo "💡 提示："
    echo "   1. 64位APK适用于大多数现代安卓手机"
    echo "   2. 32位APK适用于老旧安卓设备"
    echo "   3. 首次安装可能需要重启终端"
}

main "$@"
