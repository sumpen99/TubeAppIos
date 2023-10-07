//
//  CalendarView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-04.
//

import SwiftUI
import CoreData
var PAD_CALENDAR: Int = 0

enum CalendarSheet: Identifiable{
    case LOAD_TUBE
    
    var id: Int{
        hashValue
    }
}

struct Selected{
    let months: [String] = Calendar.current.shortMonthSymbols
    let days = Calendar.getSwedishShortWeekdayNames()
    var year: Int = Date().year()
    var month: String = Date().shortMonthName()
    var day: Int = Date().day()
    var yearHasSavedTubes:Bool = false
    var monthHasSavedTubes:Bool = false
    var dayHasSavedTubes:Bool = false
    var userWillEditTubes:Bool = false
    var expandedCalendar:Bool = false
    var collapseYear:Bool = true
    var collapseMonth:Bool = false
    var collapseDay:Bool = false
    var isDeleteTube:Bool = false
    var tubeModel:TubeModel?
    var activeCalendarSheet:CalendarSheet?
}

struct CustomCalendarView: View {
    @Namespace var animation
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var selected:Selected = Selected()
  
    let columns = [ GridItem(),GridItem(),GridItem(),GridItem()]

    let layout = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40))
        ]
    
    
    
    var body: some View {
        NavigationView{
            AppBackgroundStack(content: {
                mainPage
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    navigateToSavedTubesButton
                }
            }
            .modifier(NavigationViewModifier(title: ""))
        }
        .sheet(item: $selected.tubeModel){ tube in
            SelectedTubeView(tubeModel: tube,
                             labelBackButton: "Calendar",
                             loadViewModelWithTubeModel: loadViewModelWithTubeModel,
                             deleteTubeModel: deleteTubeModel)
        }
        .onAppear{
            searchAndSet(year: true, month: true, day: true)
        }
    }
    
    var mainPage:some View{
        List{
            calendarYearMonths
            calendarWeekdays
            tubesInfo
        }
        .listStyle(.grouped)
    }
    
    var calendarYearMonths: some View{
        Section(content: {
            if !selected.collapseYear{
                LazyVStack {
                    monthGridView
                }
          }
        }, header: { yearGridButtons })
        .listRowBackground(Color.clear)
        
    }
    
    var calendarWeekdays: some View{
        Section(content: {
            if !selected.collapseMonth{
                LazyVStack {
                    weekdaysName
                    daysGridView
                }
            }
       }, header: { monthGridButtons })
        .listRowBackground(Color.clear)
        
    }
    
    var tubesInfo: some View{
        Section(content: {
            if !selected.collapseDay{
                if let day = queryTubesSavedByDay(selected.day,addPad: false),day > 0{
                    loadTubesOnThisDate
                }
                else{
                    Text("No saved tubes")
                    .noDataBackgroundNoPadding()
                }
            }
        }, header: { dayGridButton })
        .listRowBackground(Color.clear)
        
    }
    
}

extension CustomCalendarView{
    //MARK: - GRIDVIEW MONTH AND DAYS
    var monthGridView: some View{
        LazyVGrid(columns: columns,spacing: V_GRID_SPACING,pinnedViews: [.sectionHeaders]) {
            ForEach(selected.months, id: \.self) { month in
               ZStack{
                   getMonthCell(month,haveSavedTubes: queryTubesSavedByMonth(month) > 0)
               }
           }
        }
        .onChange(of: selected.month, perform: { month in
            searchAndSet(year:true,month:true,day:true)
        })
    }
    
    func getMonthCell(_ month:String,haveSavedTubes:Bool) -> some View{
        return Text(month)
        .frame(width: 60, height: 33)
        .cornerRadius(8)
        .background(
             ZStack{
                 if month == selected.month{
                     RoundedRectangle(cornerRadius: 8).fill(Color.calendarBackground)
                      .matchedGeometryEffect(id: "CURRENTMONTH", in: animation)
                 }
                 else{
                     Color.clear
                 }
             }
        )
        .overlay{
            if haveSavedTubes{
                getBadgeMonth(month)
            }
        }
        .foregroundColor(month == selected.month ? .black : .white)
        .onTapGesture {
            withAnimation{
                selected.month = month
            }
        }
    }
    
    // MARK: - DAYS NAME VIEW
    var weekdaysName: some View{
        LazyVGrid(columns: layout, spacing: 20.0,pinnedViews: [.sectionHeaders]) {
            ForEach(selected.days, id: \.self) { item in
                Text("\(item)").foregroundColor(Color.white).font(.subheadline).bold()
           }
        }
        .padding([.horizontal,.top])
    }
    
