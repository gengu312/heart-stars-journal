
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { DatabaseManager } from './DatabaseManager';
import { PreferenceManager } from './PreferenceManager';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/utils/Logger';
import { DiaryEntry } from '../model/DiaryEntry';
import { BusinessError } from '@ohos.base';

interface BackupPrefs {
  totalStardust: number;
  mbti: string;
  constellation: string;
  themeMode: string;
}

interface BackupData {
  version: number;
  timestamp: number;
  diaries: DiaryEntry[];
  preferences: BackupPrefs;
}

export class BackupService {
  private static instance: BackupService;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  public static getInstance(): BackupService {
    if (!BackupService.instance) {
      BackupService.instance = new BackupService();
    }
    return BackupService.instance;
  }

  public init(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 导出数据为 JSON 字符串
   */
  public async exportData(): Promise<string> {
    try {
      // 1. 获取所有日记
      const diaries = await DatabaseManager.getInstance().queryAllDiaries();
      
      // 2. 获取偏好设置
      const prefManager = PreferenceManager.getInstance();
      const prefs: BackupPrefs = {
        totalStardust: await prefManager.getValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, 0) as number,
        mbti: await prefManager.getValue(CommonConstants.PREF_KEY_MBTI, '-') as string,
        constellation: await prefManager.getValue(CommonConstants.PREF_KEY_CONSTELLATION, '-') as string,
        themeMode: await prefManager.getValue(CommonConstants.PREF_KEY_THEME_MODE, 'dark') as string
      };

      // 3. 组装完整数据对象
      const backupData: BackupData = {
        version: 1,
        timestamp: new Date().getTime(),
        diaries: diaries,
        preferences: prefs
      };

      return JSON.stringify(backupData, null, 2);
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to export data: ${JSON.stringify(error)}`);
      return '';
    }
  }

  /**
   * 将数据导出到文件
   * @returns 导出文件的完整路径
   */
  public async exportToFile(): Promise<string> {
    if (!this.context) {
      Logger.error('Context not initialized in BackupService');
      return '';
    }

    try {
      const jsonData = await this.exportData();
      if (!jsonData) return '';

      const fileName = `backup_${new Date().getTime()}.json`;
      const filesDir = this.context.filesDir;
      const filePath = `${filesDir}/${fileName}`;

      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, jsonData);
      fs.closeSync(file);
      
      Logger.info(`Data exported to: ${filePath}`);
      return filePath;
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to export to file: ${JSON.stringify(error)}`);
      return '';
    }
  }

  /**
   * 导入数据 (覆盖或合并)
   * 目前简化为：恢复偏好设置，追加日记 (如果 ID 冲突则重新生成 ID 或跳过，这里简化为重新插入)
   */
  public async importData(jsonString: string): Promise<boolean> {
    try {
      const data = JSON.parse(jsonString) as BackupData;
      
      if (!data || !data.preferences || !data.diaries) {
        Logger.error('Invalid backup data format');
        return false;
      }

      // 1. 恢复偏好设置
      const prefManager = PreferenceManager.getInstance();
      if (data.preferences.totalStardust !== undefined) {
        await prefManager.putValue(CommonConstants.PREF_KEY_TOTAL_STARDUST, data.preferences.totalStardust);
      }
      if (data.preferences.mbti !== undefined) {
        await prefManager.putValue(CommonConstants.PREF_KEY_MBTI, data.preferences.mbti);
      }
      if (data.preferences.constellation !== undefined) {
        await prefManager.putValue(CommonConstants.PREF_KEY_CONSTELLATION, data.preferences.constellation);
      }

      // 2. 恢复日记 (简单的逐条插入策略，忽略原有 ID 以避免主键冲突)
      const dbManager = DatabaseManager.getInstance();
      const diaries = data.diaries;
      if (Array.isArray(diaries)) {
        for (let i = 0; i < diaries.length; i++) {
          const diary = diaries[i];
          // 清空 ID，当作新条目插入
          diary.id = null;
          await dbManager.insertDiary(diary);
        }
      }

      Logger.info('Data imported successfully');
      return true;
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to import data: ${JSON.stringify(error)}`);
      return false;
    }
  }
}
