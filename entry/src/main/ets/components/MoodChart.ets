
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';

@Component
export struct MoodChart {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @Prop data: number[] = []; // 过去 7 天的强度 [0,1,2,3,4,5]

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private drawChart() {
    if (this.data.length === 0) return;

    const width = 300;
    const height = 150;
    const padding = 20;
    
    this.context.clearRect(0, 0, width, height);

    // 绘制轴线 (可选，这里追求极简风格只画趋势)
    const stepX = (width - 2 * padding) / (this.data.length - 1);
    const maxY = 5;

    // 渐变色
    const primaryColor = this.isDarkMode ? ThemeColors.Dark.Accent : ThemeColors.Light.Accent;
    
    this.context.beginPath();
    this.context.strokeStyle = primaryColor;
    this.context.lineWidth = 3;
    this.context.lineJoin = 'round';

    this.data.forEach((val, i) => {
      const x = padding + i * stepX;
      const y = height - padding - (val / maxY) * (height - 2 * padding);
      if (i === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    });
    this.context.stroke();

    // 绘制数据点
    this.data.forEach((val, i) => {
      const x = padding + i * stepX;
      const y = height - padding - (val / maxY) * (height - 2 * padding);
      this.context.beginPath();
      this.context.arc(x, y, 4, 0, 2 * Math.PI);
      this.context.fillStyle = primaryColor;
      this.context.fill();
    });
  }

  build() {
    Column() {
      Text('近一周强度趋势')
        .fontSize(StyleConstants.FONT_SM)
        .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
        .margin({ bottom: 10 })

      Canvas(this.context)
        .width('100%')
        .height(150)
        .onReady(() => {
          this.drawChart();
        })
    }
    .width('100%')
    .padding(StyleConstants.SPACE_MD)
  }
}
