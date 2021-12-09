//
//  ContentView.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/10/28.
//

import SwiftUI
import FloatingButton
import CoreData

/*
 导航栏菜单
 */
struct ContentView: View {
    
    let orientationPublisher = NotificationCenter.default.publisher(for:
        UIDevice.orientationDidChangeNotification)
    
    
    @State private var selectedTab = 0
    
    @ObservedObject var monthBill = EmojiBillViewModel()
    

    var body: some View {
        GeometryReader{ geometry in
            TabView{
                HomePage(geometry:geometry, monthBill: monthBill)
                .tabItem{
                    Image(systemName: "house")
                    Text("首页")
                }
                Statistics(geometry: geometry, monthBill: monthBill)
                    .frame(height:geometry.size.height)
                .tabItem{
                    Image(systemName: "chart.bar.xaxis")
                    Text("统计")
                    
                }
                UserInfoView(monthBill: monthBill)
                .tabItem{
                    Image(systemName: "person.circle.fill")
                    Text("个人")
                }
            }
            .onOpenURL(perform: { url in
                print(url)
            })
            
        }
        
    }
}

/*
 导航栏界面大按钮
 */
struct MainButton: View {
    
    var imageName: String
    var colorHex: String
    var width: CGFloat = 50
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.white)
                .frame(width:width, height: width)
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(.green)
                .frame(width: width, height: width)
                .opacity(0.8)
        }
    }
}

/*
 收入支出按钮
 */
struct IconAndTextButton: View {
    
    var imageName: String
    var buttonText: String
    let imageWidth: CGFloat = 22
    var geometry: GeometryProxy
    var type: Int = 1
    var monthBill: EmojiBillViewModel

    
    var body: some View {
        NavigationLink(destination: EditingBillView(
            geometry: geometry,
            monthBill: monthBill,
            selectedClass: 1 - type)){
            ZStack {
                Color.white
                HStack {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .foregroundColor(.black)
                        .frame(width: imageWidth, height: imageWidth)
                        .clipped()
                    Spacer()
                    Text(buttonText)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 15)
            }
            .frame(width: 160, height: 45)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("F4F4F4"), lineWidth: 1)
                )
        }
    }
}



/*
 收入支出按钮中的内容
 */
struct MockData {
    
    static let colors = [
        "e84393",
        "0984e3"
    ].map { Color($0) }
    
    static let iconImageNames = [
        "cloud.fill",
        "sun.max.fill"
    ]
    
    static let iconAndTextImageNames = [
        "bag.badge.minus",
        "bag.badge.plus"
    ]
    
    static let iconAndTextTitles = [
        "支出",
        "收入"
    ]
}

/**
 展示账单类别的卡片
 */
struct ShowTypeButton: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    var buttonIndex: Int
    var buttonImage: String
    let buttonWidth: CGFloat
    var geometry: GeometryProxy
    var selectedClass: Bool
    
    
    var body: some View {
        ZStack {
            if (self.colorScheme == .dark){
                Color.black
            }
            else{
                Color.white
            }
            VStack {
                ZStack{
                    if selectedClass{
                        Circle()
                            .foregroundColor(Color.red)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
                            .frame(width: 40, height: 40)
                            .opacity(0.8)
                    }
                    else{
                        Circle()
                            .foregroundColor(Color.green)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
                            .frame(width: 40, height: 40)
                            .opacity(0.8)
                    }
                    Image(systemName: buttonImage)
                }
                .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 15)
        }
        .frame(width: buttonWidth)
        .cornerRadius(8)
        
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("F4F4F4"), lineWidth: 1)
            )
    }
}


/*
 每日账单卡片
 */
struct DayBillCard: View{
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    public var darkModeStyle: ChartStyle
    public var formSize:CGSize
    
    public var style: ChartStyle
    public var dropShadow: Bool = true
    
    public var cardDate: Date = Date()
    
