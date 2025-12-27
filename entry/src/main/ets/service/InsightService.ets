
import { DatabaseManager } from './DatabaseManager';
import { DiaryEntry } from '../model/DiaryEntry';
import { Logger } from '../common/utils/Logger';

export interface DayMood {
  day: number;
  mood: string;
  intensity: number;
}

export class InsightService {
  private static instance: InsightService;

  private constructor() {}

  public static getInstance(): InsightService {
    if (!InsightService.instance) {
      InsightService.instance = new InsightService();
    }
    return InsightService.instance;
  }

  public async getMonthlyMoods(year: number, month: number): Promise<DayMood[]> {
    try {
      const allDiaries = await DatabaseManager.getInstance().queryAllDiaries();
      const filtered = allDiaries.filter(d => {
        const date = new Date(d.createdAt);
        return date.getFullYear() === year && (date.getMonth() + 1) === month;
      });

      const dayMap = new Map<number, DayMood>();
      filtered.forEach(d => {
        const day = new Date(d.createdAt).getDate();
        if (!dayMap.has(day) || d.createdAt > (filtered.find(f => new Date(f.createdAt).getDate() === day)?.createdAt || 0)) {
          dayMap.set(day, { day: day, mood: d.mood, intensity: d.intensity });
        }
      });

      return Array.from(dayMap.values());
    } catch (err) {
      Logger.error('Failed to get monthly moods: ' + JSON.stringify(err));
      return [];
    }
  }

  public async getWeeklyIntensity(): Promise<number[]> {
    try {
      const allDiaries = await DatabaseManager.getInstance().queryAllDiaries();
      const now = new Date().getTime();
      const sevenDaysAgo = now - 7 * 24 * 60 * 60 * 1000;

      const lastWeek = allDiaries.filter(d => d.createdAt >= sevenDaysAgo);

      const intensities: number[] = new Array(7).fill(0);
      const counts: number[] = new Array(7).fill(0);

      lastWeek.forEach(d => {
        const diffDays = Math.floor((now - d.createdAt) / (24 * 60 * 60 * 1000));
        const index = 6 - diffDays;
        if (index >= 0 && index < 7) {
          intensities[index] += d.intensity;
          counts[index]++;
        }
      });

      return intensities.map((sum, i) => counts[i] > 0 ? sum / counts[i] : 0);
    } catch (err) {
      Logger.error('Failed to get weekly intensity: ' + JSON.stringify(err));
      return [0, 0, 0, 0, 0, 0, 0];
    }
  }

