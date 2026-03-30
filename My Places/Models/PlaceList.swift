//
//  PlaceList.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import Foundation
import SwiftData

@Model
final class PlaceList {
  static let defaultListName = "POI"
  @Attribute(.unique) var name: String
  var label: String
  
  @Relationship(deleteRule: .nullify, inverse: \PointOfInterest.list)
  var pois: [PointOfInterest] = []
  
  init(name: String, label: String) {
    self.name = name
    self.label = label
  }
  
  static func ensureDefaults(modelContext: ModelContext) {
    let defaultTypeName = PlaceType.defaultTypeName
    let defaultListName = PlaceList.defaultListName
    
    // Check for default type
    let typeDescriptor = FetchDescriptor<PlaceType>(predicate: #Predicate { $0.name == defaultTypeName })
    if let existingTypes = try? modelContext.fetch(typeDescriptor), existingTypes.isEmpty {
      let defaultType = PlaceType(name: defaultTypeName, label: "📍")
      modelContext.insert(defaultType)
      
      // Initial types
      modelContext.insert(PlaceType(name: "Restaurant", label: "🍴"))
      modelContext.insert(PlaceType(name: "Park", label: "🌳"))
      modelContext.insert(PlaceType(name: "Shop", label: "🛍️"))
      modelContext.insert(PlaceType(name: "Hotel", label: "🏨"))
    }
    
    // Check for default list
    let listDescriptor = FetchDescriptor<PlaceList>(predicate: #Predicate { $0.name == defaultListName })
    if let existingLists = try? modelContext.fetch(listDescriptor), existingLists.isEmpty {
      let defaultList = PlaceList(name: defaultListName, label: "📋")
      modelContext.insert(defaultList)
    }
    
    try? modelContext.save()
  }
}

