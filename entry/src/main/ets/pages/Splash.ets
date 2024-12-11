import { router } from '@kit.ArkUI';
import AIWebSocket from '../Model/AIWebSocket';
import { Holidays, SolarTerms, ToDoItemsInfo } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import PreferencesManager from '../Model/PreferencesManager';
import StoreManager from '../Model/StoreManager';
import UserCalendarManager from '../Model/UserCalendarManager';

@Entry
@Component
struct Splash {
  @StorageLink('backgroundNum')  private backgroundNum: number = 1
  @StorageLink('CurrentDate')private CurrentDate: Date = new Date()
  @StorageLink('holidays') private holidays: Holidays = {}
  @StorageLink('solarTerms') private solarTerms: SolarTerms = {}
  @StorageLink('ToDoItems') private ToDoItems: ToDoItemsInfo[] = []
  async aboutToAppear(): Promise<void> {
    console.log('模拟器Splash aboutToAppear');
    await NetworkDataFetcher.sendMessageToSparkMax('你好','你是一只猫娘')
    this.backgroundNum = await PreferencesManager.getBackground(getContext(this))
    await UserCalendarManager.initCalendar(getContext(this));
    this.holidays = await StoreManager.getHolidays(this.CurrentDate.getFullYear(), getContext(this))
    if(Object.keys(this.holidays).length == 0){
      console.info('模拟器从网络获取节假日信息,年份为：' + this.CurrentDate.getFullYear())
      this.holidays = await NetworkDataFetcher.getHolidays(this.CurrentDate.getFullYear())
      await StoreManager.addHolidays(this.holidays, getContext(this))
    }else{
      console.info('模拟器从本地获取节假日信息,年份为：' + this.CurrentDate.getFullYear())
    }
    this.solarTerms = await StoreManager.getTwentyFourSolarTerms(this.CurrentDate.getFullYear(), getContext(this))
    if(Object.keys(this.solarTerms).length == 0){
      console.info('模拟器从网络获取二十四节气信息,年份为：' + this.CurrentDate.getFullYear())
      this.solarTerms = await NetworkDataFetcher.getTwentyFourSolarTerms(this.CurrentDate.getFullYear())
      await StoreManager.addTwentyFourSolarTerms(this.solarTerms, getContext(this))
    }else{
      console.info('模拟器从本地获取二十四节气信息,年份为：'+ this.CurrentDate.getFullYear())
    }
    this.ToDoItems = await StoreManager.getToDoItemsInfo(getContext(this))
    router.replaceUrl({ url: 'pages/Index'});
  }
  build() {
    Column(){}
    .width('100%')
    .height('100%')
    .backgroundImage($r(`app.media.MyBackground${this.backgroundNum}`))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
  }
}