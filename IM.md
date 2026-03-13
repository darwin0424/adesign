# 即时通讯（IM）系统业务验证版详细设计

## 1. 引言

### 1.1 项目背景

为快速验证 IM 系统核心功能，构建一个轻量级、可单机部署的即时通讯原型系统。系统聚焦于 Web 端用户间的实时消息互通，采用简洁的技术栈，便于快速开发和测试。本文档在保留原有设计目标的基础上，对实现细节进行了优化和补充，为后续产品化打磨预留空间。

### 1.2 设计目标

* **快速验证**：实现用户登录、好友管理、单聊、群聊、离线消息等核心功能。
* **简化架构**：避免引入复杂中间件，使用嵌入式数据库和本地文件存储，支持单机部署。
* **协议通用**：消息协议设计通用灵活，便于在此基础上扩展。
* **前端友好**：基于 Vue3 + Naive UI 提供清晰简洁的聊天界面。

### 1.3 非功能性需求

* **性能指标**：
  * 单机支持 1000 并发 WebSocket 连接
  * 消息端到端延迟 < 200ms（局域网环境）
  * HTTP API 响应时间 < 100ms（P95）
* **可用性**：99.9% 服务可用性
* **安全性**：数据加密存储，传输层加密

### 1.4 文档结构说明

本文档按照系统开发的逻辑顺序组织，从总体架构到具体实现细节，最后到部署运维，便于开发团队按需查阅。

## 2. 总体架构

### 2.1 系统架构图

```text
┌─────────────────┐    ┌─────────────────┐
│     前端        │    │     后端        │
│  Vue3 SPA       │◄──►│  Spring Boot    │
│                 │ HTTP│  (8080端口)     │
└─────────────────┘    └────────┬────────┘
                                │
                        ┌───────▼───────┐
                        │   Netty服务   │
                        │ (9090端口)    │
                        └───────┬───────┘
                                │ WebSocket
                        ┌───────▼───────┐
                        │   客户端      │
                        │  (多端设备)   │
                        └───────────────┘

数据存储层：
- H2数据库：用户、好友、群组、消息等结构化数据
- 本地文件系统：上传的图片、文件等非结构化数据
```

### 2.2 架构组件

* **前端**：Vue3 SPA，打包后由后端服务器静态托管。

* **后端**：
  * **Netty 服务**：独立线程池，处理 WebSocket 长连接（端口9090）。
  * **Spring Boot 应用**：提供 REST API、业务逻辑、数据库访问、文件上传接口（端口8080）。

* **数据存储**：
  * **H2 数据库**：嵌入式，存储用户、好友、群组、消息等数据。
  * **本地文件存储**：上传的图片、文件保存在服务器指定目录。

### 2.3 架构决策说明

* **分离部署**：WebSocket（Netty）与HTTP（Spring Boot）分离部署，便于未来独立扩展。
* **单机部署**：所有组件运行在同一进程中，简化部署和调试。
* **技术栈选择**：选用成熟稳定的开源技术栈，降低学习成本和维护难度。

## 3. 技术栈

| 模块 | 技术 | 说明 |
| ----- | ----- | ----- |
| **前端** | Vue3 + TypeScript + Vite | 核心框架、状态管理、路由 |
| **前端UI** | Naive UI | 高质量Vue3组件库 |
| **WebSocket客户端** | 原生WebSocket + 重连封装 | 简单可靠 |
| **后端消息服务** | Netty | 处理WebSocket长连接 |
| **后端API服务** | Spring Boot 4.0.3 + Spring MVC | 提供REST接口、集成MyBatis |
| **数据库** | H2 Database (嵌入式模式) | 文件存储，支持SQL语法类似MySQL |
| **持久层框架** | MyBatis | 简化数据库操作 |
| **文件存储** | 本地磁盘 | 上传文件保存至指定目录 |
| **序列化** | JSON (Jackson) | 消息协议使用JSON |

## 4. 消息协议设计

### 4.1 基础消息格式

所有消息均以 JSON 格式传输，包含 Header 和 Body 两部分：

```json
{
  "header": {
    "version": "1.0",
    "messageId": "uuid",
    "contentType": "text/image/file/cmd.auth",
    "timestamp": 1620000000000,
    "from": "userId",
    "to": "userId/groupId",
    "conversationType": "single/group",
    "ackRequired": true,
    "extension": {}
  },
  "body": {}
}
```

**说明**：

* `contentType`：标识消息类型，主类型包括（text、image、file、cmd、custom）
* 子类型通过在主类型后添加多层修饰符表示，例如 `cmd.auth` 表示认证指令
* `ackRequired`：标识消息是否需要确认

### 4.2 消息类型定义

| 消息类型 | 说明 | Body 内容示例 |
|----------|------|-------------|
| `text` | 文本消息 | `{"content": "你好"}` |
| `image` | 图片消息 | `{"url": "/files/xxx.jpg", "width": 800, "height": 600, "size": 102400}` |
| `file` | 文件消息 | `{"url": "/files/xxx.pdf", "fileName": "文档.pdf", "size": 204800}` |
| `cmd`  | 指令消息 | 见 4.3 节 |

