//
//  My_PlacesTests.swift
//  My PlacesTests
//
//  Created by Mark Bush on 28/03/2026.
//

import XCTest
import SwiftData
@testable import My_Places

final class My_PlacesTests: XCTestCase {
  
  var modelContext: ModelContext!
  var container: ModelContainer!
  
  override func setUpWithError() throws {
    let schema = Schema([
      PointOfInterest.self,
      PlaceList.self,
      PlaceType.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    modelContext = ModelContext(container)
    
    // Ensure defaults are created
    PlaceList.ensureDefaults(modelContext: modelContext)
  }
  
  override func tearDownWithError() throws {
    modelContext = nil
    container = nil
  }
  
  func testPlaceTypeDeletionMigration() throws {
    // Given: A custom place type and a POI using it
    let customType = PlaceType(name: "Museum", label: "🏛️")
    modelContext.insert(customType)
    
    let defaultListName = PlaceList.defaultListName
    let listDescriptor = FetchDescriptor<PlaceList>(predicate: #Predicate { $0.name == defaultListName })
    let defaultList = try modelContext.fetch(listDescriptor).first!
    
    let poi = PointOfInterest(name: "British Museum", type: customType, list: defaultList)
    modelContext.insert(poi)
    
    try modelContext.save()
    
    // When: The custom place type is deleted
    // We need to simulate the deleteType logic in the view
    let defaultTypeName = PlaceType.defaultTypeName
    let typeDescriptor = FetchDescriptor<PlaceType>(predicate: #Predicate { $0.name == defaultTypeName })
    let defaultType = try modelContext.fetch(typeDescriptor).first!
    
    for poi in customType.pois {
      poi.type = defaultType
    }
    modelContext.delete(customType)
    try modelContext.save()
    
    // Then: The POI's type should now be the default "POI" type
    let poiDescriptor = FetchDescriptor<PointOfInterest>(predicate: #Predicate { $0.name == "British Museum" })
    let fetchedPOI = try modelContext.fetch(poiDescriptor).first!
    
    XCTAssertEqual(fetchedPOI.type?.name, PlaceType.defaultTypeName)
  }
}

