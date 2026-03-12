# 爱家影视 - Windows 环境构建指南

## 优势
- ✅ Windows上Flutter环境配置更简单
- ✅ 没有macOS版本限制
- ✅ 可以直接使用最新版Flutter和Java

---

## 步骤1：安装必要软件

### 1.1 安装 Git
1. 访问 https://git-scm.com/download/win
2. 下载并安装 Git for Windows
3. 安装时选择默认选项即可

### 1.2 安装 Java JDK 17

**方式A：使用 Winget（推荐，Windows 10/11）**
```powershell
# 打开 PowerShell 或 CMD，运行：
winget install EclipseAdoptium.Temurin.17.JDK
```

**方式B：手动下载安装**
1. 访问 https://adoptium.net/temurin/releases/?version=17
2. 下载 Windows x64 MSI 安装包
3. 双击安装，选择默认选项

**验证安装：**
```powershell
java -version
# 应显示 OpenJDK 17
```

### 1.3 安装 Android Studio

1. 访问 https://developer.android.com/studio
2. 下载 Windows 版本
3. 安装并启动 Android Studio
4. 首次启动选择 "Standard" 安装

**配置 Android SDK：**
1. 打开 Android Studio
2. 点击 "More Actions" → "SDK Manager"
3. 确保以下组件已安装：
   - Android SDK Platform 33
   - Android SDK Build-Tools 33.0.0
   - Android SDK Command-line Tools

### 1.4 安装 Flutter SDK

**方式A：使用 Git 克隆（推荐）**
```powershell
# 创建开发目录
mkdir C:\dev
cd C:\dev

# 克隆 Flutter
 git clone https://github.com/flutter/flutter.git -b stable

# 或者下载特定版本（推荐 3.16.9）
# git clone https://github.com/flutter/flutter.git -b 3.16.9
```

**方式B：下载压缩包**
1. 访问 https://docs.flutter.dev/release/archive?tab=windows
2. 下载 flutter_windows_3.16.9-stable.zip
3. 解压到 C:\dev\flutter

---

## 步骤2：配置环境变量

### 2.1 打开环境变量设置
1. 右键点击 "此电脑" → "属性"
2. 点击 "高级系统设置"
3. 点击 "环境变量"

### 2.2 添加用户变量

**添加 FLUTTER_HOME：**
- 变量名：`FLUTTER_HOME`
- 变量值：`C:\dev\flutter`

**添加 ANDROID_HOME：**
- 变量名：`ANDROID_HOME`
- 变量值：`C:\Users\你的用户名\AppData\Local\Android\Sdk`
   （或 Android Studio 中显示的 SDK 路径）

**添加 JAVA_HOME：**
- 变量名：`JAVA_HOME`
- 变量值：`C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot`
   （根据实际安装路径调整）

### 2.3 编辑 Path 变量

在 "用户变量" 或 "系统变量" 中找到 `Path`，添加以下条目：

```
%FLUTTER_HOME%\bin
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
%JAVA_HOME%\bin
```

### 2.4 验证环境变量

**关闭并重新打开 PowerShell/CMD**，然后运行：

```powershell
flutter doctor
```

应该看到类似输出：
```
[√] Flutter (Channel stable, 3.16.9, ...)
[√] Android toolchain - develop for Android devices
[√] Java binary at: ...
```

如果有 [!] 标记的项，按照提示修复。

---

## 步骤3：接受 Android 许可

```powershell
flutter doctor --android-licenses
```

输入 `y` 接受所有许可。

---

## 步骤4：获取项目代码

### 方式A：复制项目文件夹
将 `Selene-Source` 文件夹复制到 Windows 电脑上。

### 方式B：使用 Git 克隆
```powershell
# 如果项目已上传到GitHub
git clone https://github.com/你的用户名/aijia-tv.git

# 或复制本地项目
cd C:\你的项目路径
```

---

## 步骤5：构建 APK

### 5.1 进入项目目录
```powershell
cd C:\路径\到\Selene-Source
```

### 5.2 创建 local.properties（如需要）
```powershell
# 检查文件是否存在
if (!(Test-Path "android\local.properties")) {
    $sdkPath = $env:ANDROID_HOME -replace "\\", "\\\\"
    "sdk.dir=$sdkPath" | Out-File -FilePath "android\local.properties" -Encoding UTF8
}
```