### 4.3 指令消息规范

当 `contentType=cmd` 时，通过 `cmd.[commandType]` 修饰符明确标识指令类型：

| 指令类型 (commandType) | 触发条件 | body 内容示例 | 说明 |
|------------------------|----------|--------------|------|
| `auth` | 连接建立后 | `{"token": "jwt"}` | 客户端认证请求 |
| `auth_result` | 认证响应 | `{"success": true, "message": "ok"}` | 服务端认证结果返回 |
| `ack` | 消息确认 | `{"ackMessageId": "原消息 ID"}` | 接收方对发送方的 ACK 回执 |
| `heartbeat` | 心跳检测 | `{}` | 心跳包，空 body |
| `read` | 已读回执 | `{"messageId": "xxx", "conversationId": "xxx", "conversationType": "single/group"}` | 消息已读通知 |
| `typing` | 输入状态 | `{"conversationId": "xxx"}` | 对方正在输入提示 |

**完整指令消息示例**：

```json
{
  "header": {
    "version": "1.0",
    "messageId": "cmd-12345",
    "contentType": "cmd.auth",
    "timestamp": 1620000000000,
    "from": "user123",
    "to": "server",
    "conversationType": "single",
    "ackRequired": false,
    "extension": {}
  },
  "body": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**说明**：

* `cmd.read` 指令统一使用 `conversationId` 和 `conversationType`，适用于单聊和群聊
* 单聊时：`conversationType = "single"`, `conversationId = 对方用户 ID`
* 群聊时：`conversationType = "group"`, `conversationId = 群 ID`
* `contentType` 使用层级命名使得指令类型识别更加明确，无需解析 body 即可路由到对应处理器

## 5. 连接管理与会话控制

### 5.1 连接建立流程

1. 客户端连接 `ws://{host}:9090/ws`
2. 连接成功后，客户端需在 **5秒内** 发送 `auth` 指令，携带 JWT token
3. Netty 服务验证 token：
   * 成功：绑定用户 ID 与 Channel，返回 `auth_result`
   * 失败：关闭连接

### 5.2 心跳与超时机制

* **认证超时**：5秒内未发送认证消息，自动断开连接
* **心跳间隔**：客户端每30秒发送一次心跳
* **空闲超时**：60秒未收到任何消息，服务端主动关闭连接

### 5.3 多端登录管理

#### 设备类型定义

```java
public enum DeviceType {
    WEB("web"),       // Web 浏览器
    MOBILE("mobile"), // 手机 App
    PC("pc"),        // PC 客户端
    TABLET("tablet"); // 平板
    
    private final String code;
    
    DeviceType(String code) {
        this.code = code;
    }
    
    public String getCode() {
        return code;
    }
    
    public static DeviceType fromCode(String code) {
        for (DeviceType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown device type: " + code);
    }
}
```

#### 客户端会话模型

```java
public class ClientSession {
    private String sessionId;          // 会话 ID（UUID）
    private String userId;             // 用户 ID
    private DeviceType deviceType;     // 设备类型
    private Channel channel;           // Netty Channel
    private String deviceId;           // 客户端生成唯一设备 ID
    private String deviceName;         // 设备名称（如"iPhone 14 Pro"）
    private String appVersion;         // App 版本
    private Long loginTime;            // 登录时间
    private Long lastActiveTime;       // 最后活跃时间
    private Boolean isBackground;      // 是否后台运行（移动端）
    
    // 以下字段用于消息同步
    private Long lastSyncTimestamp;    // 最后同步时间戳
    private Integer unreadCount;       // 未读消息数
}
```

#### 用户连接管理器

```java
@Component
public class UserChannelManager {
    
    /**
     * 用户 ID → 该用户的所有会话列表
     * 支持同一用户在多个设备上同时在线
     */
    private final ConcurrentHashMap<String, List<ClientSession>> userSessions 
        = new ConcurrentHashMap<>();
    
    /**
     * Session ID → 会话信息（快速查找）
     */
    private final ConcurrentHashMap<String, ClientSession> sessionMap 
        = new ConcurrentHashMap<>();
    
    /**
     * 添加会话（用户认证成功后）
     */
    public void addSession(ClientSession session) {
        userSessions.computeIfAbsent(session.getUserId(), k -> 
            new CopyOnWriteArrayList<>()).add(session);
        sessionMap.put(session.getSessionId(), session);
        
        log.info("用户 {} 在设备 {} 上登录，当前在线设备数：{}", 
            session.getUserId(), 
            session.getDeviceType(),
            getUserSessionCount(session.getUserId()));
    }
    
    /**
     * 移除会话（连接断开时）
     */
    public void removeSession(String sessionId) {
        ClientSession session = sessionMap.remove(sessionId);
        if (session != null) {
            List<ClientSession> sessions = userSessions.get(session.getUserId());
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    userSessions.remove(session.getUserId());
                    log.info("用户 {} 已离线", session.getUserId());
                } else {
                    log.info("用户 {} 的设备 {} 已断开，剩余在线设备数：{}", 
                        session.getUserId(),
                        session.getDeviceType(),
                        sessions.size());
                }
            }
        }
    }
    
    /**
     * 获取用户的所有在线会话
     */
    public List<ClientSession> getUserSessions(String userId) {
        return userSessions.getOrDefault(userId, Collections.emptyList());
    }
    
    /**
     * 获取用户的在线设备数量
     */
    public int getUserSessionCount(String userId) {
        return getUserSessions(userId).size();
    }
    
    /**
     * 判断用户是否在线（任意设备）
     */
    public boolean isOnline(String userId) {
        List<ClientSession> sessions = userSessions.get(userId);
        return sessions != null && !sessions.isEmpty();
    }
    
    /**
     * 获取用户在指定设备类型的会话
     */
    public Optional<ClientSession> getSessionByDevice(
        String userId, DeviceType deviceType) {
        return getUserSessions(userId).stream()
            .filter(s -> s.getDeviceType() == deviceType)
            .findFirst();
    }
    
    /**
     * 更新会话活跃时间
     */
    public void updateActiveTime(String sessionId) {
        ClientSession session = sessionMap.get(sessionId);
        if (session != null) {
            session.setLastActiveTime(System.currentTimeMillis());
        }
    }
}
```

