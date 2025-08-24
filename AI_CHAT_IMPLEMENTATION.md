# AI 对话功能实现文档

## 概述

本文档描述了在 Flutter OpenMode 应用中实现的 AI 对话功能，该功能基于 web 版本的实现，提供了完整的聊天体验。

## 架构设计

### 1. 清洁架构 (Clean Architecture)

```
presentation/     # UI 层
├── pages/
│   └── chat_page.dart          # 聊天主页面
├── widgets/
│   ├── chat_message_widget.dart    # 消息显示组件
│   ├── chat_input_widget.dart      # 消息输入组件
│   └── chat_session_list.dart      # 会话列表组件
└── providers/
    └── chat_provider.dart          # 聊天状态管理

domain/          # 业务逻辑层
├── entities/
│   ├── chat_message.dart           # 消息实体
│   └── chat_session.dart           # 会话实体
├── repositories/
│   └── chat_repository.dart        # 仓储接口
└── usecases/
    ├── send_chat_message.dart       # 发送消息用例
    ├── get_chat_sessions.dart       # 获取会话列表用例
    ├── create_chat_session.dart     # 创建会话用例
    └── get_chat_messages.dart       # 获取消息列表用例

data/            # 数据层
├── models/
│   ├── chat_message_model.dart     # 消息数据模型
│   └── chat_session_model.dart     # 会话数据模型
├── datasources/
│   └── chat_remote_datasource.dart # 远程数据源
└── repositories/
    └── chat_repository_impl.dart   # 仓储实现
```

### 2. 核心实体

#### ChatMessage (消息实体)
- 支持用户消息 (`UserMessage`) 和助手消息 (`AssistantMessage`)
- 包含多种消息部件类型：
  - `TextPart`: 文本内容
  - `FilePart`: 文件附件
  - `ToolPart`: 工具调用
  - `ReasoningPart`: AI 推理过程

#### ChatSession (会话实体)
- 会话基本信息（ID、标题、创建时间）
- 支持会话分享和摘要功能
- 工作空间关联

### 3. API 集成

#### 主要端点
- `GET /session` - 获取会话列表
- `POST /session` - 创建新会话
- `GET /session/:id/message` - 获取消息列表
- `POST /session/:id/message` - 发送消息（支持流式响应）
- `DELETE /session/:id` - 删除会话
- `POST /session/:id/share` - 分享会话

#### 流式响应处理
- 支持 Server-Sent Events (SSE) 格式
- 实时更新消息内容和工具执行状态
- 错误处理和连接重试机制

## 主要功能

### 1. 会话管理
- ✅ 创建新的聊天会话
- ✅ 查看会话列表
- ✅ 选择和切换会话
- 🔄 重命名会话（UI 已实现，后端集成待完成）
- 🔄 删除会话（UI 已实现，后端集成待完成）
- 🔄 分享会话（UI 已实现，后端集成待完成）

### 2. 消息功能
- ✅ 发送文本消息
- ✅ 接收 AI 回复（流式）
- ✅ 消息历史记录
- ✅ 支持 Markdown 渲染
- ✅ 消息复制功能
- 🔄 文件上传（UI 已实现，功能待完成）
- 🔄 图片上传（UI 已实现，功能待完成）

### 3. AI 功能展示
- ✅ 工具调用状态显示
- ✅ AI 推理过程展示
- ✅ 错误信息显示
- ✅ 消息成本和令牌统计
- ✅ 模型和提供商信息

### 4. 用户体验
- ✅ 响应式设计
- ✅ 加载状态指示
- ✅ 错误处理和重试
- ✅ 自动滚动到最新消息
- ✅ 输入框状态管理

## 技术特性

### 1. 状态管理
- 使用 Provider 进行状态管理
- 响应式 UI 更新
- 错误状态处理
- 加载状态管理

### 2. 数据持久化
- 基于 REST API 的数据同步
- 本地状态缓存
- 网络错误容错

### 3. 依赖注入
- 使用 GetIt 进行依赖注入
- 模块化的服务注册
- 便于测试和维护

### 4. 错误处理
- 统一的异常处理机制
- 用户友好的错误提示
- 网络错误重试机制

## 使用方法

### 1. 启动聊天
1. 从主页点击"AI 对话"卡片
2. 系统自动加载会话列表
3. 选择现有会话或创建新会话

### 2. 发送消息
1. 在输入框中输入文本
2. 点击发送按钮或按 Enter
3. 实时查看 AI 回复

### 3. 管理会话
1. 点击左上角菜单查看会话列表
2. 长按会话项访问更多选项
3. 使用右上角菜单创建新会话

## 配置要求

### 1. 服务器连接
- 需要配置正确的 OpenCode 服务器地址
- 确保网络连接正常
- 服务器需要支持 WebSocket 或 SSE

### 2. 依赖版本
- Flutter SDK: ^3.8.1
- Dio: ^5.4.0
- Provider: ^6.1.1
- flutter_markdown: ^0.6.18

## 待完成功能

### 1. 高优先级
- [ ] 文件上传和发送
- [ ] 图片上传和显示
- [ ] 会话管理（重命名、删除、分享）
- [ ] 消息撤销和重发

### 2. 中优先级
- [ ] 离线缓存
- [ ] 消息搜索
- [ ] 导出对话记录
- [ ] 主题定制

### 3. 低优先级
- [ ] 语音输入
- [ ] 消息加密
- [ ] 多语言支持
- [ ] 无障碍功能优化

## 开发说明

### 1. 添加新消息类型
1. 在 `chat_message.dart` 中定义新的 `MessagePart` 子类
2. 在 `chat_message_model.dart` 中添加序列化支持
3. 在 `chat_message_widget.dart` 中添加 UI 渲染

### 2. 扩展 API 功能
1. 在 `chat_remote_datasource.dart` 中添加新的 API 调用
2. 在 `chat_repository_impl.dart` 中实现业务逻辑
3. 创建对应的用例类
4. 在 Provider 中添加状态管理

### 3. 测试
```bash
# 运行静态分析
flutter analyze

# 构建应用
flutter build apk --debug

# 运行测试（如果有）
flutter test
```

## 总结

AI 对话功能已成功集成到 OpenMode Flutter 应用中，提供了完整的聊天体验。该实现遵循了清洁架构原则，具有良好的可维护性和可扩展性。用户可以通过直观的界面与 AI 助手进行交互，享受流畅的对话体验。
