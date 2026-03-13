# 骑行软件 - 完整设计文档

## 一、产品概述

### 1.1 产品定位
**产品名称**：RideFlow（骑行流）
**产品定位**：专业骑行数据分析与社交平台
**目标用户**：骑行爱好者、自行车车队、骑行俱乐部
**核心价值**：精准记录、深度分析、智能推荐、骑友社区

### 1.2 产品愿景
成为骑行爱好者最信赖的数据分析工具和骑友社交平台，通过专业的数据分析帮助骑行者提升成绩，通过活跃的社区让骑行更有趣。

### 1.3 差异化竞争
| 对比项 | 其他竞品 | RideFlow |
|--------|----------|----------|
| 数据精度 | 普通GPS | 双频GPS + 气压计 |
| 分析深度 | 基础数据 | 专业级功率训练分析 |
| 社交功能 | 弱 | 强（车队、俱乐部、约骑） |
| 路线规划 | 基础 | AI推荐+用户路线库 |
| 设备兼容 | 有限 | 广泛兼容码表、传感器 |

---

## 二、功能架构

### 2.1 功能模块总览

```
┌─────────────────────────────────────────────────────────────┐
│                      RideFlow 骑行软件                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  骑行记录    │  │  数据分析    │  │  路线规划    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  训练计划    │  │  设备管理    │  │  骑友社区    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  挑战活动    │  │  车队管理    │  │  我的成就    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 核心功能详解

#### 2.2.1 骑行记录

**功能描述**：
- 实时GPS定位
- 速度、距离、海拔记录
- 心率、踏频、功率（连接传感器）
- 轨迹记录与回放
- 休息点标记
- 照片/视频拍摄

**记录指标**：
```yaml
基础指标:
  - 距离: 总骑行距离
  - 时长: 总时长、骑行时长、休息时长
  - 速度: 平均速度、最大速度、爬坡速度
  - 海拔: 爬升高度、下降高度、最高海拔、最低海拔
  - 时间: 开始时间、结束时间、日期

生理指标:
  - 心率: 平均心率、最大心率、心率区间分布
  - 踏频: 平均踏频、最大踏频、踏频分布
  - 功率: 平均功率、最大功率、NP（标准化功率）、TSS（训练压力）

环境指标:
  - 温度: 起始温度、最高温度、最低温度
  - 风速: 风向、风速
  - 天气: 天气状况

其他指标:
  - 消耗卡路里
  - 碳排放减少
  - 骑行效率
```

**UI设计**：
```
┌─────────────────────────────────────┐
│         🚴 正在骑行                  │
├─────────────────────────────────────┤
│  📍 北京·朝阳公园                     │
│  ⏱️ 01:23:45                        │
│  📏 42.5 km                         │
│  ⚡ 32.5 km/h                       │
│  ❤️ 145 bpm                         │
│  🔄 85 rpm                          │
│  ⛰️ ↑ 230m ↓ 180m                  │
│                                      │
│  [暂停] [结束] [拍照] [标记]         │
└─────────────────────────────────────┘
```

#### 2.2.2 数据分析

**功能描述**：
- 骑行数据可视化
- 历史数据对比
- 趋势分析
- 成绩预测
- 弱项分析

**分析维度**：

**1. 距离分析**
```yaml
周/月/年骑行距离统计
距离增长曲线
目标达成率
骑行频率分布
```

**2. 速度分析**
```yaml
速度曲线图（海拔对应）
不同路段速度分布
最佳巡航速度
平均速度趋势
```

**3. 心率分析**
```yaml
心率曲线图
心率区间分布（Zone 1-5）
心率与速度关系
最大心率趋势
```

**4. 功率分析（专业版）**
```yaml
功率曲线
功率区间分布
FTP估算
功率/体重比（W/kg）
力量训练分析
间歇训练分析
```

**5. 爬坡分析**
```yaml
爬坡识别
坡度分段分析
爬坡功率
爬坡心率
最佳爬坡路线
```

**6. 踏频分析**
```yaml
踏频分布
踏频与速度关系
踏频趋势
踏频优化建议
```

**7. 综合分析**
```yaml
体能评估（TSS、CTL、ATL、TSB）
疲劳度分析
状态监控
恢复建议
训练建议
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  📊 骑行数据分析                      │
├─────────────────────────────────────┤
│  [距离] [速度] [心率] [功率] [爬坡]   │
├─────────────────────────────────────┤
│  距离统计                            │
│  ═════════════                       │
│  本周: 156.8 km  ↑12%               │
│  本月: 523.4 km  ↑8%                │
│  本年: 3,245 km  ↑15%               │
│                                      │
│  📈 距离趋势图                        │
│  ═════════════                       │
│  [折线图：最近12个月距离变化]          │
│                                      │
│  🎯 目标达成                          │
│  ═════════════                       │
│  本周目标: 200 km                    │
│  当前进度: 156.8 km (78%)            │
│  [████████████░░░░]                 │
│                                      │
│  💡 建议                              │
│  本周还差43.2km达成目标，建议周末     │
│  安排一次50km骑行                     │
└─────────────────────────────────────┘
```

#### 2.2.3 路线规划

**功能描述**：
- 路线绘制
- 路线导入/导出（GPX、KML）
- 路线分析（距离、爬升、难度）
- AI智能推荐路线
- 热门路线库
- 用户分享路线

**路线推荐逻辑**：
```python
class RouteRecommender:
    def recommend_route(self, user, constraints):
        """
        根据用户和约束条件推荐路线

        Args:
            user: 用户信息（位置、偏好、能力）
            constraints: 约束条件（距离、时间、类型）

        Returns:
            推荐路线列表
        """
        # 1. 分析用户偏好
        user_preferences = self.analyze_preferences(user)

        # 2. 获取候选路线
        candidates = self.get_candidates(user.location, constraints)

        # 3. 路线评分
        scored_routes = []
        for route in candidates:
            score = self.score_route(route, user_preferences, constraints)
            scored_routes.append((route, score))

        # 4. 排序返回
        scored_routes.sort(key=lambda x: x[1], reverse=True)
        return [r[0] for r in scored_routes[:10]]

    def score_route(self, route, preferences, constraints):
        """路线评分"""
        score = 0

        # 距离匹配度
        distance_match = 1 - abs(route.distance - constraints.distance) / constraints.distance
        score += distance_match * 30

        # 难度匹配度
        difficulty_match = 1 - abs(route.difficulty - user.level) / 5
        score += difficulty_match * 25

        # 类型偏好
        if route.type in preferences.route_types:
            score += 20

        # 热度
        score += route.popularity * 15

        # 路况
        score += route.road_quality * 10

        return score
```

**路线分类**：
```yaml
按距离:
  - 短途: < 30km
  - 中途: 30-80km
  - 长途: 80-150km
  - 超长途: > 150km

按类型:
  - 平路训练: 坡度 < 3%
  - 爬坡训练: 坡度 > 5%
  - 综合训练: 混合路面
  - 竞速路线: 平路为主
  - 休闲骑行: 风景优美