#### 多端登录策略

**设计原则**：
* ✅ **允许同时在线**：同一用户可在多个设备上同时登录
* ✅ **消息全量推送**：消息会推送到所有在线设备
* ✅ **状态独立管理**：每个设备的连接状态、未读数独立维护
* ✅ **已读状态同步**：任一设备标记已读，通知其他设备更新

**登录限制**（可选配置）：

```yaml
# application.yml
im:
  multi-device:
    enabled: true              # 是否启用多端登录
    max-devices: 5             # 单用户最大设备数（默认 5）
    exclude-device-types: []   # 禁用的设备类型（可选）
```

```java
public class AuthenticationHandler {
    
    @Value("${im.multi-device.enabled:true}")
    private boolean multiDeviceEnabled;
    
    @Value("${im.multi-device.max-devices:5}")
    private int maxDevices;
    
    @Autowired
    private UserChannelManager channelManager;
    
    public void authenticate(ChannelHandlerContext ctx, String token) {
        // 1. 验证 Token
        UserInfo userInfo = jwtValidator.validate(token);
        
        // 2. 检查设备限制
        if (multiDeviceEnabled) {
            int currentDevices = channelManager.getUserSessionCount(userInfo.getId());
            if (currentDevices >= maxDevices) {
                // 超过最大设备数，拒绝新连接
                sendAuthResult(ctx, false, "超过最大设备数限制");
                ctx.close();
                return;
            }
        }
        
        // 3. 创建会话并绑定
        ClientSession session = createSession(ctx.channel(), userInfo);
        channelManager.addSession(session);
        
        // 4. 返回认证成功
        sendAuthResult(ctx, true, "success");
        
        // 5. 广播上线事件（仅当第一个设备上线时）
        if (channelManager.getUserSessionCount(userInfo.getId()) == 1) {
            broadcastUserStatus(userInfo.getId(), UserStatus.ONLINE);
        }
    }
}
```

### 5.4 认证与安全

* **JWT Token**：登录成功后颁发，有效期2小时，包含用户ID、过期时间等信息
* **Token刷新**：过期前10分钟自动刷新，刷新失败则要求重新登录
* **安全说明**：业务验证版本暂不启用端到端加密，所有消息以明文传输和存储

### 5.5 用户状态同步

用户上线/下线时，通知其好友状态变更：

```java
public class UserStatusEvent {
    private String userId;
    private UserStatus status; // ONLINE/OFFLINE/AWAY
    private Long timestamp;
}
```

### 5.6 异常处理与重连

* **客户端**：实现指数退避重连逻辑，重连成功后重新认证并拉取离线消息
* **服务端**：检测到连接断开，从 `UserChannelManager` 中移除该 Channel；若用户所有 Channel 均断开，则视为离线

## 6. 后端模块设计

### 6.1 项目结构

