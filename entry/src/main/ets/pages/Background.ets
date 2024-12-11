import { promptAction, router } from '@kit.ArkUI'
import { CardData, ToDoItemsInfo } from '../Model/DataInterface'
import PreferencesManager from '../Model/PreferencesManager'
import { formBindingData, formProvider } from '@kit.FormKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct Background {
  @StorageLink('backgroundNum')  private backgroundNum: number = 1
  @StorageLink('ToDoItems') private ToDoItems: ToDoItemsInfo[] = []
  private backgroundList: number[] = [1,2,3,4,5,6,7,8]

  async aboutToDisappear(): Promise<void> {
    console.info('模拟器Background aboutToDisappear')
    PreferencesManager.putBackground(this.backgroundNum, getContext(this))
    let todoList = this.ToDoItems.filter(item => item.IsDid === 0);
    let formData: CardData = {
      TodoItemList: todoList.map(item => item.content),
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
      Text('背景图片')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({left:'5%'})
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
  build() {
    Column(){
      this.topBarBuilder()
      Tabs({index:this.backgroundNum-1}){
        ForEach(this.backgroundList, (item:number)=>{
          TabContent(){
            Image($r(`app.media.MyBackground${item}`))
              .width('90%')
              .height('90%')
          }
          .width('80%')
          .height('80%')
          .borderRadius(5)
          .backgroundColor('#55737272')
          .onClick(() => {
            this.backgroundNum = item
            promptAction.showToast({
              message: '背景更换成功',
              duration: 2000
            })
          })
        })
      }
      .width('95%')
      .height('80%')
      .barHeight(0)
      .align(Alignment.Start)
      .margin({top:'5%'})
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .justifyContent(FlexAlign.Start)
  }
}