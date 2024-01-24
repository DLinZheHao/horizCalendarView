//
//  CalendarViewModel.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/23.
//

import UIKit

class CalendarViewModel {
    
    /// 日曆資料源
    var calendarModel: CalendarDataSourceModel?
    
    /// 日期形式轉換物件
    var formatter: DateFormatter = DateFormatter()
    /// 日期型態轉換物件
    var components: DateComponents = DateComponents()
    
    /// 日曆元件
    var calendar: Calendar = {
       return Calendar(identifier: .gregorian)
    }()
    
    // MARK: - 時間的方法
    
    /// 獲得今天幾號
    func getToday(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return components.day ?? 1
    }
    
    /// 獲得今天是幾月
    func getMonth(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return components.month ?? 1
    }
    
    /// 獲得今天是幾年
    func getYear(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return components.year ?? 1
    }
    
    /// 計算每個月的第一天在星期幾，從哪一個 item 開始 。
    func firstWeekdayInThisMonth(date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // 1 表示星期天，2 表示星期一，依此類推
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        guard let firstWeekday = calendar.ordinality(of: .weekday,
                                                     in: .weekOfMonth,
                                                     for: firstDayOfMonth) else { return 0 }
        // 返回的是 0-6 的星期天數
        return firstWeekday - 1
    }
    
    /// 這個月有多少天
    func totaldaysInThisMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
    /// 上個月的 date 數據
    func lastMonth(date: Date) -> Date? {
        var dateComponents = components
        dateComponents.month? -= 1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate
    }
    
    /// 下個月的 date 數據
    func nextMonth(date: Date) -> Date? {
        var dateComponents = components
        dateComponents.month? += 1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate
    }
    
    /// 計算每個月的時間，為每個月數據的鋪開創造條件
    func returnDaysNumber(section: Int) -> Int {
        guard let dateTime = getEarlierAndLaterDays(from: Date(), withMonth: section) else { return 0 }
        /// 這個月有多少天
        let daysInThisMonth = totaldaysInThisMonth(date: dateTime)
        /// 每個月的第一天在星期幾，從哪一個單元格開始
        let firstWeekDay = firstWeekdayInThisMonth(date: dateTime)
        
        return daysInThisMonth + firstWeekDay
    }
    
    /// 獲取當前日期零件（拆分）
    func getCurrentComponent(with date: Date) -> DateComponents {
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        return calendar.dateComponents(components, from: date)
    }

    /// 根據當前點擊時間獲取獲取當前點擊時間與目前時間差的月數，算出正確的點擊時間的月份（0 為當前月）
    func getEarlierAndLaterDays(from date: Date, withMonth month: Int) -> Date? {
        let components = getCurrentComponent(with: date)
        
        let year = components.year ?? 0
        let month_n = components.month ?? 0
        //希望从哪年开始写日历 例如2016年
        let monthCount = (year - (calendarModel?.year ?? calendar.component(.year, from: Date()))) * 12
        //获取当前section代表的月份和现在月份的差值
        let months = month - monthCount - month_n + 1

        self.components.month = months
        
        // 返回各月份的当前日期，如：當前是 2016-01-14，點擊２月的物件會獲得 2016-02-14
        return calendar.date(byAdding: self.components, to: date)
    }
    
    // MARK: - 需要看情況修正
    /// 獲取每個單位內開始時間
    func getBeginTimeInMonth(date: Date) -> String? {
        let calendar = Calendar.current
        let findFirstTime = calendar.dateInterval(of: .month, for: Date())

        if let _ = findFirstTime {
            return nil
        } else {
            return ""
        }
    }

    func compareDateAndGiveValue(startStr: String, endStr: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let dateOne = dateFormatter.date(from: startStr),
           let dateTwo = dateFormatter.date(from: endStr) {
            
            // let comparisonResult = dateOne.compare(dateTwo)
        
        }
    }
    
    /// 獲取當前日期格式
    func getTimeFormatArray(date: Date, month: Int) -> [String] {
        /// 數值範例：2023-01-01 08:30:57 +0000
        guard let dateTime = getEarlierAndLaterDays(from: Date(), withMonth: month) else { return [] }
        let year = String(calendar.component(.year, from: dateTime))
        let month = String(calendar.component(.month, from: dateTime))
        
        return [year, month]
    }
}
