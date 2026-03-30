//
//  PointOfInterest.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class PointOfInterest {
  @Attribute(.unique) var name: String
  var type: PlaceType?
  var list: PlaceList
  
  var latitude: Double?
  var longitude: Double?
  
  @Attribute(.externalStorage) var imageData: Data?
  var lastVisited: Date?
  var note: String?
  
  var coordinate: CLLocationCoordinate2D? {
    if let latitude = latitude, let longitude = longitude {
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    return nil
  }
  
  init(name: String, type: PlaceType? = nil, list: PlaceList) {
    self.name = name
    self.type = type
    self.list = list
  }
}

