import { i18n } from '@kit.LocalizationKit';

@Entry
@Component
struct Index {
  //页面信息显示相关的变量
  private weekdays:string[] = ['日','一','二','三','四','五','六'];
  private tabController: TabsController = new TabsController()
  private calender:i18n.Calendar = i18n.getCalendar("zh-Hans","gregory");
  //页面信息显示相关的状态变量
  @State year: number = 2024 ;
  @State months: number[] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
  @State days:Array<number[]>=[];
  @State HeightChange:number = 50;
  @State index:number = 1;
  aboutToAppear(): void {
    console.info('模拟器Index aboutToAppear')
    this.calender.setTime(new Date())
    this.days = []
    this.months.forEach(item=>{
      this.days.push(this.GetDays(this.year,item))
    })
  }
  //天数构建
  //天数构建
  GetDays(year: number, month: number): number[] {
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

  //构建顶部导航栏
  @Builder topBarBuilder() {
    Column(){
      Row(){
        Text(`${this.year}年${this.months[this.index]}月`)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .width('50%')
        Row({space: 20}){
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(25)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize(25)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
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
    }
    .width('95%')
    .height('10%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
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
              Text(`${item==0?'':item}`)
                .fontSize(20)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Start)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .height('20%')
          }
        })
      }
      .width('100%')
      .height('90%')
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
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
      .height(30)

    }
    .width('95%')
    .height(`${this.HeightChange}%`)
    .margin({ top: '5%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
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
  //日程构建
  @Builder MyScheduleBuilder(){
    Column(){

    }
    .width('100%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: `${this.HeightChange/10}%`})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  //首页
  @Builder TabBuilder(){
    Tabs({ barPosition: BarPosition.Start,controller: this.tabController,index:1}){
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
      console.info(`模拟器切换到第${index}个Tab`)
      if(index==13||index==0){
        this.year = this.year + (index==13?1:-1)
        this.aboutToAppear()
        this.tabController.changeIndex(index==13?1:12)
      }
    })
  }
  //tabBar构建
  @Builder tabBuilder(index:number) {
    SymbolGlyph($r('sys.symbol.calendar'))
      .fontSize(30)
      .fontColor([Color.White])
      .fontWeight(FontWeight.Bold)
  }
  build() {
    Column(){
      this.topBarBuilder()
      Tabs(){
        TabContent(){
          this.TabBuilder()
        }
        .tabBar(this.tabBuilder(0))
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('85%')
      .barWidth('100%')
      .barHeight('5%')
      .barMode(BarMode.Scrollable)
      .barPosition(BarPosition.End)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground3'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}