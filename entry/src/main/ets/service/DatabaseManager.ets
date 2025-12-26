
import relationalStore from '@ohos.data.relationalStore';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/utils/Logger';
import { DiaryEntry, StardustLog } from '../model/DiaryEntry';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  public async init(context: common.Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: CommonConstants.RDB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      Logger.info('RdbStore initialized');
      await this.createTables();
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to init RdbStore: ${JSON.stringify(error)}`);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }

    const createDiaryTable = `
      CREATE TABLE IF NOT EXISTS ${CommonConstants.DIARY_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT,
        mood TEXT,
        intensity INTEGER,
        tags TEXT,
        images TEXT,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    `;

    const createStardustTable = `
      CREATE TABLE IF NOT EXISTS ${CommonConstants.STARDUST_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER,
        reason TEXT,
        createdAt INTEGER
      )
    `;

    try {
      await this.rdbStore.executeSql(createDiaryTable);
      await this.rdbStore.executeSql(createStardustTable);
      Logger.info('Tables created successfully');
    } catch (err) {
      const error = err as BusinessError;
      Logger.error(`Failed to create tables: ${JSON.stringify(error)}`);
    }
  }

  // Basic CRUD for Diary
  public async insertDiary(diary: DiaryEntry): Promise<number> {
    if (!this.rdbStore) {
      return -1;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      content: diary.content,
      mood: diary.mood,
      intensity: diary.intensity,
      tags: diary.tags,
      images: diary.images,
      createdAt: diary.createdAt,
      updatedAt: diary.updatedAt
    };
    return await this.rdbStore.insert(CommonConstants.DIARY_TABLE, valueBucket);
  }

  public async queryAllDiaries(): Promise<DiaryEntry[]> {
    if (!this.rdbStore) {
      return [];
    }
    let predicates = new relationalStore.RdbPredicates(CommonConstants.DIARY_TABLE);
    predicates.orderByDesc('createdAt');
    let resultSet = await this.rdbStore.query(predicates);
    let diaries: DiaryEntry[] = [];
    while (resultSet.goToNextRow()) {
      diaries.push(new DiaryEntry(
        resultSet.getString(resultSet.getColumnIndex('content')),
        resultSet.getString(resultSet.getColumnIndex('mood')),
        resultSet.getLong(resultSet.getColumnIndex('intensity')),
        JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags'))),
        JSON.parse(resultSet.getString(resultSet.getColumnIndex('images'))),
        resultSet.getLong(resultSet.getColumnIndex('id')),
        resultSet.getLong(resultSet.getColumnIndex('createdAt')),
        resultSet.getLong(resultSet.getColumnIndex('updatedAt')),
      ));
    }
    resultSet.close();
    return diaries;
  }
}
