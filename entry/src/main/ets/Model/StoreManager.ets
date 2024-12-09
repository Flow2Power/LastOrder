import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { HolidayInfo, Holidays, SolarTerms, SolarTermsInfo } from "./DataInterface";


export class StoreManager{
  // 数据库对象
  private static store: relationalStore.RdbStore | null = null
  // 建表语句
  private static createHolidayInfoTable: string = `
CREATE TABLE IF NOT EXISTS HolidayInfo (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  name TEXT NOT NULL,
  isOffDay INTEGER NOT NULL,
  year INTEGER NOT NULL
);
`;
  private static createSolarTermsInfoTable: string = `
CREATE TABLE IF NOT EXISTS SolarTermsInfo (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pub_year TEXT NOT NULL,
  name TEXT NOT NULL,
  pub_date TEXT NOT NULL
);
`;
  // 获取数据库对象
  public static async getStore(context:Context) {
    try {
      if (StoreManager.store) {
        return StoreManager.store;
      }
      // 创建数据库对象
      StoreManager.store = await relationalStore.getRdbStore(context,{
        name:'RDB.db',//数据库名称
        securityLevel:relationalStore.SecurityLevel.S1,//数据库安全级别
      });
      // 创建表节假日信息表
      try {
        await StoreManager.store.executeSql(StoreManager.createHolidayInfoTable);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表createHolidayInfoTable失败: Code is ${error.code}, message is ${error.message}`);
      }
      try {
        await StoreManager.store.executeSql(StoreManager.createSolarTermsInfoTable);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表createSolarTermsInfoTable失败: Code is ${error.code}, message is ${error.message}`);
      }
      console.log('模拟器数据库对象创建成功');
      return StoreManager.store;
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return StoreManager.store;
    }
  }
  // 获取节假日信息
  public static async getHolidays(year:number,context:Context):Promise<Holidays>{
    let holidays:Holidays = {};
    let holidayInfo:HolidayInfo[]=[];
    try{
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('HolidayInfo');
      predicates.equalTo('year',year);
      let resultSet=await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()){
        holidayInfo.push({
          id:resultSet.getLong(resultSet.getColumnIndex('id')),
          date:resultSet.getString(resultSet.getColumnIndex('date')),
          name:resultSet.getString(resultSet.getColumnIndex('name')),
          isOffDay:resultSet.getLong(resultSet.getColumnIndex('isOffDay')),
          year:resultSet.getLong(resultSet.getColumnIndex('year')),
        })
      }
      holidayInfo.forEach(item=>{
        holidays[item.date]=item;
      })
      console.info('模拟器数据库获取节假日信息成功，返回数据为:'+JSON.stringify(holidays))
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
    }
		return holidays;
	}
  // 添加节假日信息
  public static async addHolidays(holidays:Holidays,context:Context):Promise<boolean>{
    try{
      await StoreManager.getStore(context);
      try {
        Object.keys(holidays).forEach(async key => {
          let holidayInfo: HolidayInfo = holidays[key];
          await StoreManager.store?.insert('HolidayInfo',holidayInfo as ValuesBucket);
        });
        console.info('模拟器添加节假日信息成功:'+JSON.stringify(holidays));
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加节假日信息失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取二十四节气信息
  public static async getTwentyFourSolarTerms(year:number,context:Context):Promise<SolarTerms>{
    let solarTerms:SolarTerms = {};
    let solarTermsInfo:SolarTermsInfo[]=[];
    try{
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('SolarTermsInfo');
      predicates.equalTo('pub_year',year.toString());
      let resultSet=await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()){
        solarTermsInfo.push({
          id:resultSet.getLong(resultSet.getColumnIndex('id')),
          pub_year:resultSet.getString(resultSet.getColumnIndex('pub_year')),
          name:resultSet.getString(resultSet.getColumnIndex('name')),
          pub_date:resultSet.getString(resultSet.getColumnIndex('pub_date')),
        })
      }
      solarTermsInfo.forEach(item=>{
        solarTerms[item.pub_date]=item;
      })
      console.info('模拟器数据库获取二十四节气信息成功，返回数据为:'+JSON.stringify(solarTerms))
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
    }
    return solarTerms;
  }
  // 添加二十四节气信息
  public static async addTwentyFourSolarTerms(solarTerms:SolarTerms,context:Context):Promise<boolean>{
    try{
      await StoreManager.getStore(context);
      try {
        Object.keys(solarTerms).forEach(async key => {
          let solarTermsInfo: SolarTermsInfo = solarTerms[key];
          await StoreManager.store?.insert('SolarTermsInfo',solarTermsInfo as ValuesBucket);
        });
        console.info('模拟器添加二十四节气信息成功:'+JSON.stringify(solarTerms));
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加二十四节气信息失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
}
export default StoreManager;