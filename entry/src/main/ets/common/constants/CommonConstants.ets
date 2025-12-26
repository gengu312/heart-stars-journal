
export class CommonConstants {
  /**
   * Rdb Relational Store Configs
   */
  static readonly RDB_NAME = 'HeartStarsJournal.db';
  static readonly RDB_VERSION = 1;
  static readonly RDB_TAG = 'RdbStore';

  /**
   * Table Names
   */
  static readonly DIARY_TABLE = 'diary';
  static readonly STARDUST_TABLE = 'stardust_log';

  /**
   * Preferences Configs
   */
  static readonly PREFS_NAME = 'HeartStarsPrefs';
  static readonly PREF_KEY_TOTAL_STARDUST = 'total_stardust';
  static readonly PREF_KEY_MBTI = 'user_mbti';
  static readonly PREF_KEY_CONSTELLATION = 'user_constellation';
  static readonly PREF_KEY_THEME_MODE = 'theme_mode'; // 'dark' or 'light'
}
