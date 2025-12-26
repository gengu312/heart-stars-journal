
import { ThemeColors } from '../constants/ThemeConstants';

/**
 * 样式工具类
 * 用于生成动态样式
 */
export class StyleUtils {
  
  /**
   * 获取当前主题配置
   * @param isDark 是否为深色模式
   */
  static getTheme(isDark: boolean) {
    return isDark ? ThemeColors.Dark : ThemeColors.Light;
  }

  /**
   * 获取毛玻璃背景样式
   * 注意：这些属性通常直接应用在组件链式调用中，这里仅返回参数对象供参考
   * 实际使用建议封装在组件内部或 AttributeModifier 中
   */
  static getGlassStyle(isDark: boolean) {
    if (isDark) {
      return {
        color: ThemeColors.Dark.CardBg,
        blur: 20,
        border: { width: 1, color: ThemeColors.Dark.CardBorder },
        shadow: { radius: 20, color: ThemeColors.Dark.Shadow, offsetY: 4 }
      };
    } else {
      return {
        color: ThemeColors.Light.CardBg,
        blur: 30,
        border: { width: 1, color: ThemeColors.Light.CardBorder },
        shadow: { radius: 30, color: ThemeColors.Light.Shadow, offsetY: 8 }
      };
    }
  }
}