    // MARK: - DAYS GRIDVIEW
    var daysGridView: some View{
        LazyVGrid(columns: layout, spacing: 20.0,pinnedViews: [.sectionHeaders]) {
            ForEach(1...daysInCurrentMonth(), id: \.self) { day in
                ZStack{
                    getDayCell(day)
                    if let num = queryTubesSavedByDay(day,addPad: true),num != 0{
                        getBadgeDay(day,num:num)
                    }
                }
           }
        }
        .onChange(of: selected.day, perform: { day in
            searchAndSet(year:false,month:false,day:true)
        })
        .padding([.horizontal,.top])
    }
    
    func getDayCell(_ day:Int) -> some View{
        let newDay = day - PAD_CALENDAR
        let showDay = newDay >= 1
        return Text(showDay ? "\(newDay)" : "")
                .frame(width: 30, height: 30)
                .background(
                     ZStack{
                         if newDay == selected.day{
                             Circle().fill(Color.calendarBackground)
                             .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                         }
                     }
                )
                .foregroundColor(newDay == selected.day ? .black : .white)
                .onTapGesture {
                    withAnimation{
                        selected.day = day - PAD_CALENDAR
                    }
                }
    }
    
    //MARK: - Buttons
    var topButtonRow: some View{
        HStack {
            decreaseYearButton
            Text(String(selected.year))
            addYearButton
        }
        .onChange(of: selected.year, perform: { year in
            searchAndSet(year:true,month:true,day:true)
        })
    }
    
    var yearGridButtons:some View{
        HStack{
            topButtonRow.hLeading()
            .sectionText(font: .headline)
            toggleYearButton.hTrailing()
        }
    }
    
    var monthGridButtons:some View{
        HStack{
            Text(fullMonthName)
            .sectionText(font: .subheadline)
            Spacer()
            toggleMonthButton
        }
    }
    
    var dayGridButton: some View{
        HStack{
            Text(dateAsText)
            .sectionText(font: .footnote)
            Spacer()
            toggleDayButton
        }
    }
    
    var decreaseYearButton:some View{
        Button(action: {
            if selected.year > TP_RELEASE_YEAR{
                selected.year -= 1
            }
        },label: {Text("\(Image(systemName: "chevron.left"))").foregroundColor(.systemBlue)})
    }
    
    var addYearButton:some View{
        Button(action: {
            selected.year += 1
        },label: {Text("\(Image(systemName: "chevron.right"))").foregroundColor(.systemBlue)})
    }
    
