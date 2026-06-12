//
//  LoginHelper.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject{
    
    static let shared = AuthManager()
    
    static func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    @Published var isAdmin = false
    
    static func checkAdminStatus() async -> Bool {

        guard let phone = Auth.auth().currentUser?.phoneNumber else {
            return false
        }
        do {
            let document = try await Firestore.firestore().collection("Admins").document(phone).getDocument()
            return document.exists
        } catch {
            print(error)
            return false
        }
    }
}

// MARK: - Phone Auth Service
class PhoneAuthService {
    
//    private let baseURLString = StringConstants.shared.baseUrl
    private let baseURLString = "http://localhost:8081/api/users"
    
    func sendOTP(phoneNumber: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let verificationID else {
                        continuation.resume(
                            throwing: NSError(
                                domain: "PhoneAuth",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Verification ID not found"]
                            )
                        )
                        return
                    }
                    continuation.resume(returning: verificationID)
                }
        }
    }
    
    func verifyOTP(code: String) async throws -> AuthDataResult {
        
        let verificationID = UserDefaults.standard.string(forKey: "verificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        let authResult: AuthDataResult = try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Auth",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Login failed"]
                        )
                    )
                    return
                }
                continuation.resume(returning: result)
            }
        }
        
        let firebaseUser = authResult.user
        let idToken = try await firebaseUser.getIDToken()
        let newUser = UserDTO(
            uid: firebaseUser.uid,
            name: "",
            mobileNumber: firebaseUser.phoneNumber ?? ""
        )
        do {
            _ = try await createUser(user: newUser, authToken: idToken)
        } catch {
            print("Firebase auth succeeded, but Spring Boot sync failed: \(error.localizedDescription)")
        }
        
        return authResult
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func createUser(user: UserDTO, authToken: String) async throws -> UserDTO {

        guard let url = URL(string: "\(baseURLString)/sync") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(user)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UserDTO.self, from: data)
    }
}