``` text
im-backend/
├── src/main/java/com/example/im/
│   ├── IMApplication.java               # Spring Boot启动类
│   ├── config/                           # 配置类
│   │   ├── NettyServerConfig.java        # Netty配置
│   │   ├── WebConfig.java                # 静态资源、文件上传配置
│   │   └── DatabaseConfig.java           # H2数据源配置
│   ├── netty/                            # Netty相关组件
│   │   ├── WebSocketServer.java          # Netty服务启动、关闭
│   │   ├── handler/
│   │   │   ├── WebSocketServerHandler.java   # 主处理器，负责协议解析、分发
│   │   │   ├── AuthenticationHandler.java    # 认证处理
│   │   │   ├── HeartbeatHandler.java         # 心跳处理
│   │   │   └── MessageDispatcher.java        # 消息分发
│   │   └── session/
│   │       ├── UserChannelManager.java       # 用户连接管理
│   │       └── SessionInfo.java              # 会话信息
│   ├── controller/                        # REST控制器
│   │   ├── AuthController.java
│   │   ├── UserController.java
│   │   ├── FriendController.java
│   │   ├── GroupController.java
│   │   ├── MessageController.java
│   │   └── FileUploadController.java
│   ├── service/                           # 业务逻辑层
│   │   ├── UserService.java
│   │   ├── FriendService.java
│   │   ├── GroupService.java
│   │   ├── MessageService.java           # 消息持久化、离线处理
│   │   └── PushService.java              # 消息推送（调用Netty）
│   ├── mapper/                            # MyBatis接口
│   │   ├── UserMapper.java
│   │   ├── FriendMapper.java
│   │   ├── GroupMapper.java
│   │   ├── GroupMemberMapper.java
│   │   ├── MessageMapper.java
│   │   └── OfflineMessageMapper.java
│   ├── model/                             # 实体类
│   │   ├── User.java
│   │   ├── Friend.java
│   │   ├── Group.java
│   │   ├── GroupMember.java
│   │   ├── Message.java
│   │   └── OfflineMessage.java
│   ├── dto/                               # 数据传输对象
│   │   ├── LoginDTO.java
│   │   ├── MessageDTO.java
│   │   └── ...
│   └── util/                              # 工具类（JWT、Id生成器等）
└── resources/
    ├── application.yml                    # Spring Boot配置文件
    ├── mapper/                            # MyBatis XML映射文件（可选）
    └── static/                            # 前端打包后的静态文件（由Spring Boot托管）
```

### 6.2 Netty服务器核心组件

* **WebSocketServerHandler**：继承 `SimpleChannelInboundHandler<TextWebSocketFrame>`，处理文本帧
  * 解析 JSON 为 `Message` 对象
  * 调用各处理器进行认证、心跳、消息分发处理

* **UserChannelManager**：管理用户 ID 到 Channel 的映射（支持多端登录）
  * 使用 `ConcurrentHashMap<String, List<ClientSession>>`
  * 提供线程安全的添加、移除、获取 Channel 方法

* **PushService**：Spring Bean，通过持有 `UserChannelManager` 引用推送消息
  * 将 `Message` 对象转换为 JSON 字符串
  * 构造 `TextWebSocketFrame` 发送

### 6.3 Spring集成方案

* Netty 启动后，通过 `ApplicationContextAware` 获取 Spring 管理的 Bean
* 消息分发器通过 Spring 上下文获取对应的消息处理器
* 消息持久化、离线消息处理等调用 `MessageService`

### 6.4 消息可靠性保证

* **去重机制**：服务端引入基于 `messageId` 的短暂去重缓存
* **顺序保证**：消息按服务端入库时间排序展示
* **ACK确认**：确保消息可靠送达

## 7. 前端设计

### 7.1 技术架构

* **核心框架**：Vue3 + TypeScript + Vite
* **UI组件库**：Naive UI
* **状态管理**：Pinia
* **路由管理**：Vue Router
* **WebSocket封装**：自定义 `WebSocketService` 类

### 7.2 页面结构

* **登录/注册页**：表单验证，登录成功保存 JWT
* **主界面**：
  * 左侧：会话列表（好友/群聊），显示未读数
  * 右侧上方：聊天消息列表（支持虚拟滚动）
  * 右侧下方：消息输入框（支持文本、图片、文件上传）

### 7.3 WebSocket客户端封装

``typescript
class WebSocketService {
  connect(token: string): void
  sendMessage(message: Message): void
  onMessage(callback: (message: Message) => void): void
  // 自动心跳管理
  // 指数退避重连逻辑
}

```

### 7.4 状态管理（Pinia）

* **userStore**：用户信息、token、登录状态
* **sessionStore**：会话列表，包含会话ID、类型、最后消息、未读数
* **messageStore**：当前会话的消息列表，支持历史消息加载
* **connectionStore**：WebSocket连接状态

### 7.5 消息状态机

``typescript
enum MessageStatus {
  SENDING = 'sending',    // 发送中（转圈动画）
  SENT = 'sent',          // 已发送（等待 ACK）
  DELIVERED = 'delivered',// 已送达（收到 ACK）
  READ = 'read',          // 已读（收到 read 回执）
  FAILED = 'failed'       // 发送失败（显示重发按钮）
}
```

**乐观更新策略**：发送时立即在 UI 中插入状态为 `SENDING` 的临时消息，收到 ACK 后更新状态。

### 7.6 交互体验优化

* **输入状态提示**：节流发送 `typing` 指令，接收方显示"对方正在输入..."
* **消息气泡**：区分发送/接收消息的UI样式
* **图片预览**：支持图片消息的缩略图和全屏查看

## 8. 数据库设计

### 8.1 数据库选型说明

* **H2 Database**：嵌入式数据库，单机部署友好
* **MySQL兼容模式**：`MODE=MySQL` 确保SQL语法兼容性
* **无缝迁移**：表结构设计兼容MySQL，便于后续切换

### 8.2 表结构设计

#### 用户表（user）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| username | VARCHAR(50) | 用户名，唯一 |
| password | VARCHAR(255) | 密码 (BCrypt 加密存储) |
| nickname | VARCHAR(50) | 昵称 |
| avatar | VARCHAR(255) | 头像URL |
| status | TINYINT | 在线状态（0-离线，1-在线，2-忙碌） |
| deleted_at | TIMESTAMP | 软删除时间（NULL 表示未删除） |
| created_at | TIMESTAMP | 创建时间，默认当前时间 |

