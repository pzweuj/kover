<div align="center">
  <img src="assets/icon/icon_rounded.png" width="120" alt="Kover icon" />

# Kover

非官方跨平台 [Kavita](https://www.kavitareader.com/) 客户端

</div>

> **注意：本仓库为个人自用的 Fork 分支，基于 [rodonisi/kover](https://github.com/rodonisi/kover) 进行修改，主要满足个人使用需求，不保证稳定性，也不提供官方技术支持。**

## 关于本 Fork

本仓库在原项目基础上进行了以下方面的调整：

- 添加中文界面支持
- UI/UX 优化与页面重设计
- 网络连接容错与离线回退改进
- CI/CD 构建流程调整

如需使用原版功能或提交 Issue/PR，请前往 [上游仓库](https://github.com/rodonisi/kover)。

## 功能特性

- 专用 Kavita 客户端，直接对接 Kavita API
- 书库同步，支持在线流式阅读或下载到本地离线阅读
- 内置 ePub、图片、PDF 阅读器，支持多种阅读模式与自定义设置
- 阅读进度本地存储，联网后自动同步至服务器
- 书库浏览，支持筛选、排序与搜索
- 基于 Flutter 构建，目标是全平台支持（移动端、桌面端、Web）

## 安装方式

### Android

APK 构建包可在本仓库的 [Releases](https://github.com/pzweuj/kover/releases/latest) 页面下载。

### 其他平台

暂未提供预编译包，可从源码自行构建，步骤见下文。

## 从源码构建

本项目大量使用代码生成（API、Model、数据库），生成代码不提交到仓库，需额外步骤：

1. 安装依赖：

   ```bash
   flutter pub get
   ```

2. 运行代码生成：

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. 正常构建或调试：

   ```bash
   flutter build
   # 或
   flutter run
   ```

> 修改了带注解的类后，记得重新运行 `build_runner`，开发时可使用 `dart run build_runner watch --delete-conflicting-outputs` 监听变更。

### Web 构建

Web 端需要额外依赖 Drift worker 和 Sqlite3，可通过脚本自动拉取：

```bash
dart run tools/fetch_web_dependencies.dart
```

**注意**：由于 CORS 限制，Web 版需要与 Kavita 部署在同一域名下，或通过反向代理注入 CORS 头。

## 连接 Kavita

1. 进入应用设置页面
2. 填写 Kavita 服务器地址
3. 从 Kavita 的 `Auth Keys / OPDS` 设置页获取或生成 API Key，填入应用设置中

## 截图

### 书库浏览

<p align="center">
  <img src="screenshots/home.png" alt="Screenshot" width="220" />
  <img src="screenshots/series_details.png" alt="Screenshot" width="220" />
  <img src="screenshots/series_details2.png" alt="Screenshot" width="220" />
  <img src="screenshots/all_series.png" alt="Screenshot" width="220" />
  <img src="screenshots/want_to_read.png" alt="Screenshot" width="220" />
  <img src="screenshots/menu.png" alt="Screenshot" width="220" />
</p>

### 阅读

<p align="center">
  <img src="screenshots/image_reader.png" alt="Screenshot" width="220" />
  <img src="screenshots/epub_reader.png" alt="Screenshot" width="220" />
</p>

<p align="center">
  <img src="screenshots/image_reader_settings.png" alt="Screenshot" width="220" />
  <img src="screenshots/image_reader_settings2.png" alt="Screenshot" width="220" />
  <img src="screenshots/epub_reader_settings.png" alt="Screenshot" width="220" />
</p>

### 设置

<p align="center">
  <img src="screenshots/settings.png" alt="Screenshot" width="220" />
  <img src="screenshots/settings2.png" alt="Screenshot" width="220" />
  <img src="screenshots/settings3.png" alt="Screenshot" width="220" />
</p>
