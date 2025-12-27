
import { ThemeColors } from '../common/constants/ThemeConstants';

class Star {
  x: number = 0;
  y: number = 0;
  size: number = 0;
  opacity: number = 0;
  speed: number = 0;
  twinklePhase: number = 0;

  constructor(width: number, height: number) {
    this.reset(width, height);
  }

  reset(width: number, height: number) {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2 + 0.5;
    this.opacity = Math.random();
    this.speed = Math.random() * 0.02 + 0.005;
    this.twinklePhase = Math.random() * Math.PI * 2;
  }

  update(width: number, height: number) {
    this.twinklePhase += this.speed;
    this.opacity = 0.3 + Math.sin(this.twinklePhase) * 0.7;
  }
}

class ShootingStar {
  x: number = 0;
  y: number = 0;
  speed: number = 0;
  opacity: number = 0;
  angle: number = 0;
  active: boolean = false;
  tailLength: number = 0;

  spawn(width: number, height: number) {
    this.x = Math.random() * width * 0.8;
    this.y = Math.random() * height * 0.3;
    this.speed = 8 + Math.random() * 6;
    this.opacity = 0.8 + Math.random() * 0.2;
    this.angle = Math.PI / 4 + (Math.random() - 0.5) * 0.3;
    this.active = true;
    this.tailLength = 60 + Math.random() * 40;
  }

  update(width: number, height: number) {
    if (!this.active) return;
    this.x += Math.cos(this.angle) * this.speed;
    this.y += Math.sin(this.angle) * this.speed;
    this.opacity *= 0.98;
    if (this.x > width || this.y > height || this.opacity < 0.05) {
      this.active = false;
    }
  }
}

class FloatingOrb {
  x: number = 0;
  y: number = 0;
  radius: number = 0;
  opacity: number = 0;
  speedX: number = 0;
  speedY: number = 0;
  pulsePhase: number = 0;
  pulseSpeed: number = 0;

  constructor(width: number, height: number) {
    this.reset(width, height);
  }

  reset(width: number, height: number) {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.radius = 30 + Math.random() * 50;
    this.opacity = 0.03 + Math.random() * 0.05;
    this.speedX = (Math.random() - 0.5) * 0.3;
    this.speedY = (Math.random() - 0.5) * 0.3;
    this.pulsePhase = Math.random() * Math.PI * 2;
    this.pulseSpeed = 0.01 + Math.random() * 0.02;
  }

  update(width: number, height: number) {
    this.x += this.speedX;
    this.y += this.speedY;
    this.pulsePhase += this.pulseSpeed;
    if (this.x < -this.radius) this.x = width + this.radius;
    if (this.x > width + this.radius) this.x = -this.radius;
    if (this.y < -this.radius) this.y = height + this.radius;
    if (this.y > height + this.radius) this.y = -this.radius;
  }

  getCurrentOpacity(): number {
    return this.opacity * (0.5 + Math.sin(this.pulsePhase) * 0.5);
  }
}

@Component
export struct StarryBackground {
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private stars: Star[] = [];
  private shootingStars: ShootingStar[] = [];
  private orbs: FloatingOrb[] = [];
  private intervalId: number = -1;
  private shootingStarTimer: number = -1;
  private canvasWidth: number = 400;
  private canvasHeight: number = 800;

  aboutToAppear() {
    for (let i = 0; i < 60; i++) {
      this.stars.push(new Star(this.canvasWidth, this.canvasHeight));
    }
    for (let i = 0; i < 3; i++) {
      this.shootingStars.push(new ShootingStar());
    }
    for (let i = 0; i < 5; i++) {
      this.orbs.push(new FloatingOrb(this.canvasWidth, this.canvasHeight));
    }
  }

  aboutToDisappear() {
    if (this.intervalId !== -1) clearInterval(this.intervalId);
    if (this.shootingStarTimer !== -1) clearInterval(this.shootingStarTimer);
  }

  private spawnShootingStar() {
    const inactive = this.shootingStars.find(s => !s.active);
    if (inactive && this.isDarkMode) {
      inactive.spawn(this.canvasWidth, this.canvasHeight);
    }
  }

