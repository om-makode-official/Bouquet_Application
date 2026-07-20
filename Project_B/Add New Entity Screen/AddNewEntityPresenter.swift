//
//  AddNewEntityPresenter.swift
//  Project_B
//
//  Created by Om on 5/28/26.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import UIKit

class AddNewEntityPresenter: ObservableObject {
    
    @Published var selectedLanguage: AppLanguage = .en
    @Published var ownerContact = ""
    @Published var isShowingMainPicker = false
    @Published var isShowingGalleryPicker = false
    @Published var latitude : String = "17.385000"
    @Published var longitude: String = "78.486700"
    @Published var seatingAvailability = 100
    @Published var seatingRange = stride(from: 50, through: 5000, by: 50).map { $0 }
    @Published var hallSize = ""
    @Published var roomCount = ""
    @Published var parkingCars = ""
    @Published var parkingBikes = ""
    @Published var pricePerDay = ""
    @Published var lightBillPerUnit = ""
    @Published var isACAvailable = false
    @Published var isPowerBackupAvailable = false
    @Published var allowsExternalCatering = true
    @Published var hasSoundSystem = false
    @Published var cancellationPolicy = "Moderate"
    @Published var cancellationOptions = ["Flexible", "Moderate", "Strict"]
    @Published var mainSelection: PhotosPickerItem? = nil
    @Published var gallerySelection: [PhotosPickerItem] = []
    @Published var mainScreenImage: UIImage? = nil
    @Published var hallImages: [UIImage] = []
    
    @Published var halls:[HallResponseModel] = []
    @Published var isUploading = false
    @Published var errorMessage: String? = nil
    
    @Published var isLoading: Bool = false
    
    @Published var nameLanguages: LocalizedStringModel? = LocalizedStringModel()
    @Published var addressLanguages: LocalizedStringModel? = LocalizedStringModel()
    @Published var descriptionLanguages: LocalizedStringModel? = LocalizedStringModel()
    
    @Published var flowerName: String = ""
    @Published var flowers: [LocalizedStringModel] = []
    @Published var bouquetShopName: LocalizedStringModel? = LocalizedStringModel()
    @Published var bouquetPrice: String = ""
    @Published var sizeWidth: String = ""
    @Published var sizeHeight: String = ""
    @Published var availabilityInfo: [String] = ["Same Day", "Next Day"]
    @Published var selectedAvailability: String = "Same Day"
    
    //    private let service = HallService()
    
    let interactor : AddNewEntityInteractor
    let router: AddNewEntityRouter
    let resortEntity: HallResponseModel?
    let identifier: String
    let bouquetEntity: BouquetDetailsEntity?
    
    var refreshDelegate: RefreshDataProtocol?
    
    init(interactor : AddNewEntityInteractor, router: AddNewEntityRouter, resortEntity: HallResponseModel?, identifier: String, bouquetEntity: BouquetDetailsEntity?) {
        self.interactor = interactor
        self.router = router
        self.resortEntity = resortEntity
        self.identifier = identifier
        self.bouquetEntity = bouquetEntity
        
        fillDataIfAvailable()
    }
    func getTitle() -> String{
        if identifier == "resort"{
            return "Add New Resort"
        }else if identifier == "resort", resortEntity != nil{
            return "Edit Resort"
        }else if identifier == "bouquet"{
            return "Add New Bouquet"
        }else if identifier == "bouquet", bouquetEntity != nil{
            return "Edit Bouquet"
        }
        return "Add New Data"
    }
    
    func onTapSaveUpdateButton(){
        if identifier == "resort" && getSaveUpdateText().lowercased() == "save"{
            createNewResort()
        }else if identifier == "resort" && getSaveUpdateText().lowercased() == "update"{
            updateResort()
        }else if identifier == "bouquet" && getSaveUpdateText().lowercased() == "save"{
            createBouquet()
        }else if identifier == "bouquet" && getSaveUpdateText().lowercased() == "update"{
            updateBouquet()
        }
    }
    func getSaveUpdateText() -> String{
        if resortEntity != nil || bouquetEntity != nil{
            return "Update"
        }else{
            return "Save"
        }
    }
    
