//
//  AddNewEntityPresenter.swift
//  Project_B
//
//  Created by Sai Krishna on 5/28/26.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import UIKit

class AddNewEntityPresenter: ObservableObject {
    
//    @Published var hallName: LocalizedStringModel?
//    @Published var locationAddress: LocalizedStringModel?
//    @Published var description: LocalizedStringModel?
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
    
    @Published var hallNameLanguages: LocalizedStringModel? = LocalizedStringModel()
    @Published var addressLanguages: LocalizedStringModel? = LocalizedStringModel()
    @Published var descriptionLanguages: LocalizedStringModel? = LocalizedStringModel()
    
    //    private let service = HallService()
    
    let interactor : AddNewEntityInteractor
    let router: AddNewEntityRouter
    let entity: HallResponseModel?
    
    var refreshDelegate: RefreshDataProtocol?
    
    init(interactor : AddNewEntityInteractor, router: AddNewEntityRouter, entity: HallResponseModel?) {
        self.interactor = interactor
        self.router = router
        self.entity = entity
        
        fillDataIfAvailable()
    }
    
    func loadImages(){
        Task {
            do{
                if let mainImageUrl = entity?.mainScreenImagePath, let url = URL( string: mainImageUrl ){
                        let image = try? await interactor.loadImage(url: url)
                    await MainActor.run{
                        self.mainScreenImage = image
                    }

                }
                if let galleryImages = entity?.galleryImagePaths{
                    for url in galleryImages{
                        if let imageUrl = URL(string: url){
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
        if let data = entity{
            self.hallNameLanguages = data.hallName
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
            
            
            
            self.loadImages()
            
            
            
        }
    }
    
    func uploadImages(){
        self.isLoading = true
        
        Task{
            do{
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "gallery")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "gallery")
                }
                
                let response = try await interactor.saveEntity(hallName: hallNameLanguages,
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
            }
        }
    }
    func updateEntity(){
        self.isLoading = true
        
        Task{
            do{
                var imagesArray = [String]()
                for image in hallImages{
                    let imageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "gallery")
                    
                    imagesArray.append(imageString)
                }
                
                var mainImageString = ""
                if let image = mainScreenImage{
                    mainImageString = try await ImageUpload.shared.uploadImage(image: image, targetFolder: "gallery")
                }
                
                let response = try await interactor.updateEntity(id: entity?.id ?? 0,
                                                                 hallName: hallNameLanguages,
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
            }
        }
    }
    
    func navigateBack(){
        refreshDelegate?.fetchAllEntities()
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