    var geometry: GeometryProxy
    
    /**
     查询相关数据
     */
   
    var year: String
    
    var month: String

    var day: String
    
    var weekDay: Int
    
    var fetchRequest: FetchRequest<BillPoint>
    
    
    var isFullWidth:Bool {
        return self.formSize == ChartForm.large
    }
    
    var moneyInSum: Double{
        var Sums: Double = 0
        for i in 0..<self.fetchRequest.wrappedValue.count{
            if(self.fetchRequest.wrappedValue[self.fetchRequest.wrappedValue.index(self.fetchRequest.wrappedValue.startIndex, offsetBy: i)].inOrOut){
                Sums += self.fetchRequest.wrappedValue[self.fetchRequest.wrappedValue.index(self.fetchRequest.wrappedValue.startIndex, offsetBy: i)].amount
            }
        }
        return Sums
    }
    
    var moneyOutSum: Double {
        var Sums: Double = 0
        for i in 0..<self.fetchRequest.wrappedValue.count{
            if(!self.fetchRequest.wrappedValue[self.fetchRequest.wrappedValue.index(self.fetchRequest.wrappedValue.startIndex, offsetBy: i)].inOrOut){
                Sums += self.fetchRequest.wrappedValue[self.fetchRequest.wrappedValue.index(self.fetchRequest.wrappedValue.startIndex, offsetBy: i)].amount
            }
        }
        return Sums
    }
    
    var monthBill: EmojiBillViewModel
    
    init(year: String, month: String, day: String,  geometry: GeometryProxy, monthBill: EmojiBillViewModel, dropShadow: Bool = true, form: CGSize? = ChartForm.extraLarge){
        self.style = Styles.barChartStyleOrangeLight
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        self.dropShadow = dropShadow
        self.formSize = form!
        
        self.geometry = geometry
        self.monthBill = monthBill
        
        /**
         查询数据的初始化
         */
        self.year = year
        self.month = month
        self.day = day
        // TODO: 星期的计算
        self.weekDay = 1
        
        self.fetchRequest = FetchRequest(
            entity: BillPoint.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \BillPoint.time, ascending: false)],
            predicate: NSPredicate(format: "year == %@ and month == %@ and day == %@", year, month, day),
            animation: .default)
