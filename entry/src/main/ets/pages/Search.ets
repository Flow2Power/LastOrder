import { router } from '@kit.ArkUI'
import { ToDoItemsInfo } from '../Model/DataInterface'
import { calendarManager } from '@kit.CalendarKit'
import UserCalendarManager from '../Model/UserCalendarManager'
import StoreManager from '../Model/StoreManager'

@Entry
@Component
struct SearchEvent {
  @StorageLink('backgroundNum')  private backgroundNum: number = 1
  @State Index:number=0
  @State searchText:string=""
  @State  ToDoItemsList:ToDoItemsInfo[] = []
  @State todoList: ToDoItemsInfo[] = []
  @State doneList: ToDoItemsInfo[] = []
  @State calendarsList:Array<calendarManager.Event> = [];
  @StorageLink('ToDoItems') private ToDoItems: ToDoItemsInfo[] = []
  @StorageLink('calendars') private calendars: Array<calendarManager.Event> = [];
  //补零
  private addZero(num: number): string {
    return num < 10 ? '0' + num.toString() : num.toString()
  }
  //搜索函数
  private SearchList(text:string){
    this.calendarsList = this.calendars.filter(item => item?.title?.includes(text));
    this.ToDoItemsList = this.ToDoItems.filter(item => item?.content?.includes(text));
    this.todoList = this.ToDoItemsList.filter(item => item.IsDid === 0);
    this.doneList = this.ToDoItemsList.filter(item => item.IsDid === 1);
  }
  //顶部搜索栏
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
      Search({ placeholder:'搜索（输入标题）', value: this.searchText })
        .width('90%')
        .height('80%')
        .placeholderColor(Color.White)
        .placeholderFont({ size: 18, weight: 400 })
        .fontColor(Color.White)
        .textFont({ size: 20, weight: 400 })
        .opacity(0.8)
        .onSubmit((value: string) => {
          console.log('搜索内容:'+ value);
        })
        .onChange(async (value: string) => {
          this.searchText = value;
          if(this.searchText==""){
            this.calendarsList = []
            this.ToDoItemsList = []
            this.todoList = []
            this.doneList = []
          }else{
            this.SearchList(value);
          }
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
  //日程列表
  @Builder EventBuilder(){
    Column(){
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
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
        .alignListItem(ListItemAlign.Start)
        .opacity(this.calendarsList.length==0?0:1)
      }
      .width('100%')
      .height('90%')
    }
    .width('95%')
    .height('100%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .padding('5%')
  }
  //待办事项列表
  @Builder ToDoBuilder(){
    Column(){
      Stack(){
        Column(){
          SymbolGlyph($r('sys.symbol.checkmark_circle'))
            .fontSize(100)
            .fontColor([Color.Gray])
            .fontWeight(FontWeight.Bold)
          Text('没有待办')
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .opacity(this.ToDoItemsList.length==0?0.8:0)
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
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .opacity(this.ToDoItemsList.length==0?0:1)
      }
      .width('100%')
      .height('90%')
    }
    .width('95%')
    .height('100%')
    .borderRadius(5)
    .backgroundColor('#55737272')
    .padding('5%')
  }
  //tab栏
  @Builder tabBarBuilder(index: number){
    Text(`${index==1? '待办' : '日程'}`)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.Index == index ? '#ff4646e9' : Color.White)
      .textAlign(TextAlign.Center)
      .border({
        width: { bottom: this.Index==index?3:0 },
        color: { bottom: '#ff4646e9' },
      })
  }
  //日程Item构建
  @Builder ScheduleItem(item:calendarManager.Event){
    Row(){
      Stack(){
        Text(`${new Date(item.startTime).getFullYear()}年${new Date(item.startTime).getMonth()+1}月${new Date(item.startTime).getDate()}日`)
          .fontSize(15)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .width('20%')
      .height('80%')
      .alignContent(Alignment.Center)
      Image($r('app.media.line'))
        .width(20)
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
          })
        }
      }
    ])
    .padding({ left: '3%', right: '3%' })
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
        .onChange((isChecked:boolean)=>{
          console.info('模拟器ToDoItem onChange'+JSON.stringify(item))
          if (isChecked&&item.IsDid==0) {
            item.IsDid = 1
            StoreManager.updateToDoItemsInfo(item, getContext(this))
            this.doneList.push(item)
            this.todoList = this.todoList.filter(item => item.IsDid == 0);
          }else if(isChecked&&item.IsDid==1){
            item.IsDid = 0
            StoreManager.updateToDoItemsInfo(item, getContext(this))
            this.todoList.push(item)
            this.doneList = this.doneList.filter(item => item.IsDid == 1);
          }
          console.info('模拟器ToDoItem onChange'+JSON.stringify(item))
        })
    }
    .width('95%')
    .height('90%')
    .borderRadius(10)
    .backgroundColor('#55737272')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  build() {
    Column(){
      this.topBarBuilder()
      Tabs(){
        TabContent(){
          this.EventBuilder()
        }
        .tabBar(this.tabBarBuilder(0))
        TabContent(){
          this.ToDoBuilder()
        }.tabBar(this.tabBarBuilder(1))
      }
      .width('100%')
      .height('85%')
      .barWidth('30%')
      .barHeight('5%')
      .barPosition(BarPosition.Start)
      .onChange((index: number)=>{
        this.Index=index
        console.info('模拟器切换tab:'+index)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}