    var navigateToSavedTubesButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            InboxSavedTubesView()
        })){
            Image(systemName: "list.bullet")
        }
    }
    
    var toggleYearButton:some View{
        Button(selected.collapseYear ? "\(Image(systemName: "chevron.right"))" : "\(Image(systemName: "chevron.down"))", action: {
            withAnimation{
                selected.collapseYear.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.systemBlue))
     }
    
    var toggleMonthButton:some View{
        Button(selected.collapseMonth ? "\(Image(systemName: "chevron.right"))" : "\(Image(systemName: "chevron.down"))", action: {
            withAnimation{
                selected.collapseMonth.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.systemBlue))
    }
    
    var toggleDayButton:some View{
        Button(selected.collapseDay ? "\(Image(systemName: "chevron.right"))" : "\(Image(systemName: "chevron.down"))", action: {
            withAnimation{
                selected.collapseDay.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.systemBlue))
    }
    
    //MARK: - BADGES
    func getBadgeMonth(_ month:String) -> some View{
        return ZStack{
                Circle()
                .fill(Color.systemYellow)
                .frame(width: 10, height: 10,alignment: .trailing)
            }
            .vBottom()
            .hTrailing()
    }
    
    func getBadgeDay(_ day:Int,num:Int) -> some View{
        let newDay = day - PAD_CALENDAR
        let showDay = newDay >= 1
        return ZStack{
            Circle()
                .fill(Color.systemYellow)
                .frame(width: 20, height: 20,alignment: .trailing)
            Text("\(num)").font(.caption)
        }
        .padding([.trailing],-5)
        .padding([.bottom],-5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .opacity(showDay ? 1.0 : 0.0)
    }
        
    //MARK: - LOAD TUBES FROM COREDATA
    @ViewBuilder
    var loadTubesOnThisDate: some View{
        let month = getSelectedMonthIndex()
        if let startDate = Date.from(selected.year, month, selected.day) as NSDate?,
           let endDate = Date.from(selected.year, month,selected.day+1) as NSDate?{
            FilteredList(filterStartDate: startDate, filterEndDate: endDate){ (tube: TubeModel) in
                TubeDocFileView(tube: tube){ selectedTube in
                    selected.tubeModel = tube
                }
             }
            .matchedGeometryEffect(id: "CURRENT_SAVED_TUBES", in: animation)
        }
    }
    
    //MARK: - QUERY-FUNCTIONS
    func searchAndSet(year:Bool,month:Bool,day:Bool){
        if year{
            selected.yearHasSavedTubes = queryTubesSavedByYear() > 0
        }
        if month{
            selected.monthHasSavedTubes = queryTubesSavedByMonth(selected.month) > 0
        }
        if day{
            guard let num = queryTubesSavedByDay(selected.day, addPad: false) else{
                selected.dayHasSavedTubes = false
                return
            }
            selected.dayHasSavedTubes = num > 0
        }
    }
    
    func queryTubesSavedByYear() -> Int{
        guard let startDate = Date.from(selected.year, 1, 1) as NSDate?,
              let endDate = Date.from(selected.year+1,1,1) as NSDate? else { return 0}
        return PersistenceController.fetchCountByPredicate(
            NSPredicate(format: "date >= %@ AND date < %@",startDate,endDate))
    }
    
    func queryTubesSavedByMonth(_ month:String) -> Int{
        if !selected.yearHasSavedTubes { return 0}
        let month = getSelectedMonthIndex(month)
        guard let startDate = Date.from(selected.year, month, 1) as NSDate?,
              let endDate = Date.from(selected.year,month+1,1) as NSDate? else { return 0}
        return PersistenceController.fetchCountByPredicate(
            NSPredicate(format: "date >= %@ AND date < %@",startDate,endDate))
    }
    
    func queryTubesSavedByDay(_ day:Int,addPad:Bool) -> Int?{
        if !selected.monthHasSavedTubes { return nil}
        let month = getSelectedMonthIndex()
        let d = addPad ? (day - PAD_CALENDAR) : day
        guard let startDate = Date.from(selected.year, month, d)  as NSDate?,
              let endDate = Date.from(selected.year,month,d+1)  as NSDate? else { return nil }
        return PersistenceController.fetchCountByPredicate(
            NSPredicate(format: "date >= %@ AND date < %@",startDate,endDate))
    }
    
    //MARK: - LOAD/DELETE TUBEMODEL
    func loadViewModelWithTubeModel(_ tubeModel:TubeModel){
        tubeViewModel.initViewFromModelValues(tubeModel)
        tubeViewModel.rebuild()
        navigationViewModel.navTo(.HOME)
    }
    
    func deleteTubeModel(_ tube:TubeModel){
        PersistenceController.deleteTubeImage(tube.image)
        PersistenceController.deleteTubeModel(tube)
        searchAndSet(year: true, month: true, day: true)
        selected.tubeModel = nil
    }
    
    //MARK: - HELPER FUNCTIONS DATE
    func daysInCurrentMonth() -> Int {
        let monthNumber = (selected.months.firstIndex(of: selected.month) ?? 0) + 1
        var dateComponents = DateComponents()
        dateComponents.year = selected.year
        dateComponents.month = monthNumber
        guard let date = Calendar.current.date(from: dateComponents),
              let interval = Calendar.current.dateInterval(of: .month, for: date),
              let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
        else{ return 0 }
        
        PAD_CALENDAR = date.getFirstWeekdayInMonth() - 1
        return days + PAD_CALENDAR
    }
    
    func daysInCurrentMonth(monthNumber: Int,year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = monthNumber
        guard let d = Calendar.current.date(from: dateComponents),
              let interval = Calendar.current.dateInterval(of: .month, for: d),
              let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
        else{ return 0 }
        return days
    }
    
    func getCapitalizedMonth() -> String{
        return selected.month.capitalizingFirstLetter()
    }
    
    func getSelectedMonthIndex() -> Int{
        guard let selectedMonthIndex = selected.months.firstIndex(of: selected.month) else { return -1 }
        return  selectedMonthIndex + 1
    }
    
    func getSelectedMonthIndex(_ month:String) -> Int{
        guard let selectedMonthIndex = selected.months.firstIndex(of: month) else { return -1 }
        return  selectedMonthIndex + 1
    }
    
    var dateAsText: String{
        let month = getSelectedMonthIndex()
        guard let startDate = Date.from(selected.year, month, selected.day) else {
            return "\(selected.day)" + " " + "\(selected.month)" + " " + "\(selected.year)"
        }
        let weekday = startDate.dayName()
        return "\(weekday)" + " " + "\(selected.day)" + " " + "\(selected.month)" + " " + "\(selected.year)"
    }
    
    var fullMonthName: String{
        let month = getSelectedMonthIndex()
        guard let startDate = Date.from(selected.year, month, selected.day) else {
            return "\(selected.month)"
        }
        return startDate.fullMonthName()
    }
}
