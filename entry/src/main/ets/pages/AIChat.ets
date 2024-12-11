import { promptAction, router } from '@kit.ArkUI'
import { ChatMessage } from '../Model/DataInterface'
import NetworkDataFetcher from '../Model/NetworkDataFetcher'

//构建文本输入弹窗
@CustomDialog
@Component
struct CustomDialogExample {
  @Link System: string
  controller?: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}
  build() {
    Row() {
      Column(){
        Text('设定希望的系统角色')
          .fontSize(20)
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
        TextInput({ placeholder: '例：你是一只猫娘', text: this.System })
          .height('50%')
          .width('100%')
          .placeholderFont({ size: 20, weight: FontWeight.Bold })
          .placeholderColor(Color.Gray)
          .fontSize(20)
          .fontColor(Color.Gray)
          .onChange((value: string) => {
            this.System = value
          })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('85%')
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(40)
        .fontColor([Color.Gray])
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          if (this.controller != undefined) {
            if (this.System != '') {
              this.controller.close()
              this.confirm()
              promptAction.showToast({
                message: '系统角色设定成功',
                duration: 2000
              })
            }else{
              this.controller.close()
              this.confirm()
            }
          }
        })
    }
    .width('100%')
    .height('20%')
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 20, right: 20, bottom: 20,top: 20})
    .borderRadius(10)
    .backgroundColor('#55737272')
  }
}
@Entry
@Component
struct AIChat {
  private scrollerForScroll: Scroller = new Scroller()
  private robotChoose:number = 0
  @State private System: string = ''
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> {},
      confirm: ()=> {},
      System: $System,
    }),
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })
  @StorageLink('backgroundNum')  private backgroundNum: number = 1
  @State private textValue: string = ''
  @State private MessageList: ChatMessage[] = []
  async aboutToAppear(): Promise<void> {
    console.info('模拟器AIChat aboutToAppear')
    this.MessageList = []
    let message: ChatMessage = {
      text:'你好',
      isSelf: 1
    }
    this.SendMessage(message)
  }
  private SendMessage(message:ChatMessage){
    switch (this.robotChoose){
      case 0:
        NetworkDataFetcher.sendMessageToERNIE4_8K(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 1:
        NetworkDataFetcher.sendMessageToERNIE4_Turbo_8K(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 2:
        NetworkDataFetcher.sendMessageToERNIE3_5_8K(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 3:
        NetworkDataFetcher.sendMessageToERNIESpeed(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 4:
        NetworkDataFetcher.sendMessageToERNIELite(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 5:
        NetworkDataFetcher.sendMessageToSparkPro(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 6:
        NetworkDataFetcher.sendMessageToSparkMax(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
      case 7:
        NetworkDataFetcher.sendMessageToSpark4_Ultra(message.text,this.System).then(response=>{
          this.MessageList.push(response)
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
        })
        break
    }
  }
  @Builder topBarBuilder() {
    Row(){
      SymbolGlyph($r('sys.symbol.arrow_left'))
        .fontSize(25)
        .fontColor([Color.White])
        .fontWeight(FontWeight.Bold)
        .onClick(()=>{
          router.back()
          console.info('模拟器返回')
        })
      Text('AI Chat')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({left:'5%'})
      SymbolGlyph($r('sys.symbol.trash_fill'))
        .fontSize(25)
        .fontColor([Color.White])
        .fontWeight(FontWeight.Bold)
        .margin({left:'45%'})
        .onClick(()=>{
          this.MessageList = []
          promptAction.showToast({
            message: '聊天记录清空',
            duration: 2000
          })
        })
      SymbolGlyph($r('sys.symbol.gearshape'))
        .fontSize(25)
        .fontColor([Color.White])
        .fontWeight(FontWeight.Bold)
        .margin({left:'5%'})
        .onClick(()=>{
          this.dialogController?.open()
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .width('95%')
    .height('5%')
    .margin({top:'10%'})
    .padding({left: '5%', right: '5%'})
    .borderRadius(5)
    .backgroundColor('#55737272')
  }
  @Builder MessageInputBuilder() {
    Row(){
      Image($r('app.media.robot'))
        .width(40)
        .height(35)
        .fillColor(Color.White)
        .opacity(0.8)
        .bindMenu([
          {
            value: 'ERNIE-4.0',
            action: ()=>{
              this.robotChoose = 0
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'ERNIE-4.0启用',
                duration: 2000
              })
            }
          },
          {
            value: 'ERNIE-4.0-Turbo',
            action: ()=>{
              this.robotChoose = 1
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'ERNIE-4.0-Turbo启用',
                duration: 2000
              })
            }
          },
          {
            value: 'ERNIE-3.5',
            action: ()=>{
              this.robotChoose = 2
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'ERNIE-3.5启用',
                duration: 2000
              })
            }
          },
          {
            value: 'ERNIE-Speed',
            action: ()=>{
              this.robotChoose = 3
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'ERNIE-Speed启用',
                duration: 2000
              })
            }
          },
          {
            value: 'ERNIE-Lite',
            action: ()=>{
              this.robotChoose = 4
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'ERNIE-Lite启用',
                duration: 2000
              })
            }
          },
          {
            value: 'Spark-Pro',
            action: ()=>{
              this.robotChoose = 5
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'Spark-Pro启用',
                duration: 2000
              })
            }
          },
          {
            value: 'Spark-Max',
            action: ()=>{
              this.robotChoose = 6
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'Spark-Max启用',
                duration: 2000
              })
            }
          },
          {
            value: 'Spark-4-Ultra',
            action: ()=>{
              this.robotChoose = 7
              this.MessageList = []
              let message: ChatMessage = {
                text:'你好',
                isSelf: 1
              }
              this.SendMessage(message)
              promptAction.showToast({
                message: 'Spark-4-Ultra启用',
                duration: 2000
              })
            }
          }
        ])
      TextInput({ placeholder: '今天想问什么？', text: this.textValue })
        .height('80%')
        .width('70%')
        .placeholderFont({ size: 22, weight: FontWeight.Bold })
        .placeholderColor(Color.White)
        .fontSize(22)
        .fontColor(Color.White)
        .opacity(0.8)
        .onChange((value: string) => {
          this.textValue = value
        })
      Image($r('app.media.message'))
        .width(35)
        .height(35)
        .fillColor(Color.White)
        .opacity(0.8)
        .onClick(()=>{
          let message: ChatMessage = { text: this.textValue, isSelf: 1 }
          this.MessageList.push(message)
          this.textValue = ''
          this.scrollerForScroll.scrollEdge(Edge.Bottom)
          this.SendMessage(message)
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('95%')
    .height('8%')
    .margin({bottom:'10%'})
    .padding({left: '5%', right: '5%'})
    .borderRadius(5)
    .backgroundColor('#aa737272')
  }
  @Builder MessageItem(message:ChatMessage){
    Row(){
      Image($r('app.media.Chatrobot'))
        .width(40)
        .height(40)
        .fillColor(Color.White)
        .opacity(message.isSelf ? 0 :0.8)
      Text(`${message.text}`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(message.isSelf? TextAlign.End:TextAlign.Start)
        .width('75%')
        .height('auto')
        .padding({left:'5%',right:'5%',top:'5%',bottom:'5%'})
        .opacity(0.9)
        .borderRadius(5)
        .backgroundColor('#55737272')
      Image($r('app.media.wode'))
        .width(40)
        .height(40)
        .fillColor(Color.White)
        .opacity(message.isSelf ? 0.8 :0)
    }
    .width('100%')
    .height('auto')
    .padding({left:'5%',right:'5%',top:'5%',bottom:'5%'})
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    Column(){
      this.topBarBuilder()
      Scroll(this.scrollerForScroll){
        Column(){
          List(){
            ForEach(this.MessageList, (item:ChatMessage)=>{
              ListItem(){
                this.MessageItem(item)
              }
            })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
        }
        .width('100%')
      }
      .width('100%')
      .height('80%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .scrollable(ScrollDirection.Horizontal)
      .align(Alignment.Top)
      this.MessageInputBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}