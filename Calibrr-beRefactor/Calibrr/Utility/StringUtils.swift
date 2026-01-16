//
//  StringUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Optional where Wrapped == String {
    var notNil: String { return self ?? "" }
    var isNilOrEmpty: Bool {
        guard let self = self else { return true }

        return self.isEmpty
    }
}
