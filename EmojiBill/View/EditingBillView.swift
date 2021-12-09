//
//  EditingBillView.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/18.
//

import SwiftUI
import CoreData

struct EditingBillView: View {
    
    @Environment(\.managedObjectContext)
    var context
    
    
    
    
    var geometry: GeometryProxy
    @State var amount: Decimal? = 0.00
    @State var selectedClass: Int
    @State var selectedOccasion: Int = 0
    @State var billRemark: String = ""
    @State var billDate: Date = Date()
    
    @State private var showingSuccess: Bool = false
    @State private var showingDelete: Bool = false
    
    @State
    private var isEditing: Bool = false
    
    private var monthBill: EmojiBillViewModel

    var id: NSUUID
    
    init(geometry: GeometryProxy, monthBill: EmojiBillViewModel,
         selectedClass: Int = 0, isEditing: Bool = false, id: NSUUID = NSUUID(),
         selectedOccasion: Int = 0, amount: Double = 0, remark: String = "",
         year: String = "2021", month: String = "11", day: String = "21"){
        self._selectedClass = State(initialValue: selectedClass)
        self.geometry = geometry
        self.monthBill = monthBill
        
        self._isEditing = State(initialValue: isEditing)
        self.id = id
        // 如果是为编辑状态
        if(isEditing){
            self._selectedOccasion = State(initialValue: selectedOccasion)
            self._amount = State(initialValue: Decimal(amount))
            self._billRemark = State(initialValue: remark)
            
            // 时间的转换
            let dateformatter = DateFormatter()
            let curTime = "\(year)-\(month)-\(day) 10:00:00"
            dateformatter.dateFormat="yyyy-MM-dd HH:mm:ss"

            self._billDate = State(initialValue: dateformatter.date(from: curTime)!)

         
        }
    }
    

    static let billTypeOption: [String] =
        ["收入","支出"]
    
    // 收入的展示
    static let billOccasionsIn =
        ["工资", "兼职", "投资", "奖金",
         "礼金", "提成", "退款", "其他"]
    
    static let billOccasionImageIn: [String] =
        ["dollarsign.circle.fill", "person.3.fill", "creditcard.fill", "banknote.fill",
         "giftcard.fill", "rectangle.stack.fill.badge.person.crop", "trash.slash.fill", "wallet.pass.fill"]
    
    // 支出的展示
    static let billOccasionsOut =
        ["餐饮", "日用", "交通", "娱乐",
         "教育", "礼物", "健康", "其他"]
    
    static let billOccasionImageOut: [String] =
        ["lungs.fill", "scissors", "car.fill", "tv.music.note.fill",
         "books.vertical.fill", "gift.fill", "cross.case.fill", "wallet.pass.fill"]
    
