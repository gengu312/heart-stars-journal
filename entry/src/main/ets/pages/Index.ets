
import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { StarryBackground } from '../components/StarryBackground';
import { DiaryEntry } from '../model/DiaryEntry';
import { DatabaseManager } from '../service/DatabaseManager';
import { PreferenceManager } from '../service/PreferenceManager';
import { Logger } from '../common/utils/Logger';

@Entry
@Component
struct Index {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State diaryList: DiaryEntry[] = [];
  @State totalStardust: number = 0;

  async onPageShow() {
    await this.loadData();
  }
  
  async loadData() {
    this.diaryList = await DatabaseManager.getInstance().queryAllDiaries();
    const stardust = await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, 0);
    this.totalStardust = stardust as number;
    // Load theme setting if exist, default to true (dark)
    // Here we just use default true for now to initialize AppStorage if not set
  }

  toggleTheme() {
    this.isDarkMode = !this.isDarkMode;
  }

  build() {
    Stack() {
      // 1. 底层动态背景
      StarryBackground()
      
      // 2. 渐变叠加
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: this.isDarkMode ? 
            [[ThemeColors.Dark.Bg, 0.0], ['rgba(15, 23, 42, 0.8)', 1.0]] : 
            [[ThemeColors.Light.Bg, 0.0], ['rgba(255, 247, 237, 0.8)', 1.0]]
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))

      // 2. 内容层
      Column() {
        // 顶部状态栏
        Row() {
          Column() {
            Text('HeartStars')
              .fontSize(StyleConstants.FONT_XL)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
            Text('Journal')
              .fontSize(StyleConstants.FONT_SM)
              .letterSpacing(2)
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
          }
          .alignItems(HorizontalAlign.Start)

          Row({ space: StyleConstants.SPACE_SM }) {
            // 主题切换按钮 (测试用)
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Text(this.isDarkMode ? '🌙' : '☀️')
                .fontSize(16)
            }
            .width(36)
            .height(36)
            .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
            .onClick(() => {
              this.toggleTheme();
            })

            // 积分胶囊
            Row() {
              Text('✨')
              Text(` ${this.totalStardust}`)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.isDarkMode ? 'rgba(252, 211, 77, 0.1)' : 'rgba(245, 158, 11, 0.1)')
            .borderRadius(20)
            .border({ width: 1, color: this.isDarkMode ? 'rgba(252, 211, 77, 0.2)' : 'rgba(245, 158, 11, 0.2)' })
            .onClick(() => {
              router.pushUrl({ url: 'pages/ProfileEditPage' });
            })

            // 统计入口
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Text('📊')
                .fontSize(16)
            }
            .width(36)
            .height(36)
            .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
            .onClick(() => {
              router.pushUrl({ url: 'pages/InsightsPage' });
            })

            // 治愈工具入口
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Text('🧘')
                .fontSize(16)
            }
            .width(36)
            .height(36)
            .backgroundColor(this.isDarkMode ? 'rgba(252, 211, 77, 0.1)' : 'rgba(245, 158, 11, 0.1)')
            .onClick(() => {
              router.pushUrl({ url: 'pages/HealingToolsPage' });
            })

            // 设置按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Text('⚙️')
                .fontSize(16)
            }
            .width(36)
            .height(36)
            .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' });
            })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: StyleConstants.SPACE_LG, right: StyleConstants.SPACE_LG, top: 48, bottom: StyleConstants.SPACE_MD })

        // 列表区域
        List({ space: StyleConstants.SPACE_MD }) {
          // 头部占位，增加一些留白
          ListItem() {
             Text(this.diaryList.length === 0 ? '还没有日记，点击右下角记录第一条吧~' : '最近回顾')
              .fontSize(StyleConstants.FONT_SM)
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
              .margin({ left: 4 })
          }

          ForEach(this.diaryList, (item: DiaryEntry) => {
            ListItem() {
              GlassCard() {
                Column() {
                  Row() {
                    Text(item.mood)
                      .fontSize(24)
                    
                    Column() {
                      Text(new Date(item.createdAt).toLocaleTimeString())
                         .fontSize(StyleConstants.FONT_XS)
                         .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                      Text(new Date(item.createdAt).toLocaleDateString())
                         .fontSize(StyleConstants.FONT_XS)
                         .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                    }
                    .alignItems(HorizontalAlign.End)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .margin({ bottom: StyleConstants.SPACE_SM })

                  Text(item.content)
                    .fontSize(StyleConstants.FONT_MD)
                    .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                }
              }
            }
          })
          
          // 底部占位，防止 FAB 遮挡
          ListItem().height(80)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: StyleConstants.SPACE_MD, right: StyleConstants.SPACE_MD })
      }

      // 悬浮按钮 (FAB)
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('+')
          .fontSize(32)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Lighter)
      }
      .width(56)
      .height(56)
      .position({ x: '80%', y: '85%' })
      .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
      .shadow({ radius: 10, color: this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent, offsetY: 5 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/DiaryEditPage' });
      })
    }
  }
}