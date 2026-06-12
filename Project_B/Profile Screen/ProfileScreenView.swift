//
//  ProfileScreenView.swift
//  Project_B
//
//  Created by Sai Krishna on 6/3/26.
//

import SwiftUI

struct ProfileScreenView: View {
    @StateObject var presenter: ProfileScreenPresenter
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        ZStack(alignment: .topLeading){
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
                VStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -80, y: -100)
                    Spacer()
                    Circle()
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: 80, y: 100)
                }
            
            ScrollView {
                VStack(spacing: 24) {
                    profileHeaderSection
                    personalInfoSection
                    preferencesSection
                    supportSection
                    if presenter.showSaveButton{
                        saveButton
                    }
                    logoutButton
                }
                .padding(.vertical, 24)
            }
            .onChange(of: "\(presenter.userName)|\(presenter.userAddress)|\(presenter.emailID)|\(presenter.profileImage != nil)"
            ) { _ in
                presenter.checkForChanges()
            }
            
            Button(action: {
                presenter.navigateBack()
            }, label: {
                Image(systemName: "chevron.left.circle.fill")
                    .foregroundStyle(StaticColor.shared.color())
                    .background(.white)
                    .font(.system(size: 30, weight: .bold))
                    .clipShape(Circle())
                
            }).padding(20)
            
            
        }
        .alert(item: $presenter.alertType) { alert in
            
            switch alert {
            case let .message(title,message):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    dismissButton: .default(
                        Text(LocalizationManager.shared.localized("OK"))
                    )
                )
                
            case let .action(title,message,action):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton:
                            .destructive(Text(LocalizationManager.shared.localized("Yes"))){ action() },
                    secondaryButton:
                            .cancel()
                )
            }
        }
        .navigationBarHidden(true)
    }
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if presenter.profileImage == nil, let url = URL(string: presenter.originalProfileImagePath ?? ""){
                    AsyncImage(url: url, content: { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }, placeholder: {
                        Circle()
                            .fill(StaticColor.shared.color())
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                    })
                }else{
                    if let profileImage = presenter.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(StaticColor.shared.color())
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                Button(action: {
                    presenter.showImagePickerView = true
                }) {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(Color.blue.clipShape(Circle()))
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                }
                .photosPicker(
                    isPresented: $presenter.showImagePickerView,
                    selection: $presenter.selectedImage,
                    matching: .images
                )
                .onChange(of: presenter.selectedImage) { newImage in
                    presenter.loadMainImage(from: newImage)
                }
                .offset(x: 5, y: 5)
                
            }
            
            VStack(spacing: 4) {
                Text(presenter.userName)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text(presenter.emailID)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }
        }
        .padding(.bottom, 8)
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationManager.shared.localized("Personal Information"))
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                editableField(title: LocalizationManager.shared.localized("Full Name"), text: $presenter.userName, icon: "person.fill")
                
                Divider()
                staticField(title: LocalizationManager.shared.localized("Mobile Number"), value: presenter.mobileNumber, icon: "phone.fill")
                
                Divider()
                editableField(title: LocalizationManager.shared.localized("Email"), text: $presenter.emailID, icon: "mail")
                
                Divider()
                editableField(title: LocalizationManager.shared.localized("Address"), text: $presenter.userAddress, icon: "mappin.and.ellipse")
            }
        }
        .glassCard()
    }
    private var saveButton: some View {
        Button(action: {
            presenter.updateUser()
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text(LocalizationManager.shared.localized("Save"))
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green.opacity(0.1))
            .foregroundColor(.green)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationManager.shared.localized("Preferences"))
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text(LocalizationManager.shared.localized("Language"))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Menu {
                        Button("English") {
                            languageManager.selectedLanguage = "en"
                            presenter.refreshHomeScreen()
                        }
                        Button("मराठी (Marathi)") {
                            languageManager.selectedLanguage = "mr"
                            presenter.refreshHomeScreen()
                        }
                        Button("हिन्दी (Hindi)") {
                            languageManager.selectedLanguage = "hi"
                            presenter.refreshHomeScreen()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(presenter.selectedLanguage.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                }
                
            }
        }
        .glassCard()
    }
    
    private var supportSection: some View {
        VStack(spacing: 0) {
            Button(action: presenter.contactCustomerService) {
                HStack {
                    Image(systemName: "headphones")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text(LocalizationManager.shared.localized("Customer Service"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            }
            
            Divider()
            
            Button(action: {
                presenter.navigateToFAQScreen()
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    Text(LocalizationManager.shared.localized("FAQ & Help"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            }
        }
        .glassCard()
    }
    
    private var logoutButton: some View {
        Button(action: {
            presenter.logout()
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(LocalizationManager.shared.localized("Log Out"))
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    
    private func editableField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                TextField(title, text: text)
                    .font(.subheadline)
                    .textContentType(.name)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func staticField(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
