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