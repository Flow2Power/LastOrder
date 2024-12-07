import { calendarManager } from "@kit.CalendarKit";
import { abilityAccessCtrl, common, Permissions } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";

export class UserCalendarManager{
  //日历权限
  private static permissions: Permissions[] = ["ohos.permission.READ_CALENDAR", "ohos.permission.WRITE_CALENDAR"]
  //日历账户信息
  private static calendarAccount: calendarManager.CalendarAccount = {
    name: 'MyCalendar',
    type: calendarManager.CalendarType.LOCAL,
    displayName: 'MyCalendar'
  }
  //日历配置信息
  private static calendarConfig: calendarManager.CalendarConfig = {
    enableReminder: true,
  }
  // 日历账户
  private static calendar: calendarManager.Calendar | undefined = undefined;
  //日历管理器
  private static calendarManager: calendarManager.CalendarManager | null = null;
  //初始化日历账户，日历管理器（先获取日历的相关权限，然后再创建）
  static async initCalendar(Context:Context){
    let context: common.UIAbilityContext = Context as common.UIAbilityContext;
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      let data = await atManager.requestPermissionsFromUser(context, UserCalendarManager.permissions);
      let grantStatus: Array<number> = data.authResults;
      if (grantStatus.some(status => status !== 0)) {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        console.error('模拟器未获取授权');
        return;
      }
      //获取日历管理器
      try {
        UserCalendarManager.calendarManager = calendarManager.getCalendarManager(Context);
        console.info('模拟器获取日历管理器成功');
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器获取日历管理器失败，错误码为：${error.code}，错误信息为：${error.message}`);
      }
      //获取日历账户
      try {
        UserCalendarManager.calendar=await UserCalendarManager.calendarManager?.getCalendar(UserCalendarManager.calendarAccount)
        console.info(`模拟器获取日历账户成功，日历账户ID为：${UserCalendarManager.calendar?.id}`);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器获取日历账户失败，错误码为：${error.code}，错误信息为：${error.message}`);
        //创建指定的日历账户
        try {
          UserCalendarManager.calendar = await UserCalendarManager.calendarManager?.createCalendar(UserCalendarManager.calendarAccount)
          console.info(`模拟器创建日历账户成功，日历账户ID为：${UserCalendarManager.calendar?.id}`);
        }catch (err){
          let error: BusinessError = err as BusinessError;
          console.error(`模拟器创建日历账户失败，错误码为：${error.code}，错误信息为：${error.message}`);
        }
        //配置日历账户
        try{
          await UserCalendarManager.calendar?.setConfig(UserCalendarManager.calendarConfig)
          console.info(`模拟器配置日历账户成功`);
        }catch (err){
          let error: BusinessError = err as BusinessError;
          console.error(`模拟器配置日历账户失败，错误码为：${error.code}，错误信息为：${error.message}`);
        }
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取日历权限失败，错误码为：${error.code}，错误信息为：${error.message}`);
    }
  }
  //添加日程
  static async addEvent(event: calendarManager.Event){
    try{
      let result =await UserCalendarManager.calendar?.addEvent(event)
      console.info(`模拟器添加日程成功，日程ID为：${result}`);
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器添加日程失败，错误码为：${error.code}，错误信息为：${error.message}`);
    }
  }
}
export default UserCalendarManager;