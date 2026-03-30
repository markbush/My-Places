//
//  POIDetailView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI

struct POIDetailView: View {
  @Bindable var poi: PointOfInterest
  
  var body: some View {
    Form {
      POIDetailImageView(poi: poi)
      POIDetailBasicInfoView(poi: poi)
      POIDetailLocationView(poi: poi)
      POIDetailNotesView(poi: poi)
      POIDetailVisitHistoryView(poi: poi)
    }
    .navigationTitle(poi.name)
  }
}

//#Preview {
//    POIDetailView()
//}

