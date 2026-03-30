//
//  PlaceType.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import Foundation
import SwiftData

@Model
final class PlaceType {
  static let defaultTypeName = "POI"
  @Attribute(.unique) var name: String
  var label: String
  
  @Relationship(deleteRule: .nullify, inverse: \PointOfInterest.type)
  var pois: [PointOfInterest] = []
  
  init(name: String, label: String) {
    self.name = name
    self.label = label
  }
}

