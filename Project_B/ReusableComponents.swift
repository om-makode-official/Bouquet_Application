//
//  ReusableComponents.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import SwiftUI
import MapKit
import Alamofire


struct StringConstants{
    
    static let shared = StringConstants()
    
    let base = "http://localhost:8081"
//    let base = "http://192.168.31.176:8081" //NEXT_JIO
    
    let baseUrl = "http://localhost:8081/api/halls"
//    let baseUrl = "http://192.168.31.176:8081/api/halls" //NEXT_JIO
    
    let usersBaseUrl = "http://localhost:8081/api/users"
//    let usersBaseUrl = "http://192.168.31.176:8081/api/users"  //NEXT_JIO
    
    let bouquetBaseUrl = "http://localhost:8081/api/bouquets"
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
                        fileName: getFileName(target: targetFolder),
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
    func getFileName(target: String) -> String{
        if target == "profiles"{
            return "avatar.jpg"
        }else if target == "resort"{
            return "resort_asset.jpg"
        }else if target == "bouquet"{
            return "bouquet_asset.jpg"
        }
        return "image.jpg"
    }
}


struct GalleryView: View {
    @Binding var openSheet: Bool
    let images: [String]
    
    @State private var selectedIndex: Int?
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    Text("Image Gallery")
                        .font(.title)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
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
                    .padding(.top)
                }.padding(.horizontal)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(images.indices, id: \.self) { index in
                            
                                
                            AsyncImage(
                                url: URL(string: "\(StringConstants.shared.base)/\(images[index])")
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
                                selectedIndex = index
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
                            selectedIndex != nil
                        },
                        set: { value in
                            if !value {
                                selectedIndex = nil
                            }
                        }
                    )
                ) {

                    if let index = selectedIndex {

    //                    FullScreenImageViewer(
    //                        image: image
    //                    )
                        ZoomableImageView(images: images, initialIndex: index)
                    }else{
                        Text("No Image Available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                }
                
                
            }
        }
    }
}


struct ZoomableImageView: View {
    @Environment(\.dismiss) var dismiss
    let images: [String]
    
    @State private var selectedIndex: Int
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    init(images: [String], initialIndex: Int) {
        self.images = images
        self._selectedIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                TabView(selection: $selectedIndex) {
                    ForEach(images.indices, id: \.self) { index in
                    
                        AsyncImage(url: URL(string: "\(StringConstants.shared.base)/\(images[index])"), content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(selectedIndex == index ? scale : 1.0)
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
                                .tag(index)
                            
                        }, placeholder: {
                            ZStack{
                                Image("placeholder")
                                    .resizable()
                                    .scaledToFit()
                                
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                ProgressView()
                            }
                        })
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                .onChange(of: selectedIndex) { _ in
                    scale = 1
                    lastScale = 1
                }
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(images.indices, id: \.self) { index in
                                
                                
                                AsyncImage(url: URL(string: "\(StringConstants.shared.base)/\(images[index])"), content: { image in
                                    
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIndex == index ? Color.white : Color.clear, lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                selectedIndex = index
                                            }
                                        }
                                        .id(index)
                                    
                                }, placeholder: {
                                    ZStack{
                                        Image("placeholder")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        ProgressView()
                                    }
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: selectedIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }.frame(height: 50)
            }
            
            VStack{
                HStack{
                    Spacer()
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
                Spacer()
            }
        }
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


struct CommonBackgroundView: View{
    var body: some View{
        ZStack{
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
        }
    }
}