    func loadImages(mainImageUrl: String, galleryImages: [String]?){
        Task {
            do{
                if let url = URL( string: "\(StringConstants.shared.base)/\(mainImageUrl)" ){
                        let image = try? await interactor.loadImage(url: url)
                    await MainActor.run{
                        self.mainScreenImage = image
                    }

                }
                if let images = galleryImages{
                    for url in images{
                        if let imageUrl = URL(string: "\(StringConstants.shared.base)/\(url)"){
                            if let image = try await interactor.loadImage(url: imageUrl){
                                await MainActor.run{
                                    self.hallImages.append(image)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fillDataIfAvailable(){
        if identifier == "resort"{
            if let data = resortEntity{
                self.nameLanguages = data.hallName
                self.addressLanguages = data.locationAddress
                self.descriptionLanguages = data.description
                self.ownerContact = data.ownerContact ?? ""
                self.latitude = String(data.latitude ?? 0)
                self.longitude = String(data.longitude ?? 0)
                self.seatingAvailability = data.seatingAvailability ?? 0
                self.hallSize = data.hallSize ?? ""
                self.roomCount = String(data.roomCount ?? 0)
                self.parkingCars = String(data.parkingCars ?? 0)
                self.parkingBikes = String(data.parkingBikes ?? 0)
                self.pricePerDay = String(data.pricePerDay ?? 0)
                self.lightBillPerUnit = String(data.lightBillPerUnit ?? 0)
                self.isACAvailable = data.isACAvailable ?? false
                self.isPowerBackupAvailable = data.isPowerBackupAvailable ?? false
                self.allowsExternalCatering = data.allowsExternalCatering ?? false
                self.hasSoundSystem = data.hasSoundSystem ?? false
                self.cancellationPolicy = data.cancellationPolicy ?? ""
                
                if let mainImage = resortEntity?.mainScreenImagePath{
                    self.loadImages(mainImageUrl: mainImage, galleryImages: resortEntity?.galleryImagePaths)
                }
                
                
            }
        }else if identifier == "bouquet"{
            if let data = bouquetEntity{
                self.nameLanguages = data.name
                self.addressLanguages = data.sellerAddress
                self.descriptionLanguages = data.description
                self.ownerContact = data.contactNumber ?? ""
                self.latitude = String(data.latitude ?? 0)
                self.longitude = String(data.longitude ?? 0)

                self.bouquetShopName = data.sellerName
                self.bouquetPrice = String(data.price ?? 0)
                self.sizeWidth = String(data.sizeWidth ?? 0)
                self.sizeHeight = String(data.sizeHeight ?? 0)
                self.selectedAvailability = data.availability ?? ""
                self.flowers = data.flowersUsed ?? []
                if let mainImage = bouquetEntity?.mainScreenImage{
                    self.loadImages(mainImageUrl: mainImage, galleryImages: bouquetEntity?.galleryImages)
                }
            }
        }
    }
    
    func createNewResort(){
        self.isLoading = true
        
        Task{
            do{
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "resort")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "resort")
                }
                
                let response = try await interactor.saveEntity(hallName: nameLanguages,
                                                               locationAddress: addressLanguages,
                                                               description: descriptionLanguages,
                                                               ownerContact: ownerContact,
                                                               latitude: latitude,
                                                               longitude: longitude,
                                                               seatingAvailability: seatingAvailability,
                                                               hallSize: hallSize,
                                                               roomCount: roomCount,
                                                               parkingCars: parkingCars,
                                                               parkingBikes: parkingBikes,
                                                               pricePerDay: pricePerDay,
                                                               lightBillPerUnit: lightBillPerUnit,
                                                               isACAvailable: isACAvailable,
                                                               isPowerBackupAvailable: isPowerBackupAvailable,
                                                               allowsExternalCatering: allowsExternalCatering,
                                                               hasSoundSystem: hasSoundSystem,
                                                               cancellationPolicy: cancellationPolicy,
                                                               mainImagePath: mainImageString,
                                                               galleryImagePaths: imagesArray)
                await MainActor.run{
                    if response == true{
                        self.isLoading = false
                        self.navigateBack()
                    }else{
                        self.isLoading = false
                        print("Response is false")
                    }
                }
                
                
                
            }catch let error{
                print(error.localizedDescription)
                await MainActor.run{
                    self.isLoading = false
                }
            }
        }
    }
    func updateResort(){
        self.isLoading = true
        
        Task{
            do{
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "resort")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "resort")
                }
                
                let response = try await interactor.updateEntity(id: resortEntity?.id ?? 0,
                                                                 hallName: nameLanguages,
                                                               locationAddress: addressLanguages,
                                                               description: descriptionLanguages,
                                                               ownerContact: ownerContact,
                                                               latitude: latitude,
                                                               longitude: longitude,
                                                               seatingAvailability: seatingAvailability,
                                                               hallSize: hallSize,
                                                               roomCount: roomCount,
                                                               parkingCars: parkingCars,
                                                               parkingBikes: parkingBikes,
                                                               pricePerDay: pricePerDay,
                                                               lightBillPerUnit: lightBillPerUnit,
                                                               isACAvailable: isACAvailable,
                                                               isPowerBackupAvailable: isPowerBackupAvailable,
                                                               allowsExternalCatering: allowsExternalCatering,
                                                               hasSoundSystem: hasSoundSystem,
                                                               cancellationPolicy: cancellationPolicy,
                                                               mainImagePath: mainImageString,
                                                               galleryImagePaths: imagesArray)
                await MainActor.run{
                    if response == true{
                        self.isLoading = false
                        self.navigateBack()
                    }
                }
                
                
                
            }catch let error{
                print(error.localizedDescription)
                await MainActor.run{
                    self.isLoading = false
                }
            }
        }
    }
    
    func navigateBack(){
        if identifier == "resort"{
            refreshDelegate?.fetchAllEntities()
        }else if identifier == "bouquet"{
            refreshDelegate?.fetchAllBouquets()
        }
        router.navigateBack()
    }
    
    func loadMainImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run{
                    self.mainScreenImage = uiImage
                }
            }
        }
    }
    
    func loadGalleryImages(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
//                    await MainActor.run{
                        loadedImages.append(uiImage)
//                    }
                }
            }
            await MainActor.run{
                self.hallImages.append(contentsOf: loadedImages)
                self.gallerySelection.removeAll()
            }
        }
    }
    
    func removeGalleryImage(at index: Int) {
        guard hallImages.indices.contains(index) else { return }
        hallImages.remove(at: index)
    }
}


