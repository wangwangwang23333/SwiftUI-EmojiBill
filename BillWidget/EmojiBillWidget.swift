//
//  EmojiBillWidget.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/11/20.
//

import SwiftUI
import WidgetKit

struct EmojiBillWidget: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    let emoji: Emoji
    let moneyIn: Double
    
    @ViewBuilder
    var body: some View {
      ZStack {
        Color(UIColor.random)
        
        switch family {
        case .systemSmall:
          SmallEmojiWidgetView(emoji: emoji, moneyIn: moneyIn)
        case .systemMedium:
          MediumEmojiWidgetView(emoji: emoji, moneyIn: moneyIn)
//        case .systemLarge:
//          EmptyView()
        default:
          EmptyView()
        }
      }
    }
}


struct SmallEmojiWidgetView: View {
  let emoji: Emoji
    let moneyIn: Double
    
  var body: some View {
    VStack {
        
//        HStack{
//            // 点击记账
//            Image(systemName: "square.and.pencil")
//                .resizable()
//                .frame(width: 20, height: 20)
//                .widgetURL(URL(string: "sss"))
//            VStack{
//                Text("收入：\(String(format: "%.2f", MonthBill.moneyIn))")
//                      .font(.callout)
//                  .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                  .padding([.leading, .trailing])
//                  .foregroundColor(.white)
//                  .lineLimit(1)
//                Text("支出：\(String(format: "%.2f", MonthBill.moneyOut))")
//                      .font(.callout)
//                  .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                  .padding([.leading, .trailing])
//                  .foregroundColor(.white)
//                  .lineLimit(1)
//        }
//            }
            
        }
        
        HStack{
            Text(emoji.character)
              .font(.system(size: 50))
            Text(emoji.description)
                .font(.system(size: 11))
                .foregroundColor(.white)
                .lineLimit(2)
        }

    }
  }


struct MediumEmojiWidgetView: View {
  let emoji: Emoji
    let moneyIn: Double
  
  var body: some View {
    VStack {
      SmallEmojiWidgetView(emoji: emoji, moneyIn: moneyIn)
        Text("赶紧进来记账了啦")
        .font(.body)
        .padding(.trailing, 5)
        .foregroundColor(.white)
    }.padding([.leading, .trailing])
  }
}


struct EmojiBillWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
          Color(UIColor.random)
            SmallEmojiWidgetView(emoji: Emoji.random(), moneyIn: 20.00)
        }
    }
}

struct MediumEmojiWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color(UIColor.random)
        MediumEmojiWidgetView(emoji: Emoji.random(), moneyIn: 20.00)
    }
  }
}

extension UIColor {
  static var random: UIColor {
    switch Int.random(in: 1..<8) {
    case 0:
      return UIColor.systemRed
    case 1:
      return UIColor.systemGreen
    case 2:
      return UIColor.systemBlue
    case 3:
      return UIColor.systemOrange
    case 4:
      return UIColor.systemYellow
    case 5:
      return UIColor.systemPink
    case 6:
      return UIColor.systemPurple
    case 7:
      return UIColor.systemTeal
    default:
      return UIColor.systemIndigo
    }
  }
}
