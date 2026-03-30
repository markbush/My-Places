//
//  My_PlacesApp.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import SwiftData

@main
struct My_PlacesApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      PointOfInterest.self,
      PlaceList.self,
      PlaceType.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}

