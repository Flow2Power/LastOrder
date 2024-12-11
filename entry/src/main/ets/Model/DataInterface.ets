import { ValuesBucket } from "@kit.ArkData";
//节假日信息接口
export interface HolidayInfo extends ValuesBucket  {
  id:number|null; // 数据库主键ID
  date: string; // 日期字符串
  name: string; // 节假日名称
  isOffDay: number; // 是否为休息日
  year: number;
}
export type Holidays = Record<string, HolidayInfo>;
//定义二十四节气查询结果的接口
export interface QueryInfo {
  pub_year: string; // 公历年份
  name: string; // 节假日名称
  pub_date: string; // 公历日期
  pub_time: string; // 公历时间
  pri_date: string; // 农历日期
  des: string; // 描述
  youLai: string; // 由来
  xiSu: string; // 风俗
  heath: string; // 健康提示
}
export interface QueryResult {
  reason: string; // 查询结果描述
  result: QueryInfo[]; // 节假日详细信息数组
  error_code: number; // 错误码
}
// 二十四节气信息接口
export interface SolarTermsInfo extends ValuesBucket {
  id:number|null; // 数据库主键ID
  pub_year: string; // 公历年份
  name: string; // 节假日名称
  pub_date: string; // 公历日期
}
export type SolarTerms = Record<string, SolarTermsInfo>;
// 日程信息接口
export type Events = Record<string, string>;
//待办事项数据接口
export interface ToDoItemsInfo extends ValuesBucket {
  id:number|null; // 数据库主键ID
  content: string;
  IsDid: number;
}
//卡片信息接口
export interface CardData {
  'TodoItemList': string[];
  'backgroundNum': number
}
//聊天信息接口
export interface ChatMessage {
  text: string;
  isSelf: number;
}
//ERNIE响应接口
export interface ChatCompletionResponse {
  id: string;
  object: string;
  created: number;
  result: string;
  is_truncated: boolean;
  need_clear_history: boolean;
  finish_reason: string;
  usage: Usage;
}
export interface Usage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}
//ERNIE请求接口
export interface ChatRequest {
  messages: Message[];
  system: string;
}
export interface Message {
  role: string;
  content: string;
}

//讯飞星火对话请求接口
export interface SparkMessage {
  role: string; // 消息角色，例如 "system" 或 "user"
  content: string; // 消息内容
}
export interface SparkChatRequest {
  model: string; // 模型名称
  user: string; // 用户唯一ID
  messages: SparkMessage[]; // 消息数组
}
//讯飞星火对话响应接口
export interface Choice {
  message: SparkMessage; // 消息对象
  index: number; // 选择索引
}
export interface SparkUsage {
  prompt_tokens: number; // 提示词使用的token数量
  completion_tokens: number; // 完成内容使用的token数量
  total_tokens: number; // 总共使用的token数量
}
export interface SparkChatResponse {
  code: number; // 响应代码
  message: string; // 响应消息
  sid: string; // 会话ID
  choices: Choice[]; // 选择数组
  usage: Usage; // 使用情况
}