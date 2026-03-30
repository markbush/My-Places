//
//  POIDetailView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import SwiftData

struct POIDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var poi: PointOfInterest
  
  var body: some View {
    Form {
      POIDetailImageView(poi: poi)
      POIDetailBasicInfoView(poi: poi)
      POIDetailLocationView(poi: poi)
      
      Section("Notes") {
        TextField("Note", text: Binding(
          get: { poi.note ?? "" },
          set: { poi.note = $0.isEmpty ? nil : $0 }
        ), axis: .vertical)
        .lineLimit(5...10)
      }
      
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
    .navigationTitle(poi.name)
  }
}

//#Preview {
//    POIDetailView()
//}