extension AddNewEntityPresenter{
    func createBouquet(){
        self.isLoading = true
        Task{
            do{
                
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "bouquet")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "bouquet")
                }
                
                
                let data = BouquetDetailsEntity(
                    name: nameLanguages,
                    flowersUsed: flowers,
                    sellerName: bouquetShopName,
                    sellerAddress: addressLanguages,
                    latitude: Double(latitude),
                    longitude: Double(longitude),
                    price: Double(bouquetPrice),
                    availability: selectedAvailability,
                    sizeWidth: Double(sizeWidth),
                    sizeHeight: Double(sizeHeight),
                    mainScreenImage: mainImageString,
                    galleryImages: imagesArray,
                    description: descriptionLanguages,
                    contactNumber: ownerContact)
                let response = try await interactor.createBouquet(bouquet: data)
                
                
                await MainActor.run{
                    print(response)
                    self.isLoading = false
                    self.navigateBack()
                }
            }catch let error{
                print(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    func updateBouquet(){
        self.isLoading = true
        
        Task{
            do{
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "bouquet")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "bouquet")
                }
                guard let data = bouquetEntity, let id = data.id else { return }
                
                let response = try await interactor.updateBouquet(bouquet:
                                                                    BouquetDetailsEntity(id: id,
                                                                                         name: self.nameLanguages,
                                                                                         flowersUsed: self.flowers,
                                                                                         sellerName: self.bouquetShopName,
                                                                                         sellerAddress: self.addressLanguages,
                                                                                         latitude: Double(self.latitude),
                                                                                         longitude: Double(self.longitude),
                                                                                         price: Double(self.bouquetPrice),
                                                                                         availability: self.selectedAvailability,
                                                                                         sizeWidth: Double(self.sizeWidth),
                                                                                         sizeHeight: Double(self.sizeHeight),
                                                                                         mainScreenImage: mainImageString,
                                                                                         galleryImages: imagesArray,
                                                                                         description: self.descriptionLanguages,
                                                                                         contactNumber: self.ownerContact), id: id)
                await MainActor.run{
                    if response == true{
                        self.isLoading = false
                        self.navigateBack()
                    }
                }
                
                
                
            }catch let error{
                print(error.localizedDescription)
                self.isLoading = false
                
            }
        }
    }
    
    func addFlower(name: String) {
        var flower = LocalizedStringModel()

        switch selectedLanguage {
        case .en:
            flower.en = name

        case .mr:
            flower.mr = name

        case .hi:
            flower.hi = name
        }

        flowers.append(flower)
        flowerName = ""
    }

    func removeFlower(at index: Int) {
        guard flowers.indices.contains(index) else { return }
        flowers.remove(at: index)
    }
}





// MARK: - This is for Firebase Operations
    
