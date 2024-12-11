import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  ChatCompletionResponse,
  ChatMessage,
  ChatRequest, Holidays, QueryResult, SolarTerms, SolarTermsInfo } from './DataInterface';

export class NetworkDataFetcher {
  //创建通信会话对象
  private static session = rcp.createSession();
  // //定义讯飞星火的请求头
  // private static headers:rcp.ResponseHeaders = {
  //   'Content-Type': 'application/json',
  //   'Authorization': 'Bearer NLhLLIqdRUltNPpZaZXg:JTTtnxmxkRPFiqBrdgHA'
  // }
  // //定义讯飞星火的请求数据
  // private static chatRequest:ChatRequest = {
  //   model: 'generalv3.5',
  //   user: 'user',
  //   messages: [
  //     {
  //       "role": "system",
  //       "content": "你是知识渊博的助理"
  //     },
  //     {
  //       "role": "user",
  //       "content": "你好，讯飞星火"
  //     }
  //   ]
  // }
  //创建讯飞星火的会话对象
  // private static AISession = rcp.createSession({headers: NetworkDataFetcher.headers});
  //节假日信息获取
  //文心一言
  private static API_Key = '7rNZ9QD9gkM0csjJlcK9LX3p'
  private static API_Secret = '5gp8b6EoWXheXxhVOeoHbx1wZVvCaeLy'
  private static Access_token = '24.029a3eca45b18278c7dc0ad2719d8b82.2592000.1736432026.282335-116620596'
  private static headers:rcp.ResponseHeaders = {
    'Content-Type': 'application/json'
  }
  private static AISession = rcp.createSession({headers: NetworkDataFetcher.headers});
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
  //ERNIE-4.0-8K
  public static async sendMessageToERNIE4_8K(message: string,system: string): Promise<ChatMessage>{
    let response: ChatMessage = {
      text: '',
      isSelf: 0
    }
    let requestBody: ChatRequest = {
      messages: [
        {
          role: "user",
          content: message
        }
      ],
      system: '你是日历软件的日程管理助手'
    }
    requestBody.system = system == '' ? '你是日历软件的日程管理助手' : system
    let requestContent: rcp.RequestContent = requestBody
    console.info('模拟器发送信息为:'+JSON.stringify(requestContent))
    try{
      let responseBody = await NetworkDataFetcher.session.post(`https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?client_id=${NetworkDataFetcher.API_Key}&client_secret=${NetworkDataFetcher.API_Secret}&access_token=${NetworkDataFetcher.Access_token}`,requestContent)
      let data: ChatCompletionResponse = responseBody.toJSON() as ChatCompletionResponse;
      response.text = data.result;
      console.info('模拟器发送信息成功，返回数据为:'+JSON.stringify(response))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器发送信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return response;
  }
  //ERNIE-4.0-Turbo-8K
  public static async sendMessageToERNIE4_Turbo_8K(message: string,system: string): Promise<ChatMessage>{
    let response: ChatMessage = {
      text: '',
      isSelf: 0
    }
    let requestBody: ChatRequest = {
      messages: [
        {
          role: "user",
          content: message
        }
      ],
      system: '你是日历软件的日程管理助手'
    }
    requestBody.system = system == '' ? '你是日历软件的日程管理助手' : system
    let requestContent: rcp.RequestContent = requestBody
    console.info('模拟器发送信息为:'+JSON.stringify(requestContent))
    try{
      let responseBody = await NetworkDataFetcher.session.post(`https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-4.0-turbo-8k?client_id=${NetworkDataFetcher.API_Key}&client_secret=${NetworkDataFetcher.API_Secret}&access_token=${NetworkDataFetcher.Access_token}`,requestContent)
      let data: ChatCompletionResponse = responseBody.toJSON() as ChatCompletionResponse;
      response.text = data.result;
      console.info('模拟器发送信息成功，返回数据为:'+JSON.stringify(response))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器发送信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return response;
  }
  //ERNIE-3.5-8K
  public static async sendMessageToERNIE3_5_8K(message: string,system: string): Promise<ChatMessage>{
    let response: ChatMessage = {
      text: '',
      isSelf: 0
    }
    let requestBody: ChatRequest = {
      messages: [
        {
          role: "user",
          content: message
        }
      ],
      system: '你是日历软件的日程管理助手'
    }
    requestBody.system = system == '' ? '你是日历软件的日程管理助手' : system
    let requestContent: rcp.RequestContent = requestBody
    console.info('模拟器发送信息为:'+JSON.stringify(requestContent))
    try{
      let responseBody = await NetworkDataFetcher.session.post(`https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions?client_id=${NetworkDataFetcher.API_Key}&client_secret=${NetworkDataFetcher.API_Secret}&access_token=${NetworkDataFetcher.Access_token}`,requestContent)
      let data: ChatCompletionResponse = responseBody.toJSON() as ChatCompletionResponse;
      response.text = data.result;
      console.info('模拟器发送信息成功，返回数据为:'+JSON.stringify(response))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器发送信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return response;
  }
  //ERNIE-Speed
  public static async sendMessageToERNIESpeed(message: string,system: string): Promise<ChatMessage>{
    let response: ChatMessage = {
      text: '',
      isSelf: 0
    }
    let requestBody: ChatRequest = {
      messages: [
        {
          role: "user",
          content: message
        }
      ],
      system: '你是日历软件的日程管理助手'
    }
    requestBody.system = system == '' ? '你是日历软件的日程管理助手' : system
    let requestContent: rcp.RequestContent = requestBody
    console.info('模拟器发送信息为:'+JSON.stringify(requestContent))
    try{
      let responseBody = await NetworkDataFetcher.session.post(`https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie_speed?client_id=${NetworkDataFetcher.API_Key}&client_secret=${NetworkDataFetcher.API_Secret}&access_token=${NetworkDataFetcher.Access_token}`,requestContent)
      let data: ChatCompletionResponse = responseBody.toJSON() as ChatCompletionResponse;
      response.text = data.result;
      console.info('模拟器发送信息成功，返回数据为:'+JSON.stringify(response))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器发送信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return response;
  }
  //ERNIE-Lite
  public static async sendMessageToERNIELite(message: string,system: string): Promise<ChatMessage>{
    let response: ChatMessage = {
      text: '',
      isSelf: 0
    }
    let requestBody: ChatRequest = {
      messages: [
        {
          role: "user",
          content: message
        }
      ],
      system: '你是日历软件的日程管理助手'
    }
    requestBody.system = system == '' ? '你是日历软件的日程管理助手' : system
    let requestContent: rcp.RequestContent = requestBody
    console.info('模拟器发送信息为:'+JSON.stringify(requestContent))
    try{
      let responseBody = await NetworkDataFetcher.session.post(`https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-lite-8k?client_id=${NetworkDataFetcher.API_Key}&client_secret=${NetworkDataFetcher.API_Secret}&access_token=${NetworkDataFetcher.Access_token}`,requestContent)
      let data: ChatCompletionResponse = responseBody.toJSON() as ChatCompletionResponse;
      response.text = data.result;
      console.info('模拟器发送信息成功，返回数据为:'+JSON.stringify(response))
    }catch (err){
      let error:BusinessError = new err as BusinessError;
      console.error(`模拟器发送信息失败,错误码为：${error.code}，错误信息为：${error.message}`)
    }
    return response;
  }
}
export default NetworkDataFetcher;