### 5.3 获取依赖
```powershell
flutter pub get
```

### 5.4 构建 APK
```powershell
# 构建 Release 版本（推荐）
flutter build apk --release --target-platform android-arm64,android-arm --split-per-abi

# 或使用项目脚本
.\build.ps1
```

---

## 步骤6：获取 APK 文件

构建完成后，APK 文件位于：

```
build\app\outputs\flutter-apk\
├── app-arm64-v8a-release.apk      (64位，推荐)
├── app-armeabi-v7a-release.apk    (32位)
└── app-release.apk                (通用版)
```

**复制到桌面：**
```powershell
# 创建输出目录
mkdir C:\Users\$env:USERNAME\Desktop\爱家影视APK

# 复制APK
copy build\app\outputs\flutter-apk\app-arm64-v8a-release.apk C:\Users\$env:USERNAME\Desktop\爱家影视APK\爱家影视-arm64.apk
copy build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk C:\Users\$env:USERNAME\Desktop\爱家影视APK\爱家影视-armv7a.apk
```

---

## 快速安装脚本（Windows PowerShell）

创建文件 `setup_windows.ps1`：

```powershell
# 以管理员身份运行 PowerShell
# 执行：Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# 然后运行此脚本

Write-Host "🚀 爱家影视 Windows 环境安装脚本" -ForegroundColor Cyan

# 安装 Chocolatey（包管理器）
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "安装 Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# 安装 Java
Write-Host "安装 Java 17..." -ForegroundColor Yellow
choco install temurin17 -y

# 安装 Git
Write-Host "安装 Git..." -ForegroundColor Yellow
choco install git -y

# 安装 Android Studio
Write-Host "安装 Android Studio..." -ForegroundColor Yellow
choco install androidstudio -y

# 安装 Flutter
Write-Host "安装 Flutter..." -ForegroundColor Yellow
choco install flutter -y

Write-Host "✅ 基础软件安装完成！" -ForegroundColor Green
Write-Host "请重启电脑，然后运行 flutter doctor 检查环境" -ForegroundColor Yellow
```

**运行方式：**
1. 右键点击 PowerShell → "以管理员身份运行"
2. 执行：`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. 执行：`.\setup_windows.ps1`

---

## 常见问题

### Q1: flutter 命令找不到
**解决：** 检查环境变量 Path 是否正确配置，重启 PowerShell。

### Q2: 构建时提示缺少 NDK
**解决：** 打开 Android Studio → SDK Manager → SDK Tools → 安装 NDK。

### Q3: 构建失败，提示内存不足
**解决：** 编辑 `android\gradle.properties`，添加：
```properties
org.gradle.jvmargs=-Xmx4096m
```

### Q4: 找不到 Android SDK
**解决：** 
```powershell
flutter config --android-sdk "C:\Users\你的用户名\AppData\Local\Android\Sdk"
```

---

## 文件传输方式

将项目从Mac传到Windows：

### 方式1：U盘/移动硬盘
直接复制 `Selene-Source` 文件夹。

### 方式2：局域网传输
```powershell
# Windows上开启共享，或使用工具如：
# - LocalSend (https://localsend.org)
# - 微信文件传输助手
# - QQ文件传输
```

### 方式3：上传到GitHub
```bash
# Mac上执行
cd /Users/ace/WorkBuddy/20260312162941/Selene-Source
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/aijia-tv.git
git push -u origin main

# Windows上执行
git clone https://github.com/你的用户名/aijia-tv.git
```

---

## 推荐流程

1. **Windows电脑准备**
   - 安装 Java 17
   - 安装 Flutter
   - 安装 Android Studio
   - 配置环境变量

2. **传输项目**
   - 将 `Selene-Source` 文件夹复制到Windows

3. **构建APK**
   - 运行 `flutter pub get`
   - 运行 `flutter build apk --release`

4. **获取APK**
   - 从 `build\app\outputs\flutter-apk\` 复制APK文件

---

**Windows上构建通常比Mac更简单，祝顺利！**
