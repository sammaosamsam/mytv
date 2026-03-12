@echo off
chcp 65001 >nul
title 爱家影视 APK 构建脚本
echo.
echo 🚀 爱家影视 APK 构建脚本
echo ================================
echo.

REM 检查 Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 Flutter，请先安装 Flutter SDK
    echo 下载地址: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo [信息] Flutter 版本:
flutter --version
echo.

REM 检查 Java
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 Java，请先安装 Java JDK 17
    pause
    exit /b 1
)

echo [信息] Java 版本:
java -version
echo.

REM 获取依赖
echo [信息] 获取项目依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo [错误] 获取依赖失败
    pause
    exit /b 1
)
echo [成功] 依赖获取完成
echo.

REM 清理旧构建
echo [信息] 清理旧构建...
flutter clean
echo.

REM 重新获取依赖
echo [信息] 重新获取依赖...
flutter pub get
echo.

REM 构建 APK
echo [信息] 开始构建 APK（这可能需要 5-10 分钟）...
echo [信息] 构建 Release 版本...
flutter build apk --release --target-platform android-arm64,android-arm --split-per-abi
if %errorlevel% neq 0 (
    echo [错误] APK 构建失败
    pause
    exit /b 1
)

echo.
echo [成功] APK 构建完成！
echo.

REM 复制到桌面
set "DESKTOP=%USERPROFILE%\Desktop"
set "OUTPUT_DIR=%DESKTOP%\爱家影视APK"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "%OUTPUT_DIR%\爱家影视-arm64.apk" >nul
copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "%OUTPUT_DIR%\爱家影视-armv7a.apk" >nul

echo ================================
echo ✅ 构建完成！
echo.
echo APK 文件位置：
echo   - %OUTPUT_DIR%\爱家影视-arm64.apk （64位设备，推荐）
echo   - %OUTPUT_DIR%\爱家影视-armv7a.apk （32位设备）
echo.
echo 原始文件位置：
echo   - build\app\outputs\flutter-apk\
echo.
pause
