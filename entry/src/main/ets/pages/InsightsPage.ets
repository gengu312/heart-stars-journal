
import router from '@ohos.router';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { MoodCalendar } from '../components/MoodCalendar';
import { MoodChart } from '../components/MoodChart';
import { InsightService, DayMood } from '../service/InsightService';
import { PreferenceManager } from '../service/PreferenceManager';
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct InsightsPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State monthlyMoods: DayMood[] = [];
  @State weeklyIntensity: number[] = [];
  @State personalizedAdvice: string = '正在观测星象...';
  @State mbti: string = 'default';

  async aboutToAppear() {
    await this.loadInsights();
  }

  async loadInsights() {
    const now = new Date();
    this.monthlyMoods = await InsightService.getInstance().getMonthlyMoods(now.getFullYear(), now.getMonth() + 1);
    this.weeklyIntensity = await InsightService.getInstance().getWeeklyIntensity();
    
    this.mbti = await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_MBTI, 'default') as string;
    
    // 获取最近一次日记的心情
    const lastMood = this.monthlyMoods.length > 0 ? this.monthlyMoods[this.monthlyMoods.length - 1].mood : 'default';
    this.personalizedAdvice = InsightService.getInstance().generateAdvice(this.mbti, lastMood);
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Scroll() {
        Column({ space: StyleConstants.SPACE_MD }) {
          // 顶部标题
          Row() {
            Text('< 返回')
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
              .onClick(() => router.back())
            
            Text('星辰洞察')
              .fontSize(StyleConstants.FONT_LG)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
              .flexGrow(1)
              .textAlign(TextAlign.Center)
              .margin({ right: 40 })
          }
          .width('100%')
          .padding({ top: StyleConstants.SPACE_MD, bottom: StyleConstants.SPACE_MD })

          // 1. 人格建议
          GlassCard({ customPadding: StyleConstants.SPACE_LG }) {
            Column() {
              Row() {
                Text('✨ 今日星语')
                  .fontSize(StyleConstants.FONT_MD)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                
                Text(this.mbti)
                  .fontSize(12)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(10)
                  .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .margin({ left: 10 })
              }
              .width('100%')
              .margin({ bottom: 12 })

              Text(this.personalizedAdvice)
                .fontSize(16)
                .lineHeight(26)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                .italic()
            }
            .alignItems(HorizontalAlign.Start)
          }

          // 2. 情绪月历
          GlassCard({ customPadding: 0 }) {
            MoodCalendar({ moods: this.monthlyMoods })
          }

          // 3. 趋势图表
          GlassCard({ customPadding: 0 }) {
            MoodChart({ data: this.weeklyIntensity })
          }

          Blank().height(40)
        }
        .padding(StyleConstants.SPACE_MD)
      }
      .width('100%')
      .height('100%')
    }
  }
}
