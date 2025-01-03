import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import StoreManager from '../Model/StoreManager';
import { CardData, ToDoItemsInfo } from '../Model/DataInterface';
import { BusinessError } from '@kit.BasicServicesKit';
import PreferencesManager from '../Model/PreferencesManager';


export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formData: CardData = {
      'TodoItemList': [],
      'backgroundNum': 1
    }
    StoreManager.getToDoItemsInfo(this.context).then(async (toDoItemsInfo: ToDoItemsInfo[])=>{
      toDoItemsInfo.forEach(item => {
        if(!item.IsDid){
          formData.TodoItemList.push(item.content)
        }
      });
      formData.backgroundNum = await PreferencesManager.getBackground(this.context)
      console.info('模拟器卡片获取待办事项数据为:'+JSON.stringify(formData))
      //定义需要传递给卡片的数据
      let bindData = formBindingData.createFormBindingData(formData);
      let formId = want.parameters && want.parameters['ohos.extra.param.key.form_identity'].toString()
      console.info('模拟器卡片Get formId successfully.'+formId)
      await PreferencesManager.putFormId(formId,this.context)
      //更新卡片数据
      formProvider.updateForm(formId, bindData).then(() => {
        console.log('模拟器卡片Card updated successfully.');
      }).catch((error: BusinessError) => {
        console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
      });
    }).catch((error: BusinessError)=>{
      console.error(`模拟器卡片Failed to get card data: code is ${error.code},message is ${error.message}`);
    })
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    let formData: CardData = {
      'TodoItemList': [],
      'backgroundNum': 1
    }
    StoreManager.getToDoItemsInfo(this.context).then(async (toDoItemsInfo: ToDoItemsInfo[])=>{
      toDoItemsInfo.forEach(item => {
        if(!item.IsDid){
          formData.TodoItemList.push(item.content)
        }
      });
      formData.backgroundNum = await PreferencesManager.getBackground(getContext(this))
      console.info('模拟器卡片获取待办事项数据为:'+JSON.stringify(formData))
      //定义需要传递给卡片的数据
      let bindData = formBindingData.createFormBindingData(formData);
      console.info('模拟器卡片Get formId successfully.'+formId)
      //更新卡片数据
      formProvider.updateForm(formId, bindData).then(() => {
        console.log('模拟器卡片Card updated successfully.');
      }).catch((error: BusinessError) => {
        console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
      });
    }).catch((error: BusinessError)=>{
      console.error(`模拟器卡片Failed to get card data: code is ${error.code},message is ${error.message}`);
    })
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};