按难度:
  - 入门: 距离短、坡度小
  - 初级: 距离适中、少量爬坡
  - 中级: 距离较长、有明显爬坡
  - 高级: 长距离、多爬坡
  - 专业: 职业路线级别
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  🗺️ 路线规划                         │
├─────────────────────────────────────┤
│  [推荐路线] [热门路线] [我的路线]    │
├─────────────────────────────────────┤
│  推荐路线                            │
│  ═════════════                       │
│  📍 奥林匹克公园环线                 │
│  📏 15.2 km | ⛰️ ↑50m | ⭐ 4.8     │
│  👥 1,234人骑过                      │
│  [查看详情] [开始骑行]                │
│                                      │
│  ───────────────────────────────     │
│                                      │
│  📍 香山红叶路线                      │
│  📏 42.5 km | ⛰️ ↑850m | ⭐ 4.5     │
│  👥 856人骑过                         │
│  [查看详情] [开始骑行]                │
│                                      │
│  [+] 自定义路线                       │
└─────────────────────────────────────┘
```

#### 2.2.4 训练计划

**功能描述**：
- 目标设定（减脂、增肌、提升耐力、提升速度）
- 训练计划生成
- 训练执行指导
- 训练效果评估
- 恢复建议

**训练类型**：
```yaml
有氧训练:
  - LSD（长距离慢骑）
  - 节奏骑行
  - 区间训练（Zone 2-4）

无氧训练:
  - 间歇训练
  - 冲刺训练
  - HIIT骑行

力量训练:
  - 爬坡训练
  - 低踏频力量骑行
  - 抗阻骑行

恢复训练:
  - 轻松骑行
  - 主动恢复
  - 交叉训练
```

**智能训练计划生成**：
```python
class TrainingPlanGenerator:
    def generate_plan(self, user_profile, goals, duration_weeks):
        """
        生成个性化训练计划

        Args:
            user_profile: 用户画像（能力水平、可用时间、历史数据）
            goals: 目标（减脂、提升FTP、备战比赛）
            duration_weeks: 训练周期（周）

        Returns:
            训练计划
        """
        # 1. 评估用户当前状态
        current_level = self.assess_level(user_profile)

        # 2. 计算目标差距
        gap = self.calculate_gap(current_level, goals)

        # 3. 确定训练重点
        focus_areas = self.determine_focus(gap, goals)

        # 4. 生成周计划
        weekly_plans = []
        for week in range(duration_weeks):
            week_plan = self.generate_week_plan(
                week,
                duration_weeks,
                current_level,
                focus_areas
            )
            weekly_plans.append(week_plan)

        return {
            'total_weeks': duration_weeks,
            'weekly_plans': weekly_plans,
            'milestones': self.generate_milestones(gap, duration_weeks)
        }

    def generate_week_plan(self, week, total_weeks, level, focus_areas):
        """生成周计划"""
        # 渐进超负荷原则
        intensity = 0.5 + (week / total_weeks) * 0.5

        week_days = []
        for day in range(7):
            if day == 2 or day == 5:  # 周三、周六休息
                week_days.append({
                    'type': 'rest',
                    'duration': 0,
                    'intensity': 0
                })
            elif day == 6:  # 周日长距离
                week_days.append({
                    'type': 'LSD',
                    'duration': 3 + int(level * 2),
                    'intensity': 0.6 * intensity,
                    'description': '长距离慢速骑行'
                })
            elif day % 2 == 0:  # 周一、周四有氧
                week_days.append({
                    'type': 'aerobic',
                    'duration': 1.5,
                    'intensity': 0.7 * intensity,
                    'description': '节奏骑行'
                })
            else:  # 周五间歇
                week_days.append({
                    'type': 'interval',
                    'duration': 1,
                    'intensity': 0.9 * intensity,
                    'description': '间歇训练'
                })

        return {
            'week': week + 1,
            'focus': focus_areas[week % len(focus_areas)],
            'days': week_days,
            'total_hours': sum(d['duration'] for d in week_days)
        }
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  🎯 训练计划                         │
├─────────────────────────────────────┤
│  当前计划: FTP提升计划                │
│  周期: 8周                           │
│  当前进度: 第3周 (37%)               │
│  [████████░░░░░░░░░░░]              │
├─────────────────────────────────────┤
│  本周训练                            │
│  ═════════════                       │
│  周一 ✅ 节奏骑行 1.5h               │
│  周二 ✅ 休息                         │
│  周三 🔄 间歇训练 1h                 │
│  周四 🔜 节奏骑行 1.5h               │
│  周五 🔜 休息                         │
│  周六 🔜 长距离 4h                   │
│  周日 🔜 休息                         │
│                                      │
│  本周目标                            │
│  ═════════════                       │
│  骑行距离: 200 km                    │
│  累计时长: 8h                        │
│  训练压力(TSS): 400                  │
│                                      │
│  [查看完整计划] [调整计划]            │
└─────────────────────────────────────┘
```

#### 2.2.5 设备管理

**功能描述**：
- 码表连接（佳明、Wahoo、Bryton等）
- 传感器连接（心率带、踏频传感器、功率计）
- 自动同步骑行数据
- 设备固件升级提醒
- 电量监控

**支持的设备**：
```yaml
码表:
  - Garmin (Edge系列、Forerunner系列)
  - Wahoo (Elemnt系列)
  - Bryton (Rider系列)
  - iGPSPORT

传感器:
  - 心率带: Garmin, Wahoo, Polar, 佳明
  - 踏频传感器: Garmin, Wahoo, Stages
  - 功率计: Stages, Garmin, Power2Max
  - 速度/踏频二合一: Garmin, Wahoo

连接方式:
  - Bluetooth LE
  - ANT+
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  🔌 设备管理                         │
├─────────────────────────────────────┤
│  我的设备                            │
│  ═════════════                       │
│  📱 Garmin Edge 530                 │
│  🔋 电池: 85%                        │
│  🔄 最后同步: 2小时前                │
│  [同步数据] [设备设置]                │
│                                      │
│  ───────────────────────────────     │
│                                      │
│  ❤️ Wahoo TICKR心率带                │
│  🔋 电池: 92%                        │
│  ✅ 已连接                            │
│  [断开连接] [设备设置]                │
│                                      │
│  ───────────────────────────────     │
│                                      │
│  ⚡ Stages功率计                     │
│  🔋 电池: 78%                        │
│  ✅ 已连接                            │
│  [断开连接] [校准] [设备设置]         │
│                                      │
│  [+ 添加设备]                        │
└─────────────────────────────────────┘
```

#### 2.2.6 骑友社区

**功能描述**：
- 骑友关注
- 骑行动态分享
- 路线分享
- 约骑活动
- 骑行圈子（俱乐部、车队）
- 聊天功能

**社区功能**：

**1. 骑行动态**
```yaml
动态类型:
  - 骑行完成分享
  - 路线推荐
  - 装备分享
  - 骑行感悟
  - 比赛参与

互动功能:
  - 点赞
  - 评论
  - 分享
  - 收藏
```

**2. 约骑活动**
```yaml
活动类型:
  - 日常约骑
  - 训练约骑
  - 比赛约骑
  - 活动约骑

活动信息:
  - 时间地点
  - 路线详情
  - 难度等级
  - 人数限制
  - 报名费用（如有）
```

**3. 骑行圈子**
```yaml
圈子类型:
  - 地域圈子 (北京骑行圈、上海骑行圈)
  - 车队 (职业车队、业余车队)
  - 俱乐部 (商业俱乐部、公益俱乐部)
  - 兴趣圈子 (公路车圈、山地车圈)
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  👥 骑友社区                         │
├─────────────────────────────────────┤
│  [动态] [约骑] [圈子] [消息]          │
├─────────────────────────────────────┤
│  最新动态                            │
│  ═════════════                       │
│  🚴 张三 刚刚完成了一次骑行           │
│  📍 奥林匹克公园环线                  │
│  📏 42.5 km | ⚡ 32.5 km/h          │
│  📸 [骑行照片]                        │
│  💬 5条评论 | ❤️ 23个赞               │
│                                      │
│  ───────────────────────────────     │
│                                      │
│  🚴 李四 分享了一条路线               │
│  📍 香山红叶骑行路线                  │
│  📏 28.3 km | ⛰️ ↑520m | ⭐ 4.7     │
│  💬 12条评论 | ❤️ 56个赞              │
│                                      │
│  [+] 发布动态                        │
└─────────────────────────────────────┘
```

#### 2.2.7 挑战活动

**功能描述**：
- 月度挑战
- 季度挑战
- 年度挑战
- 自定义挑战
- 挑战排行榜
- 成就徽章

**挑战类型**：
```yaml
距离挑战:
  - 月度100km挑战
  - 季度500km挑战
  - 年度5000km挑战

