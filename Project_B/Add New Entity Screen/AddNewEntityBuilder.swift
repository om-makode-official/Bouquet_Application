//
//  AddNewEntityBuilder.swift
//  Project_B
//
//  Created by Om on 5/28/26.
//

import Foundation
import UIKit
import SwiftUI

class AddNewEntityBuilder{
    func createModule(navigateToPreviousScreen: @escaping () -> Void, resortEntity: HallResponseModel?, refreshDelegate: RefreshDataProtocol, identifier: String, bouquetEntity: BouquetDetailsEntity?) -> UIViewController{
        let router = AddNewEntityRouter(navigateToPreviousScreen: navigateToPreviousScreen)
        let interactor = AddNewEntityInteractor()
        let presenter = AddNewEntityPresenter(interactor: interactor, router: router, resortEntity: resortEntity, identifier: identifier, bouquetEntity: bouquetEntity)
        presenter.refreshDelegate = refreshDelegate
        let view = AddNewEntityView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
