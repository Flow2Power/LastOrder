@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('TodoItemList') TodoItemList:string[] = ['a','b','c','d','e','f','g','h']
  @LocalStorageProp('backgroundNum')  private backgroundNum: number = 1
  build() {
    Column(){
      Row(){
        Text('全部待办')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
        Image($r('app.media.square_and_pencil_fill'))
          .width(30)
          .height(30)
          .fillColor(Color.White)
      }
      .width('95%')
      .height('20%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({top: '5%'})
      .padding({left: '5%', right: '5%'})
      .backgroundColor('#55737272')
      .border({
        width: { bottom: 1 },
        color: { bottom: Color.Gray },
      })
      List(){
        ForEach(this.TodoItemList, (item:string)=>{
          ListItem(){
            Row(){
              SymbolGlyph($r('sys.symbol.circle'))
                .fontSize(15)
                .fontColor([Color.White])
                .fontWeight(FontWeight.Bold)
              Text(item)
                .width('80%')
                .fontSize(20)
                .fontColor(Color.White)
                .textAlign(TextAlign.Start)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .border({
                  width: { bottom: 0.8 },
                  color: { bottom: Color.Gray },
                })
            }
            .width('100%')
            .height('100%')
            .padding({left: '10%', right: '10%'})
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('95%')
          .height('30%')
          .padding({top: '2%', bottom: '2%'})
        })
      }
      .width('100%')
      .height('80%')
      .margin({top: '2%'})
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .alignListItem(ListItemAlign.Start)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .backdropBlur(50)
    .onClick(() => {
      console.info('模拟器点击卡片');
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility'
      });
    })
  }
}