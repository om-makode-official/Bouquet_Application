//
//  LoginScreenBuilder.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import UIKit
import SwiftUI

class LoginScreenBuilder{
    func createModule(openHomeScreen: @escaping() -> Void) -> UIViewController{
        let authentication = PhoneAuthService()
        let router = LoginScreenRouter(openHomeScreen: openHomeScreen)
        let presenter = LoginScreenPresenter(router: router, authentication: authentication)
        let view = LoginScreenView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
