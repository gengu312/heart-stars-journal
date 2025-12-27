
import router from '@ohos.router';
import { ThemeColors, StyleConstants } from '../common/constants/ThemeConstants';
import { GlassCard } from '../components/GlassCard';
import promptAction from '@ohos.promptAction';

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  opacity: number;
  char: string;
}

@Entry
@Component
struct TrashBinPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State trashContent: string = '';
  @State isExploding: boolean = false;
  @State particles: Particle[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private animationId: number = -1;
  private canvasWidth: number = 300;
  private canvasHeight: number = 300;

  async handleDestroy() {
    if (!this.trashContent.trim()) {
      promptAction.showToast({ message: '写下你的烦恼吧...' });
      return;
    }
    this.isExploding = true;
    this.createParticles();
    this.startParticleAnimation();
  }

  createParticles() {
    this.particles = [];
    const chars = this.trashContent.split('');
    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight / 2;
    chars.forEach((char, i) => {
      const row = Math.floor(i / 15);
      const col = i % 15;
      const x = 20 + col * 18;
      const y = 30 + row * 24;
      this.particles.push({
        x: x,
        y: y,
        vx: (Math.random() - 0.5) * 8,
        vy: (Math.random() - 0.5) * 8 - 3,
        size: 14 + Math.random() * 4,
        opacity: 1,
        char: char
      });
    });
  }

  startParticleAnimation() {
    let frame = 0;
    const maxFrames = 60;
    const animate = () => {
      frame++;
      this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
      this.particles.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.15;
        p.vx *= 0.98;
        p.opacity -= 0.02;
        p.size *= 0.98;
        if (p.opacity > 0) {
          this.context.font = p.size + 'px sans-serif';
          this.context.fillStyle = this.isDarkMode ?
            'rgba(248, 250, 252, ' + p.opacity + ')' :
            'rgba(67, 20, 7, ' + p.opacity + ')';
          this.context.fillText(p.char, p.x, p.y);
        }
      });
      if (frame < maxFrames) {
        this.animationId = requestAnimationFrame(animate);
      } else {
        this.finishExplosion();
      }
    };
    animate();
  }

  finishExplosion() {
    this.trashContent = '';
    this.isExploding = false;
    this.particles = [];
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    promptAction.showToast({ message: '烦恼已化作星尘消散...' });
  }

  aboutToDisappear() {
    if (this.animationId !== -1) cancelAnimationFrame(this.animationId);
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
          Text('情绪垃圾桶')
            .fontSize(StyleConstants.FONT_MD)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
            .flexGrow(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 40 })
        }
        .width('100%')
        .padding(StyleConstants.SPACE_MD)

        Column({ space: 20 }) {
          Text('把不快、压力或秘密写下来，\n让它们在这里彻底消散。')
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .fontColor(this.isDarkMode ? ThemeColors.Dark.TextSecondary : ThemeColors.Light.TextSecondary)
            .lineHeight(24)
            .margin({ top: 20, bottom: 20 })

          Stack() {
            GlassCard({ customPadding: 0 }) {
              TextArea({
                placeholder: '在这里写下你想粉碎的内容...',
                text: this.trashContent
              })
                .height(300)
                .backgroundColor(Color.Transparent)
                .fontColor(this.isDarkMode ? ThemeColors.Dark.TextPrimary : ThemeColors.Light.TextPrimary)
                .placeholderColor(this.isDarkMode ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,0,0.3)')
                .visibility(this.isExploding ? Visibility.Hidden : Visibility.Visible)
                .onChange((value: string) => { this.trashContent = value; })
                .enabled(!this.isExploding)
            }

            if (this.isExploding) {
              Canvas(this.context)
                .width('100%')
                .height(300)
                .onReady(() => {
                  this.canvasWidth = this.context.width;
                  this.canvasHeight = this.context.height;
                })
            }
          }

          Button('彻底粉碎')
            .width('80%')
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.isExploding ? 'rgba(128,128,128,0.5)' : '#EF4444')
            .enabled(!this.isExploding)
            .onClick(() => this.handleDestroy())
            .margin({ top: 20 })
        }
        .padding(StyleConstants.SPACE_MD)
      }
    }
  }
}
