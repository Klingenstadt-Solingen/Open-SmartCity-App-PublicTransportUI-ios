//
//  SwiftUI.swift
//  OSCAPublicTransportUI
//
//  Created by Igor Dias on 27.09.23.
//

import Foundation
import SwiftUI

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}

public extension UIColor {
  var asSwiftUIColor: Color { Color(self) }
}

public extension UIFont {
    var asSwiftUIFont: Font {
        return Font.custom(self.fontName, size: self.pointSize)
    }
}

extension Color {
  public static func fromHex(_ hex: String, ifInvalid: UIColor = UIColor.red) -> Color {
    return Color(UIColor(hex: hex) ?? ifInvalid)
  }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