  public generateAdvice(mbti: string, recentMood: string): string {
    const adviceMap: Record<string, Record<string, string>> = {
      'INFP': {
        '😄': '守护星语：你的快乐像银河一样温柔。记得收藏这一刻，它是你未来的能量补给。',
        '😌': '守护星语：平静是你内心最美的风景。享受这份宁静，让灵感自然流淌。',
        '😐': '守护星语：平淡也是一种力量。不必急于追求波澜，静水深流。',
        '😣': '守护星语：亲爱的梦想家，当星空不安时，试着把思绪写在呼吸里。你的敏感是天赋，不是负担。',
        '😠': '守护星语：愤怒是被压抑的需求在呐喊。找一个安全的角落，让情绪流动。',
        '😢': '守护星语：世界太吵了，现在是你的躲避时刻。去听一首只有旋律的歌，让灵魂小睡一会儿。',
        '🤩': '守护星语：你眼中的星光比银河还亮！这份热情是宇宙给你的礼物。'
      },
      'INTJ': {
        '😄': '守护星语：达成目标的感觉很棒，对吗？享受这种秩序感，你值得这份成就。',
        '😌': '守护星语：内心的平静是你最强大的武器。在这份宁静中，下一个计划正在孕育。',
        '😐': '守护星语：保持观察，保持思考。平静不是麻木，而是清醒的等待。',
        '😣': '守护星语：逻辑能辅助行动，但无法消解每一个未知。试着给计划留出一片空白。',
        '😠': '守护星语：效率受阻时的愤怒是正常的。找出问题根源，然后逐一击破。',
        '😢': '守护星语：高效并不意味着永动机。系统需要重启，你也是。允许自己休息。',
        '🤩': '守护星语：当愿景开始成形，宇宙都在为你让路。继续前进！'
      },
      'ENFP': {
        '😄': '守护星语：你的热情能点燃整个星系！继续散播这份快乐吧。',
        '😌': '守护星语：难得的平静时刻。在这里充电，然后继续你的冒险。',
        '😐': '守护星语：暂时的平淡不是迷失方向，只是在寻找下一个灵感。',
        '😣': '守护星语：太多可能性反而让你焦虑？试着专注于此刻最想做的一件事。',
        '😠': '守护星语：你的愤怒来自对不公的敏感。用创意表达它，而不是压抑。',
        '😢': '守护星语：即使是最闪耀的星星也需要休息。拥抱你的脆弱，它同样珍贵。',
        '🤩': '守护星语：这份激动是新冒险的召唤！跟随你的好奇心，奇迹在等着你。'
      },
      'INFJ': {
        '😄': '守护星语：你的喜悦如此深沉而真挚。珍惜这份与内心的连接。',
        '😌': '守护星语：在平静中，你能听到灵魂的低语。这是属于你的神圣时刻。',
        '😐': '守护星语：你正在默默观察和理解这个世界。这份洞察力是你的天赋。',
        '😣': '守护星语：你总是为他人着想，但今天请把温柔留给自己。',
        '😠': '守护星语：当价值观被挑战时，愤怒是自然的。但记得保护好自己的能量。',
        '😢': '守护星语：你的眼泪是灵魂在释放重压。让它流淌，然后你会更轻盈。',
        '🤩': '守护星语：当你被意义深远的事物点燃，整个宇宙都在共振！'
      },
      'ENTP': {
        '😄': '守护星语：又有新点子了？让创意的火花继续飞溅！',
        '😌': '守护星语：难得的平静。在这短暂的停顿中，下一个灵感正在酝酿。',
        '😐': '守护星语：现在只是暴风雨前的宁静。新的挑战很快就会出现。',
        '😣': '守护星语：无聊比焦虑更让你难受。找一个新问题来解决吧！',
        '😠': '守护星语：愚蠢和僵化最让你愤怒。把这股能量转化为改变的动力。',
        '😢': '守护星语：你很少让人看到脆弱的一面。今天，允许自己只是一个需要休息的人。',
        '🤩': '守护星语：新挑战让你眼睛发亮！去征服它，你为此而生。'
      },
      'ISFJ': {
        '😄': '守护星语：看到他人因你而幸福，是你最大的满足。今天你值得同样的温暖。',
        '😌': '守护星语：家的温馨围绕着你。享受这份熟悉的安全感。',
        '😐': '守护星语：日常的平稳是你悉心维护的结果。感谢自己的付出。',
        '😣': '守护星语：你总是把别人放在第一位。今天，请允许自己说一次"不"。',
        '😠': '守护星语：当有人破坏了你用心维护的和谐，愤怒是正当的。但别让它伤害到你。',
        '😢': '守护星语：你默默承担了太多。今晚，让眼泪洗去疲惫，明天又是新的一天。',
        '🤩': '守护星语：被需要、被感谢的感觉真好！你的奉献值得所有的星光。'
      },
      'ISTP': {
        '😄': '守护星语：解决了一个棘手的问题？享受这份成就感。',
        '😌': '守护星语：独处的时光是你充电的方式。享受这份自在。',
        '😐': '守护星语：冷静观察，等待时机。你知道什么时候该出手。',
        '😣': '守护星语：太多无意义的社交让你疲惫？给自己一个人的空间。',
        '😠': '守护星语：无能和低效让你烦躁。与其生气，不如自己动手解决。',
        '😢': '守护星语：你不常表露情感，但今天可以。独自面对也是一种勇敢。',
        '🤩': '守护星语：新技能、新工具、新挑战——你的眼睛在发光！'
      },
      'ESFJ': {
        '😄': '守护星语：你的笑容温暖了整个房间。继续散播这份阳光！',
        '😌': '守护星语：和谐的氛围是你用心营造的。享受这份成果。',
        '😐': '守护星语：一切井井有条，虽然平淡但让人安心。',
        '😣': '守护星语：你太在意他人的评价了。今天，只为自己的心声负责。',
        '😠': '守护星语：被忽视或被误解让你受伤。你的付出值得被看见。',
        '😢': '守护星语：你总是照顾别人，今天换别人来照顾你。允许自己脆弱。',
        '🤩': '守护星语：大家都开心，你就开心！这份分享的喜悦是你最大的财富。'
      },
      'default': {
        '😄': '守护星语：愿这份喜悦如星辰般闪耀，照亮你的每一天。',
        '😌': '守护星语：享受这份平静，它是内心深处的一片净土。',
        '😐': '守护星语：平淡中蕴藏着无限可能。保持开放，等待惊喜。',
        '😣': '守护星语：深呼吸。星辰转动自有其轨道，你现在的不安也会随风消散。',
        '😠': '守护星语：愤怒是一种力量，但别让它控制你。用它来推动改变。',
        '😢': '守护星语：停下来，也是一种前进。给自己一个温暖的拥抱。',
        '🤩': '守护星语：愿这种光芒能照亮你接下来的路。追随你的热情！'
      }
    };

    const personaAdvice = adviceMap[mbti] || adviceMap['default'];
    return personaAdvice[recentMood] || personaAdvice['😐'] || '守护星语：愿你今日如星辰般自由。';
  }

