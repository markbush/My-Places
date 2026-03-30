//
//  POIDetailImageView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI
import PhotosUI

struct POIDetailImageView: View {
  @Bindable var poi: PointOfInterest
  @State private var selectedItem: PhotosPickerItem?
  
  var body: some View {
    Section {
      if let imageData = poi.imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: .infinity)
          .listRowInsets(EdgeInsets())
      }
      
      PhotosPicker(selection: $selectedItem, matching: .images) {
        Label(poi.imageData == nil ? "Add Image" : "Change Image", systemImage: "photo")
      }
      
      if poi.imageData != nil {
        Button("Remove Image", role: .destructive) {
          poi.imageData = nil
          selectedItem = nil
        }
      }
    } header: {
      Text("Image")
    }
    .onChange(of: selectedItem) { _, newItem in
      Task {
        if let data = try? await newItem?.loadTransferable(type: Data.self) {
          poi.imageData = data
        }
      }
    }
  }
}

