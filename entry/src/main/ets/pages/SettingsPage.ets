
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { BackupService } from '../service/BackupService';
import { Logger } from '../common/utils/Logger';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SettingsPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;

  aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext;
    BackupService.getInstance().init(context);
  }

  async handleExport() {
    const path = await BackupService.getInstance().exportToFile();
    if (path) {
      promptAction.showDialog({
        title: '导出成功',
        message: `文件已保存至:\n${path}`,
        buttons: [{ text: '确定', color: this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent }]
      });
    } else {
      promptAction.showToast({ message: '导出失败' });
    }
  }

  // 模拟导入功能 (因无法简单访问文件选择器，这里提供一个输入框用于测试)
  async handleImport() {
    // 实际项目中应调用 Picker，这里简化为提示
    promptAction.showDialog({
      title: '导入功能',
      message: '由于系统限制，演示版暂只支持通过代码或调试工具注入 JSON 字符串进行恢复。',
      buttons: [{ text: '我知道了', color: this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent }]
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
        // 顶部导航
        Row() {
           Image($r('app.media.startIcon')) // 使用现有的图标
             .width(24)
             .height(24)
             .objectFit(ImageFit.Contain)
             .margin({ right: 8 })
             .visibility(Visibility.None) // 暂时隐藏
          
          Text('设置')
            .fontSize(StyleConstants.FONT_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: StyleConstants.SPACE_MD })
        }
        .width('100%')
        .padding({ top: StyleConstants.SPACE_MD })
      
        // 返回按钮 (绝对定位实现)
        Row() {
           Text('< 返回')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => {
              router.back();
            })
        }
        .position({ x: StyleConstants.SPACE_MD, y: StyleConstants.SPACE_MD })


        Column({ space: StyleConstants.SPACE_MD }) {
          
          // 个人档案
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
            Row() {
              Column() {
                Text('个人档案')
                  .fontSize(StyleConstants.FONT_MD)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                Text('MBTI 与星座设定')
                  .fontSize(StyleConstants.FONT_XS)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)

              Text('>')
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              router.pushUrl({ url: 'pages/ProfileEditPage' });
            })
          }

          // 隐私保护 (模拟)
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
            Row() {
              Column() {
                Text('隐私保护锁')
                  .fontSize(StyleConstants.FONT_MD)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                Text('开启指纹/面容校验体验')
                  .fontSize(StyleConstants.FONT_XS)
                  .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)

              Toggle({ type: ToggleType.Switch, isOn: false })
                .selectedColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                .onChange((isOn: boolean) => {
                  if (isOn) {
                    promptAction.showDialog({
                      title: '生物识别校验',
                      message: '正在模拟系统级安全验证...\n[ 🔐 验证成功 ]',
                      buttons: [{ text: '确定', color: this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent }]
                    });
                  }
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }

          // 数据管理
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
            Column({ space: StyleConstants.SPACE_MD }) {
              Text('数据安全')
                .fontSize(StyleConstants.FONT_SM)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                .width('100%')
              
              Button('导出数据 (JSON)')
                .width('100%')
                .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                .onClick(() => {
                  this.handleExport();
                })

              Button('导入数据')
                .width('100%')
                .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary) // 弱化显示
                .onClick(() => {
                  this.handleImport();
                })
            }
          }

          // 关于
          GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
             Column() {
               Text('HeartStars Journal')
                 .fontSize(StyleConstants.FONT_MD)
                 .fontWeight(FontWeight.Bold)
                 .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
               Text('v1.0.0')
                 .fontSize(StyleConstants.FONT_SM)
                 .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                 .margin({ top: 4 })
             }
             .width('100%')
             .alignItems(HorizontalAlign.Center)
          }

        }
        .padding(StyleConstants.SPACE_MD)
        .margin({ top: 32 })
      }
    }
  }
}
