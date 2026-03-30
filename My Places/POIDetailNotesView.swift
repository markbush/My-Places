//
//  POIDetailNotesView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI

struct POIDetailNotesView: View {
  @Bindable var poi: PointOfInterest
  
  var body: some View {
    Section("Notes") {
      TextField("Note", text: Binding(
        get: { poi.note ?? "" },
        set: { poi.note = $0.isEmpty ? nil : $0 }
      ), axis: .vertical)
      .lineLimit(5...10)
    }
  }
}

