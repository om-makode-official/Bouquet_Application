//
//  AddNewEntityView.swift
//  Project_B
//
//  Created by Om on 5/28/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct AddNewEntityView: View {
    
    @StateObject var presenter: AddNewEntityPresenter
    @State private var isShowingMapPicker = false
    
    var body: some View {
            ZStack {
                Form {
                    languageSelectorSection
                    localizedInformationSection
                    if presenter.identifier == "resort"{
                        capacityLogisticsSection
                        pricingUtilitiesSection
                        amenitiesRulesSection
                    }
                    else if presenter.identifier == "bouquet"{
                        addFlowersView
                        bouquetInfoView
                    }
                    mediaPhotosSection
                    geolocationSection
                    saveButtonSection
                }
                .navigationTitle(presenter.getTitle())
                .navigationBarTitleDisplayMode(.inline)
                
                if presenter.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.7, anchor: .center)
                    }
                }
            }
        .sheet(isPresented: $isShowingMapPicker) {
            MapPickerView(
                initialLatitude: Double(presenter.latitude) ?? 0.0,
                initialLongitude: Double(presenter.longitude) ?? 0.0
            ) { coordinate in
                presenter.latitude = String(format: "%.6f", coordinate.latitude)
                presenter.longitude = String(format: "%.6f", coordinate.longitude)
            }
        }
    }
    
    var languageSelectorSection: some View {
        Section(header: Text("Data Entry Language").foregroundColor(.accentColor)) {
            Picker("Select Input Language", selection: $presenter.selectedLanguage) {
                ForEach(AppLanguage.allCases) { lang in
                    Text("\(lang.displayName)").tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 2)
        }
    }
    
    var localizedInformationSection: some View {
        let currentLangName = presenter.selectedLanguage.displayName
        
        return Section(header: Text("Basic Details (\(currentLangName))").foregroundColor(.accentColor)) {
            
            HStack {
                TextField("Name (\(currentLangName))", text: Binding(
                    get: {
                        switch presenter.selectedLanguage {
                        case .en: return presenter.nameLanguages?.en ?? ""
                        case .mr: return presenter.nameLanguages?.mr ?? ""
                        case .hi: return presenter.nameLanguages?.hi ?? ""
                        }
                    },
                    set: { newValue in
                        switch presenter.selectedLanguage {
                        case .en: presenter.nameLanguages?.en = newValue
                        case .mr: presenter.nameLanguages?.mr = newValue
                        case .hi: presenter.nameLanguages?.hi = newValue
                        }
                    }
                ))
                .autocorrectionDisabled()
                
                Text(presenter.selectedLanguage.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TextField("Address / Location (\(currentLangName))", text: Binding(
                    get: {
                        switch presenter.selectedLanguage {
                        case .en: return presenter.addressLanguages?.en ?? ""
                        case .mr: return presenter.addressLanguages?.mr ?? ""
                        case .hi: return presenter.addressLanguages?.hi ?? ""
                        }
                    },
                    set: { newValue in
                        switch presenter.selectedLanguage {
                        case .en: presenter.addressLanguages?.en = newValue
                        case .mr: presenter.addressLanguages?.mr = newValue
                        case .hi: presenter.addressLanguages?.hi = newValue
                        }
                    }
                ))
                
                Text(presenter.selectedLanguage.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
                    .foregroundColor(.secondary)
            }
        
            ZStack(alignment: .topLeading) {
                let descriptionBinding = Binding<String>(
                    get: {
                        switch presenter.selectedLanguage {
                        case .en: return presenter.descriptionLanguages?.en ?? ""
                        case .mr: return presenter.descriptionLanguages?.mr ?? ""
                        case .hi: return presenter.descriptionLanguages?.hi ?? ""
                        }
                    },
                    set: { newValue in
                        switch presenter.selectedLanguage {
                        case .en: presenter.descriptionLanguages?.en = newValue
                        case .mr: presenter.descriptionLanguages?.mr = newValue
                        case .hi: presenter.descriptionLanguages?.hi = newValue
                        }
                    }
                )
                
                TextEditor(text: descriptionBinding)
                    .frame(minHeight: 100)
                
                if descriptionBinding.wrappedValue.isEmpty {
                    Text("Description of the hall in \(currentLangName)...")
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.leading, 5)
                        .padding(.top, 8)
                        .disabled(true)
                }
            }
            
            TextField("Owner Contact Number", text: $presenter.ownerContact)
                .keyboardType(.phonePad)
        }
    }
    
    var mediaPhotosSection: some View {
        Section(header: Text("Media & Photos")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Main Screen Background Image").font(.caption).foregroundColor(.gray)
                
                PhotosPicker(selection: $presenter.mainSelection, matching: .images, photoLibrary: .shared()) {
                    if let mainScreenImage = presenter.mainScreenImage {
                        Image(uiImage: mainScreenImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                            .frame(height: 120)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.title2)
                                    Text("Upload Main Cover").font(.footnote)
                                }
                                .foregroundColor(.gray)
                            )
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("More Hall Images").font(.caption).foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $presenter.gallerySelection, maxSelectionCount: 20, matching: .images, photoLibrary: .shared()) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                                .overlay(Image(systemName: "plus").foregroundColor(.gray))
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(0..<presenter.hallImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: presenter.hallImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .clipped()
                                
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        presenter.removeGalleryImage(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, Color(.systemGray2))
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(.plain)
                                .offset(x: 6, y: -6)
                            }
                            .padding(.top, 6)
                            .padding(.trailing, 6)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.vertical, 4)
        }
        .onChange(of: presenter.mainSelection) { _, newValue in
            presenter.loadMainImage(from: newValue)
        }
        .onChange(of: presenter.gallerySelection) { _, newValue in
            presenter.loadGalleryImages(from: newValue)
        }
    }
    
    var geolocationSection: some View {
        Section(header: Text("Geolocation"), footer: Text("Provide precise coordinates or tap to pinpoint on map view.")) {
            HStack {
                TextField("Latitude", text: $presenter.latitude)
                    .keyboardType(.decimalPad)
                Divider()
                TextField("Longitude", text: $presenter.longitude)
                    .keyboardType(.decimalPad)
                
                Button(action: {
                    isShowingMapPicker.toggle()
                }) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    var capacityLogisticsSection: some View {
        Section(header: Text("Capacity & Logistics")) {
            Picker("Seating Capacity", selection: $presenter.seatingAvailability) {
                ForEach(presenter.seatingRange, id: \.self) { count in
                    Text("\(count) People").tag(count)
                }
            }
            
            HStack {
                Text("Hall Size")
                Spacer()
                TextField("e.g. 5000", text: $presenter.hallSize)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                Text("sq ft").foregroundColor(.gray)
            }
            HStack {
                Text("Available Guest Rooms: ")
                Spacer()
                TextField("0", text: $presenter.roomCount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Parking Capacity").font(.subheadline)
                HStack {
                    Image(systemName: "car.fill").foregroundColor(.gray)
                        Text("Cars: ")
                        Spacer()
                        TextField("0", text: $presenter.parkingCars)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                }
                HStack {
                    Image(systemName: "bicycle").foregroundColor(.gray)
                    
                    Text("Bikes: ")
                    Spacer()
                    TextField("0", text: $presenter.parkingBikes)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    var pricingUtilitiesSection: some View {
        Section(header: Text("Pricing & Utilities")) {
            HStack {
                Text("Price Per Day")
                Spacer()
                Text("Rs.").foregroundColor(.gray)
                TextField("0.00", text: $presenter.pricePerDay)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            
            HStack {
                Text("Electricity Cost (Per Unit)")
                Spacer()
                Text("Rs.").foregroundColor(.gray)
                TextField("0.00", text: $presenter.lightBillPerUnit)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
        }
    }
    
    var amenitiesRulesSection: some View {
        Section(header: Text("Amenities & Rental Rules")) {
            Toggle(isOn: $presenter.isACAvailable) {
                Label("Air Conditioning (AC)", systemImage: "snowflake")
            }
            
            Toggle(isOn: $presenter.isPowerBackupAvailable) {
                Label("Generator / Power Backup", systemImage: "bolt.shield.fill")
            }
            
            Toggle(isOn: $presenter.allowsExternalCatering) {
                Label("External Catering Allowed", systemImage: "fork.knife")
            }
            
            Toggle(isOn: $presenter.hasSoundSystem) {
                Label("DJ & Sound System Setup", systemImage: "speaker.wave.3.fill")
            }
            
            Picker("Cancellation Policy", selection: $presenter.cancellationPolicy) {
                ForEach(presenter.cancellationOptions, id: \.self) { policy in
                    Text(policy).tag(policy)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 2)
        }
    }
    
    var saveButtonSection: some View {
        Section {
            Button(action: {
                presenter.onTapSaveUpdateButton()
                
            }, label: {
                Text(presenter.getSaveUpdateText())
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            })
            .listRowBackground(Color.accentColor)
        }
    }
}


extension AddNewEntityView{
    var addFlowersView: some View{
        Section("Add Flowers"){
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Flower Name(\(presenter.selectedLanguage.displayName))",
                        text: $presenter.flowerName
                    )
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()


                    Button {
                        presenter.addFlower(name: presenter.flowerName)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .disabled(presenter.flowerName.isEmpty)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {

                        ForEach(presenter.flowers.indices, id: \.self) { index in

                            HStack(spacing: 4) {

                                Text(presenter.flowers[index].getDetails())

                                Button {
                                    presenter.removeFlower(at: index)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }
    var bouquetInfoView: some View{
        let currentLangName = presenter.selectedLanguage.displayName
        return Section(header: Text("Bouquet Info")) {
            VStack(alignment: .leading, spacing: 8){
                Text("Seller Shop Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("Enter Shop Name (\(currentLangName))", text: Binding(
                    get: {
                        switch presenter.selectedLanguage {
                        case .en: return presenter.bouquetShopName?.en ?? ""
                        case .mr: return presenter.bouquetShopName?.mr ?? ""
                        case .hi: return presenter.bouquetShopName?.hi ?? ""
                        }
                    },
                    set: { newValue in
                        switch presenter.selectedLanguage {
                        case .en: presenter.bouquetShopName?.en = newValue
                        case .mr: presenter.bouquetShopName?.mr = newValue
                        case .hi: presenter.bouquetShopName?.hi = newValue
                        }
                    }
                ))
            }
            
            HStack {
                Text("Price")
                Spacer()
                Text("Rs.").foregroundColor(.gray)
                TextField("0.00", text: $presenter.bouquetPrice)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            
            HStack{
                Text("Size")
                TextField("Width", text: $presenter.sizeWidth)
                    .keyboardType(.decimalPad)
                Divider()
                TextField("Height", text: $presenter.sizeHeight)
                    .keyboardType(.decimalPad)
            }
            
            
            VStack(alignment: .leading, spacing: 8){
                Text("Availability")
                    .font(.caption)
                    .foregroundColor(.gray)
                Picker("Cancellation Policy", selection: $presenter.selectedAvailability) {
                    ForEach(presenter.availabilityInfo, id: \.self) { availability in
                        Text(availability).tag(availability)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
            }
        }
    }
}