#### 好友关系表（friend）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| user_id | BIGINT | 用户ID |
| friend_id | BIGINT | 好友ID |
| remark | VARCHAR(50) | 好友备注 |
| status | TINYINT | 关系状态（0-正常，1-拉黑，2-删除） |
| deleted_at | TIMESTAMP | 软删除时间 |
| created_at | TIMESTAMP | 创建时间 |

#### 群组表（chat_group）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| name | VARCHAR(100) | 群名称 |
| owner_id | BIGINT | 群主ID |
| avatar | VARCHAR(255) | 群头像URL |
| deleted_at | TIMESTAMP | 软删除时间 |
| created_at | TIMESTAMP | 创建时间 |

#### 群成员表（group_member）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| group_id | BIGINT | 群ID |
| user_id | BIGINT | 用户ID |
| role | TINYINT | 角色（0-成员，1-管理员，2-群主） |
| banned_until | TIMESTAMP | 禁言截止时间（NULL 表示未禁言） |
| joined_at | TIMESTAMP | 加入时间 |

#### 消息表（message）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| message_id | VARCHAR(64) | 全局唯一消息 ID(UUID) |
| from_user | BIGINT | 发送者 ID |
| to_target | BIGINT | 接收者 ID(用户 ID或群组 ID) |
| conversation_type | TINYINT | 会话类型 (0-单聊，1-群聊) |
| content_type | VARCHAR(50) | 内容类型 (text/image/file/cmd.auth/cmd.heartbeat 等) |
| content | TEXT | 消息内容 (JSON 格式) |
| timestamp | BIGINT | 客户端消息时间戳 (毫秒) |
| status | TINYINT | 消息状态 (0-未读，1-已读) |
| recalled | BOOLEAN DEFAULT FALSE | 是否已撤回 |
| recalled_at | TIMESTAMP | 撤回时间 |
| created_at | TIMESTAMP | 服务端入库时间 |

**说明**：

* `status` 字段仅表示已读/未读状态，撤回状态由 `recalled` 字段独立表示
* 消息撤回时：`recalled = true`，`recalled_at` 记录撤回时间，`status` 保持不变
* `content_type` 使用 `VARCHAR(50)` 存储层级命名，如 `text`、`cmd.auth`、`file.pdf` 等

#### 离线消息表（offline_message）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| user_id | BIGINT | 接收者用户 ID |
| message_id | VARCHAR(64) | 消息 ID |
| conversation_type | TINYINT | 会话类型 (0-单聊，1-群聊) |
| conversation_id | BIGINT | 会话 ID（单聊时为对方用户 ID，群聊时为群 ID） |
| from_user | BIGINT | 发送者 ID |
| content_type | VARCHAR(50) | 内容类型 (同 message 表，使用字符串存储) |
| content | TEXT | 消息内容（JSON 格式，同 message 表） |
| timestamp | BIGINT | 客户端时间戳 |
| expire_at | TIMESTAMP | 过期时间（默认 7 天后） |
| status | TINYINT DEFAULT 0 | 0-未拉取，1-已拉取，2-过期 |
| created_at | TIMESTAMP | 创建时间 |

**说明**：

* `conversation_id` 替代原有的 `to_target`，语义更清晰
* 单聊时：`conversation_id = 对方用户 ID`
* 群聊时：`conversation_id = 群 ID`
* `content_type` 与 `message` 表保持一致，使用 `VARCHAR(50)` 存储

#### 群消息已读表（group_message_read）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| message_id | VARCHAR(64) | 消息 ID |
| group_id | BIGINT | 群 ID |
| user_id | BIGINT | 已读用户 ID |
| read_time | TIMESTAMP | 已读时间 |

#### JWT 黑名单表（token_blacklist）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| token_hash | VARCHAR(64) PRIMARY KEY | Token 的哈希值 |
| user_id | BIGINT | 用户 ID |
| expire_at | TIMESTAMP | Token 原始过期时间 |
| reason | VARCHAR(50) | 失效原因（LOGOUT/KICK/SECURITY） |
| created_at | TIMESTAMP | 加入黑名单时间 |

#### 文件元数据表（file_metadata）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | VARCHAR(36) PRIMARY KEY | 文件ID (UUID) |
| original_name | VARCHAR(255) | 原始文件名 |
| stored_name | VARCHAR(255) | 存储文件名 |
| file_path | VARCHAR(500) | 文件存储路径 |
| file_size | BIGINT | 文件大小（字节） |
| mime_type | VARCHAR(100) | MIME类型 |
| uploader_id | BIGINT | 上传者ID |
| upload_time | TIMESTAMP | 上传时间 |
| expire_at | TIMESTAMP | 过期时间（NULL表示永久） |

#### 系统通知表（system_notification）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT AUTO_INCREMENT | 主键，自增 |
| user_id | BIGINT | 接收者 ID |
| type | VARCHAR(50) | 通知类型 |
| content | TEXT | 通知内容（JSON 格式） |
| is_read | BOOLEAN DEFAULT FALSE | 是否已读 |
| priority | TINYINT DEFAULT 0 | 优先级 (0-普通，1-重要，2-紧急) |
| expire_at | TIMESTAMP | 过期时间（NULL 表示永久） |
| created_at | TIMESTAMP | 创建时间 |

