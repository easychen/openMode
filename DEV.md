# OpenCode Mobile 开发文档

## 项目概述

OpenCode Mobile 是一个 Flutter 移动应用，为 opencode（类似 Claude Code 和 Gemini CLI 的命令行 AI 工具）提供移动端界面。该应用通过 HTTP API 与 opencode 服务器通信，提供完整的 AI 编程助手功能。

## 核心功能分析

基于 API 文档和测试结果，opencode 提供以下核心功能：

### 1. 会话管理 (Session Management)
- 创建、删除、更新会话
- 会话层级结构（父子会话）
- 会话共享功能
- 会话历史记录

### 2. AI 对话系统 (Chat System)
- 发送消息到 AI 模型
- 支持多种消息类型（文本、文件、代理）
- 实时流式响应
- 消息撤销和重做

### 3. 文件操作 (File Operations)
- 文件搜索和读取
- 符号查找
- 文件状态监控
- 代码编辑功能

### 4. 提供商管理 (Provider Management)
- 多 AI 提供商支持（Moonshot AI、硅基流动等）
- 模型选择和切换
- API 密钥管理

### 5. 代理系统 (Agent System)
- 内置代理（build、plan、general）
- 自定义代理配置
- 权限管理

## 技术架构

### 技术栈
- **前端框架**: Flutter 3.8.1+
- **状态管理**: Provider / Riverpod
- **网络请求**: Dio
- **本地存储**: SharedPreferences / Hive
- **UI 组件**: Material Design 3
- **实时通信**: Server-Sent Events (SSE)

### 架构模式
采用 Clean Architecture 模式：

```
lib/
├── core/                    # 核心层
│   ├── constants/          # 常量定义
│   ├── errors/            # 错误处理
│   ├── network/           # 网络配置
│   └── utils/             # 工具类
├── data/                   # 数据层
│   ├── datasources/       # 数据源
│   ├── models/            # 数据模型
│   └── repositories/      # 仓库实现
├── domain/                 # 领域层
│   ├── entities/          # 实体
│   ├── repositories/      # 仓库接口
│   └── usecases/          # 用例
├── presentation/           # 表示层
│   ├── pages/             # 页面
│   ├── widgets/           # 组件
│   ├── providers/         # 状态管理
│   └── theme/             # 主题配置
└── main.dart              # 应用入口
```

## 功能模块设计

### 1. 认证模块 (Authentication)
- **功能**: 管理 API 密钥和服务器连接
- **组件**:
  - 服务器配置页面
  - API 密钥管理
  - 连接状态检测

### 2. 会话模块 (Session)
- **功能**: 会话的创建、管理和切换
- **组件**:
  - 会话列表页面
  - 会话详情页面
  - 会话设置页面

### 3. 聊天模块 (Chat)
- **功能**: AI 对话界面
- **组件**:
  - 聊天界面
  - 消息气泡组件
  - 输入框组件
  - 文件选择器

### 4. 文件管理模块 (File Management)
- **功能**: 项目文件浏览和操作
- **组件**:
  - 文件浏览器
  - 代码编辑器
  - 搜索功能

### 5. 设置模块 (Settings)
- **功能**: 应用配置和个性化设置
- **组件**:
  - 设置页面
  - 主题选择
  - 模型配置

## 数据模型

### 核心实体

```dart
// 会话实体
class Session {
  final String id;
  final String? parentId;
  final String title;
  final String version;
  final SessionTime time;
  final SessionShare? share;
  final SessionRevert? revert;
}

// 消息实体
class Message {
  final String id;
  final String sessionId;
  final MessageRole role;
  final MessageTime time;
  final List<MessagePart> parts;
}

// AI 提供商实体
class Provider {
  final String id;
  final String name;
  final List<String> env;
  final Map<String, Model> models;
}

// 代理实体
class Agent {
  final String name;
  final String description;
  final AgentMode mode;
  final bool builtIn;
  final AgentModel model;
  final Map<String, bool> tools;
}
```

## API 集成

### 网络层设计
- 使用 Dio 作为 HTTP 客户端
- 实现请求拦截器处理认证
- 支持 Server-Sent Events 实时更新
- 错误处理和重试机制

### 主要 API 端点
1. `/app` - 应用信息
2. `/session` - 会话管理
3. `/session/{id}/message` - 消息处理
4. `/config/providers` - 提供商配置
5. `/agent` - 代理管理
6. `/file` - 文件操作
7. `/event` - 实时事件流

## UI/UX 设计

### 设计原则
- **简洁性**: 界面简洁，重点突出
- **一致性**: 遵循 Material Design 规范
- **响应性**: 适配不同屏幕尺寸
- **可访问性**: 支持无障碍功能

### 主要页面
1. **启动页**: 应用 Logo 和初始化
2. **设置页**: 服务器配置和 API 密钥
3. **主页**: 会话列表和快速操作
4. **聊天页**: AI 对话界面
5. **文件页**: 项目文件管理

### 主题设计
- 支持亮色/暗色主题
- 自定义主色调
- 适配系统主题

## 开发计划

### Phase 1: 基础架构 (已完成)
- [x] 项目初始化
- [x] API 分析
- [x] 架构设计

### Phase 2: 核心功能
- [ ] 网络层实现
- [ ] 数据模型定义
- [ ] 基础 UI 框架
- [ ] 服务器连接功能

### Phase 3: 主要功能
- [ ] 会话管理
- [ ] AI 对话功能
- [ ] 文件操作
- [ ] 设置页面

### Phase 4: 优化完善
- [ ] UI/UX 优化
- [ ] 性能优化
- [ ] 错误处理
- [ ] 测试完善

## 技术要求

### 依赖包
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  dio: ^5.4.0                    # HTTP 客户端
  provider: ^6.1.1               # 状态管理
  shared_preferences: ^2.2.2     # 本地存储
  flutter_markdown: ^0.6.18      # Markdown 渲染
  flutter_highlight: ^0.7.0      # 代码高亮
  file_picker: ^6.1.1            # 文件选择
  url_launcher: ^6.2.2           # URL 启动
  package_info_plus: ^4.2.0      # 应用信息
```

### 开发环境
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK / Xcode (iOS)

## 测试策略

### 测试类型
1. **单元测试**: 业务逻辑和工具函数
2. **组件测试**: UI 组件功能
3. **集成测试**: API 集成和端到端流程
4. **用户测试**: 真实用户场景验证

### 测试覆盖率目标
- 核心业务逻辑: 90%+
- UI 组件: 70%+
- 整体覆盖率: 80%+

## 部署和发布

### 构建配置
- Android: 支持 API 21+ (Android 5.0+)
- iOS: 支持 iOS 12.0+
- 签名配置和混淆

### 发布渠道
- Google Play Store
- Apple App Store
- 内部测试分发

## 维护和更新

### 版本管理
- 遵循语义化版本规范
- 定期更新依赖包
- 兼容性测试

### 监控和分析
- 崩溃监控
- 性能分析
- 用户行为统计

---

## 更新日志

### v0.1.0 (当前版本)
- 项目初始化
- 基础架构设计
- API 分析完成