//        print("reload \(weekDay)")
    }
    
    var body: some View{
        if self.fetchRequest.wrappedValue.count != 0{
            HStack{
                Spacer(minLength: geometry.size.width / 40).layoutPriority(200)
                VStack{
                    ZStack{
                        Rectangle()
                            .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                            .cornerRadius(20)
                            .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
                        
                        HStack{
                            Spacer(minLength: 20)
                            VStack(alignment: .leading){
                                Spacer(minLength: 20)
                                HStack{
                                    
                                    Text("\(month)月\(day)日 ")
                                        .font(.headline)
                                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                                        .onTapGesture(perform: {
                                            print("\(month)")
                                        })
                                    Spacer()
                                    ZStack{
                                        Color.red
                                        Text("收")
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 20, height: 20)
                                    Text(String(format: "%.2f", moneyInSum))
                                    ZStack{
                                        Color.green
                                        Text("支")
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 20, height: 20)
                                    Text(String(format: "%.2f", moneyOutSum))
                                }
                                
                                Divider()
                                
                                ForEach(fetchRequest.wrappedValue){item in
                                    Spacer(minLength: 16)
                                    
                                    let id = item.id
                                    let type = Int(item.type)
                                    let amount = item.amount
                                    let remark = item.remark ?? ""
                                    let year = item.year ?? ""
                                    let month = item.month ?? ""
                                    let day = item.day ?? ""
                                    
                                    let view = EditingBillView(
                                        geometry: geometry,
                                        monthBill: monthBill,
                                        selectedClass: item.inOrOut ? 0 : 1,
                                        isEditing: true,
                                        id: id! as NSUUID,
                                        selectedOccasion: type,
                                        amount: amount,
                                        remark: remark,
                                        year: year,
                                        month: month,
                                        day: day
                                    )
                                    
                                
                                    
                                    NavigationLink(destination: view){
                                        HStack{
                                            if (item.inOrOut){
                                                ShowTypeButton(
                                                    buttonIndex: Int(item.type),
                                                    buttonImage: EditingBillView.billOccasionImageIn[Int(item.type)],
                                                    buttonWidth: 70,
                                                    geometry: geometry,
                                                    selectedClass: item.inOrOut
                                                )
                                            }
                                            else{
                                                ShowTypeButton(
                                                    buttonIndex: Int(item.type),
                                                    buttonImage: EditingBillView.billOccasionImageOut[Int(item.type)],
                                                    buttonWidth: 70,
                                                    geometry: geometry,
                                                    selectedClass: item.inOrOut
                                                )
                                            }
                                            VStack{
                                                if (item.inOrOut){
                                                    Text(EditingBillView.billOccasionsIn[Int(item.type)])
                                                        .font(.title2)
                                                        .multilineTextAlignment(.leading)
                                                        .frame(
                                                            width:geometry.size.width * 5 / 12,
                                                            alignment: .topLeading)
                                                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                                                }
                                                else{
                                                    Text(EditingBillView.billOccasionsOut[Int(item.type)])
                                                        .font(.title2)
                                                        .multilineTextAlignment(.leading)
                                                        .frame(
                                                            width:geometry.size.width * 5 / 12,
                                                            alignment: .topLeading)
                                                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                                                }
                                                Spacer(minLength: 5)
                                                Text((item.time ?? "") + (item.remark != "" ? " | " : "") + (item.remark ?? "" ))
                                                    .font(.footnote)
                                                    
                                                    .multilineTextAlignment(.leading)
                                                    .frame(
                                                        width:geometry.size.width * 5 / 12,
                                                        alignment: .topLeading)
                                                    .lineLimit(1)
                                                
                                            }
                                            .frame(
                                                width:geometry.size.width * 5 / 12,
                                                alignment: .topLeading)
                                            Text("\(item.inOrOut ? "+" : "-" )\(String(format:"%.2f", item.amount))")
                                                .font(.title2)
                                                .frame(
                                                    width:geometry.size.width * 3 / 12)
                                                
                                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                                        }
                                    }
                                   .buttonStyle(PlainButtonStyle())
                                }

                                
                                Spacer(minLength: 10)
                            }
                            Spacer(minLength: 20)
                        }
                    }.padding(.horizontal)
                    Spacer(minLength: 20)
                }
                .layoutPriority(100)
                Spacer(minLength: geometry.size.width / 40).layoutPriority(200)
            }
        }
    }
}

/**
 首页
 */