    static var currencyFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.isLenient = true
        return nf
    }
    
    func addBillPoint(){
        let newBillPoint = BillPoint(context: context)
        newBillPoint.id = UUID()
        newBillPoint.inOrOut = self.selectedClass == 0
        newBillPoint.amount = Double(truncating: self.amount! as NSNumber)
        
        // 时间的存储
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy"
        newBillPoint.year = dateFormatter.string(from: self.billDate)
        dateFormatter.dateFormat = "MM"
        newBillPoint.month = dateFormatter.string(from: self.billDate)
        dateFormatter.dateFormat = "dd"
        newBillPoint.day = dateFormatter.string(from: self.billDate)
        dateFormatter.dateFormat = "HH:mm"
        newBillPoint.time = dateFormatter.string(from: self.billDate)
        
        
        newBillPoint.remark = self.billRemark
        newBillPoint.type = Int32(self.selectedOccasion)
        
        // 存数据
        do {
            try context.save()
            print("成功存储数据")
        } catch {
            print(error)
        }
        
        // 时间的存储
        let curDate = Date()

        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: curDate)
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: curDate)

        
        monthBill.changeMonth(year: year, month: month)
    }
    
    func updatePoint(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let test = try context.fetch(fetchRequest)
            let taskUpdate = test[0] as! NSManagedObject
            
            // 时间更新
            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: self.billDate)
            dateFormatter.dateFormat = "MM"
            let month = dateFormatter.string(from: self.billDate)
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: self.billDate)
            
            // 时间采用当前时间
            let curDate = Date()
            
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.string(from: curDate)
            
            taskUpdate.setValue(year, forKey: "year")
            taskUpdate.setValue(month, forKey: "month")
            taskUpdate.setValue(day, forKey: "day")
            taskUpdate.setValue(time, forKey: "time")
            
            

            // 收入亦或支出
            taskUpdate.setValue(self.selectedClass == 0, forKey: "inOrOut")
            
            // 金额
            taskUpdate.setValue(Double(truncating: self.amount! as NSNumber), forKey: "amount")
            
            // 备注
            taskUpdate.setValue(self.billRemark, forKey: "remark")
                                
            // 种类
            taskUpdate.setValue(Int32(self.selectedOccasion), forKey: "type")
           
            
        } catch {
            print(error)
        }
    }
    
    func deletePoint(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        
        do {
            let test = try context.fetch(fetchRequest)
            let taskDelete = test[0] as! NSManagedObject
            context.delete(taskDelete)
        }
        catch{
            print(error)
        }
        
        //最后更新成当前时间
        self.billDate = Date()
        self.isEditing = false
        self.amount = Decimal(0)
        self.billRemark = ""
        self.selectedClass = 0
        self.selectedOccasion = 0
    }
    
    var body: some View {
        VStack(alignment:.leading){
            Form {
                Section(
                    header:Text("金额")
                ) {
                    DecimalField("Amount", value: $amount, formatter: Self.currencyFormatter)
                }
                Section(header:Text("类别")){
                   Picker("选择类别",selection: $selectedClass){
                       ForEach(0..<EditingBillView.billTypeOption.count){
                           Text(EditingBillView.billTypeOption[$0])
                       }
                   }
                   .pickerStyle(SegmentedPickerStyle())
               }
                Section(
                    header:Text("账单类型")
                ){
                    VStack{
                        HStack{
                            ForEach(0..<4){
                                if (selectedClass == 0){
                                    TextButton(
                                        buttonIndex: $0,
                                        buttonText: EditingBillView.billOccasionsIn[$0],
                                        buttonImage: EditingBillView.billOccasionImageIn[$0],
                                        buttonWidth: 70,
                                        geometry: geometry,
                                        selectedClass: $selectedClass,
                                        selectedIndex: $selectedOccasion
                                    )
                                }
                                else{
                                    TextButton(
                                        buttonIndex: $0,
                                        buttonText: EditingBillView.billOccasionsOut[$0],
                                        buttonImage: EditingBillView.billOccasionImageOut[$0],
                                        buttonWidth: 70,
                                        geometry: geometry,
                                        selectedClass: $selectedClass,
                                        selectedIndex: $selectedOccasion
                                    )
                                }
                            }
                        }
                        Spacer(minLength: geometry.size.height / 25)
                        HStack{
                            ForEach(4..<8){
                                if (selectedClass == 0){
                                    TextButton(
                                        buttonIndex: $0,
                                        buttonText: EditingBillView.billOccasionsIn[$0],
                                        buttonImage: EditingBillView.billOccasionImageIn[$0],
                                        buttonWidth: 70,
                                        geometry: geometry,
                                        selectedClass: $selectedClass,
                                        selectedIndex: $selectedOccasion
                                    )
                                }
                                else{
                                    TextButton(
                                        buttonIndex: $0,
                                        buttonText: EditingBillView.billOccasionsOut[$0],
                                        buttonImage: EditingBillView.billOccasionImageOut[$0],
                                        buttonWidth: 70,
                                        geometry: geometry,
                                        selectedClass: $selectedClass,
                                        selectedIndex: $selectedOccasion
                                    )
                                }
                            }
                        }
                    }
                }
                
                // 时间
                Section(header: Text("时间")){
                    DatePicker("请选择日期",
                               selection: $billDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .labelsHidden()
                        
                }
                
//                // 地理位置
//                Section(header: Text("位置")){
//                    NavigationLink(destination: BillLocationView()){
//                        Text("点击选择定位")
//                    }
//                }
                
                // 备注
                Section(header: Text("备注")){
                    HStack{
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        TextField("",text: $billRemark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // 确认键
                HStack{
                    Spacer()
                    if (isEditing){
                        Button(
                            action: {
                                self.showingSuccess = true
                                if (self.amount != 0){
                                    self.updatePoint()
                                }
                                else{
                                    self.showingSuccess = true
                                }
                            },
                            label: {
                                Text("修改")
                            }
                        )
                            .foregroundColor(Color.primary)
                            .alert(isPresented: $showingSuccess) {
                                if (self.amount ?? 0 <= 0){
                                    return Alert(title: Text("账单"),
                                          message: Text("金额不能为非正数😅"),
                                          dismissButton: .default(Text("确认")))
                                }
                                else{
                                    return Alert(title: Text("账单"),
                                          message: Text("成功修改！"),
                                          dismissButton: .default(Text("确认"),
                                                                  action: {
                                    })
                                                
                                    )
                                }
                            }
                    }
                    else{
                        Button(
                            action: {
                                self.showingSuccess = true
                                if (self.amount != 0){
                                    self.addBillPoint()
                                }
                                else{
                                    self.showingSuccess = true
                                }
                            },
                            label: {
                                Text("确认")
                            }
                        )
                            .foregroundColor(Color.primary)
                            .alert(isPresented: $showingSuccess) {
                                if (self.amount ?? 0 <= 0){
                                    return Alert(title: Text("账单"),
                                          message: Text("金额不能为非正数😅"),
                                          dismissButton: .default(Text("确认")))
                                }
                                else{
                                    return Alert(title: Text("账单"),
                                          message: Text("成功记账！"),
                                          dismissButton: .default(Text("确认"),
                                                                  action: {
                                    })
                                                
                                    )
                                }
                            }
                    }
                        
                    Spacer()
                }
            
                //删除键
                if (isEditing){
                    HStack{
                        Spacer()
                        Button(
                            action: {
                                self.showingDelete = true
                                self.deletePoint()
                            },
                            label: {
                                Text("删除")
                            }
                        )
                            .foregroundColor(Color.primary)
                            .alert(isPresented: $showingDelete) {
                                Alert(title: Text("账单"),
                                      message: Text("成功删除！"),
                                      dismissButton: .default(Text("确认"))
                                      )
                            }
                        Spacer()
                    }
                }
                
            }

        }
        
    }
    
}

struct TextButton: View {
    
    var buttonIndex: Int
    var buttonText: String
    var buttonImage: String
    let buttonWidth: CGFloat
    var geometry: GeometryProxy
    @Binding var selectedClass: Int
    @Binding var selectedIndex: Int
    
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
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
                    if selectedIndex == buttonIndex {
                        if selectedClass == 0{
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
                    }
                    else{
                        Circle()
                            .foregroundColor(Color.gray)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
                            .frame(width: 40, height: 40)
                            .opacity(0.3)
                    }
                    Image(systemName: buttonImage)
                }
                .frame(width: 40, height: 40)
                .onTapGesture {
                    self.selectedIndex = self.buttonIndex
                }
                
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(
                        self.colorScheme == .dark ? .white : .black
                    )
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

