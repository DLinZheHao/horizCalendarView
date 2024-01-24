//
//  CalendarDataSourceModel.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/23.
//

import UIKit

struct CalendarDataSourceModel {
    /// 可選最小日期
    var rangeMinDate: String? = ""
    /// 可選最大日期
    var rangeMaxDate: String? = ""
    /// 選擇年份
    var year: Int
    /// 總呈現月份 (預設12個月)
    var totalMonth: Int = 12
    
//    /// 已選日期
//    let choiceDates: [String]
//    /// 多選時可否選同一天
//    var canSameDay: Bool = false
//    /// 可否取消自己
//    var canCancelSelf: Bool = false
//    /// 多選時最多可以相差幾天
//    var limitGap: Int?
//    /// 備註（底下粉色）
//    var remarks: [String] = []
    /// 月曆資料
    //var dataSource: [CalendarGridData] = []
    /// 日期選擇方式：單選 | 多選
    //var mode: CalendarGridData.Mode = .single
}
