# 推送到 GitHub 仓库步骤

## 你的仓库地址
https://github.com/sammaosamsam/mytv

## 方法1：使用 GitHub Desktop（推荐，最简单）

### 步骤1：下载 GitHub Desktop
1. 访问 https://desktop.github.com
2. 下载并安装 GitHub Desktop

### 步骤2：登录并添加仓库
1. 打开 GitHub Desktop
2. 登录你的 GitHub 账号（sammaosamsam）
3. 点击 "Add" → "Add Existing Repository"
4. 选择 `/Users/ace/WorkBuddy/20260312162941/Selene-Source` 文件夹

### 步骤3：推送代码
1. 在 GitHub Desktop 中，你应该能看到已提交的更改
2. 点击 "Publish repository"
3. 选择 "GitHub.com"
4. 仓库名称填写：`mytv`
5. 点击 "Publish Repository"

---

## 方法2：使用命令行 + 个人访问令牌

### 步骤1：创建个人访问令牌
1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 填写 Note: "MyTV Build"
4. 选择有效期（建议 30 天）
5. 勾选权限：
   - [x] repo (Full control of private repositories)
6. 点击 "Generate token"
7. **复制生成的令牌**（只显示一次！）

### 步骤2：推送代码
```bash
cd /Users/ace/WorkBuddy/20260312162941/Selene-Source

# 使用令牌推送（将 YOUR_TOKEN 替换为实际令牌）
git push https://sammaosamsam:YOUR_TOKEN@github.com/sammaosamsam/mytv.git main
```

---

## 方法3：使用 SSH 密钥

### 步骤1：生成 SSH 密钥
```bash
# 检查是否已有 SSH 密钥
ls ~/.ssh/id_rsa.pub

# 如果没有，生成新的
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# 按回车使用默认位置
```

### 步骤2：添加公钥到 GitHub
```bash
# 复制公钥
cat ~/.ssh/id_rsa.pub | pbcopy
```

1. 访问 https://github.com/settings/keys
2. 点击 "New SSH key"
3. Title: "My Mac"
4. Key: 粘贴刚才复制的内容
5. 点击 "Add SSH key"

### 步骤3：修改远程地址并推送
```bash
cd /Users/ace/WorkBuddy/20260312162941/Selene-Source

# 修改远程地址为 SSH
git remote set-url origin git@github.com:sammaosamsam/mytv.git

# 推送
git push -u origin main
```

---

## 推送后查看构建状态

推送成功后：

1. 访问 https://github.com/sammaosamsam/mytv/actions
2. 查看自动构建进度
3. 等待 5-10 分钟
4. 构建完成后下载 APK

---

## 快速检查清单

- [ ] 代码已提交（git commit 完成）
- [ ] GitHub 仓库已创建（https://github.com/sammaosamsam/mytv）
- [ ] 已推送代码到 GitHub
- [ ] GitHub Actions 已开始运行
- [ ] 构建完成并下载 APK

---

## 推荐

**方法1（GitHub Desktop）** 最简单，不需要处理命令行和令牌。