**通知类型**：

* `friend_request`: 好友申请
* `group_invite`: 群组邀请  
* `group_notice`: 群公告更新
* `system_announcement`: 系统公告

**说明**：

* `priority` 字段用于区分通知的重要程度，便于前端展示排序
* `expire_at` 字段用于定时清理过期通知，减少数据量

### 8.3 索引设计

``sql
-- user 表
CREATE UNIQUE INDEX idx_username ON user(username);
CREATE INDEX idx_user_status ON user(status);
CREATE INDEX idx_user_deleted ON user(deleted_at);

-- friend 表
CREATE INDEX idx_friend_user ON friend(user_id, status);
CREATE INDEX idx_friend_friend ON friend(friend_id, status);
CREATE INDEX idx_friend_deleted ON friend(deleted_at);

-- chat_group 表
CREATE INDEX idx_group_owner ON chat_group(owner_id);
CREATE INDEX idx_group_deleted ON chat_group(deleted_at);

-- group_member 表
CREATE INDEX idx_group_member ON group_member(group_id, user_id);
CREATE INDEX idx_user_groups ON group_member(user_id, group_id);
CREATE INDEX idx_group_member_banned ON group_member(banned_until);

-- message 表
CREATE UNIQUE INDEX idx_message_message_id ON message(message_id);
CREATE INDEX idx_message_to_target ON message(to_target, conversation_type, timestamp DESC);
CREATE INDEX idx_message_from_user ON message(from_user, timestamp DESC);
-- 优化单聊双方历史查询（H2 兼容语法）
CREATE INDEX idx_message_single_chat ON message(
    CASE WHEN from_user < to_target THEN from_user ELSE to_target END,
    CASE WHEN from_user < to_target THEN to_target ELSE from_user END,
    timestamp DESC
);
CREATE INDEX idx_message_status ON message(to_target, conversation_type, status, timestamp);

-- offline_message 表
CREATE INDEX idx_offline_user ON offline_message(user_id, status, timestamp);
CREATE INDEX idx_offline_expire ON offline_message(expire_at);
CREATE INDEX idx_offline_conversation ON offline_message(user_id, conversation_type, conversation_id, timestamp);

-- group_message_read 表
CREATE INDEX idx_group_read_message ON group_message_read(message_id);
CREATE INDEX idx_group_read_user ON group_message_read(user_id);

-- file_metadata 表
CREATE INDEX idx_file_uploader ON file_metadata(uploader_id, upload_time DESC);
CREATE INDEX idx_file_expire ON file_metadata(expire_at);

-- system_notification 表
CREATE INDEX idx_notification_user ON system_notification(user_id, is_read, created_at DESC);
CREATE INDEX idx_notification_expire ON system_notification(expire_at);

-- token_blacklist 表
CREATE INDEX idx_token_user ON token_blacklist(user_id);
CREATE INDEX idx_token_expire ON token_blacklist(expire_at);

```

**说明**：

* H2 数据库不支持函数索引和 WHERE 子句索引，使用 `CASE` 表达式替代 `LEAST/GREATEST`
* `idx_message_status` 增加 `conversation_type` 字段，提高联合查询效率
* `idx_offline_conversation` 优化离线消息按会话查询的效率
* `idx_file_uploader` 用于快速查询用户上传的文件列表
* `idx_notification_user` 优化用户通知列表查询，支持按已读/未读筛选
* `idx_token_user` 便于按用户查询黑名单记录
* **注意**：`message` 表和 `offline_message` 表的 `content_type` 字段为 `VARCHAR(50)` 类型，不建议为其创建索引（字符串匹配效率较低）

## 9. 接口设计

### 9.1 RESTful API 规范

**基础规范**：

* 所有接口路径以 `/api` 开头
* 响应格式：`{ "code": 200, "data": {}, "message": "" }`

**错误码规范**：

* `200`：成功
* `400`：参数错误
* `401`：未认证 / Token 无效 / 过期
* `403`：无权限
* `404`：资源不存在
* `409`：冲突（如好友已存在）
* `429`：请求过于频繁
* `500`：服务器内部错误

### 9.2 认证相关接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/auth/login` | POST | 登录，返回 token 和过期时间 |
| `/api/auth/register` | POST | 注册新用户 |
| `/api/auth/refresh` | POST | 刷新 token |
| `/api/auth/logout` | POST | 登出，加入黑名单 |

### 9.3 用户管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/user/info` | GET | 获取当前用户信息 |
| `/api/user/update` | PUT | 更新用户信息 |
| `/api/user/search` | GET | 搜索用户 |

### 9.4 好友管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/friend/add` | POST | 添加好友（发送好友申请） |
| `/api/friend/list` | GET | 获取好友列表 |
| `/api/friend/delete` | POST | 删除好友 |
| `/api/friend/blacklist` | POST | 拉黑好友 |
| `/api/friend/request/list` | GET | 获取好友申请列表 |
| `/api/friend/request/approve` | POST | 同意好友申请 |
| `/api/friend/request/reject` | POST | 拒绝好友申请 |

