//
//  LoginScreenView.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import SwiftUI
enum LoginStep {
    case phoneInput
    case otpVerification
    case authenticated
}

struct LoginScreenView: View {
    @StateObject var presenter: LoginScreenPresenter
    
    var body: some View {
        CommonBackgroundView()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(StaticColor.shared.color())
                            .padding(.top, 40)
                        
                        Text(presenter.currentStep == .otpVerification ? "Verification" : "Welcome Back")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text(presenter.currentStep == .otpVerification ? "Enter the 6-digit code sent to \n\(presenter.mobileNumber)" : "Sign in to continue your journey")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    VStack(spacing: 24) {
                        if presenter.currentStep == .phoneInput {
                            phoneInputSection
                        } else {
                            otpInputSection
                        }
                        
                        if let error = presenter.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }
                        
                        actionButton
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground).opacity(0.8))
                            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    if presenter.currentStep == .phoneInput {
                        socialLoginSection
                    }
                }
            }
        }
    
    
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mobile Number")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Text("+91")
                    .fontWeight(.medium)
                    .padding(.leading, 4)
                
                Divider()
                    .frame(height: 24)
                
                TextField("Enter mobile number", text: $presenter.mobileNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            }
            .padding()
            .background(Color(.systemGroupedBackground).opacity(0.6))
            .cornerRadius(12)
        }
    }
    
    private var otpInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Security Code")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack {
                Image(systemName: "envelope.open.fill")
                    .foregroundColor(.secondary)
                
                TextField("Enter 6-digit OTP", text: $presenter.otpCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
            }
            .padding()
            .background(Color(.systemGroupedBackground).opacity(0.6))
            .cornerRadius(12)
            
            Button(action: {
                withAnimation { presenter.currentStep = .phoneInput }
            }) {
                Text("Change phone number?")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
    }
    
    private var actionButton: some View {
        Button(action: {
            withAnimation {
                if presenter.currentStep == .phoneInput {
                    presenter.sendOtpToPhoneNumber()
                    presenter.currentStep = .otpVerification
                } else {
                    presenter.verifyOtp()
                }
            }
        }) {
            HStack {
                if presenter.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(presenter.currentStep == .phoneInput ? "Send OTP" : "Verify & Proceed")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(StaticColor.shared.color())
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(presenter.isLoading)
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack { Divider() }
                Text("or continue with")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                VStack { Divider() }
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Button(action: presenter.loginWithApple) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                        Text("Apple")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(12)
                }
                
                Button(action: presenter.loginWithGoogle) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 18))
                        Text("Google")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
