//
//  BouquetDetailsView.swift
//  Project_B
//
//  Created by Om on 6/19/26.
//

import SwiftUI
import MapKit


struct BouquetDetailsView: View {
    
    @StateObject var presenter: BouquetDetailsPresenter
    
    let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]
    
    var body: some View {

        ScrollView {

            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {

                    GeometryReader { geometry in

                        let minY = geometry.frame(in: .global).minY
                        let isScrollingDown = minY > 0

                        AsyncImage(
                            url: URL(string: "\(StringConstants.shared.base)/\(presenter.selectedImage)")
                        ) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image("placeholder")
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height + (isScrollingDown ? minY : 0)
                        )
                        .offset(y: isScrollingDown ? -minY : 0)
                        .clipShape(Rectangle())
                    }
                    .frame(height: 400)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 200)
                    

                    galleryView
                        

                    VStack {

                        HStack {

                            Button {
                                presenter.navigateToListScreen()
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(StaticColor.shared.color())
                                    .background(.white)
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Button {
                                presenter.openSheet = true
                            } label: {
                                Image(systemName: "photo.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(StaticColor.shared.color())
                                    .background(.white)
                                    .clipShape(Circle())
                            }

                        }
                        .padding(.horizontal,20)
                        .padding(.top,50)

                        Spacer()
                    }

                }

                // Main Card
                VStack(alignment: .leading, spacing: 24) {

                    titleView

                    Divider()

                    priceTagView

                    flowersScrollView
                    

                    Text("Bouquet Size")
                        .font(.headline)

                    bouquetSizeView
                        .frame(maxWidth: .infinity)
                    imageGalleryView

                    aboutView

                    callNowButtonView

                    locationView
                    feedbackView
                    feedbackListView

                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 32,
                        style: .continuous
                    )
                )
                .offset(y: -30)
                .padding(.bottom, -30)

            }

        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .sheet(isPresented: $presenter.openSheet, content: {
            GalleryView(openSheet: $presenter.openSheet,
                        images: presenter.galleryImages)
        })
        .fullScreenCover(
            isPresented: Binding(
                get: { presenter.selectedIndex != nil },
                set: { value in if !value { presenter.selectedIndex = nil } }
            )
        ) {
            if let index = presenter.selectedIndex {
                ZoomableImageView(images: presenter.galleryImages, initialIndex: index)
            }
        }
    }
    
    private var galleryView: some View {
        VStack{
            HStack{
                HStack(spacing: 5){
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= presenter.feedbackResponse?.getRatingCount() ?? 1 ? "star.fill" : "star")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }
    //                    Text(presenter.feedbackResponse?.getTotalRatings() ?? "")
                    Text(presenter.feedbackResponse?.getAverageRating() ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.leading, 10)
                
                Spacer()
                
                if let viewCount = presenter.viewCount?.getViewsCount(){
                    Text(viewCount)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.trailing, 24)
                }
                
            }

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 8) {
                    
                    ForEach(Array(presenter.previewImages.enumerated()), id: \.offset) { index, image in

                        AsyncImage(url: URL(string: "\(StringConstants.shared.base)/\(image)")) { loadedImage in
                            loadedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            presenter.selectedImageIndex == index
                                            ? Color.white
                                            : Color.clear,
                                            lineWidth: 3
                                        )
                                }
                        } placeholder: {
                            ProgressView()
                                .frame(width: 60, height: 50)
                                .background(.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                presenter.selectedImageIndex = index
                            }
                        }
                    }

                    Button(action: {
                        presenter.openSheet = true
                    }, label: {
                        ZStack {

                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white.opacity(0.6))
                                .frame(width: 35, height: 50)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)

                        }
                    })

                }
                
            }
        }.padding(.leading,15)
            .padding(.bottom,35)
    }
    private var titleView: some View{
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(presenter.entity.name?.getDetails() ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(presenter.entity.sellerAddress?.getDetails() ?? "")
                }
                .font(.callout)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    presenter.isLiked.toggle()
                    presenter.handleLikeButtonTapped(bouquetId: presenter.entity.id ?? 0, currentLikeState: presenter.isLiked)
                }
            }) {
                Image(systemName: presenter.isLiked ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(presenter.isLiked ? .red : .gray)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
    private var priceTagView: some View{
            HStack(spacing: 20) {
                VStack{
                    HStack(spacing: 4) {
                        Text("Price: ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(Int(presenter.entity.price ?? 0))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        
                    }
                    
                    HStack{
                        Text("Seller Name:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(presenter.entity.sellerName?.getDetails() ?? "")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    Spacer()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Availability")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(presenter.entity.availability ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green.opacity(0.8))
                }
                
            }
            
            
        
    }

    private var flowersScrollView: some View {

        VStack(alignment: .leading, spacing: 16) {

                Text("Flowers Used")
                .font(.headline)

            if let flowers = presenter.entity.flowersUsed,
               !flowers.isEmpty{

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 110), spacing: 12)
                    ],
                    spacing: 12
                ) {

                    ForEach(Array(Set(flowers)), id: \.self) { flower in

                            HStack(spacing: 8) {

                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.pink)

                                Text(flower.getDetails())
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.pink.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.pink.opacity(0.25), lineWidth: 1)
                            )
                    }
                }

            } else {

                VStack(spacing: 8) {

                    Image(systemName: "leaf")
                        .font(.largeTitle)
                        .foregroundColor(.gray)

                    Text("No Flowers Mentioned")
                        .foregroundColor(.secondary)

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.08))
                .cornerRadius(20)
            }
        }
    }
    private var bouquetSizeView: some View{
            HStack{
                VStack{
                    Image("dummyBouquet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    HStack(spacing: 0){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                        Rectangle()
                            .fill(.black)
                            .frame(width: 100, height: 1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                    Text("\(Int(presenter.entity.sizeWidth ?? 0)) cm")
                        .font(.caption)
                }
                VStack{
                    HStack{
                        VStack{
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .medium))
                            Rectangle()
                                .fill(.black)
                                .frame(width: 1, height: 100)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                            
                        }
                        Text("\(Int(presenter.entity.sizeHeight ?? 0)) cm")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                }
            }
    }
    private var imageGalleryView: some View{
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(LocalizationManager.shared.localized("Gallery"))
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    if !presenter.galleryImages.isEmpty{
                        Button(LocalizationManager.shared.localized("See All")) {
                            presenter.openSheet = true
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                }
                if !presenter.galleryImages.isEmpty{
                    if !presenter.firstFiveImages.isEmpty{
                        galleryScrollView(images: presenter.firstFiveImages, showMoreView: true)
                    }else{
                        galleryScrollView(images: presenter.galleryImages, showMoreView: false)
                    }
                
                }else{
                    HStack{
                        Spacer()
                        Text("No Images Available")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                
            }
            .padding(.top, 15)
        
    }
    private func galleryScrollView(images: [String], showMoreView: Bool) -> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: "\(StringConstants.shared.base)/\(images[index])")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            
                    }
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onTapGesture {
                        presenter.selectedIndex = index
                    }
                }
                
                if showMoreView{
                    Button(action: {
                        presenter.openSheet = true
                    }, label: {
                        ZStack{
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 50, height: 140)
                                .cornerRadius(5)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    })
                }
            }
        }
    }
    
    private var aboutView: some View{
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
            
            Text(presenter.entity.description?.getDetails() ?? "")
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    private var callNowButtonView: some View{
        Button(action: {
            presenter.onTapCallButton(number: presenter.entity.contactNumber ?? "")
        }) {
            HStack {
                Image(systemName: "phone.fill")
                Text("Call Now")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 10)
    }
    private var locationView: some View{
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.title3)
                .fontWeight(.bold)
            
            Map(position: .constant(.region(MKCoordinateRegion(
                center: presenter.entity.getCoordinate(),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))) {
                Marker(presenter.entity.name?.getDetails() ?? "", coordinate: presenter.entity.getCoordinate())
                    .tint(.blue)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Text(presenter.entity.sellerAddress?.getDetails() ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            Button {
                openDirections()
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Directions")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 15)
        }
        .padding(.top, 15)
    }
    private func openDirections() {
        let destination = MKMapItem(
            placemark: MKPlacemark(
                coordinate: presenter.entity.getCoordinate()
            )
        )
        
        destination.name = presenter.entity.name?.getDetails()
        
        MKMapItem.openMaps(
            with: [destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
    
    var feedbackView: some View{
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Rate and review")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= presenter.rating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            presenter.showPostFeedbackButton = true
                            presenter.rating = star
                            presenter.showFeedbackArea = true
                        }
                }
                
                Spacer()
                
                if presenter.showPostFeedbackButton{
                    Button(action: {
                        presenter.postFeedback()
                        presenter.showFeedbackArea = false
                        presenter.showPostFeedbackButton = false
                    }, label: {
                        Image(systemName: "paperplane.circle.fill")
                        //.foregroundStyle(StaticColor.shared.color())
                            .foregroundColor(.green)
                            .font(.system(size: 30, weight: .semibold))
                    })
                }
            }
            
            if presenter.showFeedbackArea{
                    TextField("Additional feedback (optional)",text: $presenter.feedback, axis: .vertical)
                        .lineLimit(3...5)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let feedback = presenter.feedbackResponse?.getCurrentUserFeedback(userId: presenter.userId ?? ""){
                HStack{
                    (
                        Text("Your Feedback: ")
                            .foregroundColor(.gray)
                            .font(.system(size: 12, weight: .medium))
                        +
                        Text(feedback.feedback)
                            .foregroundColor(.black.opacity(0.8))
                            .font(.system(size: 12, weight: .medium))
                    )
                    
                    Button(action: {
                        presenter.showFeedbackArea = true
                        presenter.showPostFeedbackButton = true
                    }, label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20,weight: .medium))
                            .foregroundColor(.green)
                    })
                        
                }
            }
        }
    }
    
    var feedbackListView: some View{
        VStack(alignment: .leading, spacing: 12) {
            //put it in localizable
            Text("Reviews")
                .font(.title3)
                .fontWeight(.bold)
            
            if let feedbackResponse = presenter.feedbackResponse, !feedbackResponse.feedbacks.isEmpty{
                if feedbackResponse.feedbacks.count >= 5{
                    let firstFiveFeedbacks = feedbackResponse.getFirstFiveFeedbacks()
                    
                    LazyVStack(spacing: 12) {
                        ForEach(firstFiveFeedbacks, id: \.userId) { feedback in
                                if feedback.userId == presenter.userId{
                                    feedbackCellView(feedback: feedback.feedback, userName: "You")
                                }
                                else{
                                    feedbackCellView(feedback: feedback.feedback, userName: feedback.userName)
                                }
                        }
                    }
                }else{
                    LazyVStack(spacing: 12) {
                        ForEach(feedbackResponse.feedbacks, id: \.userId) { feedback in
                                if feedback.userId == presenter.userId{
                                    feedbackCellView(feedback: feedback.feedback, userName: "You")
                                }
                                else{
                                    feedbackCellView(feedback: feedback.feedback, userName: feedback.userName)
                                }
//                            }
                        }
                    }
                }
            } else {
                HStack{
                    Spacer()
                    Text("No Reviews Yet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
    }
    
    func feedbackCellView(feedback: String, userName: String) -> some View{
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.secondary)

                Spacer()
                
                Text("~ \(userName)")
                    .font(.system(size: 12,weight: .medium))
                    .foregroundColor(.gray)
            }

            Text(feedback)
                .font(.body)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

}

