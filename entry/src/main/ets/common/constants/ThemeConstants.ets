
/**
 * 主题颜色常量定义
 * 包含深色模式 (Deep Space) 和浅色模式 (Morning Light)
 */
export interface ThemePalette {
  Bg: string;
  TextPrimary: string;
  TextSecondary: string;
  CardBg: string;
  CardBorder: string;
  Accent: string;
  Shadow: string;
}

export class ThemeColors {
  // Deep Space (Dark) - 深空模式
  static readonly Dark: ThemePalette = {
    Bg: '#0F172A',         // 午夜蓝背景
    TextPrimary: '#F8FAFC', // 冷白主要文字
    TextSecondary: 'rgba(248, 250, 252, 0.6)', // 次要文字
    CardBg: 'rgba(255, 255, 255, 0.05)', // 卡片背景
    CardBorder: 'rgba(255, 255, 255, 0.15)', // 卡片边框
    Accent: '#FCD34D',     // 强调色 (星光)
    Shadow: 'rgba(0, 0, 0, 0.2)' // 阴影
  };
  
  // Morning Light (Light) - 晨曦模式
  static readonly Light: ThemePalette = {
    Bg: '#FFF7ED',         // 暖米色背景
    TextPrimary: '#431407', // 深棕主要文字
    TextSecondary: 'rgba(67, 20, 7, 0.5)', // 次要文字
    CardBg: 'rgba(255, 255, 255, 0.4)', // 卡片背景
    CardBorder: 'rgba(255, 255, 255, 0.6)', // 卡片边框
    Accent: '#F59E0B',     // 强调色 (琥珀)
    Shadow: 'rgba(251, 191, 36, 0.15)' // 阴影 (暖色光晕)
  };
}

export class StyleConstants {
  static readonly FONT_XS = 10;
  static readonly FONT_SM = 12;
  static readonly FONT_MD = 14;
  static readonly FONT_LG = 16;
  static readonly FONT_XL = 20;
  static readonly FONT_XXL = 32;

  static readonly RADIUS_SM = 8;
  static readonly RADIUS_MD = 12;
  static readonly RADIUS_LG = 16;
  static readonly RADIUS_XL = 24;
  
  static readonly SPACE_XS = 4;
  static readonly SPACE_SM = 8;
  static readonly SPACE_MD = 16;
  static readonly SPACE_LG = 24;
  static readonly SPACE_XL = 32;
}
