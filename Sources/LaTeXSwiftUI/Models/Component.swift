//
//  Component.swift
//  LaTeXSwiftUI
//
//  Copyright (c) 2023 Colin Campbell
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation
import MathJaxSwift
import SwiftUI

/// A block of components.
public struct ComponentBlock: Hashable, Identifiable {

  /// The component's identifier.
  ///
  /// Unique to every instance.
  public let id = UUID()
  
  /// The block's components.
  let components: [Component]
  
  /// True iff this block has only one component and that component is
  /// not inline.
  var isEquationBlock: Bool {
    components.count == 1 && !components[0].type.inline
  }
  
}

/// A LaTeX component.
public struct Component: CustomStringConvertible, Equatable, Hashable {

  /// A LaTeX component type.
  enum ComponentType: String, Equatable, CustomStringConvertible {
    
    /// A text component.
    case text
    
    /// An inline equation component.
    ///
    /// - Example: `$x^2$`
    case inlineEquation
    
    /// A TeX-style block equation.
    ///
    /// - Example: `$$x^2$$`.
    case texEquation
    
    /// A block equation.
    ///
    /// - Example: `\[x^2\]`
    case blockEquation
    
    /// A named equation component.
    ///
    /// - Example: `\begin{equation}x^2\end{equation}`
    case namedEquation
    
    /// A named equation component.
    ///
    /// - Example: `\begin{equation*}x^2\end{equation*}`
    case namedNoNumberEquation
    
    /// The component's description.
    var description: String {
      rawValue
    }
    
    /// The component's left terminator.
    var leftTerminator: String {
      switch self {
      case .text: return ""
      case .inlineEquation: return "$"
      case .texEquation: return "$$"
      case .blockEquation: return "\\["
      case .namedEquation: return "\\begin{equation}"
      case .namedNoNumberEquation: return "\\begin{equation*}"
      }
    }
    
    /// The component's right terminator.
    var rightTerminator: String {
      switch self {
      case .text: return ""
      case .inlineEquation: return "$"
      case .texEquation: return "$$"
      case .blockEquation: return "\\]"
      case .namedEquation: return "\\end{equation}"
      case .namedNoNumberEquation: return "\\end{equation*}"
      }
    }
    
    /// Whether or not this component is inline.
    var inline: Bool {
      switch self {
      case .text, .inlineEquation: return true
      default: return false
      }
    }
    
    /// True iff the component is not `text`.
    var isEquation: Bool {
      return self != .text
    }
  }
  
  /// The component's inner text.
  let text: String
  
  /// The component's type.
  let type: ComponentType
  
  /// The component's SVG image.
  let svg: SVG?
  
  /// The original input text that created this component.
  var originalText: String {
    "\(type.leftTerminator)\(text)\(type.rightTerminator)"
  }
  
  /// The component's original text with newlines trimmed.
  var originalTextTrimmingNewlines: String {
    originalText.trimmingCharacters(in: .newlines)
  }
  
  /// The component's conversion options.
  var conversionOptions: ConversionOptions {
    ConversionOptions(display: !type.inline)
  }
  
  /// The component's description.
  public var description: String {
    return "(\(type), \"\(text)\")"
  }
  
  // MARK: Initializers
  
  /// Initializes a component.
  ///
  /// The text passed to the component is stripped of the left and right
  /// terminators defined in the component's type.
  ///
  /// - Parameters:
  ///   - text: The component's text.
  ///   - type: The component's type.
  ///   - svg: The rendered SVG (only applies to equations).
  init(text: String, type: ComponentType, svg: SVG? = nil) {
    if type.isEquation {
      var text = text
      if text.hasPrefix(type.leftTerminator) {
        text = String(text[text.index(text.startIndex, offsetBy: type.leftTerminator.count)...])
      }
      if text.hasSuffix(type.rightTerminator) {
        text = String(text[..<text.index(text.endIndex, offsetBy: -type.rightTerminator.count)])
      }
      self.text = text
    }
    else {
      self.text = text
    }
    
    self.type = type
    self.svg = svg
  }
  
}
