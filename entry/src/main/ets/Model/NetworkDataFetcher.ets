import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HolidayInfo, Holidays, QueryResult, SolarTerms, SolarTermsInfo } from './DataInterface';

export class NetworkDataFetcher {
  private static session = rcp.createSession();
  //节假日信息获取
  public static async getHolidays(year: number): Promise<Holidays>{
    let holidays: Holidays = {};
    try{
      let response = await NetworkDataFetcher.session.get(`https://api.jiejiariapi.com/v1/holidays/${year}`)
      holidays = response.toJSON() as Holidays;
      Object.keys(holidays).forEach(async key => {
        holidays[key].year = year;
      });
      console.info('模拟器网络获取节假日信息成功，返回数据为:'+JSON.stringify(holidays))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器网络获取节假日信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    ;
    return holidays;
  }
  //二十四节气信息获取
  public static async getTwentyFourSolarTerms(year: number): Promise<SolarTerms>{
    let solarTerms: SolarTerms = {};
    let solarTermsInfo: SolarTermsInfo[] = []
    try{
      let response = await NetworkDataFetcher.session.get(`http://apis.juhe.cn/fapig/solarTerms/query?year=${year}&name=&key=46b6f1a4baaf151b8c8ebcdba2833ebc`)
      let data : QueryResult = response.toJSON() as QueryResult;
      data.result.forEach(item => {
        solarTermsInfo.push({
          pub_year: item.pub_year,
          name: item.name,
          pub_date: item.pub_date
        } as SolarTermsInfo)
      })
      solarTermsInfo.forEach(item => {
        solarTerms[item.pub_date] = item;
      })
      console.info('模拟器获取二十四节气信息成功，返回数据为:'+JSON.stringify(solarTerms))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器获取二十四节气信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return solarTerms;
  }
}
export default NetworkDataFetcher;