爬升挑战:
  - 月度1000m爬升挑战
  - 年度10000m爬升挑战

速度挑战:
  - 30分钟最远距离挑战
  - 1小时最远距离挑战

时间挑战:
  - 连续骑行30天挑战
  - 连续骑行100天挑战

特殊挑战:
  - 环湖骑行挑战
  - 登山骑行挑战
  - 夜骑挑战
```

**成就系统**：
```yaml
初级成就:
  - 新手起步: 完成第一次骑行
  - 百里骑行: 单次骑行100km
  - 千里骑行: 累计骑行1000km

中级成就:
  - 爬坡新手: 完成总爬升1000m
  - 夜骑勇士: 完成10次夜骑
  - 骑行达人: 连续骑行30天

高级成就:
  - 骑行高手: 累计骑行10000km
  - 爬坡达人: 完成总爬升100000m
  - 速度之王: 平均速度突破35km/h

大师成就:
  - 骑行大师: 累计骑行50000km
  - 巅峰挑战: 单次骑行200km
  - 全年无休: 连续骑行365天
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  🏆 挑战与成就                       │
├─────────────────────────────────────┤
│  [进行中] [已完成] [排行榜] [我的成就] │
├─────────────────────────────────────┤
│  进行中的挑战                        │
│  ═════════════                       │
│  🎯 3月骑行挑战                      │
│  目标: 300 km                       │
│  当前进度: 156.8 km (52%)            │
│  [████████████░░░░░░]              │
│  剩余23天 | 2,345人参与              │
│  [详情] [分享]                       │
│                                      │
│  ───────────────────────────────     │
│                                      │
│  🏔️ 爬升挑战                         │
│  目标: 1000m爬升                     │
│  当前进度: 650m (65%)                │
│  [█████████████░░░]                 │
│  剩余15天 | 1,876人参与               │
│  [详情] [分享]                       │
│                                      │
│  [+ 参与新挑战]                       │
└─────────────────────────────────────┘
```

#### 2.2.8 车队管理

**功能描述**：
- 创建/加入车队
- 车队成员管理
- 车队训练计划
- 车队活动组织
- 车队数据统计
- 车队排行榜

**车队功能**：
```yaml
车队信息:
  - 车队名称、logo
  - 车队简介
  - 车队类型 (职业、业余、俱乐部)

成员管理:
  - 成员邀请
  - 成员角色 (队长、副队长、队员)
  - 成员权限管理

团队活动:
  - 训练计划共享
  - 团队约骑
  - 比赛组队

数据统计:
  - 车队总里程
  - 成员排名
  - 活跃度统计
```

#### 2.2.9 我的成就

**功能描述**：
- 个人数据统计
- 历史成就
- 排行榜排名
- 数据对比
- 生成骑行报告

**数据统计维度**：
```yaml
基础数据:
  - 总骑行距离
  - 总骑行时长
  - 总爬升高度
  - 总消耗卡路里
  - 减少碳排放量

年度数据:
  - 本年距离
  - 本年骑行次数
  - 最长单次距离
  - 最高速度
  - 最大爬升

记录数据:
  - 最快速度
  - 最长距离
  - 最多爬升
  - 最长时长
```

**UI设计**：
```
┌─────────────────────────────────────┐
│  📊 我的成就                         │
├─────────────────────────────────────┤
│  总里程: 3,245 km                    │
│  总时长: 156h 32m                   │
│  总爬升: 12,450m                    │
│  消耗热量: 156,234 kcal             │
│  减排: 324 kg CO₂                   │
├─────────────────────────────────────┤
│  📈 年度统计                         │
│  ═════════════                       │
│  2025年: 3,245 km                    │
│  2024年: 12,456 km                   │
│  2023年: 8,234 km                    │
│  [查看历史]                          │
│                                      │
│  🏆 个人记录                          │
│  ═════════════                       │
│  最快速度: 52.3 km/h                 │
│  最长距离: 186.5 km                 │
│  最多爬升: 1,850 m                  │
│  最长时长: 8h 45m                   │
│                                      │
│  🥇 排行榜排名                        │
│  ═════════════                       │
│  距离排名: #1,234                   │
│  速度排名: #567                      │
│  爬升排名: #890                      │
│  [查看完整排名]                      │
└─────────────────────────────────────┘
```

---

## 三、终端设计（移动端）

### 3.1 技术栈选择

#### 3.1.1 跨平台方案
**推荐方案**：Flutter

**选择理由**：
- 一套代码多端运行（iOS、Android）
- 性能接近原生
- 丰富的第三方库
- 谷歌官方支持

**备选方案**：React Native、原生开发

#### 3.1.2 核心依赖库

```yaml
状态管理:
  - flutter_bloc / riverpod

网络请求:
  - dio / retrofit

本地存储:
  - hive / shared_preferences
  - sqflite (SQLite)

地图服务:
  - flutter_map (OpenStreetMap)
  - 高德地图SDK
  - 百度地图SDK

GPS定位:
  - geolocator
  - location

传感器连接:
  - flutter_blue_plus (BLE)

图表可视化:
  - fl_chart
  - syncfusion_flutter_charts

视频/图片:
  - image_picker
  - camera

权限管理:
  - permission_handler

工具类:
  - intl (国际化)
  - path_provider
  - package_info_plus
```

### 3.2 架构设计

#### 3.2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Pages   │  │ Widgets  │  │ Dialogs  │  │  Bottom   │   │
│  │          │  │          │  │          │  │Navigation│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Bloc   │  │Use Cases │  │ Services │  │ Repos    │   │
│  │ Providers│  │          │  │          │  │          │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                       Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Local   │  │  Remote  │  │  Models  │  │  Data    │   │
│  │  Storage │  │  API     │  │          │  │ Sources  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

#### 3.2.2 目录结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # App配置
├── config/                            # 配置
│   ├── env_config.dart
│   ├── api_config.dart
│   └── route_config.dart
├── core/                              # 核心功能
│   ├── constants/                     # 常量
│   ├── theme/                         # 主题
│   ├── utils/                         # 工具类
│   └── extensions/                    # 扩展方法
├── data/                              # 数据层
│   ├── models/                        # 数据模型
│   ├── repositories/                  # 仓储
│   ├── datasources/                   # 数据源
│   │   ├── local/                     # 本地数据源
│   │   └── remote/                    # 远程数据源
│   └── dto/                           # 数据传输对象
├── domain/                            # 领域层
│   ├── entities/                      # 实体
│   ├── repositories/                  # 仓储接口
│   └── usecases/                      # 用例
├── presentation/                      # 表现层
│   ├── pages/                         # 页面
│   │   ├── home/
│   │   ├── ride/
│   │   ├── route/
│   │   ├── analysis/
│   │   ├── community/
│   │   └── profile/
│   ├── widgets/                       # 通用组件
│   │   ├── charts/
│   │   ├── maps/
│   │   └── cards/
│   ├── bloc/                          # Bloc
│   └── routes/                        # 路由
└── services/                          # 服务
    ├── location_service.dart          # 定位服务
    ├── gps_service.dart               # GPS服务
    ├── sensor_service.dart            # 传感器服务
    ├── bluetooth_service.dart         # 蓝牙服务
    └── notification_service.dart      # 推送服务
```

