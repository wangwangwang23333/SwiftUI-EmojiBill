//
//  UserInfoView.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/22.
//

import SwiftUI
import CoreData

struct UserInfoView: View {
    
    @Environment(\.managedObjectContext)
    var context
    
    @State
    var deleteAllAlert: Bool = false
    
    @State
    var emoji: Emoji = Emoji.random()
    
    var monthBill: EmojiBillViewModel
    
    func deleteAllBill(){
        print("清除所有数据！")
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "BillPoint")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do {
            try context.execute(DelAllReqVar)
    
            exit(0)
        }
        catch {
            print(error)
            
        }
        
        
    }
    
    var body: some View {
        Form{
            Section{
                HStack{
                    Text(emoji.character)
                    Text(emoji.description)
                }
            }
            .onTapGesture {
                emoji = Emoji.random()
            }
            
            Section{
                HStack{
                    Image(systemName: "person")
                    Text("用户")
                }
                
                
            }
         
            Section{
//                NavigationLink(destination: BillLocationView()){
//                    HStack{
//                        Image(systemName: "text.book.closed")
//                        Text("年度账单")
//                    }
//                }
                
                HStack{
                    Image(systemName: "trash.fill")
                    Text("清除数据")
                }
                .onTapGesture {
                    deleteAllAlert = true
                }
                .foregroundColor(Color.primary)
                .alert(isPresented: $deleteAllAlert) {
                    Alert(title: Text("账单"),
                          message: Text("确认删除所有数据吗？\n警告：不可恢复，清理完成后将会自动关闭"),
                          primaryButton: .default(Text("确认").foregroundColor(.red),
                                                  action: {
                        deleteAllBill()
                    }),
                          secondaryButton: .default(Text("取消"))
                    )
                }
                
                HStack{
                    Image(systemName: "wrench")
                    Text("待开发")
                }
            }
        }
    }
}

