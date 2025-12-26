
import { ThemeColors } from '../common/constants/ThemeConstants';

class Star {
  x: number = 0;
  y: number = 0;
  size: number = 0;
  opacity: number = 0;
  speed: number = 0;

  constructor(width: number, height: number) {
    this.reset(width, height);
  }

  reset(width: number, height: number) {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2 + 0.5;
    this.opacity = Math.random();
    this.speed = Math.random() * 0.02 + 0.005;
  }

  update(width: number, height: number) {
    this.opacity += this.speed;
    if (this.opacity > 1 || this.opacity < 0.2) {
      this.speed = -this.speed;
    }
  }
}

@Component
export struct StarryBackground {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private stars: Star[] = [];
  private intervalId: number = -1;
  private canvasWidth: number = 400;
  private canvasHeight: number = 800;

  @Styles commonFull() {
    .width('100%')
    .height('100%')
  }

  aboutToAppear() {
    // 初始化星星
    for (let i = 0; i < 50; i++) {
      this.stars.push(new Star(this.canvasWidth, this.canvasHeight));
    }
  }

  aboutToDisappear() {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
    }
  }

  private draw() {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    
    // 仅在深色模式下显示明显星光，浅色模式下弱化
    if (!this.isDarkMode) {
      this.context.fillStyle = 'rgba(251, 191, 36, 0.05)'; // 浅色模式极淡金光
    } else {
      this.context.fillStyle = 'white';
    }

    this.stars.forEach(star => {
      star.update(this.canvasWidth, this.canvasHeight);
      this.context.globalAlpha = this.isDarkMode ? star.opacity * 0.4 : star.opacity * 0.05;
      this.context.beginPath();
      this.context.arc(star.x, star.y, star.size, 0, Math.PI * 2);
      this.context.fill();
    });
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.canvasWidth = this.context.width;
        this.canvasHeight = this.context.height;
        this.intervalId = setInterval(() => {
          this.draw();
        }, 50);
      })
      .hitTestBehavior(HitTestMode.None) // 不拦截触摸事件
  }
}
