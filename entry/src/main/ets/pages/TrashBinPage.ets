
import router from '@ohos.router';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct TrashBinPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State trashContent: string = '';
  @State textOpacity: number = 1.0;
  @State textScale: number = 1.0;
  @State isExploding: boolean = false;

  async handleDestroy() {
    if (!this.trashContent.trim()) {
      promptAction.showToast({ message: '写下你的烦恼吧...' });
      return;
    }

    this.isExploding = true;
    
    // 文字消散动效
    animateTo({ duration: 1500, curve: Curve.EaseOut }, () => {
      this.textOpacity = 0;
      this.textScale = 1.5;
    });

    setTimeout(() => {
      this.trashContent = '';
      this.textOpacity = 1.0;
      this.textScale = 1.0;
      this.isExploding = false;
      promptAction.showToast({ message: '烦恼已化作尘埃 ✨' });
    }, 1500);
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Column() {
        // 顶部
        Row() {
          Text('< 返回')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => router.back())
          
          Text('情绪垃圾桶')
            .fontSize(StyleConstants.FONT_MD)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 }) // 抵消返回键宽度
        }
        .width('100%')
        .padding(StyleConstants.SPACE_MD)

        Column({ space: 20 }) {
          Text('把不快、压力或秘密写下来，\n让它们在这里彻底消散。')
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .lineHeight(24)
            .margin({ top: 20, bottom: 20 })

          GlassCard({ customPadding: 0 }) {
            TextArea({ 
              placeholder: '在这里写下你想粉碎的内容...',
              text: this.trashContent
            })
              .height(300)
              .backgroundColor(Color.Transparent)
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
              .placeholderColor(this.isDarkMode ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,0,0.3)')
              .opacity(this.textOpacity)
              .scale({ x: this.textScale, y: this.textScale })
              .onChange((value: string) => {
                this.trashContent = value;
              })
              .enabled(!this.isExploding)
          }

          Button('彻底粉碎')
            .width('80%')
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.isExploding ? 'rgba(128,128,128,0.5)' : '#EF4444')
            .enabled(!this.isExploding)
            .onClick(() => this.handleDestroy())
            .margin({ top: 20 })
        }
        .padding(StyleConstants.SPACE_MD)
      }
    }
  }
}
