
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { DayMood } from '../service/InsightService';

@Component
export struct MoodCalendar {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @Prop moods: DayMood[] = [];
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth() + 1;
  @State days: number[] = [];

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

  prevMonth() {
    if (this.currentMonth === 1) {
      this.currentMonth = 12;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
    this.calculateDays();
  }

  nextMonth() {
    const now = new Date();
    if (this.currentYear === now.getFullYear() && this.currentMonth === now.getMonth() + 1) {
      return;
    }
    if (this.currentMonth === 12) {
      this.currentMonth = 1;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
    this.calculateDays();
  }

  getMoodForDay(day: number): string | null {
    const found = this.moods.find(m => m.day === day);
    return found ? found.mood : null;
  }

  build() {
    Column() {
      Row() {
        Text('<')
          .fontSize(20)
          .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
          .padding(10)
          .onClick(() => this.prevMonth())

        Text(this.currentYear + '年 ' + this.currentMonth + '月')
          .fontSize(StyleConstants.FONT_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('>')
          .fontSize(20)
          .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
          .padding(10)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .margin({ bottom: 20 })

      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
          Text(day)
            .fontSize(12)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .width('14.28%')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .margin({ bottom: 10 })

      Grid() {
        ForEach(this.days, (day: number) => {
          GridItem() {
            Column() {
              Text(day + '')
                .fontSize(14)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)

              if (this.getMoodForDay(day)) {
                Text(this.getMoodForDay(day))
                  .fontSize(14)
                  .margin({ top: 2 })
              } else {
                Circle()
                  .width(4)
                  .height(4)
                  .fill(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)')
                  .margin({ top: 6 })
              }
            }
            .width('100%')
            .height(45)
            .justifyContent(FlexAlign.Center)
          }
        }, (day: number) => day.toString())
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .width('100%')
    }
    .width('100%')
    .padding(StyleConstants.SPACE_MD)
  }
}
