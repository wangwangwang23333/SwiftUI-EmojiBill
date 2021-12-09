//
//  EmojiBillViewModel.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/21.
//

import Foundation
import SwiftUI
import CoreData

class EmojiBillViewModel: ObservableObject {
    
    private static func createEmojiBillModel() -> EmojiBillModel {
        EmojiBillModel()
    }
    
    @Published private var model = createEmojiBillModel()
    
    func changeMonth(year: String, month: String){
        self.model.changeDate(year: year, month: month)
    }

    
    var month: String{
        model.month
    }
    
    var year: String{
        model.year
    }
    

}