### 3.3 核心模块实现

#### 3.3.1 GPS定位服务

```dart
// services/location_service.dart
class LocationService {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  final List<LocationData> _locationHistory = [];

  // 开始定位
  Future<bool> startLocationTracking() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      _locationHistory.add(locationData);
      // 上传到服务器
      _uploadLocation(locationData);
    });

    return true;
  }

  // 停止定位
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // 获取当前位置
  Future<LocationData?> getCurrentLocation() async {
    return await _location.getLocation();
  }

  // 计算两点间距离
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 地球半径（米）
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
        cos(_degreesToRadians(lat2)) *
        pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
```

#### 3.3.2 传感器连接服务

```dart
// services/sensor_service.dart
class SensorService {
  final FlutterBluePlus _ble = FlutterBluePlus.instance;
  final Map<String, BluetoothDevice> _connectedDevices = {};

  // 扫描蓝牙设备
  Stream<List<ScanResult>> scanDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  // 连接设备
  Future<bool> connectDevice(String deviceId) async {
    try {
      BluetoothDevice device = await _ble.connect(deviceId).first;
      _connectedDevices[deviceId] = device;
      return true;
    } catch (e) {
      print('连接失败: $e');
      return false;
    }
  }

  // 断开设备
  Future<void> disconnectDevice(String deviceId) async {
    await _connectedDevices[deviceId]?.disconnect();
    _connectedDevices.remove(deviceId);
  }

  // 读取心率数据
  Stream<int> readHeartRate(String deviceId) async* {
    BluetoothDevice device = _connectedDevices[deviceId];
    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        // 心率服务UUID: 0x180D
        if (service.uuid.toString().contains('180D')) {
          characteristic.setNotifyValue(true);

          await for (var value in characteristic.value) {
            // 解析心率数据
            int heartRate = _parseHeartRate(value);
            yield heartRate;
          }
        }
      }
    }
  }

  // 解析心率数据
  int _parseHeartRate(List<int> data) {
    // 心率数据格式根据标准定义
    if (data.length > 1) {
      return data[1];
    }
    return 0;
  }
}
```

#### 3.3.3 骑行记录服务

```dart
// services/ride_service.dart
class RideService {
  final LocationService _locationService = LocationService();
  final RideRepository _rideRepository;

  RideData? _currentRide;
  Timer? _timer;
  bool _isRiding = false;

  // 开始骑行
  Future<void> startRide({
    required String routeId,
    required String routeName,
  }) async {
    if (_isRiding) return;

    // 开始定位
    await _locationService.startLocationTracking();

    // 创建骑行记录
    _currentRide = RideData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routeId: routeId,
      routeName: routeName,
      startTime: DateTime.now(),
      locations: [],
      distances: [0.0],
      speeds: [],
      heartRates: [],
      cadences: [],
    );

    // 启动定时器，每秒更新数据
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRideData();
    });

    _isRiding = true;
  }

  // 更新骑行数据
  Future<void> _updateRideData() async {
    if (_currentRide == null) return;

    // 获取当前位置
    LocationData? location = await _locationService.getCurrentLocation();
    if (location == null) return;

    // 添加位置点
    _currentRide!.locations.add(RideLocation(
      latitude: location.latitude!,
      longitude: location.longitude!,
      altitude: location.altitude ?? 0.0,
      timestamp: DateTime.now(),
    ));

    // 计算距离
    double distance = _calculateTotalDistance();
    _currentRide!.distances.add(distance);

    // 计算速度
    double speed = _calculateSpeed();
    _currentRide!.speeds.add(speed);

    // 更新骑行记录到UI
    _notifyRideUpdate();
  }

  // 暂停骑行
  void pauseRide() {
    _timer?.cancel();
    _timer = null;
    _locationService.stopLocationTracking();
    _currentRide!.isPaused = true;
  }

  // 继续骑行
  Future<void> resumeRide() async {
    if (!_currentRide!.isPaused) return;

    await _locationService.startLocationTracking();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRideData();
    });
    _currentRide!.isPaused = false;
  }

  // 结束骑行
  Future<void> endRide() async {
    _timer?.cancel();
    _timer = null;
    _locationService.stopLocationTracking();

    _currentRide!.endTime = DateTime.now();

    // 计算统计数据
    _calculateRideStats();

    // 保存骑行记录
    await _rideRepository.saveRide(_currentRide!);

    // 上传到服务器
    await _rideRepository.uploadRide(_currentRide!);

    _isRiding = false;
    _currentRide = null;
  }

  // 计算总距离
  double _calculateTotalDistance() {
    if (_currentRide!.locations.length < 2) return 0.0;

    double totalDistance = _currentRide!.distances.last;
    RideLocation lastLocation = _currentRide!.locations[_currentRide!.locations.length - 2];
    RideLocation currentLocation = _currentRide!.locations.last;

    double distance = _locationService.calculateDistance(
      lastLocation.latitude,
      lastLocation.longitude,
      currentLocation.latitude,
      currentLocation.longitude,
    );

    return totalDistance + distance;
  }

  // 计算速度
  double _calculateSpeed() {
    if (_currentRide!.locations.length < 2) return 0.0;

    RideLocation lastLocation = _currentRide!.locations[_currentRide!.locations.length - 2];
    RideLocation currentLocation = _currentRide!.locations.last;

    double distance = _locationService.calculateDistance(
      lastLocation.latitude,
      lastLocation.longitude,
      currentLocation.latitude,
      currentLocation.longitude,
    );

    double timeDiff = currentLocation.timestamp.difference(lastLocation.timestamp).inSeconds;

    return timeDiff > 0 ? (distance / timeDiff) * 3.6 : 0.0; // 转换为km/h
  }

  // 计算骑行统计数据
  void _calculateRideStats() {
    // 平均速度
    _currentRide!.averageSpeed = _calculateAverageSpeed();

    // 最大速度
    _currentRide!.maxSpeed = _currentRide!.speeds.reduce((a, b) => a > b ? a : b);

    // 总爬升
    _currentRide!.ascent = _calculateAscent();

    // 总下降
    _currentRide!.descent = _calculateDescent();

    // 消耗卡路里
    _currentRide!.calories = _calculateCalories();

    // 骑行时长
    _currentRide!.duration = _currentRide!.endTime!.difference(_currentRide!.startTime);
  }

  // 计算平均速度
  double _calculateAverageSpeed() {
    if (_currentRide!.distances.isEmpty) return 0.0;
    double totalDistance = _currentRide!.distances.last;
    int duration = _currentRide!.endTime!.difference(_currentRide!.startTime).inSeconds;
    return duration > 0 ? (totalDistance / duration) * 3.6 : 0.0;
  }

  // 计算爬升高度
  double _calculateAscent() {
    double ascent = 0.0;
    for (int i = 1; i < _currentRide!.locations.length; i++) {
      double altitudeDiff = _currentRide!.locations[i].altitude - _currentRide![i - 1].altitude;
      if (altitudeDiff > 0) {
        ascent += altitudeDiff;
      }
    }
    return ascent;
  }

  // 计算下降高度
  double _calculateDescent() {
    double descent = 0.0;
    for (int i = 1; i < _currentRide!.locations.length; i++) {
      double altitudeDiff = _currentRide!.locations[i].altitude - _currentRide![i - 1].altitude;
      if (altitudeDiff < 0) {
        descent += altitudeDiff.abs();
      }
    }
    return descent;
  }

  // 计算消耗卡路里
  int _calculateCalories() {
    // 简化计算：根据距离和速度估算
    double avgSpeed = _currentRide!.averageSpeed;
    double distance = _currentRide!.distances.last;

    // 基础代谢率 (简化版)
    double baseCaloriesPerKm = 30.0;

    // 速度系数
    double speedFactor = avgSpeed / 20.0;

    return (distance * baseCaloriesPerKm * speedFactor).toInt();
  }
}
```

