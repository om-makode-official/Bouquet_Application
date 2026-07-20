//
//  LanguageManager.swift
//  Project_B
//
//  Created by Om on 6/8/26.
//

import Foundation
import SwiftUI

final class LanguageManager: ObservableObject {

    static let shared = LanguageManager()

    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(
                selectedLanguage,
                forKey: "selectedLanguage"
            )
        }
    }

    private init() {

        selectedLanguage =
        UserDefaults.standard.string(
            forKey: "selectedLanguage"
        ) ?? "en"
    }
}

final class LocalizationManager {

    static let shared = LocalizationManager()

    private init() {}

    func localized(_ key: String) -> String {

        let language =
        UserDefaults.standard.string(
            forKey: "selectedLanguage"
        ) ?? "en"

        guard let path =
                Bundle.main.path(
                    forResource: language,
                    ofType: "lproj"
                ),

              let bundle =
                Bundle(path: path)

        else {

            return key
        }

        return NSLocalizedString(
            key,
            bundle: bundle,
            comment: ""
        )
    }
}
