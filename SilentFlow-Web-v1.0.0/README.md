# 🌐 SilentFlow Web版本 v1.0.0

## 📋 部署说明

这是SilentFlow团队协作平台的Web版本，可以在任何现代浏览器中运行。

### 🚀 快速部署

#### 方式1：本地运行（推荐用于测试）

**使用Python：**
```bash
# 在本目录下运行
python -m http.server 8000

# 然后访问 http://localhost:8000
```

**使用Node.js：**
```bash
# 如果安装了Node.js
npx serve . -p 8000

# 然后访问 http://localhost:8000
```

**使用PHP：**
```bash
# 如果安装了PHP
php -S localhost:8000

# 然后访问 http://localhost:8000
```

#### 方式2：部署到Web服务器

将本目录下的所有文件上传到您的Web服务器根目录或子目录即可。

### 🌐 在线部署选项

#### 免费托管平台：

1. **GitHub Pages**
   - 将文件提交到GitHub仓库
   - 在仓库设置中启用GitHub Pages

2. **Netlify**
   - 直接拖拽本文件夹到 netlify.com
   - 或连接GitHub仓库自动部署

3. **Vercel**
   - 上传到 vercel.com
   - 支持自定义域名

4. **Firebase Hosting**
   - 使用 Firebase CLI 部署
   - 支持CDN加速

### 📱 系统要求

#### 支持的浏览器：
- ✅ Chrome 57+
- ✅ Firefox 52+
- ✅ Safari 10.1+
- ✅ Edge 79+

#### 设备要求：
- **桌面端**: 推荐使用，最佳体验
- **平板端**: 完全支持
- **手机端**: 响应式设计，完全兼容

### 🎯 功能特性

- 🏊‍♂️ **团队池架构** - 完整的团队管理体系
- 📊 **工作流可视化** - 直观的任务流程图表  
- 🎯 **智能任务管理** - 8种专业项目模板
- 🎨 **响应式设计** - 自适应各种屏幕尺寸
- 💾 **本地存储** - 数据保存在浏览器本地

### ⚙️ 配置说明

#### 自定义域名部署：
如果部署在子目录下，需要修改 `index.html` 中的 base href：
```html
<base href="/your-subdirectory/">
```

#### HTTPS要求：
- PWA功能需要HTTPS
- Service Worker需要HTTPS
- 建议在生产环境使用HTTPS

### 🔧 故障排除

#### 白屏问题：
1. 检查浏览器控制台是否有错误
2. 确保所有文件都已上传
3. 检查服务器是否支持所需的MIME类型

#### 加载缓慢：
1. 确保使用CDN或高速服务器
2. 检查网络连接
3. 清除浏览器缓存后重试

#### 功能异常：
1. 确认浏览器版本符合要求
2. 禁用浏览器扩展重试
3. 检查是否启用了JavaScript

### 📞 技术支持

- **GitHub Issues**: [https://github.com/Adam-code-line/SilentFlow/issues](https://github.com/Adam-code-line/SilentFlow/issues)
- **功能建议**: [https://github.com/Adam-code-line/SilentFlow/discussions](https://github.com/Adam-code-line/SilentFlow/discussions)

### 📄 文件说明

- `index.html` - 主页面文件
- `main.dart.js` - 核心应用逻辑
- `flutter.js` - Flutter Web框架
- `assets/` - 资源文件目录
- `canvaskit/` - 图形渲染引擎
- `icons/` - 应用图标文件

---

**SilentFlow** - *让团队协作更有结构，让项目管理更加智能*

**版本**: v1.0.0 | **构建日期**: 2025年8月20日
