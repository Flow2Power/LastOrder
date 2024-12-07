import { router } from '@kit.ArkUI'
import { calendarManager } from '@kit.CalendarKit'
import UserCalendarManager from '../Model/UserCalendarManager'

@Entry
@Component
struct AddEvent {
  @State private title:string = ''
  @State private content:string = ''
  @State private StartTime: Date = new Date();
  @State private EndTime: Date = new Date();
  @State private reminderTime: number[] = [10]
  @State private isAllDay: boolean = false;
  private event:calendarManager.Event|undefined= undefined;
  //辅助函数，将分钟数补零
  private addZero(num: number): string {
    return num < 10 ? '0' + num.toString() : num.toString()
  }
  //添加日程
  private addEvent(){
    this.event={
      type: calendarManager.EventType.NORMAL,
      title: this.title,
      description: this.content,
      startTime: this.StartTime.getTime(),
      endTime: this.EndTime.getTime(),
      reminderTime: this.reminderTime,
      isAllDay: this.isAllDay
    }as calendarManager.Event
    UserCalendarManager.addEvent(this.event).then(()=>{
      router.back();
    })
  }

  @Builder topBarBuilder() {
    Row(){
      Row(){
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(25)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .onClick(()=>{
            console.log('模拟器新建日程取消');
            router.back();
          })
        Text('新建日程')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width('35%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      SymbolGlyph($r('sys.symbol.checkmark'))
        .fontSize(25)
        .fontColor([Color.White])
        .fontWeight(FontWeight.Bold)
        .onClick(()=>{
          this.addEvent();
        })
    }
    .width('95%')
    .height('5%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .margin({ top: '8%' })
    .padding({ top: '2%', bottom: '2%', left: '5%', right: '5%' })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  // 标题输入框
  @Builder titleInputBuilder(){
    Row(){
      Image($r('app.media.t'))
        .width(30)
        .height(30)
        .fillColor(Color.Grey)
      TextInput({ placeholder:'标题', text: this.title })
        .placeholderFont({ size: 20})
        .placeholderColor(Color.White)
        .fontSize(20)
        .fontColor(Color.White)
        .onChange((value: string) => {
          this.title = value
        })
    }
    .width('95%')
    .height('6%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .margin({ top: '2%' })
    .padding({ left: '5%', right: '5%' })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  //备注输入框
  @Builder contentInputBuilder(){
    Row(){
      Image($r('app.media.b'))
        .width(30)
        .height(30)
        .fillColor(Color.Grey)
        .margin({ top: '1%' })
      TextArea({ placeholder:'备注', text: this.content })
        .placeholderFont({ size: 20})
        .placeholderColor(Color.White)
        .fontSize(20)
        .fontColor(Color.White)
        .height('100%')
        .onChange((value: string) => {
          this.content = value
        })
    }
    .width('95%')
    .height('30%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .margin({ top: '2%' })
    .padding({ top: '2%',bottom: '2%',left: '5%', right: '5%' })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  //时间输入框
  @Builder timeInputBuilder(){
    Row({space: 40}){
      Image($r('app.media.time'))
        .width(30)
        .height(30)
        .fillColor(Color.Grey)
      Column(){
        Row(){
          Text('全天')
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
          Toggle({type: ToggleType.Switch,isOn:this.isAllDay})
            .onChange((isOn: boolean)=>{
              this.isAllDay = isOn
              console.info('模拟器时间输入框开关状态：'+isOn)
            })
        }
        .height('25%')
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: '5%', right: '5%' })
        .border({
          width: { bottom: 1 },
          color: { bottom: Color.Gray },
        })
        Row(){
          Column(){
            Text('开始日期')
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
            Text(this.isAllDay ? `${this.StartTime.getMonth()}月${this.StartTime.getDate()}日` :`${this.StartTime.getHours()}:${this.addZero(this.StartTime.getMinutes())}`)
              .fontSize(25)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
            Text(`${this.StartTime.getMonth()}月${this.StartTime.getDate()}日`)
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .opacity(this.isAllDay? 0:1)
          }
          .height('100%')
          .width('40%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(()=>{
            DatePickerDialog.show({
              start: new Date("2000-1-1"),
              end: new Date("2100-12-31"),
              selected: this.StartTime,
              showTime:true,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: '20fp'} },
              textStyle: { color: Color.Black, font: { size: '20fp'} },
              selectedTextStyle: { color: Color.Blue, font: { size: '20fp'} },
              onDateAccept: (value: Date) => {
                this.StartTime = value
                console.info("模拟器DatePickerDialog:onDateAccept()" + value.toString())
              },
              onCancel: () => {
                console.info("模拟器DatePickerDialog:onCancel()")
              },
              onDateChange: (value: Date) => {
                console.info("模拟器DatePickerDialog:onDateChange()" + value.toString())
              },
              onDidAppear: () => {
                console.info("模拟器DatePickerDialog:onDidAppear()")
              },
              onDidDisappear: () => {
                console.info("模拟器DatePickerDialog:onDidDisappear()")
              },
              onWillAppear: () => {
                console.info("模拟器DatePickerDialog:onWillAppear()")
              },
              onWillDisappear: () => {
                console.info("模拟器DatePickerDialog:onWillDisappear()")
              }
            })
          })
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(40)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
          Column(){
            Text('结束日期')
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
            Text(this.isAllDay? `${this.EndTime.getMonth()}月${this.EndTime.getDate()}日`:`${this.EndTime.getHours()}:${this.addZero(this.EndTime.getMinutes())}`)
              .fontSize(25)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
            Text(`${this.EndTime.getMonth()}月${this.EndTime.getDate()}日`)
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .opacity(this.isAllDay? 0:1)
          }
          .height('100%')
          .width('40%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(()=>{
            DatePickerDialog.show({
              start: new Date("2000-1-1"),
              end: new Date("2100-12-31"),
              selected: this.EndTime,
              showTime:true,
              useMilitaryTime: true,
              disappearTextStyle: { color: Color.Black, font: { size: '20fp'} },
              textStyle: { color: Color.Black, font: { size: '20fp'} },
              selectedTextStyle: { color: Color.Blue, font: { size: '20fp'} },
              onDateAccept: (value: Date) => {
                this.EndTime = value
                console.info("模拟器DatePickerDialog:onDateAccept()" + value.toString())
              },
              onCancel: () => {
                console.info("模拟器DatePickerDialog:onCancel()")
              },
              onDateChange: (value: Date) => {
                console.info("模拟器DatePickerDialog:onDateChange()" + value.toString())
              },
              onDidAppear: () => {
                console.info("模拟器DatePickerDialog:onDidAppear()")
              },
              onDidDisappear: () => {
                console.info("模拟器DatePickerDialog:onDidDisappear()")
              },
              onWillAppear: () => {
                console.info("模拟器DatePickerDialog:onWillAppear()")
              },
              onWillDisappear: () => {
                console.info("模拟器DatePickerDialog:onWillDisappear()")
              }
            })
          })
        }
        .height('65%')
        .width('90%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .width('80%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('95%')
    .height('20%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .margin({ top: '2%' })
    .padding({ top: '2%',bottom: '2%',left: '5%', right: '5%' })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  //提醒时间输入框
  @Builder reminderTimeInputBuilder(){
    Row(){
      Image($r('app.media.clock'))
        .width(30)
        .height(30)
        .fillColor(Color.Grey)
      Column(){
        ForEach(this.reminderTime,(item:number)=>{
          Row(){
            Text(`${item}分钟前`)
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(25)
              .fontColor([Color.White])
              .fontWeight(FontWeight.Bold)
              .onClick(()=>{
                this.reminderTime.splice(this.reminderTime.indexOf(item),1)
              })
          }
          .width('100%')
          .height(50)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .border({
            width: { bottom: 1 },
            color: { bottom: Color.Gray },
          })
        })
        Row(){
          Text('添加提醒')
            .fontSize(20)
            .fontColor(Color.Gray)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
            .onClick(()=>{
              this.reminderTime.push(this.reminderTime[this.reminderTime.length-1]+15)
            })
        }
        .width('100%')
        .height(50)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .width('80%')
    }
    .width('95%')
    .height(`${this.reminderTime.length*50+60}`)
    .borderRadius(5)
    .backgroundColor('#55737272')
    .margin({ top: '2%', bottom: '2%' })
    .padding({top: '2%',bottom: '2%', left: '5%', right: '5%' })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    Scroll(){
      Column(){
        this.topBarBuilder()
        this.titleInputBuilder()
        this.contentInputBuilder()
        this.timeInputBuilder()
        this.reminderTimeInputBuilder()
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground3'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}