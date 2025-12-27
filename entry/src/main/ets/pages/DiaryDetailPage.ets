
import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import { DiaryEntry } from '../model/DiaryEntry';
import { DatabaseManager } from '../service/DatabaseManager';
import { Logger } from '../common/utils/Logger';
import promptAction from '@ohos.promptAction';

interface RouteParams {
  diaryId: number;
}

@Entry
@Component
struct DiaryDetailPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State diary: DiaryEntry | null = null;
  @State isEditing: boolean = false;
  @State editContent: string = '';
  @State editMood: string = '';
  @State editIntensity: number = 3;
  @State editTags: string[] = [];
  private diaryId: number = -1;
  private moodOptions: string[] = ['😄', '😌', '😐', '😣', '😠', '😢', '🤩'];
  private tagOptions: string[] = ['工作', '学习', '生活', '深夜', '独处', '社交', '运动', '旅行'];

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.diaryId) {
      this.diaryId = params.diaryId;
      this.loadDiary();
    }
  }

  async loadDiary() {
    try {
      const diary = await DatabaseManager.getInstance().queryDiaryById(this.diaryId);
      if (diary) {
        this.diary = diary;
        this.editContent = diary.content;
        this.editMood = diary.mood;
        this.editIntensity = diary.intensity;
        this.editTags = diary.tags ? [...diary.tags] : [];
      }
    } catch (err) {
      Logger.error('Failed to load diary: ' + JSON.stringify(err));
    }
  }

  toggleTag(tag: string) {
    const idx = this.editTags.indexOf(tag);
    if (idx >= 0) {
      this.editTags = this.editTags.filter(t => t !== tag);
    } else {
      this.editTags = [...this.editTags, tag];
    }
  }

  async saveDiary() {
    if (!this.diary) return;
    try {
      this.diary.content = this.editContent;
      this.diary.mood = this.editMood;
      this.diary.intensity = this.editIntensity;
      this.diary.tags = this.editTags;
      await DatabaseManager.getInstance().updateDiary(this.diary);
      promptAction.showToast({ message: '保存成功' });
      this.isEditing = false;
    } catch (err) {
      Logger.error('Failed to save diary: ' + JSON.stringify(err));
      promptAction.showToast({ message: '保存失败' });
    }
  }

  async deleteDiary() {
    if (!this.diary) return;
    promptAction.showDialog({
      title: '确认删除',
      message: '删除后无法恢复，确定要删除这篇日记吗？',
      buttons: [
        { text: '取消', color: this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary },
        { text: '删除', color: '#EF4444' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        try {
          await DatabaseManager.getInstance().deleteDiary(this.diaryId);
          promptAction.showToast({ message: '已删除' });
          router.back();
        } catch (err) {
          Logger.error('Failed to delete diary: ' + JSON.stringify(err));
        }
      }
    });
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return date.getFullYear() + '年' + (date.getMonth() + 1) + '月' + date.getDate() + '日 ' +
           date.getHours().toString().padStart(2, '0') + ':' + date.getMinutes().toString().padStart(2, '0');
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? ThemeColors.Dark.Bg : ThemeColors.Light.Bg)

      Column() {
        Row() {
          Text('< 返回')
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .onClick(() => router.back())

          if (this.isEditing) {
            Text('保存')
              .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
              .fontWeight(FontWeight.Bold)
              .onClick(() => this.saveDiary())
          } else {
            Row({ space: 16 }) {
              Text('编辑')
                .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                .onClick(() => { this.isEditing = true; })
              Text('删除')
                .fontColor('#EF4444')
                .onClick(() => this.deleteDiary())
            }
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(StyleConstants.SPACE_MD)

        if (this.diary) {
          Scroll() {
            Column({ space: StyleConstants.SPACE_MD }) {
              GlassCard({ customPadding: StyleConstants.SPACE_LG }) {
                Column({ space: 12 }) {
                  Row() {
                    if (this.isEditing) {
                      List({ space: 8 }) {
                        ForEach(this.moodOptions, (item: string) => {
                          ListItem() {
                            Text(item)
                              .fontSize(28)
                              .padding(6)
                              .backgroundColor(this.editMood === item ?
                                (this.isDarkMode ? 'rgba(252, 211, 77, 0.2)' : 'rgba(245, 158, 11, 0.2)') :
                                Color.Transparent)
                              .borderRadius(8)
                              .onClick(() => { this.editMood = item; })
                          }
                        })
                      }
                      .listDirection(Axis.Horizontal)
                      .scrollBar(BarState.Off)
                    } else {
                      Text(this.diary.mood)
                        .fontSize(40)
                    }
                  }

                  Text(this.formatDate(this.diary.createdAt))
                    .fontSize(StyleConstants.FONT_SM)
                    .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                }
              }

              if (this.isEditing) {
                GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
                  Column({ space: 8 }) {
                    Text('场景标签')
                      .fontSize(StyleConstants.FONT_SM)
                      .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
                      .width('100%')

                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(this.tagOptions, (tag: string) => {
                        Text(tag)
                          .fontSize(12)
                          .fontColor(this.editTags.includes(tag) ? '#FFFFFF' :
                            (this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary))
                          .backgroundColor(this.editTags.includes(tag) ?
                            (this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent) :
                            (this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)'))
                          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                          .borderRadius(16)
                          .margin({ right: 8, bottom: 8 })
                          .onClick(() => this.toggleTag(tag))
                      })
                    }
                  }
                }
              } else if (this.diary.tags && this.diary.tags.length > 0) {
                GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
                  Row({ space: 8 }) {
                    ForEach(this.diary.tags, (tag: string) => {
                      Text(tag)
                        .fontSize(12)
                        .fontColor(this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent)
                        .backgroundColor(this.isDarkMode ? 'rgba(252, 211, 77, 0.15)' : 'rgba(245, 158, 11, 0.15)')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .borderRadius(16)
                    })
                  }
                }
              }

              GlassCard({ customPadding: StyleConstants.SPACE_LG }) {
                if (this.isEditing) {
                  TextArea({ text: this.editContent })
                    .backgroundColor(Color.Transparent)
                    .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                    .fontSize(16)
                    .lineHeight(28)
                    .height(300)
                    .onChange((value: string) => { this.editContent = value; })
                } else {
                  Text(this.diary.content)
                    .fontSize(16)
                    .lineHeight(28)
                    .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                    .width('100%')
                }
              }

              if (this.diary.images && this.diary.images.length > 0) {
                GlassCard({ customPadding: StyleConstants.SPACE_MD }) {
                  ForEach(this.diary.images, (img: string) => {
                    Image(img)
                      .width('100%')
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                  })
                }
              }

              Blank().height(40)
            }
            .padding(StyleConstants.SPACE_MD)
          }
        } else {
          Column() {
            Text('加载中...')
              .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
