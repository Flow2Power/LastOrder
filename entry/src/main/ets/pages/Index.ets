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
  @State months: number[] = [1,2,3,4,5,6,7,8,9,10,11,12];
  @State days:number[] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
  @State HeightChange:number = 50;
  @State index:number = 0;
  aboutToAppear(): void {
    console.info('模拟器Index aboutToAppear')
    this.calender.setTime(new Date())
    this.days=this.GetDays(this.year,this.months[this.index])
  }
  //天数构建
  GetDays(year:number, month:number):number[]{
    let days:number[]=[];
    //获取当前月份天数
    let date = new Date(year, month-1, 0);
    for(let i=0;i<date.getDay();i++){
      days.push(0)
    }
    for(let i=1;i<=date.getDate();i++){
      days.push(i)
    }
    console.info('模拟器天数构建'+year+'年'+month+'月'+days.length+'天')
    return days
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
      Row(){
        ForEach(this.weekdays, (item:string)=>{
          Column(){
            Text(item)
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width(50)
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
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
  @Builder MyCalendarBuilder() {
    Column(){
      Grid(){
        ForEach(this.days, (item:number)=>{
          GridItem(){
            Column(){
              Text(`${item==0?'':item}`)
                .fontSize(15)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Start)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .width(50)
            .height('20%')
          }
        })
      }
      .width('100%')
      .height('90%')
      .margin({ left: '4%' })
      Row(){
        SymbolGlyph($r(this.HeightChange==50?'sys.symbol.chevron_down':'sys.symbol.chevron_up'))
          .fontSize(30)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(30)

    }
    .width('95%')
    .height(`${this.HeightChange}%`)
    .margin({ top: '5%'})
    .padding({ top: '2%'})
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
  @Builder MyScheduleBuilder(){
    Column(){

    }
    .width('100%')
    .height('90%')
    .borderRadius(5)
    .margin({ top: `${this.HeightChange/10}%`})
    .backgroundColor('#55737272')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  @Builder TabContentBuilder(){
    this.MyCalendarBuilder()
    this.MyScheduleBuilder()
  }
  build() {
    Column(){
      this.topBarBuilder()
      Tabs({ barPosition: BarPosition.Start,controller: this.tabController}){
        ForEach(this.months, (item:number)=>{
          TabContent(){
            this.TabContentBuilder()
          }
          .align(Alignment.Top)
        })
      }
      .width('100%')
      .height('90%')
      .fadingEdge(false)
      .barMode(BarMode.Scrollable)
      .barPosition(BarPosition.End)
      .onChange((index: number)=>{
        this.index = index
        console.info(`模拟器切换到第${index}个Tab`)
        if(index==12){
          this.tabController.changeIndex(0)
        }
        console.info('模拟器'+this.months)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground3'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}