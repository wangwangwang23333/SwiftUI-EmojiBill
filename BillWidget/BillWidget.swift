//
//  EmojiWidget.swift
//  EmojiWidget
//
//  Created by 汪明杰 on 2021/11/20.
//

import WidgetKit
import SwiftUI
import Intents


struct Provider: IntentTimelineProvider {

    
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(),
                    emoji: Emoji.random(), moneyIn: getCurMoneyIn())
    }

    //var moc = PersistenceController.shared.managedObjectContext
    
    
    var moneyIn: Double = 0
    
    init (){

        // TODO: 增加收支功能
        self.moneyIn = 0
    }
    
    
    // 获取当天收入
    private func getCurMoneyIn() -> Double {
        
        return moneyIn
    }
    
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, emoji: Emoji.random(), moneyIn: getCurMoneyIn())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration,
                                    emoji: Emoji.random(), moneyIn: getCurMoneyIn())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let emoji: Emoji
    let moneyIn: Double
}

struct EmojiWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        EmojiBillWidget(emoji: entry.emoji, moneyIn: entry.moneyIn)
    }
}

@main
struct EmojiWidget: Widget {
    let kind: String = "EmojiWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            EmojiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Emoji Bill")
        .description("我是一个emoji桌面组件，欢迎每天看我emo")
    }
}

struct EmojiWidget_Previews: PreviewProvider {
    static var previews: some View {
        EmojiWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), emoji: Emoji.random(), moneyIn: 20.0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}