**说明**：

* `/api/friend/add` 会向对方发送系统通知（类型为 `friend_request`）
* 好友申请相关接口用于处理待处理的好友请求

### 9.5 群组管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/group/create` | POST | 创建群组 |
| `/api/group/list` | GET | 获取群组列表 |
| `/api/group/detail` | GET | 获取群组详情 |
| `/api/group/addMember` | POST | 添加群成员 |
| `/api/group/removeMember` | POST | 移除群成员 |
| `/api/group/quit` | POST | 退出群组 |
| `/api/group/transfer` | POST | 转让群主 |
| `/api/group/setAdmin` | POST | 设置/取消管理员 |
| `/api/group/banMember` | POST | 禁言成员 |
| `/api/group/kickMember` | POST | 踢出成员 |
| `/api/group/dismiss` | POST | 解散群组 |
| `/api/group/bannedList` | GET | 获取群禁言列表 |
| `/api/group/notice` | POST/GET | 发布/获取群公告 |

### 9.6 消息相关接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/message/history` | GET | 拉取历史消息 |
| `/api/message/offline` | GET | 分页拉取离线消息 |
| `/api/message/recall` | POST | 撤回消息（2 分钟内） |

**说明**：

* 实时消息发送通过 WebSocket 实现，不经过 REST API
* WebSocket 消息格式遵循第 4 节协议规范

### 9.7 文件管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/file/upload` | POST | 文件上传 |
| `/api/file/{fileId}` | GET | 获取文件（需权限校验） |

**说明**：

* 统一使用 `/api/file` 前缀（单数形式）
* `fileId` 为文件元数据表中的 UUID

### 9.8 会话管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/conversation/list` | GET | 获取会话列表 |
| `/api/conversation/delete` | POST | 删除会话（仅本地） |
| `/api/conversation/top` | POST | 会话置顶 |
| `/api/conversation/read` | POST | 标记会话为已读 |

### 9.9 通知管理接口

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/notification/list` | GET | 获取通知列表 |
| `/api/notification/read` | POST | 标记通知为已读 |
| `/api/notification/unread` | GET | 获取未读通知数量 |

### 9.10 WebSocket 消息协议

所有实时消息均通过 WebSocket 传输，遵循第4节协议规范。客户端需在连接建立后立即认证。

## 10. 关键业务流程

### 10.1 用户登录与连接建立

1. 用户调用 `/api/auth/login` 获取 JWT token
2. 前端保存 token，建立 WebSocket 连接到 `ws://{host}:9090/ws`
3. WebSocket 连接成功后，发送 `auth` 指令携带 token
4. 服务端验证 token，成功后返回 `auth_result` 并绑定用户会话
5. 服务端通过 WebSocket 推送离线消息通知（包含离线消息总数）
6. 客户端调用 `/api/message/offline` 分页拉取离线消息
7. 服务端广播用户上线事件给好友列表中的在线用户

**说明**：

* 步骤 5 的离线消息通知通过 WebSocket 推送，消息类型为 `command`，具体格式可自定义
* 步骤 7 的上线事件仅通知当前在线的好友，避免打扰离线用户

### 10.2 单聊消息发送流程

**前端处理**：

1. 生成全局唯一 `messageId` (UUID)
2. 封装消息对象，设置 `ackRequired: true`
3. 插入本地消息列表（状态 `SENDING`）
4. 通过 WebSocket 发送消息

**服务端处理**：

1. 解析消息，验证发送者身份
2. 保存消息到 `message` 表（`status=0` 未读）
3. 查询接收者在线状态：
   * 在线：通过 `UserChannelManager` 推送消息
   * 离线：插入 `offline_message` 表
4. 返回 ACK 确认（如果 `ackRequired=true`）
5. 接收者查看消息时，发送 `read` 指令，更新消息状态为已读

### 10.3 群聊消息发送流程

**服务端处理差异**：

1. 验证发送者是否为群成员且未被禁言
2. 保存消息到 `message` 表
3. 查询群组所有成员（排除发送者）
4. 遍历每个成员，分别推送消息或记录离线消息
5. 群聊已读回执：接收者发送 `read` 指令时记录到 `group_message_read` 表

### 10.4 离线消息拉取流程

1. 用户上线后收到离线消息提示（包含总条数）
2. 客户端分页请求 `/api/message/offline?page=1&size=50`
3. 服务端返回对应页消息，并标记为已拉取（`status=1`）
4. 客户端按时间顺序插入本地消息列表
5. 重复拉取直至完成所有离线消息

### 10.5 文件上传流程

1. 前端调用 `/api/file/upload` 上传文件
2. 服务端保存文件，生成 UUID 文件名
3. 记录文件元数据到 `file_metadata` 表
4. 返回文件信息（包含签名URL）
5. 文件访问通过权限校验的 Controller 处理

## 11. 监控与运维

### 11.1 健康检查

