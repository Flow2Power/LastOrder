import { router } from '@kit.ArkUI';

@Entry
@Component
struct Splash {
  aboutToAppear(): void {
    console.log('模拟器Splash aboutToAppear');
    setTimeout(()=> {
      router.replaceUrl({ url: 'pages/Index'});
    }, 1000)
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