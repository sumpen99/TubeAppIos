//
//  NotificationHandler.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
import UserNotifications
class NotificationHandler : NSObject,ObservableObject,UNUserNotificationCenterDelegate{
    let notificationCenter = UNUserNotificationCenter.current()
    
    override init(){
        super.init()
        notificationCenter.delegate = self
    }
    
    func checkPermission(completion: @escaping (UNNotificationSettings) -> Void){
        notificationCenter.getNotificationSettings(completionHandler:completion)
    }
    
    func requestPermission(completion: @escaping ((Bool, (any Error)?) -> Void)) {
        notificationCenter.requestAuthorization(options:[.sound , .alert , .badge ],
                                                completionHandler:completion)
    }
    
    func createNotificationDate(weekday:Date,hour:Int,minutes:Int) -> Date?{
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var components = calendar.components([.calendar, .weekday, .weekOfYear, .year, .hour, .minute, .second, .timeZone], from: weekday)
        components.hour = hour
        components.minute = minutes
        //components.weekday = weekday
        components.timeZone = TimeZone.current
        return calendar.date(from: components)
        
        
    }
    
    func createID(notificationID:String,weekDay:String) -> String{
        return "\(notificationID)\(weekDay)"
    }
    
    func scheduleNotification(date:Date,title:String,body:String,notificationId:String){
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
        
        let content = UNMutableNotificationContent()
        let id = createID(notificationID:notificationId,weekDay:date.dayName())
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = id
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request){ (error) in
            //debugLog(object:error)
        }
    }
    
    func getScheduleNotifications(){
        notificationCenter.getPendingNotificationRequests{ request in
            for req in request{
                if req.trigger is UNCalendarNotificationTrigger{
                    debugLog(object:(req.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()!)
                }
            }
        }
    }
    
    func removeNotifications(identifiers:[String]){
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeNotifications(){
        notificationCenter.removeAllPendingNotificationRequests()
   }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        NSLog("Application delegate method userNotificationCenter:didReceive:withCompletionHandler: is called with user info: %@", response.notification.request.content.userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        NSLog("userNotificationCenter:willPresent")
        completionHandler([.banner, .badge, .sound])
    }
}
