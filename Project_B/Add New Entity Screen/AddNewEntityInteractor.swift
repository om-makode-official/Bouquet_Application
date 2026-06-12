//
//  AddNewEntityInteractor.swift
//  Project_B
//
//  Created by Sai Krishna on 5/29/26.
//

import Foundation
import UIKit
import Alamofire

class AddNewEntityInteractor{
    private let baseURLString = StringConstants.shared.baseUrl
    
    func saveEntity(hallName: LocalizedStringModel?,
                    locationAddress: LocalizedStringModel?,
                    description: LocalizedStringModel?,
                    ownerContact: String,
                    latitude: String,
                    longitude: String,
                    seatingAvailability: Int,
                    hallSize: String,
                    roomCount: String,
                    parkingCars: String,
                    parkingBikes: String,
                    pricePerDay: String,
                    lightBillPerUnit: String,
                    isACAvailable: Bool,
                    isPowerBackupAvailable: Bool,
                    allowsExternalCatering: Bool,
                    hasSoundSystem: Bool,
                    cancellationPolicy: String,
                    mainImagePath: String,
                    galleryImagePaths: [String]) async throws -> Bool? {
        
        
        guard let url = URL(string: baseURLString) else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 1. Prepare localized nested dictionaries to match backend expectation
        let localizedHallName: [String: String] = [
            "en": hallName?.en ?? "",
            "mr": hallName?.mr ?? "",
            "hi": hallName?.hi ?? ""
        ]
        
        let localizedLocationAddress: [String: String] = [
            "en": locationAddress?.en ?? "",
            "mr": locationAddress?.mr ?? "",
            "hi": locationAddress?.hi ?? ""
        ]
        
        let localizedDescription: [String: String] = [
            "en": description?.en ?? "",
            "mr": description?.mr ?? "",
            "hi": description?.hi ?? ""
        ]
        
        // 2. Build HTTP request payload with safe numeric parsing
        let body: [String: Any] = [
            "hallName": localizedHallName,
            "locationAddress": localizedLocationAddress,
            "description": localizedDescription,
            "ownerContact": ownerContact,
            "latitude": Double(latitude) ?? 0.0,               // Converted to Double
            "longitude": Double(longitude) ?? 0.0,             // Converted to Double
            "seatingAvailability": seatingAvailability,
            "hallSize": hallSize,
            "roomCount": Int(roomCount) ?? 0,
            "parkingCars": Int(parkingCars) ?? 0,
            "parkingBikes": Int(parkingBikes) ?? 0,
            "pricePerDay": Double(pricePerDay) ?? 0.0,         // Converted to Double for BigDecimal mapping
            "lightBillPerUnit": Double(lightBillPerUnit) ?? 0.0, // Converted to Double for BigDecimal mapping
            "isACAvailable": isACAvailable,
            "isPowerBackupAvailable": isPowerBackupAvailable,
            "allowsExternalCatering": allowsExternalCatering,
            "hasSoundSystem": hasSoundSystem,
            "cancellationPolicy": cancellationPolicy,
            "mainScreenImagePath": mainImagePath,
            "galleryImagePaths": galleryImagePaths
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let response = try await URLSession.shared.data(for: urlRequest)
        guard let res = response.1 as? HTTPURLResponse else { return false }
        
        if res.statusCode == 200 || res.statusCode == 201 {
            return true
        }
        
        print("Server Error Response:", res)
        return false
    }
    
    // MARK: - 2. UPDATE (PUT)
    func updateEntity(id: Int,
                      hallName: LocalizedStringModel?,
                      locationAddress: LocalizedStringModel?,
                      description: LocalizedStringModel?,
                      ownerContact: String,
                      latitude: String,
                      longitude: String,
                      seatingAvailability: Int,
                      hallSize: String,
                      roomCount: String,
                      parkingCars: String,
                      parkingBikes: String,
                      pricePerDay: String,
                      lightBillPerUnit: String,
                      isACAvailable: Bool,
                      isPowerBackupAvailable: Bool,
                      allowsExternalCatering: Bool,
                      hasSoundSystem: Bool,
                      cancellationPolicy: String,
                      mainImagePath: String,
                      galleryImagePaths: [String]) async throws -> Bool{
        
        
        let urlString = "\(baseURLString)/\(id)"
        
        guard let url = URL(string: urlString) else { return false }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let localizedHallName: [String: String] = [
            "en": hallName?.en ?? "",
            "mr": hallName?.mr ?? "",
            "hi": hallName?.hi ?? ""
        ]
        
        let localizedLocationAddress: [String: String] = [
            "en": locationAddress?.en ?? "",
            "mr": locationAddress?.mr ?? "",
            "hi": locationAddress?.hi ?? ""
        ]
        
        let localizedDescription: [String: String] = [
            "en": description?.en ?? "",
            "mr": description?.mr ?? "",
            "hi": description?.hi ?? ""
        ]
        
        let body: [String: Any] = [
            "id": id,
            "hallName": localizedHallName,
            "locationAddress": localizedLocationAddress,
            "description": localizedDescription,
            "ownerContact": ownerContact,
            "latitude": Double(latitude) ?? 0.0,
            "longitude": Double(longitude) ?? 0.0,
            "seatingAvailability": seatingAvailability,
            "hallSize": hallSize,
            "roomCount": Int(roomCount) ?? 0,
            "parkingCars": Int(parkingCars) ?? 0,
            "parkingBikes": Int(parkingBikes) ?? 0,
            "pricePerDay": Double(pricePerDay) ?? 0.0,
            "lightBillPerUnit": Double(lightBillPerUnit) ?? 0.0,
            "isACAvailable": isACAvailable,
            "isPowerBackupAvailable": isPowerBackupAvailable,
            "allowsExternalCatering": allowsExternalCatering,
            "hasSoundSystem": hasSoundSystem,
            "cancellationPolicy": cancellationPolicy,
            "mainScreenImagePath": mainImagePath,
            "galleryImagePaths": galleryImagePaths
        ]
        
        print("MainImagePath Target:", mainImagePath)
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let response = try await URLSession.shared.data(for: urlRequest)
        guard let res = response.1 as? HTTPURLResponse else { return false }
        
        if res.statusCode == 200 {
            let data = try JSONDecoder().decode(HallResponseModel.self, from: response.0)
            print("Response Data Updated Successfully:", data)
            return true
        }
        print("Update Failed Status:", response.1)
        return false
    }
    
    
    
//    func uploadImage(image: UIImage) async throws -> String {
//        let uploadURLString = "\(baseURLString)/upload"
//        
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw URLError(.badURL)
//        }
//        
//        let res = try await withCheckedThrowingContinuation { continuation in
//            AF.upload(
//                multipartFormData: { multipart in
//                    multipart.append(
//                        imageData,
//                        withName: "file",
//                        fileName: "hall_asset.jpg",
//                        mimeType: "image/jpeg"
//                    )
//                },
//                to: uploadURLString,
//                method: .post
//            )
//            .validate()
//            .responseString { response in
//                switch response.result {
//                case .success(let imageUrl):
//                    print("Image uploaded successfully via Alamofire")
//                    continuation.resume(returning: imageUrl)
//                    
//                case .failure(let error):
//                    print("Alamofire multi-part context failure")
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//        print("Response Path Result:", res)
//        return res
//    }
    
    func loadImage(url: URL ) async throws -> UIImage? {

        let (data, _) = try await URLSession.shared.data( from: url )

        return UIImage( data: data )
    }
}
