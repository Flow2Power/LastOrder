import { calendarManager } from '@kit.CalendarKit';
import { promptAction, router } from '@kit.ArkUI';
import UserCalendarManager from '../Model/UserCalendarManager';
import { i18n } from '@kit.LocalizationKit';
import { CardData, Holidays, SolarTerms, ToDoItemsInfo } from '../Model/DataInterface';
import StoreManager from '../Model/StoreManager';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import PreferencesManager from '../Model/PreferencesManager';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';

//构建文本输入弹窗
@CustomDialog
@Component
struct CustomDialogExample {
  @Link textValue: string
  @Link ToDoItems: ToDoItemsInfo[]
  @Link todoList: ToDoItemsInfo[]
  @Link doneList: ToDoItemsInfo[]
  @Link backgroundNum: number
  controller?: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}
  build() {
    Row() {
      TextInput({ placeholder: '待办事项', text: this.textValue })
        .height('80%')
        .width('85%')
        .placeholderFont({ size: 20, weight: FontWeight.Bold })
        .placeholderColor(Color.Gray)
        .fontSize(20)
        .fontColor(Color.Gray)
        .onChange((value: string) => {
          this.textValue = value
        })
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(40)
        .fontColor([Color.Gray])
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          if (this.controller != undefined) {
            if (this.textValue != '') {
              StoreManager.addToDoItemsInfo({
                id:null,
                content:this.textValue,
                IsDid:0
              } as ToDoItemsInfo, getContext(this)).then(async ()=>{
                this.ToDoItems = await StoreManager.getToDoItemsInfo(getContext(this))
                this.todoList = this.ToDoItems.filter(item => item.IsDid === 0);
                this.doneList = this.ToDoItems.filter(item => item.IsDid === 1);
                let formData: CardData = {
                  TodoItemList: this.todoList.map(item => item.content),
                  backgroundNum: this.backgroundNum
                }
                let bindData = formBindingData.createFormBindingData(formData);
                let formId = await PreferencesManager.getFormId(getContext(this))
                formProvider.updateForm(formId, bindData).then(() => {
                  console.log('模拟器卡片Card updated successfully.');
                }).catch((error: BusinessError) => {
                  console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
                });
                promptAction.showToast({
                  message: '待办事项添加成功',
                  duration: 2000
                })
                this.textValue = ''
                this.controller?.close()
                this.confirm()
              })
            }else{
              this.textValue = ''
              this.controller.close()
              this.confirm()
            }
          }
        })
    }
    .width('100%')
    .height('10%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 20, right: 20})
    .borderRadius(10)
    .backgroundColor('#55737272')
  }
}
@Entry
@Component
struct Index {
  @StorageLink('backgroundNum')  private backgroundNum: number = 1
  @State textValue: string = ''
  @StorageLink('ToDoItems') private ToDoItems: ToDoItemsInfo[] = []
  @State todoList: ToDoItemsInfo[] = []
  @State doneList: ToDoItemsInfo[] = []
  //页面信息显示相关的变量
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> {},
      confirm: ()=> {},
      textValue: $textValue,
      ToDoItems: this.ToDoItems,
      todoList: this.todoList,
      doneList: this.doneList,
      backgroundNum: this.backgroundNum
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
  private weekdays:string[] = ['日','一','二','三','四','五','六'];
  private LunarMonths = ['正月','二月','三月','四月','五月','六月','七月','八月','九月','十月','冬月','腊月']
  private lunarDays = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十', '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十', '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];
  private tabController: TabsController = new TabsController()
  @StorageLink('CurrentDate')private CurrentDate: Date = new Date()
  @StorageLink('holidays') private holidays: Holidays = {}
  @StorageLink('solarTerms') private solarTerms: SolarTerms = {}
  private currentDate: Date = new Date()
  @StorageLink('calendars') private calendars: Array<calendarManager.Event> = [];
  private calendar : i18n.Calendar = i18n.getCalendar("zh-Hans", "chinese");
  //页面信息显示相关的状态变量
  @State year: number = this.CurrentDate.getFullYear() ;
  @State months: number[] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
  @State days:Array<number[]>=[];
  @State LunarDays:Array<string[]>=[];
  @State calendarsList: Array<calendarManager.Event> = [];
  @State daysIsChoose:number[]=[]
  @State HeightChange:number = 50;
  @State index:number = this.CurrentDate.getMonth()+1;
  @State choose:number = 0;
  @State dayDifference:number = 0
  @State ChoosePre:number = 0
  aboutToAppear(): void {
    console.info('模拟器Index aboutToAppear')
    this.currentDate.setHours(0,0,0,0)
    this.days = []
    this.LunarDays = []
    this.months.forEach(item=>{
      this.days.push(this.GetDays(this.year,item))
      this.LunarDays.push(this.GetLunarDays(this.year,item))
    })
    this.daysIsChoose = new Array(32).fill(0)
    this.ChoosePre=this.year==this.CurrentDate.getFullYear()&&this.CurrentDate.getMonth()+1==this.months[this.index]?this.CurrentDate.getDate():1
    this.daysIsChoose[this.ChoosePre]=1
  }
  aboutToDisappear(): void {
    console.info('模拟器Index aboutToDisappear')
    this.dialogController = null
  }
  onPageShow(): void {
    console.info('模拟器Index onPageShow')
    UserCalendarManager.queryEvent(this.year).then((result: Array<calendarManager.Event>)=>{
      this.calendars = result
      this.calendarsList = this.QueryCalendar(this.ChoosePre)
    })
    this.todoList = this.ToDoItems.filter(item => item.IsDid === 0);
    this.doneList = this.ToDoItems.filter(item => item.IsDid === 1);
  }
  //天数构建
  private GetDays(year: number, month: number): number[] {
    let days: number[] = [];
    if (month == 0 || month == 13) {
      return days;
    }
    // 获取当前月份第一天
    let firstDayOfMonth = new Date(year, month - 1, 1);
    // 获取当前月份第一天为星期几
    for (let i = 0; i < firstDayOfMonth.getDay(); i++) {
      days.push(0);
    }
    // 获取当前月份的总天数
    let lastDayOfMonth = new Date(year, month, 0).getDate();
    for (let i = 1; i <= lastDayOfMonth; i++) {
      days.push(i);
    }
    return days;
  }
  //农历天数构建
  private GetLunarDays(year: number, month: number): string[] {
    let LunarDays: string[] = [];
    if (month == 0 || month == 13) {
      return LunarDays;
    }
    LunarDays.push(' ');
    // 获取当前月份的总天数
    let lastDayOfMonth = new Date(year, month, 0).getDate();
    for (let i = 1; i <= lastDayOfMonth; i++) {
      LunarDays.push(this.LunarDateToText(year, month, i));
    }
    return LunarDays;
  }
  //日期转农历称呼
  private LunarDateToText(year: number, month: number, day: number):string{
    this.calendar.setTime(new Date(year, month-1, day));
    let Month = this.calendar.get("month")
    let Day = this.calendar.get("date")
    return this.LunarMonths[Month]+this.lunarDays[Day-1]
  }
  //判断是否为当天
  private IsToday(mouth:number, day:number): boolean{
    return day==this.CurrentDate.getDate()&&mouth==this.CurrentDate.getMonth()+1&&this.year==this.CurrentDate.getFullYear()
  }
  //补零
  private addZero(num: number): string {
    return num < 10 ? '0' + num.toString() : num.toString()
  }
  //查询对应日期的日程
  private QueryCalendar(day:number): Array<calendarManager.Event>{
    let result:Array<calendarManager.Event> = []
    let startTime = new Date(`${this.year}-${this.addZero(this.months[this.index])}-${this.addZero(day)}T00:00:00.000Z`).getTime()
    let endTime = new Date(`${this.year}-${this.addZero(this.months[this.index])}-${this.addZero(day)}T23:59:59.000Z`).getTime()
    result = this.calendars.filter(item => item.startTime > startTime && item.endTime < endTime);
    return result
  }
  //判断是否为节假日
  private IsHoliday(day:number): string{
    let date = this.year.toString()+'-'+this.addZero(this.months[this.index])+'-'+this.addZero(day)
    if(this.holidays[date]==undefined){
      return ''
    }
    return this.holidays[date].isOffDay?'休':'班';
  }
  //判断是否为节气
  private IsSolarTerms(day:number): string{
    let date = this.months[this.index].toString()+'月'+day.toString()+'日'
    if(this.solarTerms[date]==undefined){
      return ''
    }
    return this.solarTerms[date].name
  }
  //构建顶部导航栏
  @Builder topBarBuilder() {
    Column(){
      Row(){
        Text(this.choose==0?`${this.year}年${this.months[this.index]}月`:this.choose==1?'我的一天':'待办')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .width('50%')
        Row({space: 20}){
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(25)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
            .onClick(()=>{
              console.info('模拟器点击搜索')
              router.pushUrl({url: 'pages/Search'})
            })
          SymbolGlyph($r('sys.symbol.picture'))
            .fontSize(25)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
            .onClick(()=>{
              console.info('模拟器点击背景')
              router.pushUrl({url: 'pages/Background'})
            })
        }
        .width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      Grid(){
        ForEach(this.weekdays, (item:string)=>{
          GridItem(){
            Column(){
              Text(item)
                .fontSize(20)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
        })
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .margin({ top: '5%'})
      .opacity((this.choose==0?1:0))
    }
    .width('95%')
    .height(`${this.choose==0?10:5}%`)
    .borderRadius(5)
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .margin({ top: '10%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
  }
  //日历构建
  @Builder MyCalendarBuilder(index:number) {
    Column(){
      Grid(){
        ForEach(this.days[index], (item:number)=>{
          GridItem(){
            Column(){
              Stack(){
                Text(`${item==0?'':item}`)
                  .fontSize(20)
                  .fontColor(this.IsToday(index,item)? '#ff1d72f1' :Color.White)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                Text(`${item==0?'':this.LunarDays[index][item]}`)
                  .fontSize(10)
                  .fontColor(this.IsToday(index,item)? '#ff1d72f1' :Color.White)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .margin({ top: '60%' })
                Text(`${item==0?'':this.IsHoliday(item)}`)
                  .fontSize(10)
                  .fontColor(this.IsHoliday(item)=='休'?'#ff2760b5':'#ffe95151')
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .margin({ top: '-20%',left: '70%' })
              }
              .alignContent(Alignment.Center)
              .width(50)
              .height(50)
              .borderRadius(90)
              .border({ width: this.daysIsChoose[item], color: Color.White})
              .onClick(()=>{
                this.daysIsChoose[this.ChoosePre]=0
                this.daysIsChoose[item]=1
                this.ChoosePre=item
                this.calendarsList = this.QueryCalendar(item)
                let date = new Date(this.year,this.months[this.index]-1,item)
                date.setHours(0, 0, 0, 0); // 设置时间为00:00:00.000
                this.dayDifference = Math.round(date.getTime() - this.currentDate.getTime()) / (1000 * 60 * 60 * 24);
              })
              Text(`${item==0?'':this.IsSolarTerms(item)}`)
                .fontSize(15)
                .height(20)
                .fontColor('#ff223e66')
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .opacity(this.IsSolarTerms(item)!=''&&this.HeightChange==100?1:0)
                .border({ width: this.IsSolarTerms(item)!=''&&this.HeightChange==100?1:0, color: Color.White})
                .borderRadius(5)
              Text(`${item==0?'':this.QueryCalendar(item).length==0?'':this.QueryCalendar(item)[0].title}`)
                .fontSize(15)
                .height(20)
                .width(40)
                .fontColor('#ff723518')
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .opacity(item!=0&&this.HeightChange==100&&this.QueryCalendar(item).length!=0?1:0)
                .border({ width: item!=0&&this.HeightChange==100&&this.QueryCalendar(item).length!=0?1:0, color: Color.White })
                .borderRadius(5)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .height('15%')
        })
      }
      .width('100%')
      .height('90%')
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .alignItems(GridItemAlignment.DEFAULT)
      .padding({ top: '2%', bottom: '2%' })
      Row(){
        SymbolGlyph($r(this.HeightChange==50?'sys.symbol.chevron_down':'sys.symbol.chevron_up'))
          .fontSize(30)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .opacity((index!=0&&index!=13)?1:0)
      }
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(20)

    }
    .width('95%')
    .height(`${this.HeightChange}%`)
    .margin({ top: '5%'})
    .padding({left: '2%', right: '2%'})
    .borderRadius(5)
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .gesture(SwipeGesture({direction: SwipeDirection.Vertical})
      .onAction((event: GestureEvent)=>{
        animateTo({
          duration: 1000,
        },() => {
          this.HeightChange = this.HeightChange==50?100:50;
        })
      }))
  }
  //日程Item构建
  @Builder ScheduleItem(item:calendarManager.Event){
    Row(){
      Stack(){
        Column(){
          Text(`${new Date(item.startTime).getHours()}:${this.addZero(new Date(item.startTime).getMinutes())}`)
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
          Text(`${new Date(item.endTime).getHours()}:${this.addZero(new Date(item.endTime).getMinutes())}`)
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .opacity(item.isAllDay?0:1)
        Text('全天')
          .fontSize(15)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .opacity(item.isAllDay?1:0)
      }
      .width('15%')
      .height('80%')
      .padding({ top: '3%', bottom: '3%' })
      .alignContent(Alignment.Center)
      Image($r('app.media.line'))
        .width(50)
        .height(50)
        .fillColor('#ff1d72f1')
      Marquee({
        start: true,
        step: -1,
        loop: 50,
        fromStart: true,
        src:"【"+item.title+"】"+item.description
      })
        .width('70%')
        .height('80%')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .width('95%')
    .height('90%')
    .borderRadius(10)
    .backgroundColor('#55737272')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .bindMenu([
      {
        value: '删除日程',
        action: ()=>{
          UserCalendarManager.deleteEvent(item).then(()=>{
            this.calendarsList = this.calendarsList.filter((e:calendarManager.Event)=>{
              return e.id!=item.id
            })
            promptAction.showToast({
              message: '删除日程成功',
              duration: 2000
            })
          })
        }
      }
    ])
  }
  //日程构建
  @Builder MyScheduleBuilder(){
    Column(){
      Row(){
        Text(`${this.dayDifference==0?'今':Math.abs(this.dayDifference)}天${this.dayDifference==0?'':this.dayDifference>0?'后':'前'}`)
          .fontSize(20)
          .fontColor(Color.White)
          .width('20%')
          .height('100%')
          .textAlign(TextAlign.Start)
        Text(`农历${this.LunarDays[this.months[this.index]][this.ChoosePre]}`)
          .fontSize(20)
          .fontColor(Color.White)
          .height('100%')
          .textAlign(TextAlign.Start)
          .opacity(0.8)
      }
      .width('100%')
      .height('10%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({ left: '2%', right: '2%'})
      .border({
        width: { bottom: 1 },
        color: { bottom: Color.Gray },
      })
      Stack(){
        Column(){
          SymbolGlyph($r('sys.symbol.calendar_fill'))
            .fontSize(100)
            .fontColor([Color.Gray])
            .fontWeight(FontWeight.Bold)
          Text('没有日程')
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .opacity(this.calendarsList.length==0?0.8:0)
        List(){
          ForEach(this.calendarsList, (item:calendarManager.Event)=>{
            ListItem(){
              this.ScheduleItem(item)
            }
            .width('100%')
            .height(100)
          })
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.None)
        .alignListItem(ListItemAlign.Start)
        .opacity(this.calendarsList.length==0?0:1)
      }
      .width('100%')
      .height('90%')
    }
    .width('104%')
    .height('89%')
    .borderRadius(5)
    .margin({ top: `${this.HeightChange/6}%`})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  //日历
  @Builder CalendarBuilder(){
    Tabs({ barPosition: BarPosition.Start,controller: this.tabController,index:this.CurrentDate.getMonth()+1}){
      ForEach(this.months, (item:number)=>{
        TabContent(){
          this.MyCalendarBuilder(item)
          this.MyScheduleBuilder()
        }
        .align(Alignment.Top)
      })
    }
    .width('100%')
    .height('100%')
    .barHeight(0)
    .fadingEdge(false)
    .barMode(BarMode.Scrollable)
    .barPosition(BarPosition.End)
    .onChange((index: number)=>{
      this.index = index
      this.calendarsList = this.QueryCalendar(this.ChoosePre)
      let date = new Date(this.year,this.months[this.index]-1,this.ChoosePre)
      date.setHours(0, 0, 0, 0); // 设置时间为00:00:00.000
      this.dayDifference = Math.round(date.getTime() - this.currentDate.getTime()) / (1000 * 60 * 60 * 24);
      console.info(`模拟器切换到第${index}个Tab`)
      if(index==13||index==0){
        this.year = this.year + (index==13?1:-1)
        StoreManager.getHolidays(this.year, getContext(this)).then(async holidays=>{
          if(Object.keys(holidays).length == 0){
            console.info('模拟器从网络获取节假日信息,年份为：' + this.year)
            this.holidays = await NetworkDataFetcher.getHolidays(this.year)
            await StoreManager.addHolidays(holidays, getContext(this))
          }else{
            this.holidays = holidays
            console.info('模拟器从本地获取节假日信息,年份为：' + this.year)
          }
          StoreManager.getTwentyFourSolarTerms(this.year, getContext(this)).then(async solarTerms=>{
            if(Object.keys(solarTerms).length == 0){
              console.info('模拟器从网络获取二十四节气信息,年份为：' + this.year)
              this.solarTerms = await NetworkDataFetcher.getTwentyFourSolarTerms(this.year)
              await StoreManager.addTwentyFourSolarTerms(solarTerms, getContext(this))
            }else{
              this.solarTerms = solarTerms
              console.info('模拟器从本地获取二十四节气信息,年份为：'+ this.year)
            }
            this.aboutToAppear()
            this.tabController.changeIndex(index==13?1:12)
          })
        })
      }
    })
  }
  //一天
  @Builder OneDayBuilder(){
    Column(){
      Row(){
        Text(`${this.months[this.index]}月${this.ChoosePre}日`)
          .fontSize(20)
          .fontColor(Color.White)
          .height('100%')
          .textAlign(TextAlign.Start)
        Text(`农历${this.LunarDays[this.months[this.index]][this.ChoosePre]}`)
          .fontSize(20)
          .fontColor(Color.White)
          .height('100%')
          .textAlign(TextAlign.Start)
          .opacity(0.8)
      }
      .width('100%')
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: '2%', right: '2%'})
      .border({
        width: { bottom: 1 },
        color: { bottom: Color.Gray },
      })
      Stack(){
        List(){
          ForEach(this.calendarsList, (item:calendarManager.Event)=>{
            ListItem(){
              this.ScheduleItem(item)
            }
            .width('100%')
            .height(100)
          })
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.None)
        .alignListItem(ListItemAlign.Start)
        .opacity(this.calendarsList.length==0?0:1)
        Column(){
          SymbolGlyph($r('sys.symbol.calendar_fill'))
            .fontSize(100)
            .fontColor([Color.Gray])
            .fontWeight(FontWeight.Bold)
          Text('没有日程')
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
          Text('今天要做什么？')
            .width('100%')
            .fontSize(35)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({ top: '10%' })
          Text('点击 + 按钮记录一下')
            .width('100%')
            .fontSize(20)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({ top: '5%' })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .opacity(this.calendarsList.length==0?0.8:0)
      }
      .width('100%')
      .height('90%')
      .alignContent(Alignment.Center)
    }
    .width('95%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: '5%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  //待办事项Item构建
  @Builder TodoItem(item:ToDoItemsInfo){
    Row(){
      Image($r('app.media.line'))
        .width(50)
        .height(50)
        .fillColor('#ff1d72f1')
      Marquee({
        start: true,
        step: -1,
        loop: 50,
        fromStart: true,
        src:item.content
      })
        .width('70%')
        .height('80%')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
      Radio({value: item?.id?.toString(),group: item?.id?.toString()})
        .checked(item.IsDid==1)
        .onChange(async (isChecked:boolean)=>{
          if (isChecked&&item.IsDid==0) {
            item.IsDid = 1
            StoreManager.updateToDoItemsInfo(item, getContext(this))
            this.doneList.push(item)
            this.todoList = this.todoList.filter(item => item.IsDid == 0);
            let formData: CardData = {
              TodoItemList: this.todoList.map(item => item.content),
              backgroundNum: this.backgroundNum
            }
            let bindData = formBindingData.createFormBindingData(formData);
            let formId = await PreferencesManager.getFormId(getContext(this))
            formProvider.updateForm(formId, bindData).then(() => {
              console.log('模拟器卡片Card updated successfully.');
            }).catch((error: BusinessError) => {
              console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
            });
          }else if(isChecked&&item.IsDid==1){
            item.IsDid = 0
            StoreManager.updateToDoItemsInfo(item, getContext(this))
            this.todoList.push(item)
            this.doneList = this.doneList.filter(item => item.IsDid == 1);
            let formData: CardData = {
              TodoItemList: this.todoList.map(item => item.content),
              backgroundNum: this.backgroundNum
            }
            let bindData = formBindingData.createFormBindingData(formData);
            let formId = await PreferencesManager.getFormId(getContext(this))
            formProvider.updateForm(formId, bindData).then(() => {
              console.log('模拟器卡片Card updated successfully.');
            }).catch((error: BusinessError) => {
              console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
            });
          }
        })
    }
    .width('95%')
    .height('90%')
    .borderRadius(10)
    .backgroundColor('#55737272')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  //待办事项
  @Builder TodoBuilder(){
    Column(){
      Row(){
        Text(`未完成(${this.todoList.length}条)`)
          .fontSize(20)
          .fontColor(Color.White)
          .height('100%')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: '2%', right: '2%'})
      .border({
        width: { bottom: 1 },
        color: { bottom: Color.Gray },
      })
      List(){
        ForEach(this.todoList, (item:ToDoItemsInfo)=>{
          ListItem(){
            this.TodoItem(item)
          }
          .width('100%')
          .height(50)
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('40%')
      .alignListItem(ListItemAlign.Start)
      Row(){
        Text(`已完成(${this.doneList.length}条)`)
          .fontSize(20)
          .fontColor(Color.White)
          .height('100%')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: '2%', right: '2%'})
      .border({
        width: { bottom: 1 },
        color: { bottom: Color.Gray },
      })
      List(){
        ForEach(this.doneList, (item:ToDoItemsInfo)=>{
          ListItem(){
            this.TodoItem(item)
          }
          .width('100%')
          .height(50)
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('40%')
      .alignListItem(ListItemAlign.Start)
    }
    .width('95%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: '5%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  //tabBar构建
  @Builder tabBuilder(index:number) {
    SymbolGlyph($r(index==0?'sys.symbol.calendar':index==1?'sys.symbol.calendar_badge_clock':'sys.symbol.checkmark_square'))
      .fontSize(30)
      .fontColor([this.choose==index?Color.White:Color.Gray])
      .width(30)
      .height(30)
      .margin({ left: '10%',right: '10%' })
  }

  build() {
    Column(){
      this.topBarBuilder()
      Stack(){
        Tabs(){
          TabContent(){
            this.CalendarBuilder()
          }
          .tabBar(this.tabBuilder(0))
          .width('100%')
          .height('100%')
          TabContent(){
            this.OneDayBuilder()
          }
          .tabBar(this.tabBuilder(1))
          .width('100%')
          .height('100%')
          TabContent(){
            this.TodoBuilder()
          }
          .tabBar(this.tabBuilder(2))
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(`${this.choose==0?85:90}%`)
        .barWidth('100%')
        .barHeight('5%')
        .barMode(BarMode.Scrollable)
        .barPosition(BarPosition.End)
        .onChange((index: number)=>{
          animateTo({
            duration: 1000,
          }, () => {
              this.choose = index
          })
        })
        Row(){
          Column(){
            Image($r('app.media.AI'))
              .width(45)
              .height(45)
              .fillColor(Color.White)
              .onClick(()=>{
                console.info('模拟器点击AI')
                router.pushUrl({ url: 'pages/AIChat' });
              })
            Image($r('app.media.add'))
              .width(45)
              .height(45)
              .fillColor(Color.White)
              .onClick(()=>{
                console.info('模拟器点击添加日程')
                router.pushUrl({ url: 'pages/AddEvent' });
              })
            Image($r('app.media.square_and_pencil_fill'))
              .width(45)
              .height(45)
              .fillColor(Color.White)
              .onClick(()=>{
                console.info('模拟器点击添加待办')
                this.dialogController?.open()
              })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .height('100%')
        }
        .width('100%')
        .height('22%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .padding({ top: '2%', bottom: '2%', left: '10%', right: '10%' })
        .margin({ top: `${this.choose==0?120:130}%` })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}