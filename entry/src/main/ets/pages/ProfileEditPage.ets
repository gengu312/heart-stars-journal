
import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { PreferenceManager } from '../service/PreferenceManager';
import { Logger } from '../common/utils/Logger';

@Entry
@Component
struct ProfileEditPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State selectedMBTI: string = '-';
  @State selectedConstellation: string = '-';

  private mbtiOptions: string[] = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];

  private constellationOptions: string[] = [
    '白羊座', '金牛座', '双子座', '巨蟹座',
    '狮子座', '处女座', '天秤座', '天蝎座',
    '射手座', '摩羯座', '水瓶座', '双鱼座'
  ];

  async onPageShow() {
    try {
      this.selectedMBTI = await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_MBTI, '-') as string;
      this.selectedConstellation = await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_CONSTELLATION, '-') as string;
    } catch (err) {
      Logger.error(`Failed to load profile: ${JSON.stringify(err)}`);
    }
  }

  async saveProfile() {
    try {
      await PreferenceManager.getInstance().putValue(CommonConstants.PREF_KEY_MBTI, this.selectedMBTI);
      await PreferenceManager.getInstance().putValue(CommonConstants.PREF_KEY_CONSTELLATION, this.selectedConstellation);
      Logger.info('Profile saved');
      router.back();
    } catch (err) {
      Logger.error(`Failed to save profile: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Column() {
        // 顶部导航
        Row() {
           Text('取消')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => {
              router.back();
            })
          
          Text('星辰档案')
            .fontSize(StyleConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)

          Text('保存')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.saveProfile();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(StyleConstants.SPACE_MD)

        Column({ space: StyleConstants.SPACE_MD }) {
          // MBTI 设置
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
            Column() {
              Text('你的 MBTI 人格')
                .fontSize(StyleConstants.FONT_MD)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                .margin({ bottom: StyleConstants.SPACE_SM })
                .width('100%')
              
              Grid() {
                 ForEach(this.mbtiOptions, (item: string) => {
                   GridItem() {
                     Text(item)
                       .fontSize(StyleConstants.FONT_SM)
                       .fontColor(this.selectedMBTI === item ? '#FFFFFF' : (this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary))
                       .fontWeight(this.selectedMBTI === item ? FontWeight.Bold : FontWeight.Normal)
                       .backgroundColor(this.selectedMBTI === item ? (this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent) : 'transparent')
                       .padding({ top: 8, bottom: 8 })
                       .width('100%')
                       .textAlign(TextAlign.Center)
                       .borderRadius(StyleConstants.RADIUS_SM)
                       .onClick(() => {
                         this.selectedMBTI = item;
                       })
                   }
                 })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .height(180)
            }
          }

          // 星座设置
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
            Column() {
              Text('你的星座')
                .fontSize(StyleConstants.FONT_MD)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                .margin({ bottom: StyleConstants.SPACE_SM })
                .width('100%')

              Grid() {
                 ForEach(this.constellationOptions, (item: string) => {
                   GridItem() {
                     Text(item)
                       .fontSize(StyleConstants.FONT_SM)
                       .fontColor(this.selectedConstellation === item ? '#FFFFFF' : (this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary))
                       .fontWeight(this.selectedConstellation === item ? FontWeight.Bold : FontWeight.Normal)
                       .backgroundColor(this.selectedConstellation === item ? (this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent) : 'transparent')
                       .padding({ top: 8, bottom: 8 })
                       .width('100%')
                       .textAlign(TextAlign.Center)
                       .borderRadius(StyleConstants.RADIUS_SM)
                       .onClick(() => {
                         this.selectedConstellation = item;
                       })
                   }
                 })
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .height(180)
            }
          }
        }
        .padding(StyleConstants.SPACE_MD)
      }
    }
  }
}
