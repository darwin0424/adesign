# 即时通讯（IM）系统 — 修订版设计（用于功能验证原型，兼顾可产品化扩展）

版本：v1.1-revised
作者：项目组（基于原始文档整理与修订）
目标：提供一份清晰、一致、可执行的设计文档，适用于快速验证单机原型，同时保留面向产品化（集群、监控、安全）的扩展路径与实现细节。

目录
1. 概述
2. 需求（功能与非功能）
3. 总体架构与部署模式
4. 消息协议与 WebSocket 规范
5. 连接管理与会话控制
6. 后端模块设计（Netty + Spring Boot）
7. 前端设计要点
8. 数据库设计（统一字段与迁移）
9. 接口设计（REST 规范、示例）
10. 安全设计（JWT、WSS、黑名单等）
11. 监控、日志与运维
12. 测试、CI/CD 与交付清单
13. 扩展建议与产品化路线
附录 A：示例 SQL / Flyway Migration
附录 B：重要枚举、术语与字段说明

---

1. 概述
- 目的：快速搭建并验证 IM 系统核心功能（登录、好友、单聊/群聊、离线消息、文件上传），文档同时描述必要的生产化改进点以降低后续重构成本。
- 范围：面向 Web 端优先（Vue3），支持多端（web/pc/mobile）概念与多端同步。
- 说明：当前优先实现单机可运行原型（所有组件可在同一进程/主机运行），但架构与数据模型应保留横向扩展能力（引入 Redis、消息队列、分布式路由的改变点已标注）。

2. 总体架构与部署模式

2.1 架构图（文本）
┌────────────┐   HTTP/Static   ┌──────────────┐
│   前端 SPA  │ ◄──────────────►│ Spring Boot  │ (8080)
└────────────┘                 └─────┬────────┘
                                      │ 内嵌或独立
                               ┌──────▼──────┐
                               │  Netty WS   │ (9090)
                               └─────────────┘
数据存储：
- H2（嵌入式）用于开发原型；生产建议 MySQL/Postgres + Flyway/Liquibase + Redis（在线状态）

2.2 部署模式说明
- 原型默认：单机模式（Spring Boot 启动并可内嵌 Netty 服务），便于本地调试。
- 可扩展模式：Netty 与 REST 服务可分离进程或容器部署（不同主机/端口），在线状态与 Channel 映射迁移到 Redis；消息路由采用一致性哈希或消息总线。

2.3 冲突与约定
- 文档中已统一：消息/离线消息均使用 conversation_id 与 conversation_type（见数据库设计），不再使用 to_target。

3. 技术栈
- 前端：Vue3 + TypeScript + Vite
- UI：Naive UI
- WebSocket 客户端：原生 WebSocket + 重连封装
- 后端消息服务：Netty
- 后端 API：Spring Boot 4.0.3 + Spring MVC
- DB：H2 (dev), MySQL/Postgres (prod)
- 持���层：MyBatis
- 序列化：JSON (Jackson)

4. 消息协议与 WebSocket 规范

4.1 统一消息格式（JSON）
所有实时消息以 JSON 文本帧传输，包含 header 与 body：

{
  "header": {
    "version":"1.0",
    "messageId":"uuid",
    "seqNo":123,
    "contentType":"text/image/file/cmd.auth",
    "timestamp":1620000000000,
    "from":"userId",
    "to":"userId/groupId",
    "conversationType":"single",
    "conversationId":12345,
    "deviceId":"device-uuid",
    "deviceType":"web",
    "ackRequired":true,
    "extension":{}
  },
  "body": {}
}

说明要点：
- conversationId：单聊时为对方 userId；群聊时为群组 ID。服务端以此字段为主进行路由与存储。
- messageId：客户端生成的全局唯一 ID，用于去重与幂等。
- seqNo：可选，用于设备内部消息乱序检测。
- 新增 deviceId/deviceType：便于多端管理与设备级策略。

4.2 contentType 与指令约定
- 主类型：text、image、file、cmd、custom
- 指令：cmd.[commandType]，示例：cmd.auth, cmd.auth_result, cmd.ack, cmd.heartbeat, cmd.read, cmd.typing

