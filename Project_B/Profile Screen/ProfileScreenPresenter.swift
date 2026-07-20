//
//  ProfileScreenPresenter.swift
//  Project_B
//
//  Created by Om on 6/3/26.
//

import Foundation
import UIKit
import FirebaseAuth
import SwiftUI
import PhotosUI

class ProfileScreenPresenter: ObservableObject {
    
    @Published var userName: String = ""
    @Published var mobileNumber: String = ""
    @Published var userAddress: String = ""
    @Published var emailID: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var selectedLanguage: AppLanguage = .en
    @Published var isLoading: Bool = false
    @Published var alertType: HomeScreenAlertEnum?
    @Published var showImagePickerView: Bool = false
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var originalProfileImagePath: String?
    @Published var showSaveButton = false

    var refreshDelegate: RefreshDataProtocol?
    
    var userDtoModel: UserDTO?
    
    let router: ProfileScreenRouterProtocol
    let interactor: ProfileScreenInteractorProtocol
    
    init(router: ProfileScreenRouterProtocol,interactor: ProfileScreenInteractorProtocol){
        self.router = router
        self.interactor = interactor
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
        Task{
            do{
                guard let userId = Auth.auth().currentUser?.uid else { return }
                let response = try await interactor.fetchUser(uid: userId)
                
                await MainActor.run{
                    self.userDtoModel = response
                    userName = response.name
                    mobileNumber = Auth.auth().currentUser?.phoneNumber ?? "9999999999"
                    userAddress = response.address ?? ""
                    emailID = response.email ?? ""
                    originalProfileImagePath = response.profileImagePath
                    print("fetchCurrentUser response+++++++++",response)
                }
                
            }catch let error{
                
                await MainActor.run{
//                    mobileNumber = Auth.auth().currentUser?.phoneNumber ?? "9999999999"
                }
                print("fetchCurrentUser error",error.localizedDescription)
            }
        }
    }
    
    func updateUser(){
        Task{
            do{
                var imageString: String?
                if let isProfileSelected = profileImage{
                    imageString = try await ImageUpload.shared.uploadImage(image: isProfileSelected, targetFolder: "profiles")
                }
                guard let userId = Auth.auth().currentUser?.uid else{ return }
                let userDto = UserDTO(uid: userId, name: self.userName,email: self.emailID,address: self.userAddress, mobileNumber: self.mobileNumber, profileImagePath: imageString)
                
                let response = try await interactor.updateUser(user: userDto)
                
                await MainActor.run{
                    print("new user dto",response)
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
        refreshHomeScreen()
    }
    
    func refreshHomeScreen(){
        self.refreshDelegate?.fetchAllEntities()
    }
    
    func checkForChanges() {
        showSaveButton =
            userName != (userDtoModel?.name ?? "") ||
            userAddress != (userDtoModel?.address ?? "") ||
            emailID != (userDtoModel?.email ?? "") ||
            profileImage != nil
    }

    
    func logout() {
        
        self.alertType = .action(title: "Log Out", message: "Are you sure?", action: {
            self.logoutUser()
        })
    }
    
    func contactCustomerService() {
        print("Opening Calling Screen")
            if let url = URL(string: "tel://\(9999999999)") {
                UIApplication.shared.open(url)
            }
    }
    
    func logoutUser(){
        PhoneAuthService().logout()
        router.navigateToLoginScreen()
    }
    
    func navigateBack(){
        if showSaveButton{
            alertType = .action(title: "Save", message: "Do you want to save changes?", action: {
                self.updateUser()
                self.router.navigateBack()
            })
        }
        else{
            router.navigateBack()
        }
    }
    
    func navigateToFAQScreen(){
        router.navigateToFAQScreen()
    }
    
    func loadMainImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run{
                    self.profileImage = uiImage
                }
            }
        }
    }
}
