//
//  EmojiBillModel.swift
//  EmojiBill
//
//  Created by Jwy John on 2021/11/18.
//

import Foundation
import CoreData
import SwiftUI

struct EmojiBillModel{
    
    
  
    
    var year: String
    var month: String

    
    init(){
        self.year = "2021"
        self.month = "11"
        
        
    }
    
    mutating func changeDate(year: String, month: String){
        self.year = year
        self.month = month
    }
   
    
  
}
