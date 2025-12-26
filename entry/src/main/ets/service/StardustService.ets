
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/utils/Logger';
import { PreferenceManager } from './PreferenceManager';
import { DatabaseManager } from './DatabaseManager';
import { BusinessError } from '@ohos.base';

export class StardustService {
  private static instance: StardustService;
  
  // 积分规则常量
  static readonly EARN_DIARY = 10;
  static readonly EARN_BREATHING = 5;

  private constructor() {}

  public static getInstance(): StardustService {
    if (!StardustService.instance) {
      StardustService.instance = new StardustService();
    }
    return StardustService.instance;
  }

  /**
   * 增加星辰积分
   * @param amount 数量
   * @param reason 原因 (用户不可见，用于日志)
   * @returns 新的总积分
   */
  public async addStardust(amount: number, reason: string): Promise<number> {
    try {
      // 1. 获取当前积分
      const currentTotal = await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, 0) as number;
      const newTotal = currentTotal + amount;
      
      // 2. 更新 Preferences
      await PreferenceManager.getInstance().putValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, newTotal);
      
      // 3. 记录日志到数据库 (可选，用于未来查询明细)
      // await DatabaseManager.getInstance().insertStardustLog(...) // 暂略，简化阶段不强求日志表
      
      Logger.info(`Added ${amount} stardust. New total: ${newTotal}`);
      return newTotal;
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to add stardust: ${JSON.stringify(error)}`);
      return -1;
    }
  }

  /**
   * 获取当前总积分
   */
  public async getTotalStardust(): Promise<number> {
    return await PreferenceManager.getInstance().getValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, 0) as number;
  }
}
