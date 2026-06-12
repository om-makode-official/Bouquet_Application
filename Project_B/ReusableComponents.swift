//
//  ReusableComponents.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
//

import Foundation
import SwiftUI
import MapKit
import Alamofire


struct StringConstants{
    
    static let shared = StringConstants()
    
    let baseUrl = "http://localhost:8081/api/halls"
}


struct StaticColor{
    
    static let shared = StaticColor()
    
    func color() -> LinearGradient{
        return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ImageUpload{
    private let baseURLString = StringConstants.shared.baseUrl
    
    static let shared = ImageUpload()
    
    func uploadImage(image: UIImage, targetFolder: String) async throws -> String {
        let uploadURLString = "\(baseURLString)/upload?folder=\(targetFolder)"
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.badURL)
        }
        
        let res = try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: { multipart in
                    multipart.append(
                        imageData,
                        withName: "file", // Matches @RequestParam("file") in Java
                        fileName: targetFolder == "profiles" ? "avatar.jpg" : "hall_asset.jpg",
                        mimeType: "image/jpeg"
                    )
                },
                to: uploadURLString,
                method: .post
            )
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let imageUrl):
                    print("Image uploaded successfully via Alamofire to folder: \(targetFolder)")
                    continuation.resume(returning: imageUrl)
                    
                case .failure(let error):
                    print("Alamofire multi-part upload network context failure")
                    continuation.resume(throwing: error)
                }
            }
        }
        print("Response Path Result:", res)
        return res
    }
}


struct GalleryView: View {
    @Binding var openSheet: Bool
    let images: [String]
    
    @State private var selectedImage: String?
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(images, id: \.self) { item in
                        
                            
                        AsyncImage(
                            url: URL(string: item)
                        ) { image in

                            image
                                .resizable()
                                .scaledToFit()

                        } placeholder: {

                            Image("placeholder")
                                .resizable()
                                .scaledToFit()

                        }
                        .clipped()
                        .onTapGesture {
                            selectedImage = item
                        }
                    }
                }
            }
            .navigationTitle("All Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        openSheet = false
                    }
                    .fontWeight(.bold)
                }
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: {
                        selectedImage != nil
                    },
                    set: { value in
                        if !value {
                            selectedImage = nil
                        }
                    }
                )
            ) {

                if let image = selectedImage {

                    FullScreenImageViewer(
                        image: image
                    )

                }

            }
            
            Button(action: {
                self.openSheet = false
            }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .clipShape(Circle())
            })
            .padding()
        }
    }
}

// MARK: - Full Screen Image Viewer
struct FullScreenImageViewer: View {
    let image: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            VStack{
                Spacer()
                ZoomableImageView(imageName: image)
                Spacer()
            }
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let imageName: String
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    var body: some View {
        AsyncImage(
            url: URL(string: imageName)
        ) { image in

            image
                .resizable()
                .scaledToFit()

        } placeholder: {

            ProgressView()

        }.scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = lastScale * value
                        scale = min(max(newScale, 1), 5)
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .ignoresSafeArea()
    }
}



struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let initialLatitude: Double?
    let initialLongitude: Double?
    
    var onSelectLocation: (CLLocationCoordinate2D) -> Void
    
    @State private var region: MKCoordinateRegion

    init(initialLatitude: Double?, initialLongitude: Double?, onSelectLocation: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onSelectLocation = onSelectLocation
        self.initialLatitude = initialLatitude
        self.initialLongitude = initialLongitude
        
        let defaultLat = initialLatitude ?? 17.3850
        let defaultLon = initialLongitude ?? 78.4867
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: defaultLat, longitude: defaultLon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region)
                    .edgesIgnoringSafeArea(.bottom)
                
                VStack {
                    Image(systemName: "mappin")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.red)
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 3)
                        .offset(y: -20)
                    
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 8, height: 4)
                        .scaleEffect(x: 1, y: 0.5)
                        .offset(y: -20)
                }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Coordinates")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(String(format: "Lat: %.6f, Lon: %.6f", region.center.latitude, region.center.longitude))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                        
                        Button(action: {
                            onSelectLocation(region.center)
                            dismiss()
                        }) {
                            Text("Confirm Location")
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Pinpoint Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
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
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCardModifier())
    }
}
