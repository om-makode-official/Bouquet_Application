//
//  LoginScreenPresenter.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import FirebaseAuth

class LoginScreenPresenter: ObservableObject {
    
    @Published var mobileNumber: String = ""
    @Published var isLoading = false
    @Published var otpCode: String = ""
    @Published var currentStep: LoginStep = .phoneInput
    @Published var errorMessage: String? = nil
    
    let router: LoginScreenRouter
    let authentication: PhoneAuthService
    
    init( router: LoginScreenRouter, authentication: PhoneAuthService) {
        self.router = router
        self.authentication = authentication
    }
    
    func sendOtpToPhoneNumber(){
        Task{
            do {
                let numberWithCode = "+91\(mobileNumber)"
                
                let verificationID = try await authentication.sendOTP(phoneNumber: numberWithCode)
                
                UserDefaults.standard.set(
                    verificationID,
                    forKey: "verificationID"
                )
                
                print("OTP sent")
                print("Verification ID: \(verificationID)")
                
            } catch {
                await MainActor.run{
                    errorMessage = error.localizedDescription
                    
                    print(error.localizedDescription)
                    print(error)
                    
                    let nsError = error as NSError
                    
                    print("FULL ERROR:", error)
                    print("CODE:", nsError.code)
                    print("DOMAIN:", nsError.domain)
                    print("USER INFO:", nsError.userInfo)
                }
            }
        }
    }
    func verifyOtp() {
        
        Task {
            do {
                let result = try await authentication.verifyOTP(code: otpCode)
                print("USER ID:", result.user.uid)
                print("PHONE:", result.user.phoneNumber ?? "")
                
                await MainActor.run{
                    navigateToHomeScreen()
                }
                
            } catch {
                let nsError = error as NSError
                print(error)
                print(nsError.userInfo)
                
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func navigateToHomeScreen() {
        router.navigateToHomeScreen()
    }
    func loginWithGoogle() {
        print("Google Sign-In Tapped")
    }
    
    func loginWithApple() {
        print("Apple Sign-In Tapped")
    }
}
