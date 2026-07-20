//
//  HomeScreenEntity.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import MapKit
import FirebaseCore
import SwiftUI

enum ContentTabsEnum{
    case halls
    case bouquet
    case items
    case other
    
    var id: Self{
        return self
    }
    
    var title: String{
        switch self{
        case .halls:
            return "Resorts"
        case .bouquet:
            return "Bouquets"
        case .items:
            return "3rd"
        case .other:
            return "Others..."
        }
    }
    var image: String{
        switch self{
            
        case .halls:
            return "resort"
        case .bouquet:
            return "bouquet"
        case .items:
            return "placeholder"
        case .other:
            return "placeholder"
        }
    }
}

enum HomeScreenAlertEnum: Identifiable {
    case message(title: String, message: String)
    case action(title: String, message: String, action: () -> Void)
    
    var id: Int {
        switch self {
        case .message(_,_):
            return 0
        case .action(_,_,_):
            return 1
        }
    }
}

enum HomeScreenLoadingState{
    case idle
    case loading
    case loaded([HallResponseModel])
    case error
}

enum BouquetLoadingState{
    case idle
    case loading
    case loaded([BouquetDetailsEntity])
    case error
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case mr
    case hi
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .en: return "English"
        case .mr: return "Marathi"
        case .hi: return "Hindi"
        }
    }
}

struct HallResponseModel: Codable, Identifiable {
    
    let id: Int?
    let hallName: LocalizedStringModel?
    let locationAddress: LocalizedStringModel?
    let description: LocalizedStringModel?
    let ownerContact: String?
    let latitude: Double?
    let longitude: Double?
    let seatingAvailability: Int?
    let hallSize: String?
    let roomCount: Int?
    let parkingCars: Int?
    let parkingBikes: Int?
    let pricePerDay: Double?
    let lightBillPerUnit: Double?
    let isACAvailable: Bool?
    let isPowerBackupAvailable: Bool?
    let allowsExternalCatering: Bool?
    let hasSoundSystem: Bool?
    let cancellationPolicy: String?
    let mainScreenImagePath: String?
    let galleryImagePaths: [String]?
    
    func getCoordinate() -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
    
    static func getDummyData() -> [HallResponseModel] {
        return (0..<6).map { index in
            HallResponseModel(
                id: index,
                hallName: LocalizedStringModel(
                    en: "                           ",
                    mr: "                           ",
                    hi: "                           "
                ),
                locationAddress: LocalizedStringModel(
                    en: "                           ",
                    mr: "                           ",
                    hi: "                           "
                ),
                description: LocalizedStringModel(
                    en: "                           ",
                    mr: "                           ",
                    hi: "                           "
                ),
                ownerContact: "       ",
                latitude: 0,
                longitude: 0,
                seatingAvailability: 00,
                hallSize: "  ",
                roomCount: 0,
                parkingCars: 0,
                parkingBikes: 0,
                pricePerDay: 0,
                lightBillPerUnit: 0,
                isACAvailable: false,
                isPowerBackupAvailable: true,
                allowsExternalCatering: true,
                hasSoundSystem: true,
                cancellationPolicy: "       ",
                mainScreenImagePath: "",
                galleryImagePaths: ["","",""]
            )
        }
    }
}

struct LocalizedStringModel: Codable, Hashable {
    var en: String?
    var mr: String?
    var hi: String?
    
    func getDetails() -> String{
        switch LanguageManager.shared.selectedLanguage{
            
        case "en":
            return en ?? ""
            
        case "mr":
            return mr ?? ""
            
        case "hi":
            return hi ?? ""
            
        default:
            return en ?? ""
        }
    }
}

enum PriceRange: String, CaseIterable, Identifiable {
    case all = "All Prices"
    case under50 = "Under Rs. 50"
    case fiftyTo100 = "Rs. 50 - Rs. 100"
    case over100 = "Over Rs. 100"
    
    var id: String { self.rawValue }
}


struct BouquetDetailsEntity: Identifiable, Codable {
    var id: Int?
    var name: LocalizedStringModel?
    var flowersUsed: [LocalizedStringModel]?
    var sellerName: LocalizedStringModel?
    var sellerAddress: LocalizedStringModel?
    var latitude: Double?
    var longitude: Double?
    var price: Double?
    var availability: String?
    var sizeWidth: Double?
    var sizeHeight: Double?
    var mainScreenImage: String?
    var galleryImages: [String]?
    var description: LocalizedStringModel?
    var contactNumber: String?
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
}