  public getConstellationFortune(constellation: string): string {
    const fortunes: Record<string, string[]> = {
      '白羊座': [
        '今日能量充沛，适合开启新项目。行动力是你最大的武器。',
        '冲动是魔鬼，今天做决定前多想三秒。好事多磨。',
        '贵人运旺盛，主动出击会有意想不到的收获。'
      ],
      '金牛座': [
        '稳扎稳打的一天，财运小旺。坚持你的节奏。',
        '今天适合享受美食和放松。工作的事明天再说。',
        '感情上可能有小惊喜。保持开放的心态。'
      ],
      '双子座': [
        '脑子转得飞快，创意源源不断。把想法记下来！',
        '社交活跃，但小心祸从口出。说话前过过脑子。',
        '好奇心会带你发现新天地。大胆探索吧！'
      ],
      '巨蟹座': [
        '今天适合宅家充电，和家人相处。温暖是你的能量源。',
        '情绪有些敏感，记得保护好自己的小宇宙。',
        '直觉很准，相信你内心的声音。'
      ],
      '狮子座': [
        '闪耀的一天！所有目光都会被你吸引。自信地展现自己。',
        '今天可能遇到挑战，但你天生就是王者。迎难而上！',
        '创造力爆棚，适合做艺术创作或表演。'
      ],
      '处女座': [
        '细节决定成败，今天的严谨会带来好结果。',
        '别太苛求完美，有时候"够好"就是最好。',
        '健康运需要关注，记得休息和运动。'
      ],
      '天秤座': [
        '人际关系和谐的一天，适合谈判和合作。',
        '选择困难症发作？相信第一直觉。',
        '审美在线，今天穿搭会收获赞美。'
      ],
      '天蝎座': [
        '洞察力敏锐，别人的小心思逃不过你的眼睛。',
        '深度思考的日子，适合反思和规划。',
        '神秘的魅力值拉满，感情上有机会。'
      ],
      '射手座': [
        '渴望自由的心在蠢蠢欲动。来一场说走就走的小探险？',
        '乐观是你的超能力，今天用它感染身边的人。',
        '学习运很好，新知识会让你兴奋。'
      ],
      '摩羯座': [
        '努力会被看见的一天。坚持住，成功在望。',
        '今天适合规划长远目标，一步一个脚印。',
        '工作狂模式开启，但别忘了生活也需要经营。'
      ],
      '水瓶座': [
        '奇思妙想层出不穷，你就是未来的先行者。',
        '今天可能会遇到志同道合的灵魂。珍惜这份连接。',
        '打破常规，做你认为对的事。'
      ],
      '双鱼座': [
        '灵感如潮水涌来，适合创作和冥想。',
        '今天容易共情他人，但记得保护好自己的情绪边界。',
        '浪漫运势不错，适合表达爱意。'
      ]
    };

    const dailyFortunes = fortunes[constellation] || fortunes['白羊座'];
    const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000);
    const fortuneIndex = dayOfYear % dailyFortunes.length;

    return dailyFortunes[fortuneIndex];
  }
}
