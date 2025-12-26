
import hilog from '@ohos.hilog';

export class Logger {
  private static readonly DOMAIN: number = 0x0000;
  private static readonly TAG: string = 'HeartStarsJournal';

  static debug(...args: string[]): void {
    hilog.debug(Logger.DOMAIN, Logger.TAG, Logger.format(args));
  }

  static info(...args: string[]): void {
    hilog.info(Logger.DOMAIN, Logger.TAG, Logger.format(args));
  }

  static warn(...args: string[]): void {
    hilog.warn(Logger.DOMAIN, Logger.TAG, Logger.format(args));
  }

  static error(...args: string[]): void {
    hilog.error(Logger.DOMAIN, Logger.TAG, Logger.format(args));
  }

  private static format(args: string[]): string {
    return args.join(' ');
  }
}