struct HomePage:View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    
    var monthBill: EmojiBillViewModel
    
    @State private var selectedDate: Date = Date()
    
    private var yearFormatter: DateFormatter
    private var monthFormatter: DateFormatter
    
    
    var geometry: GeometryProxy
    @State var isOpen = false

    init(geometry: GeometryProxy, monthBill: EmojiBillViewModel){
        self.geometry = geometry

        self.monthBill = monthBill
        
        self.yearFormatter = DateFormatter()
        self.yearFormatter.dateFormat = "yyyy"
        self.monthFormatter = DateFormatter()
        self.monthFormatter.dateFormat = "MM"

    }
    

    var body: some View {
        NavigationView {
            ZStack{
                ScrollView{
                    ZStack{
                        Rectangle()
                            .fill(self.colorScheme == .dark ? .black : .white)
                            .cornerRadius(20)
                            .shadow(color: Styles.barChartStyleOrangeLight.dropShadowColor, radius: 8)
                        HStack{
                            DatePicker("请选择月份",
                                       selection: $selectedDate,
                                       in: ...Date(),
                                       displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.automatic)
                            Spacer()
                           
                            SumInAndOut(year: yearFormatter.string(from: selectedDate), month: monthFormatter.string(from: selectedDate), monthBill: monthBill)
                            
                        }
                        .frame(width: geometry.size.width * 9 / 10)
                        
                    }
                    .frame(width: geometry.size.width ,
                           height: geometry.size.height / 10)
                    
                    Spacer(minLength: 20)
                    
                    ForEach(1..<32){ i in
                        
                        DayBillCard(year: monthBill.year,
                                    month: monthBill.month,
                            day: String (format:  "%02d" , 32-i),
                            geometry: geometry,
                            monthBill: monthBill)
                    }
                }
                HStack{
                    // 添加账单按钮
                    let mainButton1 = MainButton(imageName: "pencil.circle.fill", colorHex: "eb3b5a", width: 60)
                    let textButtons = MockData.iconAndTextTitles.enumerated().map { index, value in
                        IconAndTextButton(imageName: MockData.iconAndTextImageNames[index],
                                          buttonText: value,
                        geometry: geometry,
                                          type:index, monthBill: monthBill)
                            .onTapGesture { isOpen.toggle() }
                    }
                    
                    VStack{
                        Spacer(minLength: geometry.size.height * 8 / 11)
                        FloatingButton(
                            mainButtonView: mainButton1,
                            buttons: textButtons,
                            isOpen: $isOpen)
                            .straight()
                            .direction(.top)
                            .alignment(.left)
                            .spacing(10)
                            .initialOffset(x: -1000)
                            .animation(.spring())
                    }
                    Spacer(minLength: geometry.size.width * 3 / 5)
                }
            }
        }
        
    }
}


struct SumInAndOut: View{
    var year: String
    var month: String

    
    private var fetchRequest: FetchRequest<BillPoint>
    private var monthBill: EmojiBillViewModel
    
