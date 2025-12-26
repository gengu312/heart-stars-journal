
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { DayMood } from '../service/InsightService';

@Component
export struct MoodCalendar {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @Prop moods: DayMood[] = [];
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth() + 1;

  private days: number[] = [];

  aboutToAppear() {
    this.calculateDays();
  }

  calculateDays() {
    const lastDay = new Date(this.currentYear, this.currentMonth, 0).getDate();
    this.days = [];
    for (let i = 1; i <= lastDay; i++) {
       this.days.push(i);
    }
  }

  getMoodForDay(day: number): string | null {
    const found = this.moods.find(m => m.day === day);
    return found ? found.mood : null;
  }

  build() {
    Column() {
      // 月份标题
      Row() {
        Text(`${this.currentYear}年 ${this.currentMonth}月`)
          .fontSize(StyleConstants.FONT_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 日历网格
      Grid() {
        ForEach(this.days, (day: number) => {
          GridItem() {
            Column() {
              Text(`${day}`)
                .fontSize(14)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
              
              // 情绪点
              if (this.getMoodForDay(day)) {
                Text(this.getMoodForDay(day))
                  .fontSize(12)
                  .margin({ top: 4 })
              } else {
                Circle()
                  .width(4)
                  .height(4)
                  .fill(this.isDarkMode ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)')
                  .margin({ top: 8 })
              }
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
          }
        }, (day: number) => day.toString())
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .width('100%')
    }
    .width('100%')
    .padding(StyleConstants.SPACE_MD)
  }
}
