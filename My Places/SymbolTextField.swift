//
//  SymbolTextField.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import UIKit

// A custom UITextField subclass that specifically requests the emoji keyboard
class EmojiTextField: UITextField {
  override open var textInputMode: UITextInputMode? {
    for mode in UITextInputMode.activeInputModes {
      if mode.primaryLanguage == "emoji" {
        return mode
      }
    }
    return super.textInputMode
  }
}

struct SymbolTextField: UIViewRepresentable {
  var placeholder: String
  @Binding var text: String
  
  func makeUIView(context: Context) -> EmojiTextField {
    let textField = EmojiTextField()
    textField.placeholder = placeholder
    textField.delegate = context.coordinator
    textField.textAlignment = .left
    return textField
  }
  
  func updateUIView(_ uiView: EmojiTextField, context: Context) {
    uiView.text = text
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: SymbolTextField
    
    init(_ parent: SymbolTextField) {
      self.parent = parent
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
      DispatchQueue.main.async {
        self.parent.text = textField.text ?? ""
      }
    }
  }
}

extension String {
  var isSingleEmoji: Bool {
    guard count == 1, let character = first else { return false }
    return character.isEmoji
  }
}

extension Character {
  var isEmoji: Bool {
    guard let scalar = unicodeScalars.first else { return false }
    return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
  }
}

