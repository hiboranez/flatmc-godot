# FlatMC Godot Edition Alpha 版本记录

> [!IMPORTANT]
> 本仓库缺少各历史版本对应的完整源码提交和可验证构建。所有规范化版本标签均使用 FlatMC Godot Edition 最终 `v0.2.0` 归档源码快照；GitHub 自动生成的源码压缩包不是早期 Release 的原始源码。

## Alpha v0.1.0 · 2024-11-10/11

原版本名称为 `Godot Alpha 0.1.0.0`，是首个公开 Godot 版本。

### 游戏基础

- 加入 Windows、Android、键鼠与触屏操作。
- 加入基础方块、超平坦世界和 16×16 区块存档。
- 加入主菜单、单人、多人、设置、语言、音乐和调试信息。
- 加入中英文、聊天、LAN 发现、手动服务器和官方测试服务器。
- 加入 `/help` 与 `/tp` 命令。

### 已知限制

- 仅有早期方块与超平坦世界，异常退出可能导致存档丢失。
- 多人状态同步受延迟影响时可能产生位置抖动。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.0)

## Alpha v0.1.1 · 2024-11-13/15

原版本名称为 `Godot Alpha 0.1.0.1`。

### 改进与修复

- 专用服务器日志增加时间信息。
- Android 返回键不再直接退出游戏。
- 增加版本设置字段并改进旧配置读取。
- 修复世界选择、聊天拖动、服务器退出提示等问题。
- 初步优化多人同步卡顿。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.1)

## Alpha v0.1.2 · 2024-11-16

原版本名称为 `Godot Alpha 0.1.1.0`。

### 方块与物品栏

- 加入基岩、矿石、矿物块、工作台、树叶和 16 色羊毛。
- 加入物品栏、快捷栏选择和物品名称提示。
- 加入玩家转身动画。

### 兼容性

- 加入旧存档向新版本转换的版本检查。
- 加入客户端与服务器版本识别，冲突版本会被拒绝连接。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.2)

## Alpha v0.1.3 · 2024-11-23

原版本名称为 `Godot Alpha 0.1.1.1`。

### 操作与平台

- 加入鼠标中键或触屏双击拾取方块。
- 加入 Windows x86-32 支持。
- 优化移动端按钮和物品栏交互。

### 修复

- 修复飞行状态、转身帧率、暂停、音乐设置和聊天操作问题。
- 限制玩家名格式与渲染范围。
- 减少传送过程中的重复区块请求。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.3)

## Alpha v0.1.4 · 2024-11-24

原版本名称为 `Godot Alpha 0.1.2.0`。

### 区块与服务器

- 区块由全量加载改为按需加载，不活跃区块会自动释放。
- 加入服务器日志并曾加入 Windows ARM64 支持。
- 优化服务端地图加载、内存占用和大批量区块传输。

### 修复

- 修复不存在区块请求导致服务器崩溃。
- 修复玩家抖动、未加载区块下坠、玩家列表和名称限制问题。
- 修复旧世界转换和多项移动端操作问题。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.4)

## Alpha v0.1.5 · 2024-12-14

原版本名称为 `Godot Alpha 0.1.3`。

### 生存与世界

- 加入生存模式、受伤提示、死亡动画和登录、离线、传送动画。
- 加入火把、光线传播和日光。
- 加入基于噪声的自然地形和平原生物群落。
- 调整 `/gamemode` 命令。

### 修复

- 修复碰撞、方块同时操作、区块同步和玩家位置回弹问题。
- 提升渲染范围并修正区块名称。
- 停止 Windows ARM64 支持。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.5)

## Alpha v0.1.6 · 2025-02-23

原版本名称为 `25w8a`。

### 归档说明

- 已确认原版本名称和发布日期。
- 独立的完整更新日志、原始源码和构建尚未恢复。
- 本 Release 不根据最终版功能反向推测此版本的具体变化。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.6)

## Alpha v0.1.7 · 2025-05-23

原版本名称为 `25w20a`。

### 归档说明

- 已确认原版本名称和发布日期。
- 独立的完整更新日志、原始源码和构建尚未恢复。
- 本 Release 不根据最终版功能反向推测此版本的具体变化。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.7)

## Alpha v0.1.8 · 2025-05-30

原版本名称为 `25w22a`。

### 归档说明

- 已确认原版本名称和发布日期。
- 独立的完整更新日志、原始源码和构建尚未恢复。
- 本 Release 不根据最终版功能反向推测此版本的具体变化。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.1.8)

## Alpha v0.2.0 · 2025-06-09/14

原版本名称为 `Godot Alpha 0.2.0`，是 FlatMC Godot Edition 最终大型版本。

### 世界与内容

- 大幅扩充方块、矿石、矿物块、装饰方块、工具和合成配方。
- 加入背景层、梯子、农业、树木生长、沙漠、矿洞和随机矿物。
- 加入剑、弓箭、耐久、挖掘等级、攻击冷却和粒子效果。
- 加入食物、饥饿、生物、掉落物、成就和完整昼夜表现。

### 玩家与界面

- 加入 3D 双层玩家皮肤、手持物、自动跳跃和完整物品栏交互。
- 加入小地图头像、平滑光照、全屏、垂直同步和材质包切换。
- 扩展至中文、英文、日语、韩语、西班牙语、法语、德语、俄语、阿拉伯语、印地语、越南语和泰语。

### 保存与联机

- 保存玩家生命、背包和实体信息。
- 改善联机位置容错、传送和方块操作稳定性。

[English release notes](https://github.com/hiboranez/flatmc-godot/releases/tag/v0.2.0)

## 项目状态

**已归档 / 不再维护。** FlatMC Godot Edition 已由 FlatCraft 取代。以上 Release 用于保存版本历史，不保证与 FlatCraft 兼容。

