//
//  DateExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension Calendar {
    
    static func monthFromInt(_ month: Int) -> String {
        let monthSymbols = Calendar.current.monthSymbols
        let max = monthSymbols.count
        let monthInt = month-1
        if monthInt < 0 || monthInt >= max { return ""}
        return monthSymbols[monthInt].capitalizingFirstLetter()
    }
    
    func startOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
    
    static func getSwedishWeekdayNames() -> [String]{
        let calendar = Calendar(identifier: .gregorian)
        //calendar.locale = Locale(identifier: "en_US_POSIX")
        //calendar.locale = Locale(identifier: "sv")
        return calendar.weekdaySymbols
    }
    
    static func getSwedishShortWeekdayNames() -> [String]{
        let calendar = Calendar(identifier: .gregorian)
        //calendar.locale = Locale(identifier: "en_US_POSIX")
        //calendar.locale = Locale(identifier: "sv")
        return calendar.shortWeekdaySymbols
    }
    
    static func getWeekdayName(_ weekday:Int) -> String{
        return getSwedishWeekdayNames()[weekday-1]
    }
    
    static func getShortWeekdayName(_ weekday:Int) -> String{
        return getSwedishShortWeekdayNames()[weekday-1]
    }
    
    static func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: from)
        let toDate = calendar.startOfDay(for: to)
        let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day ?? 0
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func adding(days: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = days

        return NSCalendar.current.date(byAdding: dateComponents, to: self)
    }
    
    func yesterDay() -> Date? {
        let calendar = Calendar.current
        var dayComponent = DateComponents()
        dayComponent.day = -1
        return calendar.date(byAdding: dayComponent, to: self)
    }
    
    func plusThisMuchDays(_ add:Int) -> Date? {
        let calendar = Calendar.current
        var dayComponent = DateComponents()
        dayComponent.day = add
        return calendar.date(byAdding: dayComponent, to: self)
    }
    
    func dayValue() -> Int?{
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func nextWeekDay(weekday:Int) -> Date?{
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = weekday
        if let weekday = cal.nextDate(after: self, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents) {
            return weekday
        }
        return nil
    }
    
    func numberOfDaysTo(_ to: Date) -> Int? {
        let cal = Calendar.current
        let fromDate = cal.startOfDay(for: self) // <1>
        let toDate = cal.startOfDay(for: to) // <2>
        let numberOfDays = cal.dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day
    }
    
    func isSameDayAs(_ otherDay:Date) -> Bool{
        let cal = Calendar.current
        let order = cal.compare(self, to: otherDay, toGranularity: .day)

        switch order {
            case .orderedAscending:
                fallthrough
            case .orderedDescending:
                return false
            default:
                return true
        }
    }
    
    func compareTo(_ otherDay:Date) -> ComparisonResult{
        let cal = Calendar.current
        return cal.compare(self, to: otherDay, toGranularity: .day)
    }
    
    func hourMinuteSeconds() -> (hour:Int,minutes:Int,seconds:Int){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        let seconds = calendar.component(.second, from: self)
        return (hour:hour,minutes:minutes,seconds:seconds)
    }
    
    func dayDateMonth() -> String{
        let components = self.get(.day, .month, .year)
        let day = self.dayName()
        let month = self.shortMonthName()
        if let c_date = components.day{
            return "\(day.uppercased()) \(c_date) \(month.uppercased())"
        }
        return "\(day.uppercased())  \(month.uppercased())"
    }
    
    func dateMonthYear() -> String{
        let components = self.get(.day, .month, .year)
        let month = self.shortMonthName()
        let year = self.year()
        // TISDAG 2 MAJ 2023
        if let c_date = components.day{
            return "\(c_date) \(month.uppercased()) \(year)"
        }
        return " ? \(month.uppercased()) \(year)"
    }
    
    func iosLongMessageFormat() -> String{
        guard let daysToToday = self.numberOfDaysTo(Date())
        else { return ""}
        switch daysToToday{
        case 0:return self.shortTime()
        case 1:return "Yesterday \(self.shortTime())"
        case 2: fallthrough
        case 3: fallthrough
        case 4: fallthrough
        case 5: fallthrough
        case 6: fallthrough
        case 7: return "\(self.dayName()) \(self.shortTime())"
        default:return self.toISO8601String()
        }
    }
    
    func iosShortMessageFormat() -> String{
        guard let daysToToday = self.numberOfDaysTo(Date())
        else { return ""}
        switch daysToToday{
        case 0:return self.shortTime()
        case 1:return "Yesterday"
        case 2: fallthrough
        case 3: fallthrough
        case 4: fallthrough
        case 5: fallthrough
        case 6: fallthrough
        case 7: return self.dayName()
        default:return self.toISO8601String()
        }
    }
 
    func dayDateMonthYear() -> (dateformatted:String,weekday:String){
        let components = self.get(.day, .month, .year)
        var day = self.dayName()
        var month = self.shortMonthName()
        let year = self.year()
        day.capitalizeFirst()
        month.capitalizeFirst()
        if let c_date = components.day{
            return (dateformatted:"\(c_date) \(month) \(year)",weekday:day)
        }
        return (dateformatted:"? \(month) \(year)",weekday:day)
    }
    
    static func from(_ year: Int, _ month: Int, _ day: Int) -> Date?{
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents(calendar: gregorianCalendar, year: year, month: month, day: day)
        dateComponents.timeZone = .gmt
        return gregorianCalendar.date(from: dateComponents)
    }
    
    static func fromISO8601StringToDate(_ dateToProcess:String) -> Date?{
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: dateToProcess)
    }
    
    func toISO8601String() -> String{
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return formatter.string(from: self)
    }
    
    func getFirstWeekdayInMonth() -> Int{
        let calendar = Calendar.current
         return calendar.component(.weekday, from: calendar.startOfMonth(self))
    }
     
    
    static func fromInputString(_ input:String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        //dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.date(from: input)
    }
    
    func formattedString() -> String{
        let weekday = dayName()
        return "\(weekday)" + " " + "\(day())" + " " + shortMonthName() + " " + "\(year())"
    }
    
    func formattedStringWithTime() -> String{
        let weekday = dayName()
        return "\(weekday)" + " " + "\(day())" + " " + shortMonthName() + " " + "\(year())" + " " + time()
    }
    
    func addOneDay() -> Date?{
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func time() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
         
        return dateFormatter.string(from: self)
    }
    
    func shortTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
         
        return dateFormatter.string(from: self)
    }
    
    func year() -> Int {
        return Calendar.current.component(.year, from: self)
        
    }
    
    func month() -> Int {
        return Calendar.current.component(.month, from: self)
        
    }
    
    func day() -> Int {
        return Calendar.current.component(.day, from: self)
        
    }
    
    func shortMonthName() -> String{
        if let monthInt = Calendar.current.dateComponents([.month], from: self).month {
            return Calendar.current.shortMonthSymbols[monthInt-1]
        }
        return ""
    }
    
    func fullMonthName() -> String{
        if let monthInt = Calendar.current.dateComponents([.month], from: self).month {
            return Calendar.current.monthSymbols[monthInt-1]
        }
        return ""
    }
    
    func dayName() -> String{
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("EEEE")
        return df.string(from: self)
    }
    
    func getDaysInMonth() -> Int?{
        let calendar = Calendar.current

        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date)
        else{
            return nil
        }
        return range.count
    }
    
}

