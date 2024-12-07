import { router } from '@kit.ArkUI';
import UserCalendarManager from '../Model/UserCalendarManager';

@Entry
@Component
struct Splash {
  aboutToAppear(): void {
    console.log('模拟器Splash aboutToAppear');
    UserCalendarManager.initCalendar(getContext(this)).then(()=>{
      router.replaceUrl({ url: 'pages/Index'});
    })
  }
  build() {
    Column(){

    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground3'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
  }
}