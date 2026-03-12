# GitHub Actions 自动构建 APK

## 优势
- ✅ 无需配置本地环境
- ✅ 不受macOS 12限制
- ✅ 每次推送代码自动构建
- ✅ 构建产物自动保存

## 使用步骤

### 1. 创建GitHub仓库

1. 访问 https://github.com/new
2. 创建新仓库（例如：aijia-tv）
3. 选择 **Public**（免费）或 **Private**

### 2. 上传代码到GitHub

```bash
# 进入项目目录
cd /Users/ace/WorkBuddy/20260312162941/Selene-Source

# 初始化git仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: 爱家影视 - 修复闪退BUG"

# 添加远程仓库（替换YOUR_USERNAME为你的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/aijia-tv.git

# 推送代码
git push -u origin main
```

### 3. 触发自动构建

推送代码后，GitHub Actions会自动开始构建：

1. 打开你的GitHub仓库页面
2. 点击 **Actions** 标签
3. 查看构建进度（约5-10分钟）

### 4. 下载APK

构建完成后：

1. 在Actions页面点击最新的工作流运行
2. 滚动到底部找到 **Artifacts**
3. 点击 **爱家影视-APK** 下载

### 5. 发布Release（可选）

如果你想发布正式版本：

```bash
# 创建标签
git tag v1.0.0

# 推送标签
git push origin v1.0.0
```

推送标签后，GitHub会自动：
- 构建APK
- 创建Release页面
- 上传APK到Release

## 文件说明

已为你创建的文件：
- `.github/workflows/build_apk.yml` - GitHub Actions配置文件

## 构建配置

- **Flutter版本**: 3.16.9（稳定版）
- **Java版本**: OpenJDK 17
- **目标平台**: Android arm64 + armv7a
- **构建模式**: Release

## 常见问题

### Q: 构建失败怎么办？
A: 点击Actions页面的构建任务，查看日志找出错误原因。

### Q: 如何更新代码后重新构建？
A: 修改代码后再次推送，GitHub Actions会自动重新构建。

### Q: 构建的APK在哪里？
A: 在Actions页面的Artifacts部分下载，或在Release页面下载。

### Q: 需要付费吗？
A: GitHub Actions对公开仓库免费，私有仓库有免费额度。

## 快速开始命令

复制以下命令，替换 `YOUR_USERNAME` 后执行：

```bash
cd /Users/ace/WorkBuddy/20260312162941/Selene-Source
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/aijia-tv.git
git push -u origin main
```

然后访问 `https://github.com/YOUR_USERNAME/aijia-tv/actions` 查看构建进度。

---

**推荐**：这是最简单的方案，无需处理macOS 12的兼容性问题！
