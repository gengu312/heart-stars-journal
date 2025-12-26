
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

  /**
   * 获取指定月份的情绪分布
   */
  public async getMonthlyMoods(year: number, month: number): Promise<DayMood[]> {
    try {
      const allDiaries = await DatabaseManager.getInstance().queryAllDiaries();
      // 在本地按年月过滤 (SQLite 驱动没写复杂查询，这里在内存中过滤)
      const filtered = allDiaries.filter(d => {
        const date = new Date(d.createdAt);
        return date.getFullYear() === year && (date.getMonth() + 1) === month;
      });

      // 每天取最后一次记录作为主情绪
      const dayMap = new Map<number, DayMood>();
      filtered.forEach(d => {
        const day = new Date(d.createdAt).getDate();
        if (!dayMap.has(day) || d.createdAt > (filtered.find(f => new Date(f.createdAt).getDate() === day)?.createdAt || 0)) {
          dayMap.set(day, { day: day, mood: d.mood, intensity: d.intensity });
        }
      });

      return Array.from(dayMap.values());
    } catch (err) {
      Logger.error(`Failed to get monthly moods: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 获取最近 7 天的情绪强度趋势
   */
  public async getWeeklyIntensity(): Promise<number[]> {
    try {
      const allDiaries = await DatabaseManager.getInstance().queryAllDiaries();
      const now = new Date().getTime();
      const sevenDaysAgo = now - 7 * 24 * 60 * 60 * 1000;
      
      const lastWeek = allDiaries.filter(d => d.createdAt >= sevenDaysAgo);
      
      // 按天分组求平均强度 (天数索引 0-6)
      const intensities: number[] = new Array(7).fill(0);
      const counts: number[] = new Array(7).fill(0);

      lastWeek.forEach(d => {
        const diffDays = Math.floor((now - d.createdAt) / (24 * 60 * 60 * 1000));
        const index = 6 - diffDays; // 0 是 7天前，6 是今天
        if (index >= 0 && index < 7) {
          intensities[index] += d.intensity;
          counts[index]++;
        }
      });

      return intensities.map((sum, i) => counts[i] > 0 ? sum / counts[i] : 0);
    } catch (err) {
      Logger.error(`Failed to get weekly intensity: ${JSON.stringify(err)}`);
      return [0, 0, 0, 0, 0, 0, 0];
    }
  }

  /**
   * 基于 MBTI 和情绪生成本地建议
   */
  public generateAdvice(mbti: string, recentMood: string): string {
    const adviceMap: Record<string, Record<string, string>> = {
      'INFP': {
        '焦虑': '守护星语：亲爱的梦想家，当星空不安时，试着把思绪写在呼吸里。你的敏感是天赋，不是负担。',
        '疲惫': '守护星语：世界太吵了，现在是你的躲避时刻。去听一首只有旋律的歌，让灵魂小睡一会儿。',
        '开心': '守护星语：你的快乐像银河一样温柔。记得收藏这一刻，它是你未来的能量补给。'
      },
      'INTJ': {
        '焦虑': '守护星语：逻辑能辅助行动，但无法消解每一个未知。试着给计划留出一片空白。',
        '疲惫': '守护星语：高效并不意味着永动机。系统需要重启，你也是。',
        '开心': '守护星语：达成目标的感觉很棒，对吗？享受这种秩序感。'
      },
      'default': {
        '焦虑': '守护星语：深呼吸。星辰转动自有其轨道，你现在的不安也会随风消散。',
        '疲惫': '守护星语：停下来，也是一种前进。给自己一个温暖的拥抱。',
        '开心': '守护星语：愿这种光芒能照亮你接下来的路。'
      }
    };

    const personaAdvice = adviceMap[mbti] || adviceMap['default'];
    return personaAdvice[recentMood] || personaAdvice['default'] || '守护星语：愿你今日如星辰般自由。';
  }
}
