
import dataPreferences from '@ohos.data.preferences';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/utils/Logger';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

export class PreferenceManager {
  private static instance: PreferenceManager;
  private preferences: dataPreferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): PreferenceManager {
    if (!PreferenceManager.instance) {
      PreferenceManager.instance = new PreferenceManager();
    }
    return PreferenceManager.instance;
  }

  public async init(context: common.Context): Promise<void> {
    try {
      this.preferences = await dataPreferences.getPreferences(context, CommonConstants.PREFS_NAME);
      Logger.info('Preferences initialized');
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to init Preferences: ${JSON.stringify(error)}`);
    }
  }

  public async putValue(key: string, value: dataPreferences.ValueType): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to put value to preferences: ${JSON.stringify(error)}`);
    }
  }

  public async getValue(key: string, defaultValue: dataPreferences.ValueType): Promise<dataPreferences.ValueType> {
    if (!this.preferences) {
      return defaultValue;
    }
    try {
      return await this.preferences.get(key, defaultValue);
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to get value from preferences: ${JSON.stringify(error)}`);
      return defaultValue;
    }
  }
}
