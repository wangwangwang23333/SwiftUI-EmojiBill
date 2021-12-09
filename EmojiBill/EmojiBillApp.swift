//
//  EmojiBillApp.swift
//  EmojiBill
//
//  Created by 汪明杰 on 2021/10/28.
//

import SwiftUI

@main
struct EmojiBillApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
