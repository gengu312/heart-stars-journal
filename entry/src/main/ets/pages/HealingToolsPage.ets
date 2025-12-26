
import router from '@ohos.router';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';

@Entry
@Component
struct HealingToolsPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Column() {
        // 标题栏
        Row() {
          Text('< 返回')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => router.back())
          
          Text('治愈工具箱')
            .fontSize(StyleConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 })
        }
        .width('100%')
        .padding(StyleConstants.SPACE_MD)

        Column({ space: StyleConstants.SPACE_MD }) {
          // 星之呼吸
          GlassCard({ customPadding: StyleConstants.SPACE_LG }) {
            Row() {
              Column() {
                Text('✨ 星之呼吸')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                Text('平复心率，积累星辰')
                  .fontSize(14)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Start)
              .flexGrow(1)

              Image($r('app.media.startIcon')) // 临时占位
                .width(40)
                .height(40)
                .opacity(0.6)
            }
            .width('100%')
            .onClick(() => router.pushUrl({ url: 'pages/BreathExercisePage' }))
          }

          // 情绪垃圾桶
          GlassCard({ customPadding: StyleConstants.SPACE_LG }) {
            Row() {
              Column() {
                Text('🗑️ 情绪垃圾桶')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                Text('写下烦恼，化作微尘')
                  .fontSize(14)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Start)
              .flexGrow(1)

              Text('💥')
                .fontSize(32)
                .opacity(0.6)
            }
            .width('100%')
            .onClick(() => router.pushUrl({ url: 'pages/TrashBinPage' }))
          }
        }
        .padding(StyleConstants.SPACE_MD)
        .margin({ top: 20 })
      }
    }
  }
}
