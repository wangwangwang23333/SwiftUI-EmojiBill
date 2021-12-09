//
//  CoreDataTestView.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/18.
//

import SwiftUI
import CoreData

struct CoreDataTestView: View {
    @Environment(\.managedObjectContext)
    var moc
    @FetchRequest(
        entity: BillPoint.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BillPoint.time, ascending: true)],
        predicate: NSPredicate(format: "year == %@ and month == %@", "2021", "11"),
        animation: .default)
    var bills: FetchedResults<BillPoint>
    
    
    
    @State var year: String = "2021"
    @State var month: String = "12"
    
    var date: Date = Date()
    
    @ObservedObject
    var emojiModel: EmojiBillViewModel = EmojiBillViewModel()
   
    
    init(){
        _year = State(initialValue: "2021")
        _month = State(initialValue: "11")
        
        self.emojiModel = EmojiBillViewModel()
    }
    
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                
                DataView(year: "2021", month: month)
                Button(
                    action: {
                        self.month = "10"
                    },
                    label: {
                        Text("查看10月")
                    }
                )
                
                
            }
        }
        
    }
}

struct DataView: View {
    
    
    @State
    var year: String
    @State
    var month: String
    
    var fetchRequest: FetchRequest<BillPoint>
   
    
    init(year: String, month: String){
        _year = State(initialValue: year)
        _month = State(initialValue: month)
        
        self.fetchRequest = FetchRequest(
            entity: BillPoint.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \BillPoint.time, ascending: true)],
            predicate: NSPredicate(format: "year == %@ and month == %@", year, month),
            animation: .default)
    }
    
    @Environment(\.managedObjectContext)
    var context
    
    
    func test(id:NSUUID = NSUUID()){
        print("success")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BillPoint")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let test = try context.fetch(fetchRequest)
            let taskUpdate = test[0] as! NSManagedObject
            taskUpdate.setValue("20:00", forKey: "time")
        } catch {
            print(error)
        }
    }
    
    
    var body: some View {
        ForEach(0..<31){i in
            Text("\(i)日")
            ForEach(fetchRequest.wrappedValue){ item in
                if(item.day ?? "" == String (format:  "%02d" , i)){
                    HStack{
                        
                        Text(item.month ?? "")
                            .onTapGesture {
                                test(id: item.id! as NSUUID)
                            }
                        Text(item.day ?? "")
                            .onTapGesture {
                                test(id: item.id! as NSUUID)
                            }
                    }
                }
            }
        }
        
    }
}


struct CoreDataTestView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataTestView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
