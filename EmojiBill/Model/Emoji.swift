//
//  Emoji.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/20.
//

import Foundation
import SwiftUI
import CoreData

struct Emoji: Identifiable{
    let character: String
    let description: String
    
    var id: String{character}
    
    init(character: String, description: String){
        self.character = character
        self.description = description
    }
    
    /**
     Emoji集合
     */
    static func collections() -> [Emoji] {
        return [
            Emoji(
              character: "😅",
              description: "只要你不尴尬，尴尬的就是别人"
            ),
            Emoji(
              character: "😄",
              description: "我的💦呢？哦，刚刚卖了还没记账"
            ),
            Emoji(
              character: "😓",
              description: "再乱花钱，这个月就又没有余额咯"
            ),
            Emoji(
              character: "🐭",
              description: "哪怕是嘉定🐭🐭，也要存好每一笔"
            ),
            Emoji(
              character: "🥵",
              description: "烧死自己，也要记下柴火费"
            ),
            Emoji(
              character: "🥺",
              description: "施舍我点💰吧"
            ),
            Emoji(
              character: "🧊",
              description: "不存钱的人有🧊🧊"
            ),
            Emoji(
              character: "🌈",
              description: "风雨之后总有🌈"
            ),
            Emoji(
              character: "🐶",
              description: "不记账是🐶哈"
            ),
            Emoji(
              character: "🤡",
              description: "与其做🤡，不如做自己的超人"
            ),
        ]
    }
    
    /**
     随机返回一个Emoji
     */
    static func random() -> Emoji {
        let emojis = Emoji.collections()
        return emojis[Int.random(in: 0..<emojis.count)]
    }
    
    static func getMoneyIn() -> Double {
        print("sorry")
        let curDate = Date()
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: curDate)
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: curDate)
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: curDate)
        
        let fetchRequest: FetchRequest<BillPoint> = FetchRequest(
            entity: BillPoint.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \BillPoint.time, ascending: false)],
            predicate: NSPredicate(format: "year == %@ and month == %@ and day == %@ and inOrOut == %@", year, month, day, true),
            animation: .default)
        
        var Sums: Double = 0
        
        for i in 0..<fetchRequest.wrappedValue.count{
            Sums += fetchRequest.wrappedValue[fetchRequest.wrappedValue.index(fetchRequest.wrappedValue.startIndex, offsetBy: i)].amount
        }
        
        return Sums

    }
    
    static func getMoneyOut() -> Double {
        return 0
    }
}