4.3 ACK 状态机
- SENDING -> SENT -> DELIVERED -> READ / FAILED
- 服务端返回 cmd.ack 带 status 字段

4.4 去重与幂等
- 服务端以 messageId 去重（短期缓存如 Caffeine，TTL 5 分钟）

4.5 心跳与超时
- 客户端心跳：默认 30s
- 认证超时：连接后 5s 未 auth 则断开
- 空闲超时：服务端 60s 未收到消息则关闭

5. 连接管理与会话控制
- DeviceType 字符串："web","mobile","pc","tablet"
- ClientSession 模型包含 sessionId, userId, deviceId, deviceType, channel, appVersion, loginTime, lastActiveTime, lastSyncTimestamp, unreadCount
- UserChannelManager：userId -> List<ClientSession>, sessionId -> ClientSession
- 多端策略：允许多端在线（可配置最大设备数），消息推送到所有在线设备，已读同步通知其他设备

6. 后端模块设计（要点）
- 在 Spring Boot 中内嵌或独立运行 Netty。推荐原型内嵌以简化部署。
- WebSocketServerHandler -> AuthenticationHandler, HeartbeatHandler, MessageDispatcher
- MessageHandler 负责入库、离线判断、推送、ACK 返回
- 去重缓存（messageId）、顺序由服务端入库时间为准，结合 seqNo/timestamp 校正

7. 前端设计要点
- WebSocketService：connect(token), sendMessage, onMessage, auto heartbeat, exponential backoff
- 状态管理：Pinia（userStore, sessionStore, messageStore, connectionStore）
- UI：乐观更新、typing 节流、图片预览、权限校验

8. 数据库设计（统一与迁移）
- 使用 Flyway 管理 schema，dev 使用 H2 (MODE=MySQL)
- 关键变更：统一使用 conversation_id 替代 to_target；增加 conversation_pair 字段用于单聊索引

重要表摘要（message/offline_message/group_message_read/token_blacklist/file_metadata/system_notification 等），见原文节省篇幅。

索引建议：
- message(message_id UNIQUE)
- message(conversation_id, conversation_type, created_at DESC)
- message(from_user, created_at DESC)
- message(conversation_pair)
- offline_message(user_id, status, created_at DESC)

9. 接口设计（/api/v1）
- 统一前缀 /api/v1
- 响应格式：{ code, data, message, requestId }
- 认证：POST /api/v1/auth/login, refresh, logout
- 消息历史：GET /api/v1/message/history?conversationId=&conversationType=&page=&size=
- 离线：GET /api/v1/message/offline?page=&size=
- 文件：POST /api/v1/file/upload, GET /api/v1/file/{fileId}

10. 安全设计
- 生产环境强制 WSS
- access token 2h，refresh token 7d，支持 refresh rotation
- token_blacklist 存 token_hash（SHA-256）
- 文件上传白名单 + 病毒扫描建议
- 速率限制（登录/注册/关键接口）

11. 监控、日志与运维
- 指标导出（Prometheus）：connections, messages_in/out, persist_latency
- 结构化 JSON 日志，包含 traceId/requestId/userId/messageId/sessionId
- 健康检查 /actuator/health 包含 db status 和 websocketConnections
- 定时任务：离线消息清理、黑名单清理、通知清理、文件清理

12. 测试、CI/CD 与交付清单
- 单元/集成/性能测试（1000 ws 并发目标）
- CI: build -> unit tests -> docker image -> publish

13. 扩展与产品化路径
- 在线状态迁移到 Redis
- 引入 MQ（Kafka/RabbitMQ）用于群发/异步处理
- 离线推���（APNs/FCM）与推送 token 管理
- ES 搜索、消息归档、链路追踪（OTel/SkyWalking）

附录 A: Flyway 示例（见文件 resources/db/migration/V1__init.sql）

附录 B: 术语表与字段说明

---

变更说明：
- 统一字段：conversation_id 替代 to_target
- 增加 conversation_pair 用于单聊高效查询
- 协议 header 增加 deviceId、seqNo
- 接口统一版本化为 /api/v1

-- End of IM.md