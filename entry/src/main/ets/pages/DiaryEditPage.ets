
import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { DiaryEntry } from '../model/DiaryEntry';
import { DatabaseManager } from '../service/DatabaseManager';
import { StardustService } from '../service/StardustService';
import { Logger } from '../common/utils/Logger';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct DiaryEditPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State content: string = '';
  @State mood: string = '😐';
  @State intensity: number = 3;
  
  // 简单的心情列表
  private moodOptions: string[] = ['😄', '😌', '😐', '😣', '😠', '😢', '🤩'];

  async saveDiary() {
    if (this.content.trim() === '') {
      // 实际应用中应用弹窗提示
      return;
    }
    
    // 构造日记对象
    const newDiary = new DiaryEntry(
      this.content,
      this.mood,
      this.intensity
    );
    
    try {
      await DatabaseManager.getInstance().insertDiary(newDiary);
      Logger.info('Diary saved successfully');
      
      // 增加积分
      const newTotal = await StardustService.getInstance().addStardust(StardustService.EARN_DIARY, 'Writing Diary');
      
      promptAction.showToast({
        message: `✨ 获得 ${StardustService.EARN_DIARY} 星辰！当前: ${newTotal}`,
        duration: 2000
      });

      router.back();
    } catch (err) {
      Logger.error(`Failed to save diary: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      // 内容区域
      Column() {
        // 顶部导航栏
        Row() {
          Text('取消')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => {
              router.back();
            })
          
          Text('新日记')
            .fontSize(StyleConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
          
          Text('保存')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.saveDiary();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(StyleConstants.SPACE_MD)

        Scroll() {
          Column({ space: StyleConstants.SPACE_MD }) {
            
            // 心情选择
            GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
              Column({ space: StyleConstants.SPACE_SM }) {
                Text('此刻心情')
                  .fontSize(StyleConstants.FONT_MD)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .width('100%')
                
                // Emoji 列表
                List({ space: StyleConstants.SPACE_SM }) {
                  ForEach(this.moodOptions, (item: string) => {
                    ListItem() {
                      Text(item)
                        .fontSize(32)
                        .padding(8)
                        .backgroundColor(this.mood === item ? 
                          (this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)') : 
                          Color.Transparent)
                        .borderRadius(8)
                        .onClick(() => {
                          this.mood = item;
                        })
                    }
                  })
                }
                .listDirection(Axis.Horizontal)
                .width('100%')
                .scrollBar(BarState.Off)

                // 强度滑块
                Row() {
                  Text('强度')
                    .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  Slider({
                    value: this.intensity,
                    min: 1,
                    max: 5,
                    style: SliderStyle.OutSet
                  })
                    .trackColor(this.isDarkMode ? '#334155' : '#E2E8F0')
                    .selectedColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                    .onChange((value: number) => {
                      this.intensity = value;
                    })
                    .layoutWeight(1)
                }
                .width('100%')
                .margin({ top: 8 })
              }
            }

            // 文本输入
            GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
               TextArea({ placeholder: '写下此刻的想法...', text: this.content })
                .placeholderColor(this.isDarkMode ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,0,0.3)')
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                .backgroundColor(Color.Transparent)
                .height(300)
                .onChange((value: string) => {
                  this.content = value;
                })
            }
          }
          .padding(StyleConstants.SPACE_MD)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
