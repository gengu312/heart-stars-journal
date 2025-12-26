
import router from '@ohos.router';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { StardustService } from '../service/StardustService';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct BreathExercisePage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State circleScale: number = 1.0;
  @State instruction: string = '准备好开始了吗？';
  @State isRunning: boolean = false;
  @State progress: number = 0;
  
  private timer: number = -1;
  private totalSeconds: number = 60; // 默认 1 分钟练习
  private currentSeconds: number = 0;

  @Styles commonPadding() {
    .padding(StyleConstants.SPACE_LG)
  }

  aboutToDisappear() {
    this.stopExercise();
  }

  startExercise() {
    this.isRunning = true;
    this.currentSeconds = 0;
    this.progress = 0;
    this.runCycle();
    
    this.timer = setInterval(() => {
      this.currentSeconds++;
      this.progress = (this.currentSeconds / this.totalSeconds) * 100;
      
      if (this.currentSeconds >= this.totalSeconds) {
        this.finishExercise();
      }
    }, 1000);
  }

  runCycle() {
    if (!this.isRunning) return;

    // 吸气 (4s)
    this.instruction = '吸气...';
    animateTo({ duration: 4000, curve: Curve.EaseInOut }, () => {
      this.circleScale = 1.8;
    });

    // 呼气 (4s)
    setTimeout(() => {
      if (!this.isRunning) return;
      this.instruction = '呼气...';
      animateTo({ duration: 4000, curve: Curve.EaseInOut }, () => {
        this.circleScale = 1.0;
      });
    }, 4000);

    // 循环
    setTimeout(() => {
      if (this.isRunning) this.runCycle();
    }, 8000);
  }

  stopExercise() {
    this.isRunning = false;
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  async finishExercise() {
    this.stopExercise();
    const earned = StardustService.EARN_BREATHING;
    const newTotal = await StardustService.getInstance().addStardust(earned, 'Breathing Exercise');
    
    promptAction.showDialog({
      title: '练习完成',
      message: `太棒了！你已经静心呼吸了 1 分钟。\n获得 ✨ ${earned} 星辰！`,
      buttons: [{ 
        text: '确定', 
        color: this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent 
      }]
    });
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Column() {
        // 返回按钮
        Row() {
          Text('< 返回')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => router.back())
        }
        .width('100%')
        .padding(StyleConstants.SPACE_MD)

        Blank()

        // 呼吸圆环
        Stack() {
          // 呼吸动画圆
          Circle()
            .width(150)
            .height(150)
            .fill(this.isDarkMode ? 'rgba(252, 211, 77, 0.2)' : 'rgba(245, 158, 11, 0.2)')
            .scale({ x: this.circleScale, y: this.circleScale })
            .shadow({ radius: 50, color: this.isDarkMode ? 'rgba(252, 211, 77, 0.3)' : 'rgba(245, 158, 11, 0.3)' })

          // 核心圆
          Circle()
            .width(60)
            .height(60)
            .fill(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
        }
        .margin({ bottom: 80 })

        // 指引文字
        Text(this.instruction)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
          .margin({ bottom: 40 })

        if (!this.isRunning) {
          Button('开始练习')
            .width(200)
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
            .fontColor('#FFFFFF')
            .onClick(() => this.startExercise())
        } else {
          // 进度条
          Progress({ value: this.progress, total: 100, type: ProgressType.Capsule })
            .width('60%')
            .height(10)
            .color(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
            .margin({ bottom: 20 })
          
          Text('坚持住...')
            .fontSize(14)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
        }

        Blank()
        Blank()
      }
      .width('100%')
      .height('100%')
    }
  }
}