//    func saveHallData() {
//        guard !hallName.isEmpty else {
//            self.errorMessage = "Please enter a valid Hall Name"
//            return
//        }
//        
//        isUploading = true
//        errorMessage = nil
//        Task {
//            do {
//                let parsedLat = Double(latitude.replacingOccurrences(of: ",", with: ".")) ?? 0.0
//                let parsedLon = Double(longitude.replacingOccurrences(of: ",", with: ".")) ?? 0.0
//
//                let hall = HallModel(
//                    hallName: hallName,
//                    locationAddress: locationAddress,
//                    description: description,
//                    ownerContact: ownerContact,
//                    latitude: parsedLat,
//                    longitude: parsedLon,
//                    seatingAvailability: seatingAvailability,
//                    hallSize: hallSize,
//                    roomCount: roomCount,
//                    parkingCars: parkingCars,
//                    parkingBikes: parkingBikes,
//                    pricePerDay: pricePerDay,
//                    lightBillPerUnit: lightBillPerUnit,
//                    isACAvailable: isACAvailable,
//                    isPowerBackupAvailable: isPowerBackupAvailable,
//                    allowsExternalCatering: allowsExternalCatering,
//                    hasSoundSystem: hasSoundSystem,
//                    cancellationPolicy: cancellationPolicy,
//                    mainImage: mainScreenImage,
//                    galleryImages: hallImages
//                )
//
//                try await service.createHall(hall: hall)
//                
//                await MainActor.run{
//                    self.isUploading = false
//                }
//                print("SUCCESS: Hall Data and Media Uploaded.")
//            } catch {
//                await MainActor.run{
//                    self.isUploading = false
//                    self.errorMessage = error.localizedDescription
//                }
//                print("ERROR:", error)
//            }
//        }
//    }
//    func fetchAllHalls(){
//        Task{
//            do{
//                let data = try await service.fetchHalls()
//                await MainActor.run{
//                    self.halls = data
//                    print("Hall Data",data)
//                }
//            }catch{
//                print(error)
//            }
//        }
//    }
//}
//
//class HallService {
//    private let db = Firestore.firestore()
//    private func convertImageToBase64(_ image: UIImage?) -> String? {
//        guard let image else {
//            return nil
//        }
//        guard let data = image.jpegData(compressionQuality: 0.35) else {
//            return nil
//        }
//        return data.base64EncodedString()
//    }
//    
//    func createHall(hall: HallModel) async throws {
//        let parentHallId = UUID().uuidString
//        let mainImageBase64 = convertImageToBase64(hall.mainImage)
//        let galleryBase64 = hall.galleryImages.compactMap { convertImageToBase64($0) }
//        try await db.collection("halls").document(parentHallId).setData([
//
//                "id": parentHallId,
//                "hallName": hall.hallName,
//                "locationAddress": hall.locationAddress,
//                "description": hall.description,
//                "ownerContact": hall.ownerContact,
//                "latitude": hall.latitude,
//                "longitude": hall.longitude,
//                "seatingAvailability": hall.seatingAvailability,
//                "hallSize": hall.hallSize,
//                "roomCount": hall.roomCount,
//                "parkingCars": hall.parkingCars,
//                "parkingBikes": hall.parkingBikes,
//                "pricePerDay": Double(hall.pricePerDay),
//                "lightBillPerUnit": Double(hall.lightBillPerUnit),
//                "isACAvailable": hall.isACAvailable,
//                "isPowerBackupAvailable": hall.isPowerBackupAvailable,
//                "allowsExternalCatering": hall.allowsExternalCatering,
//                "hasSoundSystem": hall.hasSoundSystem,
//                "cancellationPolicy": hall.cancellationPolicy,
//                "mainImage": mainImageBase64 ?? "",
//                "galleryImages": galleryBase64,
//                "createdAt": FieldValue.serverTimestamp()
//        ])
//        print("Saved Successfully")
//    }
//    func fetchHalls() async throws -> [HallResponseModel] {
//        let snapshot = try await db.collection("halls").getDocuments()
//        let halls = snapshot.documents.compactMap { document -> HallResponseModel? in
//            do {
//                return try document.data(as: HallResponseModel.self)
//            } catch {
//                print(error)
//                return nil
//            }
//        }
//        return halls
//    }
//}

//struct HallModel {
//    let hallName: String
//    let locationAddress: String
//    let description: String
//    let ownerContact: String
//    let latitude: Double
//    let longitude: Double
//    let seatingAvailability: Int
//    let hallSize: String
//    let roomCount: Int
//    let parkingCars: Int
//    let parkingBikes: Int
//    let pricePerDay: String
//    let lightBillPerUnit: String
//    let isACAvailable: Bool
//    let isPowerBackupAvailable: Bool
//    let allowsExternalCatering: Bool
//    let hasSoundSystem: Bool
//    let cancellationPolicy: String
//    let mainImage: UIImage?
//    let galleryImages: [UIImage]
//}