    init(year: String, month: String, monthBill: EmojiBillViewModel){
        self.year = year
        self.month = month
        
        self.fetchRequest = FetchRequest(
            entity: BillPoint.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \BillPoint.time, ascending: false)],
            predicate: NSPredicate(format: "year == %@ and month == %@", year, month)
        )
        print("refresh")
        if (year != monthBill.year || month != monthBill.month){
            monthBill.changeMonth(year: year, month: month)
        }
        self.monthBill = monthBill
    }
    
    var moneyInSum: Double{
        
        var Sums: Double = 0
        for i in 0..<fetchRequest.wrappedValue.count{
            if(fetchRequest.wrappedValue[fetchRequest.wrappedValue.index(fetchRequest.wrappedValue.startIndex, offsetBy: i)].inOrOut){
                Sums += fetchRequest.wrappedValue[fetchRequest.wrappedValue.index(fetchRequest.wrappedValue.startIndex, offsetBy: i)].amount
            }
        }
        MonthBill.moneyIn = Sums
        return Sums
    }
    
    var moneyOutSum: Double{

        var Sums: Double = 0
        for i in 0..<fetchRequest.wrappedValue.count{
            if(!fetchRequest.wrappedValue[fetchRequest.wrappedValue.index(fetchRequest.wrappedValue.startIndex, offsetBy: i)].inOrOut){
                Sums += fetchRequest.wrappedValue[fetchRequest.wrappedValue.index(fetchRequest.wrappedValue.startIndex, offsetBy: i)].amount
            }
        }
        MonthBill.moneyOut = Sums
        return Sums
    }
    
    
    var body: some View{
        HStack{
            VStack{
                ZStack{
                    Color.red
                    Text("收")
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
                Text(String(format: "%.2f", moneyInSum))
                    
            }
            VStack{
                ZStack{
                    Color.green
                    Text("支")
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
                Text(String(format: "%.2f", moneyOutSum))
            }
            VStack{
                ZStack{
                    Color.yellow
                    Text("结")
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
                Text(String(format: "%.2f", moneyInSum - moneyOutSum))
            }
        }
    }
}

/**
 数据统计界面
 */
struct Statistics: View{
    @State var selectedSegment = 0
    
    private var monthBill: EmojiBillViewModel
    
    @Environment(\.managedObjectContext)
    var context
    
    init(geometry: GeometryProxy, monthBill: EmojiBillViewModel){
        self.geometry = geometry
        self.monthBill = monthBill
        
        // fetch data
        selectedSegment = 1
        selectedSegment = 0
    }
    
    @State
    var hasMoneyIn: Bool = true
    
    var pieAmountMoneyIn: [Double] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.type, ascending: false)]
        
        var results: [Double] = [0,0,0,0,0,0,0,0]
        
        var sumAmount: Double = 0
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if (isBillIn){
                    print(taskUpdate.value(forKey: "time") ?? "10:00")
                    
                    let type: Int = (taskUpdate.value(forKey: "type") ?? 0) as! Int
                    print("type: \(type)")
                    let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                    results[results.index(results.startIndex, offsetBy: type)] += amount
                    sumAmount += amount
                    
                }
                
            }
            if (sumAmount == 0){
                
            }
            else {
                for i in 0..<8{
                    results[results.index(results.startIndex, offsetBy: i)] /= (sumAmount * 0.01)
                }
            }
            
            return results
        }
        catch{
            print(error)
            results[results.startIndex] = 100
            return results
        }
    }
    
    var pieAmountMoneyOut: [Double] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.type, ascending: false)]
        
        var results: [Double] = [0,0,0,0,0,0,0,0]
        
        var sumAmount: Double = 0
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if (!isBillIn){
                    print(taskUpdate.value(forKey: "time") ?? "10:00")
                    
                    let type: Int = (taskUpdate.value(forKey: "type") ?? 0) as! Int
                    print("type: \(type)")
                    let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                    results[results.index(results.startIndex, offsetBy: type)] += amount
                    sumAmount += amount
                    
                }
                
            }
            if (sumAmount == 0){
                
            }
            else {
                for i in 0..<8{
                    results[results.index(results.startIndex, offsetBy: i)] /= (sumAmount * 0.01)
                }
            }
            
            return results
        }
        catch{
            print(error)
            results[results.startIndex] = 100
            return results
        }
    }
    
    var chartAmountMoneyIn: [(String, Double)] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.day, ascending: false)]
        
        var results: [(String, Double)] = []
        
        
        let curMonth: Int = ( (Int(monthBill.month)) ?? 1)
        
        if (curMonth == 1 || curMonth == 3
            || curMonth == 5 || curMonth == 7
            || curMonth == 8 || curMonth == 10
            || curMonth == 12){
            for i in 1..<32 {
                results.append(("\(i)日",0))
            }
        }
        else if (curMonth == 2){
            for i in 1..<30 {
                results.append(("\(i)日",0))
            }
        }
        else{
            for i in 1..<31 {
                results.append(("\(i)日",0))
            }
        }
        
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if (isBillIn){
                    print(taskUpdate.value(forKey: "time") ?? "10:00")
                    
                    let dayStr: String = ((taskUpdate.value(forKey: "day") ?? "1") as! String)
                    
                    let day = ( (Int(dayStr)) ?? 1)
                    
                   
                    print("day: \(day)")
                    let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                    results[results.index(results.startIndex, offsetBy: day-1)].1 += amount
                    
                }
                
            }

            return results
        }
        catch{
            print(error)
            return results
        }
    }
    
    var chartAmountMoneyOut: [(String, Double)] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.day, ascending: false)]
        
        var results: [(String, Double)] = []
        
        
        let curMonth: Int = ( (Int(monthBill.month)) ?? 1)
        
        if (curMonth == 1 || curMonth == 3
            || curMonth == 5 || curMonth == 7
            || curMonth == 8 || curMonth == 10
            || curMonth == 12){
            for i in 1..<32 {
                results.append(("\(i)日",0))
            }
        }
        else if (curMonth == 2){
            for i in 1..<30 {
                results.append(("\(i)日",0))
            }
        }
        else{
            for i in 1..<31 {
                results.append(("\(i)日",0))
            }
        }
        
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if (!isBillIn){
                    print(taskUpdate.value(forKey: "time") ?? "10:00")
                    
                    let dayStr: String = ((taskUpdate.value(forKey: "day") ?? "1") as! String)
                    
                    let day = ( (Int(dayStr)) ?? 1)
                    
                   
                    print("day: \(day)")
                    let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                    results[results.index(results.startIndex, offsetBy: day-1)].1 += amount
                    
                }
                
            }

            return results
        }
        catch{
            print(error)
            return results
        }
    }
    
    
    var geometry: GeometryProxy
    var body: some View{
        VStack{
            Spacer(minLength: geometry.size.height / 12)
            HStack{
                ZStack{
                    if self.selectedSegment == 0 {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.secondary)
                            .opacity(0.7)
                    }
                    Button(action: {
                        self.selectedSegment = 0
                    }) {
                        Image(systemName: "bag.badge.plus")
                        Text("收入")
                    }
                    .frame(width:geometry.size.width / 2,
                           height: geometry.size.height / 12)
                }
                .frame(width:geometry.size.width / 2,
                       height: geometry.size.height / 12)
                ZStack{
                    if self.selectedSegment == 1 {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.secondary)
                            .opacity(0.7)
                    }
                    Button(action: {
                        self.selectedSegment = 1
                    }) {
                        Image(systemName: "bag.badge.minus")
                        Text("支出")
                    }
                    .frame(width:geometry.size.width / 2,
                           height: geometry.size.height / 12)
                }
                .frame(width:geometry.size.width / 2,
                       height: geometry.size.height / 12)
            }
            ScrollView{
                // 控制两边距离
                if (hasMoneyIn){
                    HStack{
                        Spacer(minLength: geometry.size.width / 20)
                        VStack{
                            Spacer(minLength: geometry.size.height / 15)
                          
                            if (selectedSegment == 0){
                                PieChartView(data: pieAmountMoneyIn,
                                             labels: ["工资", "兼职", "投资", "奖金",
                                                      "礼金", "提成", "退款", "其他"],
                                             title: "收入构成",
                                             form: ChartForm.extraLarge)
                            }
                            else{
                                PieChartView(data: pieAmountMoneyOut,
                                             labels: ["餐饮", "日用", "交通", "娱乐",
                                                      "教育", "礼物", "健康", "其他"],
                                             title: "支出构成",
                                             form: ChartForm.extraLarge)
                            }
                            
                            Spacer(minLength: geometry.size.width / 12)
                            
                            if(selectedSegment == 0){
                                BarChartView(
                                    data: ChartData(values: chartAmountMoneyIn),
                                    title: "当月收入情况",
                                    form: ChartForm.extraLarge)
                            }
                            else{
                                BarChartView(
                                    data: ChartData(values: chartAmountMoneyOut),
                                    title: "当月支出情况",
                                    form: ChartForm.extraLarge)
                            }
                            
                            Spacer(minLength: geometry.size.width / 12)
                            
                            ChangeStatistics(monthBill: monthBill, selectedSegment: selectedSegment)
                            
                            Spacer(minLength: geometry.size.width / 12)
                        }
                        Spacer(minLength: geometry.size.width / 20)
                    }
                }
                else{
                    Section{
                        Text("本月无收入")
                    }
                }
            }
        }

    }
}

