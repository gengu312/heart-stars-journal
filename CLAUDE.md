# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 提供本仓库的开发指南。

## 项目概述

**心辰手记 (HeartStars Journal)** 是一款基于 **HarmonyOS Next** 的治愈系情绪记录与自我探索 App。
核心理念是将“情绪日记”与“星辰/人格指引 (MBTI/星座)”深度融合。

## 基本原则

- **遵循架构**：严格遵守 `entry/src/main/ets` 下的分层架构 (pages, components, model, viewmodel, service)。
- **样式统一**：使用 ArkUI 属性修饰符实现毛玻璃风格 (Glassmorphism)。
- **本地优先**：所有用户日记、情感数据及「星辰」积分**必须存储在本地** (SQLite/Preferences)。
- **术语规范**：积分统称为**「星辰」 (Stardust)**。
- **语言统一**：代码注释、文档和 Git 提交信息使用**简体中文**。
- **文档维护**：每次开发完成后，必须**及时更新文档** (如 `walkthrough.md`, `task.md`) 以反映项目最新状态。

## 常用命令

```bash
# 构建与运行
hvigorw clean                                 # 清理构建产物
hvigorw assembleHap                           # 构建 HAP 包

# 依赖管理
ohpm install                                  # 安装依赖
```

## 技术栈与存储规范

- **系统**: HarmonyOS Next (API 11+)
- **数据存储**: 
    - `RelationalStore` (SQLite): 存储日记 (`DiaryEntry`)、情绪趋势、星辰明细。
    - `Preferences`: 存储用户配置 (MBTI, 星座)、当前星辰余额、打卡天数。
- **数据安全**: 暂不接入独立后端，通过**本地导出/导入 (JSON)** 和**系统云空间**确保数据安全。

## 核心 UI 规范 (双模式)

### 配色常量 (ThemeColors)
```typescript
// common/constants/ColorConstants.ets
export class ThemeColors {
  // Deep Space (Dark)
  static readonly Dark = {
    Bg: '#0F172A',
    TextPrimary: '#F8FAFC',
    CardBg: 'rgba(255, 255, 255, 0.05)',
    CardBorder: 'rgba(255, 255, 255, 0.15)',
    Accent: '#FCD34D'
  }
  
  // Morning Light (Light)
  static readonly Light = {
    Bg: '#FFF7ED',
    TextPrimary: '#431407',
    CardBg: 'rgba(255, 255, 255, 0.4)',
    CardBorder: 'rgba(255, 255, 255, 0.6)',
    Accent: '#F59E0B'
  }
}
```

### 毛玻璃卡片 (Glassmorphism 2.0)
需根据主题变量 (`AppStorage.Get('theme')`) 动态切换：

**A. 深色模式 (沉浸感)**
```typescript
.backgroundColor('rgba(255, 255, 255, 0.05)')
.backdropBlur(20)
.border({ width: 1, color: 'rgba(255, 255, 255, 0.15)' })
```

**B. 浅色模式 (通透感)**
```typescript
.backgroundColor('rgba(255, 255, 255, 0.4)')
.backdropBlur(30) // 更高模糊度
.saturate(1.8)    // 增加饱和度
.shadow({ radius: 30, color: 'rgba(251, 191, 36, 0.15)', offsetY: 8 }) // 暖色光晕
```

### 动效规范
- **转场**: 优先使用 `SharedTransition` (共享元素)
- **微交互**: 按钮点击缩放至 98% (`scale: {x: 0.98, y: 0.98}`)

## Git 提交规则

- **格式**：`类型: 简短描述`
- **语言**：**必须使用简体中文**（所有提交信息、提交描述均使用简体中文）
- **类型前缀**：使用常见的提交类型（feat, fix, ui, refactor, docs, style, test, chore 等）
- **示例**：
    - `feat: 实现本地星辰积分获取逻辑`
    - `ui: 优化星辰收集动画效果`
    - `fix: 修复日记保存时的数据丢失问题`
    - `docs: 更新开发指南中的存储规范说明`

## 后续规划 (Out of Scope for now)
- **云端存储/后端服务**: 列入未来计划，当前阶段无需编写任何后端联调代码。
