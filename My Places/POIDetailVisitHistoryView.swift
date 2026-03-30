//
//  POIDetailVisitHistoryView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI

struct POIDetailVisitHistoryView: View {
  @Bindable var poi: PointOfInterest
  
  var body: some View {
    Section("Visit History") {
      DatePicker("Last Visited", selection: Binding(
        get: { poi.lastVisited ?? .now },
        set: { poi.lastVisited = $0 }
      ), displayedComponents: .date)
      
      if poi.lastVisited != nil {
        Button("Clear Visit Date", role: .destructive) {
          poi.lastVisited = nil
        }
      } else {
        Button("Mark as Visited") {
          poi.lastVisited = .now
        }
      }
    }
  }
}