```java
@RestController
@RequestMapping("/actuator")
public class HealthController {
    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", System.currentTimeMillis());
        health.put("database", dbHealthCheck());
        health.put("websocketConnections", 
            userChannelManager.getTotalConnections());
        return health;
    }
}
```

### 11.2 日志规范

* **关键操作日志**：用户登录/登出、消息发送/接收、文件上传、群组变更
* **日志格式**：包含 `messageId`、`userId` 等关键字段，便于链路追踪
* **异常日志**：完整堆栈信息，便于问题排查

### 11.3 定时任务

* **离线消息清理**：每日凌晨删除过期的离线消息（`expire_at < now()`）
* **黑名单清理**：清理过期的 Token 黑名单记录（`expire_at < now()`）
* **通知清理**：每日凌晨删除过期的系统通知（`expire_at < now()`）
* **文件清理**：可选，清理过期的临时文件（`expire_at < now()`）

**说明**：

* 所有清理任务建议配置在业务低峰期执行（如凌晨 2-4 点）
* 清理任务应记录日志，便于问题排查和审计

## 12. 部署与运行

### 12.1 环境要求

* **JDK**：21
* **Maven**：3.8+
* **Node.js**：20.x (LTS)
* **Spring Boot**：4.0.3

**说明**：

* Maven 3.8+ 版本稳定且广泛使用
* Node.js 20.x 为当前长期支持版本（LTS）

### 12.2 构建流程

1. **前端构建**：`npm install && npm run build`，生成 `dist` 目录
2. **资源整合**：将 `dist` 目录内容复制到 `src/main/resources/static`
3. **后端打包**：`mvn clean package`，生成可执行 JAR
4. **运行应用**：`java -jar im-backend.jar`

### 12.3 配置文件

``yml
server:
  port: 8080

spring:
  h2:
    console:
      enabled: true   # 开发环境可启用，生产环境必须禁用
  datasource:
    url: jdbc:h2:~/imdb;DB_CLOSE_DELAY=-1;MODE=MySQL
    driver-class-name: org.h2.Driver
    username: sa
    password:
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.example.im.model

netty:
  websocket:
    port: 9090
    boss-threads: 1
    worker-threads: 4

file:
  upload-dir: ./uploads
  allowed-types: image/jpeg,image/png,image/gif,application/pdf
  max-size: 10485760

security:
  jwt:
    secret: ${JWT_SECRET:your-default-secret}  # 必须通过环境变量覆盖
    expiration: 7200000
    refresh-threshold: 600000

```

### 12.4 安全注意事项

* **JWT密钥**：生产环境必须通过环境变量设置强密码
* **H2控制台**：生产环境必须禁用
* **文件上传**：限制文件类型和大小，防止恶意文件上传
* **SQL注入**：使用 MyBatis 参数化查询，避免拼接SQL

## 13. 扩展性与产品化建议

### 13.1 架构扩展方向

* **消息协议扩展**：通过 `messageType` 轻松增加语音、视频、位置等新消息类型
* **数据库迁移**：H2 可无缝切换为 MySQL/PostgreSQL
* **存储扩展**：文件存储可替换为云 OSS（阿里云OSS、MinIO等）
* **协议扩展**：核心业务逻辑与传输层解耦，可增加 TCP/MQTT 等协议支持

### 13.2 集群化方案

* **在线状态管理**：引入 Redis 存储用户在线状态和 Channel 映射
* **消息路由**：通过一致性哈希实现消息的分布式路由
* **服务发现**：使用 Nacos/Eureka 实现服务注册与发现

### 13.3 功能增强建议

* **消息可靠性**：引入消息重试机制、持久化双写确保不丢消息
* **安全增强**：
  * 传输层加密（WSS）
  * 文件访问权限控制（URL签名）
  * 敏感信息加密存储
  * 敏感词过滤、内容审核
* **用户体验优化**：
  * 消息搜索（Elasticsearch）
  * 表情包系统
  * 消息撤回扩展（延长撤回时间）
  * 消息转发、收藏功能

### 13.4 监控与可观测性

* **指标监控**：集成 Prometheus + Grafana 监控连接数、消息吞吐量等
* **日志聚合**：ELK 栈实现结构化日志收集和分析
* **链路追踪**：集成 SkyWalking/OpenTelemetry 实现全链路追踪
* **告警系统**：关键指标异常自动告警

## 14. 附录

### 14.1 术语表

* **ACK**：Acknowledgment，确认消息已收到
* **JWT**：JSON Web Token，用于身份认证的令牌
* **UUID**：Universally Unique Identifier，全局唯一标识符
* **WebSocket**：HTML5提供的全双工通信协议
* **Netty**：高性能异步事件驱动的网络应用框架

### 14.2 版本历史

* **v1.0**：初始版本，包含核心功能设计
* **v1.1**：优化文档结构，修正技术细节，增强可读性

### 14.3 参考资料

* [WebSocket RFC 6455](https://tools.ietf.org/html/rfc6455)
* [JWT RFC 7519](https://tools.ietf.org/html/rfc7519)
* [Netty 官方文档](https://netty.io/wiki/)
* [Spring Boot 官方文档](https://docs.spring.io/spring-boot/docs/current/reference/html/)
