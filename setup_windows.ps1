# 爱家影视 - Windows 环境一键安装脚本
# 以管理员身份运行 PowerShell，然后执行此脚本

param(
    [switch]$SkipChoco,
    [switch]$SkipAndroidStudio
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-Warning($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Write-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Host "🚀 爱家影视 Windows 环境安装脚本" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "请以管理员身份运行此脚本！"
    Write-Host "右键点击 PowerShell → 以管理员身份运行"
    exit 1
}

# 安装 Chocolatey
if (-not $SkipChoco) {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Info "安装 Chocolatey 包管理器..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        try {
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Success "Chocolatey 安装完成"
        } catch {
            Write-Error "Chocolatey 安装失败: $_"
            Write-Warning "请手动安装所需软件"
            exit 1
        }
    } else {
        Write-Success "Chocolatey 已安装"
    }
}

# 安装 Java 17
Write-Info "安装 Java 17 (Eclipse Temurin)..."
try {
    choco install temurin17 -y --force
    Write-Success "Java 17 安装完成"
} catch {
    Write-Warning "Java 安装可能失败，请手动检查"
}

# 安装 Git
Write-Info "安装 Git..."
try {
    choco install git -y
    Write-Success "Git 安装完成"
} catch {
    Write-Warning "Git 安装可能失败"
}

# 安装 Flutter
Write-Info "安装 Flutter SDK..."
try {
    choco install flutter -y
    Write-Success "Flutter 安装完成"
} catch {
    Write-Warning "Flutter 安装可能失败"
}

# 安装 Android Studio
if (-not $SkipAndroidStudio) {
    Write-Info "安装 Android Studio..."
    Write-Warning "这可能需要较长时间，请耐心等待..."
    try {
        choco install androidstudio -y
        Write-Success "Android Studio 安装完成"
    } catch {
        Write-Warning "Android Studio 安装可能失败，请手动下载安装"
        Write-Host "下载地址: https://developer.android.com/studio"
    }
}

# 刷新环境变量
Write-Info "刷新环境变量..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Success "软件安装完成！"
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 重启电脑" -ForegroundColor White
Write-Host "2. 打开新的 PowerShell 窗口" -ForegroundColor White
Write-Host "3. 运行: flutter doctor" -ForegroundColor White
Write-Host "4. 运行: flutter doctor --android-licenses" -ForegroundColor White
Write-Host ""
Write-Host "然后就可以构建 APK 了：" -ForegroundColor Yellow
Write-Host "  cd 项目目录" -ForegroundColor White
Write-Host "  flutter pub get" -ForegroundColor White
Write-Host "  flutter build apk --release" -ForegroundColor White
Write-Host ""
Read-Host "按回车键退出"
