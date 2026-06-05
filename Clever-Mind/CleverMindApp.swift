//
//  CleverMindApp.swift
//  CleverMind
//
//  Created by Heydon Costello on 03/11/2022.
//

import SwiftUI

@main
struct CleverMindApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(nodeRepository: NodeCoreDataRepository(moc: dataController.container.viewContext)).environment(\.managedObjectContext, dataController.container.viewContext)
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 800)
        #endif
    }
}
