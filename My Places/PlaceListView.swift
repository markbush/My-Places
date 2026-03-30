//
//  PlaceListView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import SwiftData

struct PlaceListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \PlaceList.name) private var placeLists: [PlaceList]
  
  @State private var showingAddList = false
  @State private var editingList: PlaceList?
  
  @State private var listName = ""
  @State private var listLabel = "📋"
  @State private var showingDuplicateNameAlert = false
  
  var body: some View {
    List {
      ForEach(placeLists) { list in
        HStack {
          Text(list.label)
          Text(list.name)
          if list.name == PlaceList.defaultListName {
            Spacer()
            Text("Default")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .swipeActions {
          if list.name != PlaceList.defaultListName {
            Button(role: .destructive) {
              deleteList(list)
            } label: {
              Label("Delete", systemImage: "trash")
            }
            
            Button {
              editingList = list
              listName = list.name
              listLabel = list.label
              showingAddList = true
            } label: {
              Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
          }
        }
      }
    }
    .navigationTitle("Place Lists")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          editingList = nil
          listName = ""
          listLabel = "📋"
          showingAddList = true
        }) {
          Label("Add List", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $showingAddList) {
      NavigationStack {
        Form {
          TextField("Name", text: $listName)
          SymbolTextField(placeholder: "Symbol", text: $listLabel)
            .frame(height: 44)
            .onChange(of: listLabel) { _, newValue in
              if newValue.count > 1 {
                listLabel = String(newValue.prefix(1))
              }
            }
        }
        .navigationTitle(editingList == nil ? "New List" : "Edit List")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              showingAddList = false
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              saveList()
            }
            .disabled(listName.isEmpty || !listLabel.isSingleEmoji)
          }
        }
      }
    }
    .alert("Duplicate Name", isPresented: $showingDuplicateNameAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("A place list with this name already exists. Please choose a unique name.")
    }
  }
  
  private func saveList() {
    let name = listName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Validation: Check for unique name
    let fetchDescriptor = FetchDescriptor<PlaceList>(predicate: #Predicate { $0.name == name })
    if let existing = try? modelContext.fetch(fetchDescriptor), existing.contains(where: { $0.id != editingList?.id }) {
      showingDuplicateNameAlert = true
      return
    }
    
    if let editingList = editingList {
      editingList.name = name
      editingList.label = listLabel
    } else {
      let newList = PlaceList(name: name, label: listLabel)
      modelContext.insert(newList)
    }
    showingAddList = false
  }
  
  private func deleteList(_ list: PlaceList) {
    let defaultListName = PlaceList.defaultListName
    let listDescriptor = FetchDescriptor<PlaceList>(predicate: #Predicate { $0.name == defaultListName })
    guard let defaultList = (try? modelContext.fetch(listDescriptor))?.first else {
      return
    }
    
    // Move all POIs in this list to the default list
    for poi in list.pois {
      poi.list = defaultList
    }
    
    modelContext.delete(list)
  }
}

#Preview {
  NavigationStack {
    PlaceListView()
      .modelContainer(for: [PlaceList.self, PointOfInterest.self], inMemory: true)
  }
}