/**
 变化趋势
 */
struct ChangeStatistics: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    @Environment(\.managedObjectContext)
    var context
    
    public var darkModeStyle: ChartStyle
    public var formSize:CGSize
    
    public var style: ChartStyle
    public var dropShadow: Bool = true
    
    private var monthBill: EmojiBillViewModel
    
    private var selectedSegment: Int
    
    var isFullWidth:Bool {
        return self.formSize == ChartForm.large
    }
    
    init(monthBill: EmojiBillViewModel, selectedSegment: Int = 0, dropShadow: Bool = true, form: CGSize? = ChartForm.extraLarge){
        self.style = Styles.barChartStyleOrangeLight
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        self.dropShadow = dropShadow
        self.formSize = form!
        
        self.monthBill = monthBill
        self.selectedSegment = selectedSegment
        
    }
    
    var maxAmount: Double {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.type, ascending: false)]
        
        print(monthBill.year)
        
      
        var maxAmount: Double = 0
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if (selectedSegment == 0){
                    if (isBillIn){
                        
                        let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                        
                        if (amount > maxAmount){
                            maxAmount = amount
                        }
                        
                    }
                }
                else{
                    if (!isBillIn){
                        
                        let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                        
                        if (amount > maxAmount){
                            maxAmount = amount
                        }
                        
                    }
                }
                
            }
            
            
            return maxAmount
        }
        catch{
            print(error)
            return 0
        }
    }
    
    var aveAmount: Double {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "year == %@ and month == %@ ", monthBill.year , monthBill.month)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BillPoint.type, ascending: false)]
        print(monthBill.year)
      
        var maxAmount: Double = 0
        var billCount: Int = 0
        
        do {
            let test = try context.fetch(fetchRequest)
            for i in 0..<test.count {
                let taskUpdate = test[i] as! NSManagedObject
                
                let isBillIn: Bool = (taskUpdate.value(forKey: "inOrOut") ?? false) as! Bool
                
                if(selectedSegment == 0){
                    if (isBillIn){
                        
                        let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                        
                        maxAmount += amount
                        billCount += 1
                    }
                }
                else{
                    if (!isBillIn){
                        
                        let amount: Double = (taskUpdate.value(forKey: "amount") ?? 0) as! Double
                        
                        maxAmount += amount
                        billCount += 1
                    }
                }
                
            }
            let curMonth: Int = ( (Int(monthBill.month)) ?? 1)
            
            if (curMonth == 1 || curMonth == 3
                || curMonth == 5 || curMonth == 7
                || curMonth == 8 || curMonth == 10
                || curMonth == 12){
                return maxAmount / 31
            }
            else if (curMonth == 2){
                return maxAmount / 28
            }
            else{
                return maxAmount / 30
            }
            
        }
        catch{
            print(error)
            return 0
        }
    }
    
    var body: some View{
        ZStack{
            Rectangle()
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .cornerRadius(20)
                .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
            
            VStack(alignment: .leading){
                HStack{
                    Text("变化趋势")
                        .font(.headline)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    Spacer()
                    Image(systemName: "bolt.horizontal.fill")
                        .imageScale(.large)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                }.padding()
                HStack{
                    VStack{
                        if(selectedSegment == 0){
                            Text("单笔最高收入")
                                .font(.headline)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : .secondary)
                        }
                        else{
                            Text("单笔最高支出")
                                .font(.headline)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : .secondary)
                        }
                        Text("\(String(format: "%.2f", maxAmount))")
                            .font(.title3)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        
                    }
                    Spacer()
                    VStack{
                        if(selectedSegment == 0){
                            Text("日均收入")
                                .font(.headline)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : .secondary)
                        }
                        else{
                            Text("日均支出")
                                .font(.headline)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : .secondary)
                        }
                        Text("\(String(format: "%.2f", aveAmount))")
                            .font(.title3)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        
                    }
                }
                .padding(.horizontal)
                Spacer(minLength: 20)
            }
        }.frame(minWidth:self.formSize.width,
                maxWidth: self.isFullWidth ? .infinity : self.formSize.width)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