#### 3.3.4 地图服务

```dart
// widgets/maps/ride_map.dart
class RideMap extends StatefulWidget {
  final List<RideLocation> locations;
  final bool isLive;

  const RideMap({
    super.key,
    required this.locations,
    this.isLive = false,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locations.isEmpty) {
      return Center(child: Text('暂无骑行数据'));
    }

    List<LatLng> points = widget.locations
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: points.first,
        initialZoom: 14.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.rideflow',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: 4.0,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        if (widget.isLive)
          MarkerLayer(
            markers: [
              Marker(
                point: points.last,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.directions_bike,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        // 起点标记
        if (!widget.isLive)
          MarkerLayer(
            markers: [
              Marker(
                point: points.first,
                width: 30,
                height: 30,
                child: Icon(
                  Icons.circle,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              Marker(
                point: points.last,
                width: 30,
                height: 30,
                child: Icon(
                  Icons.flag,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
```

#### 3.3.5 图表组件

```dart
// widgets/charts/heart_rate_chart.dart
class HeartRateChart extends StatelessWidget {
  final List<int> heartRates;
  final String title;

  const HeartRateChart({
    super.key,
    required this.heartRates,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 2.5,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: heartRates
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                      .toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### 3.4 UI设计规范

#### 3.4.1 主题配置

```dart
// config/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Color(0xFF2196F3),
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2196F3),
        secondary: Color(0xFFFF5722),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFF44336),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Color(0xFF1976D2),
      scaffoldBackgroundColor: Color(0xFF121212),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFFFF7043),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFEF5350),
      ),
    );
  }
}
```

#### 3.4.2 底部导航栏

```dart
// widgets/common/bottom_navigation.dart
class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '首页',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: '路线',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.directions_bike_outlined,
                activeIcon: Icons.directions_bike,
                label: '骑行',
                index: 2,
                isPrimary: true,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people_outlined,
                activeIcon: Icons.people,
                label: '社区',
                index: 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '我的',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isPrimary = false,
  }) {
    final isActive = currentIndex == index;

    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              child: Icon(
                activeIcon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 四、后端架构设计

### 4.1 技术栈选择

#### 4.1.1 后端框架
**推荐方案**：Spring Boot 3.x + Spring Cloud Alibaba

**选择理由**：
- 生态完善，社区活跃
- 适合中大型项目
- 微服务支持好
- 与前端技术栈统一（您之前有Java经验）

#### 4.1.2 数据存储

```yaml
关系型数据库:
  - MySQL 8.0 (主数据库)
  - 分库分表: ShardingSphere

缓存:
  - Redis 7.0 (缓存、会话)
  - Redis Cluster (分布式缓存)

文档数据库:
  - MongoDB (日志、非结构化数据)

搜索引擎:
  - Elasticsearch (全文搜索)

对象存储:
  - MinIO (图片、GPX文件)
  - 阿里云OSS (备选)

消息队列:
  - RocketMQ (异步处理)
  - Kafka (大数据流处理)

时序数据库:
  - InfluxDB (骑行数据存储，可选)
```

#### 4.1.3 基础设施

```yaml
服务注册/发现:
  - Nacos

配置中心:
  - Nacos Config

API网关:
  - Spring Cloud Gateway

负载均衡:
  - Spring Cloud LoadBalancer

熔断降级:
  - Sentinel

分布式事务:
  - Seata

监控告警:
  - Prometheus + Grafana
  - SkyWalking (APM)

日志收集:
  - ELK Stack
```

### 4.2 服务拆分

#### 4.2.1 服务列表

```
┌─────────────────────────────────────────────────────────────┐
│                    微服务架构                                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │用户服务  │ │骑行服务  │ │路线服务  │ │分析服务  │       │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │社区服务  │ │挑战服务  │ │车队服务  │ │通知服务  │       │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                   │
│  │设备服务  │ │训练服务  │ │支付服务  │                   │
│ └──────────┘ └──────────┘ └──────────┘                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

#### 4.2.2 服务详细说明

**1. 用户服务 (user-service)**
- 用户注册/登录
- 用户信息管理
- 第三方登录（微信、Apple ID）
- 用户权限管理
- API密钥管理

**2. 骑行服务 (ride-service)**
- 骑行记录CRUD
- 骑行数据上传
- 骑行轨迹管理
- 实时骑行数据流
- 骑行统计分析

**3. 路线服务 (route-service)**
- 路线CRUD
- 路线搜索
- 路线推荐
- 热门路线
- 路线分享

**4. 分析服务 (analysis-service)**
- 数据统计分析
- 趋势分析
- 对比分析
- 预测分析
- 报告生成

**5. 社区服务 (community-service)**
- 骑行动态
- 评论/点赞
- 用户关注
- 聊天功能
- 圈子管理

**6. 挑战服务 (challenge-service)**
- 挑战管理
- 挑战参与
- 排行榜
- 成就系统
- 奖励发放

**7. 车队服务 (team-service)**
- 车队管理
- 成员管理
- 车队活动
- 车队数据统计

**8. 通知服务 (notification-service)**
- 推送通知
- 短信通知
- 邮件通知
- 消息中心

**9. 设备服务 (device-service)**
- 设备绑定
- 设备同步
- 设备管理
- 传感器数据

**10. 训练服务 (training-service)**
- 训练计划生成
- 训练记录
- 训练效果评估
- FTP估算

**11. 支付服务 (payment-service)**
- 订单管理
- 支付集成
- 退款处理
- 会员订阅

### 4.3 数据库设计

#### 4.3.1 分库分表策略

```yaml
用户库:
  user_db:
    - user_info (用户基本信息)
    - user_profile (用户详细资料)
    - user_device (用户设备)
    - user_settings (用户设置)

骑行库:
  ride_db:
    - ride_record (骑行记录)
    - ride_track (骑行轨迹)
    - ride_metrics (骑行指标)
    - ride_photo (骑行照片)

路线库:
  route_db:
    - route_info (路线信息)
    - route_track (路线轨迹)
    - route_rating (路线评分)

社区库:
  community_db:
    - post (动态)
    - comment (评论)
    - like (点赞)
    - follow (关注)
```

#### 4.3.2 核心表设计

**用户表**
```sql
CREATE TABLE user_info (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar VARCHAR(255) COMMENT '头像URL',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    password_hash VARCHAR(255) COMMENT '密码哈希',
    status TINYINT DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';
```

**骑行记录表**
```sql
CREATE TABLE ride_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '骑行记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    route_id BIGINT COMMENT '路线ID',
    title VARCHAR(100) COMMENT '骑行标题',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    duration INT COMMENT '骑行时长(秒)',
    distance DECIMAL(10, 2) COMMENT '距离(km)',
    average_speed DECIMAL(5, 2) COMMENT '平均速度(km/h)',
    max_speed DECIMAL(5, 2) COMMENT '最大速度(km/h)',
    ascent DECIMAL(8, 2) COMMENT '爬升高度(m)',
    descent DECIMAL(8, 2) COMMENT '下降高度(m)',
    max_altitude DECIMAL(8, 2) COMMENT '最高海拔(m)',
    min_altitude DECIMAL(8, 2) COMMENT '最低海拔(m)',
    average_heart_rate INT COMMENT '平均心率(bpm)',
    max_heart_rate INT COMMENT '最大心率(bpm)',
    average_cadence INT COMMENT '平均踏频(rpm)',
    max_cadence INT COMMENT '最大踏频(rpm)',
    average_power INT COMMENT '平均功率(w)',
    max_power INT COMMENT '最大功率(w)',
    calories INT COMMENT '消耗卡路里',
    status TINYINT DEFAULT 1 COMMENT '状态 1-完成 0-进行中',
    is_public TINYINT DEFAULT 1 COMMENT '是否公开',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_start_time (start_time),
    INDEX idx_distance (distance)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='骑行记录表';
```

**骑行轨迹表**
```sql
CREATE TABLE ride_track (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '轨迹点ID',
    ride_id BIGINT NOT NULL COMMENT '骑行记录ID',
    sequence INT NOT NULL COMMENT '序号',
    latitude DECIMAL(10, 7) NOT NULL COMMENT '纬度',
    longitude DECIMAL(10, 7) NOT NULL COMMENT '经度',
    altitude DECIMAL(8, 2) COMMENT '海拔(m)',
    speed DECIMAL(5, 2) COMMENT '速度(km/h)',
    heart_rate INT COMMENT '心率(bpm)',
    cadence INT COMMENT '踏频(rpm)',
    power INT COMMENT '功率(w)',
    timestamp DATETIME NOT NULL COMMENT '时间戳',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ride_id (ride_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='骑行轨迹表';
```

**路线表**
```sql
CREATE TABLE route_info (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '路线ID',
    creator_id BIGINT NOT NULL COMMENT '创建者ID',
    name VARCHAR(100) NOT NULL COMMENT '路线名称',
    description TEXT COMMENT '路线描述',
    distance DECIMAL(10, 2) COMMENT '距离(km)',
    ascent DECIMAL(8, 2) COMMENT '爬升(m)',
    descent DECIMAL(8, 2) COMMENT '下降(m)',
    max_altitude DECIMAL(8, 2) COMMENT '最高海拔(m)',
    difficulty TINYINT COMMENT '难度等级 1-5',
    route_type VARCHAR(20) COMMENT '路线类型',
    tags JSON COMMENT '标签',
    cover_image VARCHAR(255) COMMENT '封面图',
    view_count INT DEFAULT 0 COMMENT '浏览次数',
    ride_count INT DEFAULT 0 COMMENT '骑行次数',
    rating DECIMAL(3, 2) DEFAULT 0 COMMENT '评分',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_id (creator_id),
    INDEX idx_distance (distance),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='路线信息表';
```

**动态表**
```sql
CREATE TABLE post (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '动态ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type VARCHAR(20) NOT NULL COMMENT '类型 ride/route/photo/text',
    title VARCHAR(200) COMMENT '标题',
    content TEXT COMMENT '内容',
    images JSON COMMENT '图片列表',
    ride_id BIGINT COMMENT '骑行记录ID',
    route_id BIGINT COMMENT '路线ID',
    location VARCHAR(100) COMMENT '位置',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    comment_count INT DEFAULT 0 COMMENT '评论数',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态表';
```

**挑战表**
```sql
CREATE TABLE challenge (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '挑战ID',
    name VARCHAR(100) NOT NULL COMMENT '挑战名称',
    description TEXT COMMENT '挑战描述',
    type VARCHAR(20) NOT NULL COMMENT '类型 distance/ascent/time',
    target_value DECIMAL(10, 2) NOT NULL COMMENT '目标值',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME NOT NULL COMMENT '结束时间',
    participant_count INT DEFAULT 0 COMMENT '参与人数',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='挑战表';
```

### 4.4 核心API设计

#### 4.4.1 骑行相关API

```yaml
# 骑行记录
POST   /api/v1/rides/start                    # 开始骑行
POST   /api/v1/rides/pause                    # 暂停骑行
POST   /api/v1/rides/resume                   # 继续骑行
POST   /api/v1/rides/end                      # 结束骑行
POST   /api/v1/rides/upload                   # 上传骑行数据
GET    /api/v1/rides                          # 获取骑行列表
GET    /api/v1/rides/{id}                     # 获取骑行详情
DELETE /api/v1/rides/{id}                     # 删除骑行记录

# 骑行轨迹
POST   /api/v1/rides/{id}/tracks              # 上传轨迹点
GET    /api/v1/rides/{id}/tracks              # 获取轨迹
GET    /api/v1/rides/{id}/tracks/gpx          # 导出GPX

# 骑行统计
GET    /api/v1/rides/statistics/summary       # 总体统计
GET    /api/v1/rides/statistics/trend         # 趋势分析
GET    /api/v1/rides/statistics/comparison    # 对比分析
```

#### 4.4.2 路线相关API

```yaml
# 路线管理
POST   /api/v1/routes                         # 创建路线
GET    /api/v1/routes                         # 获取路线列表
GET    /api/v1/routes/{id}                    # 获取路线详情
PUT    /api/v1/routes/{id}                    # 更新路线
DELETE /api/v1/routes/{id}                    # 删除路线

# 路线推荐
GET    /api/v1/routes/recommended             # 推荐路线
GET    /api/v1/routes/nearby                  # 附近路线
GET    /api/v1/routes/popular                 # 热门路线

# 路线评分
POST   /api/v1/routes/{id}/rating            # 路线评分
GET    /api/v1/routes/{id}/rating            # 获取评分
```

#### 4.4.3 分析相关API

```yaml
# 数据分析
GET    /api/v1/analysis/distance             # 距离分析
GET    /api/v1/analysis/speed                # 速度分析
GET    /api/v1/analysis/heart-rate           # 心率分析
GET    /api/v1/analysis/power                # 功率分析
GET    /api/v1/analysis/ascent                # 爬升分析

# 报告生成
POST   /api/v1/analysis/report               # 生成报告
GET    /api/v1/analysis/report/{id}          # 获取报告
GET    /api/v1/analysis/report/{id}/download # 下载报告
```

#### 4.4.4 社区相关API

```yaml
# 动态
POST   /api/v1/posts                          # 发布动态
GET    /api/v1/posts                          # 获取动态列表
GET    /api/v1/posts/{id}                     # 获取动态详情
DELETE /api/v1/posts/{id}                     # 删除动态

# 互动
POST   /api/v1/posts/{id}/like                # 点赞
DELETE /api/v1/posts/{id}/like                # 取消点赞
POST   /api/v1/posts/{id}/comment             # 评论
GET    /api/v1/posts/{id}/comments            # 获取评论

# 关注
POST   /api/v1/users/{id}/follow             # 关注用户
DELETE /api/v1/users/{id}/follow             # 取消关注
GET    /api/v1/users/{id}/followers          # 获取粉丝
GET    /api/v1/users/{id}/following          # 获取关注
```

### 4.5 核心功能实现

#### 4.5.1 骑行数据上传与处理

```java
@Service
public class RideUploadService {

    @Autowired
    private RideRecordRepository rideRecordRepository;

    @Autowired
    private RideTrackRepository rideTrackRepository;

    @Autowired
    private DataAnalysisService dataAnalysisService;

    /**
     * 处理骑行数据上传
     */
    @Transactional
    public RideRecord processRideUpload(RideUploadDTO uploadDTO) {
        // 1. 保存骑行记录
        RideRecord record = new RideRecord();
        record.setUserId(uploadDTO.getUserId());
        record.setStartTime(uploadDTO.getStartTime());
        record.setEndTime(uploadDTO.getEndTime());
        rideRecordRepository.save(record);

        // 2. 批量保存轨迹点
        List<RideTrack> tracks = uploadDTO.getTracks().stream()
                .map(dto -> convertToTrack(dto, record.getId()))
                .collect(Collectors.toList());
        rideTrackRepository.saveAll(tracks);

        // 3. 计算统计数据
        calculateRideStats(record, tracks);

        // 4. 异步分析数据
        asyncAnalyzeData(record, tracks);

        // 5. 更新用户统计数据
        updateUserStats(uploadDTO.getUserId(), record);

        return record;
    }

    /**
     * 计算骑行统计数据
     */
    private void calculateRideStats(RideRecord record, List<RideTrack> tracks) {
        // 距离
        double distance = calculateTotalDistance(tracks);
        record.setDistance(distance);

        // 时长
        Duration duration = Duration.between(record.getStartTime(), record.getEndTime());
        record.setDuration((int) duration.getSeconds());

        // 速度
        double avgSpeed = distance / (duration.getSeconds() / 3600.0);
        record.setAverageSpeed(avgSpeed);
        record.setMaxSpeed(calculateMaxSpeed(tracks));

        // 爬升/下降
        record.setAscent(calculateAscent(tracks));
        record.setDescent(calculateDescent(tracks));

        // 最高/最低海拔
        record.setMaxAltitude(tracks.stream().mapToDouble(RideTrack::getAltitude).max().orElse(0));
        record.setMinAltitude(tracks.stream().mapToDouble(RideTrack::getAltitude).min().orElse(0));

        // 心率
        record.setAverageHeartRate(calculateAverageHeartRate(tracks));
        record.setMaxHeartRate(calculateMaxHeartRate(tracks));

        // 踏频
        record.setAverageCadence(calculateAverageCadence(tracks));
        record.setMaxCadence(calculateMaxCadence(tracks));

        // 卡路里
        record.setCalories(calculateCalories(record, tracks));

        rideRecordRepository.save(record);
    }

    /**
     * 计算总距离
     */
    private double calculateTotalDistance(List<RideTrack> tracks) {
        double totalDistance = 0.0;
        for (int i = 1; i < tracks.size(); i++) {
            RideTrack p1 = tracks.get(i - 1);
            RideTrack p2 = tracks.get(i);

            totalDistance += HaversineDistance.calculate(
                    p1.getLatitude(), p1.getLongitude(),
                    p2.getLatitude(), p2.getLongitude()
            );
        }
        return totalDistance;
    }

    /**
     * 计算爬升高度
     */
    private double calculateAscent(List<RideTrack> tracks) {
        double ascent = 0.0;
        for (int i = 1; i < tracks.size(); i++) {
            double altDiff = tracks.get(i).getAltitude() - tracks.get(i - 1).getAltitude();
            if (altDiff > 0) {
                ascent += altDiff;
            }
        }
        return ascent;
    }

    /**
     * 计算卡路里
     */
    private int calculateCalories(RideRecord record, List<RideTrack> tracks) {
        // 简化计算公式
        double avgHeartRate = record.getAverageHeartRate();
        double weight = 70.0; // 默认体重，实际应该从用户数据获取
        double durationHours = record.getDuration() / 3600.0;

        // MET估算
        double met = 8.0; // 骑行MET值
        double calories = met * weight * durationHours;

        return (int) calories;
    }
}

/**
 * Haversine距离计算
 */
public class HaversineDistance {

    private static final double EARTH_RADIUS = 6371000; // 地球半径（米）

    public static double calculate(double lat1, double lon1, double lat2, double lon2) {
        double dLat = toRadians(lat2 - lat1);
        double dLon = toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS * c;
    }

    private static double toRadians(double degrees) {
        return degrees * Math.PI / 180;
    }
}
```

#### 4.5.2 路线推荐算法

```java
@Service
public class RouteRecommendationService {

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private UserService userService;

    /**
     * 推荐路线
     */
    public List<RouteDTO> recommendRoutes(Long userId, RouteRecommendRequest request) {
        // 1. 获取用户信息
        UserInfo user = userService.getUserById(userId);

        // 2. 获取候选路线
        List<Route> candidates = routeRepository.findCandidates(
                user.getLocation(),
                request.getDistanceMin(),
                request.getDistanceMax()
        );

        // 3. 为每条路线评分
        List<RouteScore> scoredRoutes = candidates.stream()
                .map(route -> scoreRoute(route, user, request))
                .collect(Collectors.toList());

        // 4. 排序并返回Top N
        return scoredRoutes.stream()
                .sorted((a, b) -> Double.compare(b.getScore(), a.getScore()))
                .limit(10)
                .map(RouteScore::getRoute)
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 路线评分
     */
    private RouteScore scoreRoute(Route route, UserInfo user, RouteRecommendRequest request) {
        double score = 0.0;

        // 1. 距离匹配度 (30%)
        double distanceMatch = calculateDistanceMatch(route, request);
        score += distanceMatch * 30;

        // 2. 难度匹配度 (25%)
        double difficultyMatch = calculateDifficultyMatch(route, user);
        score += difficultyMatch * 25;

        // 3. 热度 (20%)
        double popularity = calculatePopularity(route);
        score += popularity * 20;

        // 4. 类型偏好 (15%)
        double typePreference = calculateTypePreference(route, user);
        score += typePreference * 15;

        // 5. 距离距离 (10%)
        double distanceProximity = calculateDistanceProximity(route, user.getLocation());
        score += distanceProximity * 10;

        return new RouteScore(route, score);
    }

    /**
     * 计算距离匹配度
     */
    private double calculateDistanceMatch(Route route, RouteRecommendRequest request) {
        double targetDistance = (request.getDistanceMin() + request.getDistanceMax()) / 2.0;
        double distanceDiff = Math.abs(route.getDistance() - targetDistance);
        return Math.max(0, 1.0 - distanceDiff / targetDistance);
    }

    /**
     * 计算难度匹配度
     */
    private double calculateDifficultyMatch(Route route, UserInfo user) {
        int userLevel = user.getRidingLevel();
        int routeDifficulty = route.getDifficulty();

        double diff = Math.abs(userLevel - routeDifficulty);
        return Math.max(0, 1.0 - diff / 5.0);
    }

    /**
     * 计算热度
     */
    private double calculatePopularity(Route route) {
        // 标准化到0-1
        return Math.min(1.0, route.getRideCount() / 1000.0);
    }

    /**
     * 计算类型偏好
     */
    private double calculateTypePreference(Route route, UserInfo user) {
        String userPreference = user.getRouteTypePreference();
        return route.getRouteType().equals(userPreference) ? 1.0 : 0.5;
    }

    /**
     * 计算距离距离
     */
    private double calculateDistanceProximity(Route route, String userLocation) {
        // 简化处理，实际应该计算地理距离
        return 0.5;
    }
}
```

#### 4.5.3 数据分析服务

```java
@Service
public class DataAnalysisService {

    @Autowired
    private RideRecordRepository rideRecordRepository;

    /**
     * 分析距离趋势
     */
    public DistanceTrendDTO analyzeDistanceTrend(Long userId, int months) {
        LocalDate startDate = LocalDate.now().minusMonths(months);

        // 获取骑行记录
        List<RideRecord> rides = rideRecordRepository.findByUserIdAndStartTimeAfter(userId, startDate);

        // 按月分组统计
        Map<YearMonth, List<RideRecord>> grouped = rides.stream()
                .collect(Collectors.groupingBy(r -> YearMonth.from(r.getStartTime())));

        // 生成趋势数据
        List<MonthDistanceData> trendData = new ArrayList<>();
        for (int i = months - 1; i >= 0; i--) {
            YearMonth yearMonth = YearMonth.now().minusMonths(i);
            List<RideRecord> monthRides = grouped.getOrDefault(yearMonth, Collections.emptyList());

            double totalDistance = monthRides.stream()
                    .mapToDouble(RideRecord::getDistance)
                    .sum();

            int rideCount = monthRides.size();

            trendData.add(MonthDistanceData.builder()
                    .month(yearMonth.toString())
                    .distance(totalDistance)
                    .rideCount(rideCount)
                    .build());
        }

        return DistanceTrendDTO.builder()
                .userId(userId)
                .months(months)
                .trendData(trendData)
                .build();
    }

    /**
     * 分析心率区间分布
     */
    public HeartRateZoneDTO analyzeHeartRateZones(Long userId, LocalDate startDate, LocalDate endDate) {
        List<RideRecord> rides = rideRecordRepository.findByUserIdAndStartTimeBetween(
                userId, startDate, endDate);

        // 收集所有心率数据
        List<Integer> allHeartRates = new ArrayList<>();
        for (RideRecord ride : rides) {
            allHeartRates.add(ride.getAverageHeartRate());
            allHeartRates.add(ride.getMaxHeartRate());
        }

        if (allHeartRates.isEmpty()) {
            return HeartRateZoneDTO.empty();
        }

        // 计算最大心率（简化，实际应该从传感器数据获取）
        int maxHeartRate = allHeartRates.stream().mapToInt(Integer::intValue).max().orElse(200);

        // 计算各区间的分布
        Map<Integer, Integer> zoneDistribution = new HashMap<>();
        for (int hr : allHeartRates) {
            int zone = calculateHeartRateZone(hr, maxHeartRate);
            zoneDistribution.put(zone, zoneDistribution.getOrDefault(zone, 0) + 1);
        }

        return HeartRateZoneDTO.builder()
                .maxHeartRate(maxHeartRate)
                .zone1Count(zoneDistribution.getOrDefault(1, 0))
                .zone2Count(zoneDistribution.getOrDefault(2, 0))
                .zone3Count(zoneDistribution.getOrDefault(3, 0))
                .zone4Count(zoneDistribution.getOrDefault(4, 0))
                .zone5Count(zoneDistribution.getOrDefault(5, 0))
                .build();
    }

    /**
     * 计算心率区间
     */
    private int calculateHeartRateZone(int heartRate, int maxHeartRate) {
        double percentage = (double) heartRate / maxHeartRate;

        if (percentage < 0.6) return 1;
        if (percentage < 0.7) return 2;
        if (percentage < 0.8) return 3;
        if (percentage < 0.9) return 4;
        return 5;
    }

    /**
     * 生成骑行报告
     */
    public RideReportDTO generateRideReport(Long userId, LocalDate startDate, LocalDate endDate) {
        List<RideRecord> rides = rideRecordRepository.findByUserIdAndStartTimeBetween(
                userId, startDate, endDate);

        if (rides.isEmpty()) {
            return RideReportDTO.empty();
        }

        // 总体统计
        double totalDistance = rides.stream().mapToDouble(RideRecord::getDistance).sum();
        int totalDuration = rides.stream().mapToInt(RideRecord::getDuration).sum();
        double totalAscent = rides.stream().mapToDouble(RideRecord::getAscent).sum();

        // 平均数据
        double avgDistance = totalDistance / rides.size();
        double avgSpeed = rides.stream().mapToDouble(RideRecord::getAverageSpeed).average().orElse(0);
        double avgHeartRate = rides.stream().mapToInt(RideRecord::getAverageHeartRate).average().orElse(0);

        // 最大值
        double maxDistance = rides.stream().mapToDouble(RideRecord::getDistance).max().orElse(0);
        double maxSpeed = rides.stream().mapToDouble(RideRecord::getMaxSpeed).max().orElse(0);

        // 消耗卡路里
        int totalCalories = rides.stream().mapToInt(RideRecord::getCalories).sum();

        return RideReportDTO.builder()
                .userId(userId)
                .startDate(startDate)
                .endDate(endDate)
                .rideCount(rides.size())
                .totalDistance(totalDistance)
                .totalDuration(totalDuration)
                .totalAscent(totalAscent)
                .averageDistance(avgDistance)
                .averageSpeed(avgSpeed)
                .averageHeartRate(avgHeartRate)
                .maxDistance(maxDistance)
                .maxSpeed(maxSpeed)
                .totalCalories(totalCalories)
                .build();
    }
}
```

### 4.6 性能优化

#### 4.6.1 缓存策略

```yaml
用户信息缓存:
  Key: user:{userId}
  TTL: 1小时
  更新: 用户信息变更时

骑行记录缓存:
  Key: ride:{userId}:{year}:{month}
  TTL: 30分钟
  更新: 新增骑行记录时

路线缓存:
  Key: route:{routeId}
  TTL: 24小时
  更新: 路线信息变更时

排行榜缓存:
  Key: ranking:{type}:{period}
  TTL: 1小时
  更新: 定时任务刷新
```

#### 4.6.2 异步处理

```java
/**
 * 异步处理骑行数据分析
 */
@Service
public class AsyncAnalysisService {

    @Autowired
    private DataAnalysisService dataAnalysisService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Async("analysisExecutor")
    public void analyzeRideData(Long rideId) {
        try {
            // 1. 获取骑行数据
            RideRecord ride = rideRecordRepository.findById(rideId).orElse(null);
            if (ride == null) return;

            // 2. 分析数据
            List<AnalysisResult> results = dataAnalysisService.analyze(ride);

            // 3. 缓存结果
            String cacheKey = "analysis:ride:" + rideId;
            redisTemplate.opsForValue().set(cacheKey, results, 24, TimeUnit.HOURS);

            // 4. 更新用户统计
            updateUserStats(ride.getUserId(), results);

        } catch (Exception e) {
            log.error("分析骑行数据失败: rideId={}", rideId, e);
        }
    }
}
```

### 4.7 监控与运维

#### 4.7.1 关键指标监控

```yaml
业务指标:
  - 日活跃用户数 (DAU)
  - 日骑行次数
  - 日骑行总距离
  - 新增用户数

技术指标:
  - API响应时间 (P50/P95/P99)
  - API错误率
  - 数据库查询时间
  - 缓存命中率

资源指标:
  - CPU使用率
  - 内存使用率
  - 磁盘使用率
  - 网络流量
```

---

## 五、开发计划

### 5.1 MVP阶段（3个月）

#### 第1个月
- [ ] 项目搭建（后端、前端）
- [ ] 用户注册/登录
- [ ] 基础骑行记录功能
- [ ] GPS定位功能

#### 第2个月
- [ ] 骑行轨迹记录
- [ ] 基础数据统计
- [ ] 骑行数据可视化
- [ ] 传感器连接（心率、踏频）

#### 第3个月
- [ ] 路线功能（浏览、分享）
- [ ] 基础社区功能
- [ ] 简单的数据分析
- [ ] 测试与优化

### 5.2 V1.0阶段（6个月）

- [ ] 完整的数据分析功能
- [ ] 路线推荐
- [ ] 训练计划
- [ ] 挑战活动
- [ ] 车队管理
- [ ] 性能优化

### 5.3 V2.0阶段（12个月）

- [ ] AI路线推荐
- [ ] 功率分析
- [ ] 个性化训练
- [ ] 社交功能增强
- [ ] 商业化功能

---

## 六、总结

这个骑行软件设计方案涵盖了从产品定位到技术实现的完整内容。作为骑行爱好者和研发人员，您可以：

1. **从自己最需要的功能开始** - 比如精准的骑行记录和数据分析
2. **注重数据准确性** - 这是骑行软件的核心竞争力
3. **逐步扩展功能** - 先MVP，再根据用户反馈迭代
4. **重视用户体验** - 做到简单易用，操作流畅

祝您的骑行软件开发顺利！🚴

---

**文档版本**：v1.0
**创建日期**：2025-03-13
