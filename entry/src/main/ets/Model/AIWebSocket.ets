import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, util } from '@kit.ArkTS';
import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';


export class AIWebSocket {
  private static readonly URL = "wss://spark-api.xf-yun.com/v3.5/chat";
  private static readonly APPID = "b7090a88";
  private static readonly API_SECRET = "NjcwMDM5OThhOWE1ZDhiNGYyY2M2OWUw";
  private static readonly API_KEY = "0373e298759e8bf305ed4801c3c521df";
  private static ws = webSocket.createWebSocket()
  //hmac-sha256
  private static async HmacSHA256(input: Uint8Array, key: Uint8Array): Promise<Uint8Array> {
    let mac = cryptoFramework.createMac("SHA256")
    let generator = cryptoFramework.createSymKeyGenerator("HMAC")
    let symKey = await generator.convertKey({ data: key })
    await mac.init(symKey)
    await mac.update({ data: input })
    let result = await mac.doFinal()
    return result.data
  }
  //构建鉴权url
   static async getUrl(): Promise<string>{
    let algorithm = "hmac-sha256";
    let headers = "host date request-line";
    //首先获取主机接口,host
    let host = 'spark-api.xf-yun.com'
    //获取当前时间戳,date
    let date = new Date().toUTCString();
    //构建鉴权参数,authorization
    let signatureOrigin = `host: ${host}\ndate: ${date}\nGET /v3.5/chat HTTP/1.1`;
    let signatureSha = await AIWebSocket.HmacSHA256(AIWebSocket.stringToUTF8Array(signatureOrigin), AIWebSocket.stringToUTF8Array(AIWebSocket.API_SECRET)) as Uint8Array;
     let base64 = new util.Base64Helper();
     let signature = base64.encodeToStringSync(signatureSha)
     let authorization_origin = `api_key="${AIWebSocket.API_KEY}", algorithm="${algorithm}", headers="${headers}", signature="${signature}"`
     let authorization = base64.encodeToStringSync(AIWebSocket.stringToUTF8Array(authorization_origin))
     //构建鉴权url
     return `${AIWebSocket.URL}?authorization=${authorization}&date=${date}&host=${host}`
  }
  private static stringToUTF8Array(str: string) {
    let bufferstr = buffer.from(str, 'utf8');
    return new Uint8Array(bufferstr.buffer, 0, bufferstr.length)
  }
  //建立连接
  static connect() {
    //初始化
    AIWebSocket.ws.on('open', (err: BusinessError, value: Object) => {
      console.log("模拟器on open, status:" + JSON.stringify(value));
      // 当收到on('open')事件时，可以通过send()方法与服务器进行通信
      AIWebSocket.ws.send("Hello, server!", (err: BusinessError, value: boolean) => {
        if (!err) {
          console.log("模拟器Message sent successfully");
        } else {
          console.log("模拟器Failed to send the message. Err:" + JSON.stringify(err));
        }
      });
    });
    AIWebSocket.ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      console.log("模拟器on message, message:" + value);
      // 当收到服务器的`bye`消息时（此消息字段仅为示意，具体字段需要与服务器协商），主动断开连接
      if (value === 'bye') {
        AIWebSocket.ws.close((err: BusinessError, value: boolean) => {
          if (!err) {
            console.log("模拟器Connection closed successfully");
          } else {
            console.log("模拟器Failed to close the connection. Err: " + JSON.stringify(err));
          }
        });
      }
    });
    AIWebSocket.ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      console.log("模拟器on close, code is " + value.code + ", reason is " + value.reason);
    });
    AIWebSocket.ws.on('error', (err: BusinessError) => {
      console.log("模拟器on error, error:" + JSON.stringify(err));
      console.error(`模拟器AIWebSocket connect failed,code is ${err.code},message is ${err.message}`)
    });
     AIWebSocket.getUrl().then(url=>{
       AIWebSocket.ws.connect(url).then((value: boolean)=> {
         console.info('模拟器AIWebSocket connect success')
       })
     }).catch((error: BusinessError)=> {
       console.error(`模拟器AIWebSocket connect failed,code is ${error.code},message is ${error.message}`)
     })
  }
}
export default AIWebSocket;