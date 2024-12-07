import { calendarManager } from '@kit.CalendarKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  //页面信息显示相关的变量
  private weekdays:string[] = ['日','一','二','三','四','五','六'];
  private tabController: TabsController = new TabsController()
  private CurrentDate: Date = new Date()
  private ChoosePre:number = 0
  //页面信息显示相关的状态变量
  @State year: number = 2024 ;
  @State months: number[] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
  @State days:Array<number[]>=[];
  @State daysIsChoose:number[]=[]
  @State HeightChange:number = 50;
  @State index:number = this.CurrentDate.getMonth()+1;
  @State choose:number = 0;
  aboutToAppear(): void {
    console.info('模拟器Index aboutToAppear')
    this.days = []
    this.months.forEach(item=>{
      this.days.push(this.GetDays(this.year,item))
    })
    this.daysIsChoose = new Array(32).fill(0)
    console.info(`模拟器测试CurrentDate：年:${this.CurrentDate.getFullYear()}月:${this.CurrentDate.getMonth()}日:${this.CurrentDate.getDate()}`)
  }
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
  //判断是否为当天
  IsToday(mouth:number, day:number): boolean{
    return day==this.CurrentDate.getDate()&&mouth==this.CurrentDate.getMonth()+1&&this.year==this.CurrentDate.getFullYear()
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
                Text(`${item==0?'':'休'}`)
                  .fontSize(10)
                  .fontColor('#ff2760b5')
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
              })
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Start)
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
      this.daysIsChoose=new Array(32).fill(0);
      console.info(`模拟器切换到第${index}个Tab`)
      if(index==13||index==0){
        this.year = this.year + (index==13?1:-1)
        this.aboutToAppear()
        this.tabController.changeIndex(index==13?1:12)
      }
    })
  }
  //一天
  @Builder OneDayBuilder(){
    Column(){

    }
    .width('95%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: '5%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  //待办事项
  @Builder TodoBuilder(){
    Column(){

    }
    .width('95%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: '5%'})
    .padding({ top: '2%', bottom: '2%', left: '2%', right: '2%'})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  //tabBar构建
  @Builder tabBuilder(index:number) {
    SymbolGlyph($r(index==0?'sys.symbol.calendar':index==1?'sys.symbol.calendar_badge_clock':'sys.symbol.checkmark_circle'))
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
          },() => {
            this.choose = index
          })
        })
        Row(){
          Column(){
            Image($r('app.media.AI'))
              .width(50)
              .height(50)
              .fillColor(Color.White)
            Image($r('app.media.add'))
              .width(50)
              .height(50)
              .fillColor(Color.White)
              .onClick(()=>{
                console.info('模拟器点击添加日程')
                router.pushUrl({ url: 'pages/AddEvent' });
              })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .height('100%')
        }
        .width('100%')
        .height('20%')
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
    .backgroundImage($r('app.media.MyBackground3'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}