
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';

@Component
export struct GlassCard {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @BuilderParam content: () => void;
  public radius: number = StyleConstants.RADIUS_MD;
  public customPadding: number = StyleConstants.SPACE_MD;

  build() {
    Column() {
      if (this.content) {
        this.content()
      }
    }
    .width('100%')
    .padding(this.customPadding)
    .borderRadius(this.radius)
    // 根据模式应用不同的背景色
    .backgroundColor(this.isDarkMode ? ThemeColors.Dark.CardBg : ThemeColors.Light.CardBg)
    // 毛玻璃模糊效果
    .backdropBlur(this.isDarkMode ? 20 : 30)
    // 边框
    .border({ 
      width: 1, 
      color: this.isDarkMode ? ThemeColors.Dark.CardBorder : ThemeColors.Light.CardBorder 
    })
    // 阴影
    .shadow({ 
      radius: this.isDarkMode ? 20 : 30, 
      color: this.isDarkMode ? ThemeColors.Dark.Shadow : ThemeColors.Light.Shadow, 
      offsetY: this.isDarkMode ? 4 : 8 
    })
    // 浅色模式增加饱和度 (通过 ImageEffect 暂未直接支持，此处暂时忽略或后续优化)
  }
}
