import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
export class PreferencesManager {
  //定义存储路径
  private static readonly PREFERENCES_PATH: string = 'DataPersistence';
  //定义存储键
  private static readonly KEY_Background: string = 'Background';
  private static readonly KEY_formId: string = 'formId';
  //定义存储对象
  private static preferences: dataPreferences.Preferences | undefined = undefined;
  //储存Background
  public static async putBackground(Background: number, context: Context): Promise<void> {
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      await PreferencesManager.preferences.put(PreferencesManager.KEY_Background, Background);
      await PreferencesManager.preferences.flush();
      console.info('模拟器putBackground success');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器Failed to put Background. Code:${error.code}, message:${error.message}`);
    }
  }
  //获取Background
  public static async getBackground(context: Context): Promise<number> {
    let Background: number = 0;
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      Background = await PreferencesManager.preferences.get(PreferencesManager.KEY_Background, 1) as number;
      console.info('模拟器getBackground success'+JSON.stringify(Background));
    } catch (err) {
      let error: BusinessError= err as BusinessError;
      console.error(`模拟器Failed to get Background. Code:${error.code}, message:${error.message}`);
    }
    return Background;
  }
  //储存formId
  public static async putFormId(formId: string|undefined, context: Context): Promise<void> {
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      await PreferencesManager.preferences.put(PreferencesManager.KEY_formId, formId);
      await PreferencesManager.preferences.flush();
      console.info('模拟器putFormId success');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器Failed to put formId. Code:${error.code}, message:${error.message}`);
    }
  }
  //获取formId
  public static async getFormId(context: Context): Promise<string> {
    let formId: string = '';
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      formId = await PreferencesManager.preferences.get(PreferencesManager.KEY_formId, '') as string;
      console.info('模拟器getFormId success'+JSON.stringify(formId));
    } catch (err) {
     let error: BusinessError= err as BusinessError;
     console.error(`模拟器Failed to get formId. Code:${error.code}, message:${error.message}`);
    }
    return formId;
  }
}
export default PreferencesManager;