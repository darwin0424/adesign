# adesign — IM 原型项目

本仓库包含即时通讯（IM）系统的设计文档与示例后端实现骨架（Java + Spring Boot + Netty）。当前分支用于提交文档修订和初始化迁移脚本。

快速开始（开发）

1. 克隆仓库

   git clone https://github.com/darwin0424/adesign.git
   cd adesign

2. 后端（如果已有 Maven 和 JDK 21）

   mvn clean package
   java -jar target/your-backend.jar

3. 前端

   - 前端工程路径（若存在）: 构建后将 dist 放到 backend/src/main/resources/static

配置与环境变量
- JWT_SECRET: 用于签名 JWT，生产环境必须设置强密钥
- SPRING_DATASOURCE_URL: 数据库连接（开发默认 H2）

使用 Docker (示例)

   docker build -t adesign-im:latest .
   docker run -e JWT_SECRET=your-secret -p 8080:8080 adesign-im:latest

贡献与 PR
- 我已在分支 im/revise-im-md 中提交修订文档与 Flyway 初始化脚本。请在仓库页面发起 PR：
  - 标题建议：设计优化，优化IM系统设计方案
  - 描述：整理并修订 IM 系统设计文档，添加 Flyway 初始化脚本、README 与 Dockerfile。