  private draw() {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制漂浮光斑
    const orbColor = this.isDarkMode ? 'rgba(252, 211, 77,' : 'rgba(251, 191, 36,';
    this.orbs.forEach(orb => {
      orb.update(this.canvasWidth, this.canvasHeight);
      const gradient = this.context.createRadialGradient(orb.x, orb.y, 0, orb.x, orb.y, orb.radius);
      const op = orb.getCurrentOpacity();
      gradient.addColorStop(0, orbColor + (op * 0.8) + ')');
      gradient.addColorStop(0.5, orbColor + (op * 0.3) + ')');
      gradient.addColorStop(1, orbColor + '0)');
      this.context.fillStyle = gradient;
      this.context.beginPath();
      this.context.arc(orb.x, orb.y, orb.radius, 0, Math.PI * 2);
      this.context.fill();
    });

    // 绘制星星
    this.stars.forEach(star => {
      star.update(this.canvasWidth, this.canvasHeight);
      if (this.isDarkMode) {
        const starOp = star.opacity * 0.6;
        const glow = this.context.createRadialGradient(star.x, star.y, 0, star.x, star.y, star.size * 3);
        glow.addColorStop(0, 'rgba(255, 255, 255, ' + starOp + ')');
        glow.addColorStop(0.3, 'rgba(255, 255, 255, ' + (starOp * 0.5) + ')');
        glow.addColorStop(1, 'rgba(255, 255, 255, 0)');
        this.context.fillStyle = glow;
        this.context.beginPath();
        this.context.arc(star.x, star.y, star.size * 3, 0, Math.PI * 2);
        this.context.fill();
        this.context.fillStyle = 'rgba(255, 255, 255, ' + starOp + ')';
        this.context.beginPath();
        this.context.arc(star.x, star.y, star.size, 0, Math.PI * 2);
        this.context.fill();
      } else {
        this.context.globalAlpha = star.opacity * 0.08;
        this.context.fillStyle = 'rgba(251, 191, 36, 1)';
        this.context.beginPath();
        this.context.arc(star.x, star.y, star.size * 1.5, 0, Math.PI * 2);
        this.context.fill();
        this.context.globalAlpha = 1;
      }
    });

    // 绘制流星
    if (this.isDarkMode) {
      this.shootingStars.forEach(star => {
        if (!star.active) return;
        star.update(this.canvasWidth, this.canvasHeight);
        // 尾迹
        const tailEndX = star.x - Math.cos(star.angle) * star.tailLength;
        const tailEndY = star.y - Math.sin(star.angle) * star.tailLength;
        const tailGrad = this.context.createLinearGradient(star.x, star.y, tailEndX, tailEndY);
        tailGrad.addColorStop(0, 'rgba(255, 255, 255, ' + star.opacity + ')');
        tailGrad.addColorStop(1, 'rgba(255, 255, 255, 0)');
        this.context.strokeStyle = tailGrad;
        this.context.lineWidth = 2;
        this.context.beginPath();
        this.context.moveTo(star.x, star.y);
        this.context.lineTo(tailEndX, tailEndY);
        this.context.stroke();
        // 头部光晕
        const headGlow = this.context.createRadialGradient(star.x, star.y, 0, star.x, star.y, 6);
        headGlow.addColorStop(0, 'rgba(255, 255, 255, ' + star.opacity + ')');
        headGlow.addColorStop(0.5, 'rgba(252, 211, 77, ' + (star.opacity * 0.5) + ')');
        headGlow.addColorStop(1, 'rgba(252, 211, 77, 0)');
        this.context.fillStyle = headGlow;
        this.context.beginPath();
        this.context.arc(star.x, star.y, 6, 0, Math.PI * 2);
        this.context.fill();
      });
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.canvasWidth = this.context.width;
        this.canvasHeight = this.context.height;
        this.stars = [];
        this.orbs = [];
        for (let i = 0; i < 60; i++) {
          this.stars.push(new Star(this.canvasWidth, this.canvasHeight));
        }
        for (let i = 0; i < 5; i++) {
          this.orbs.push(new FloatingOrb(this.canvasWidth, this.canvasHeight));
        }
        this.intervalId = setInterval(() => { this.draw(); }, 50);
        this.shootingStarTimer = setInterval(() => {
          if (Math.random() > 0.7) this.spawnShootingStar();
        }, 3000);
      })
      .hitTestBehavior(HitTestMode.None)
  }
}
