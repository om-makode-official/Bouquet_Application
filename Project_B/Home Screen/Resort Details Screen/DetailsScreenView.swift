//
//  DetailsScreenView.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import SwiftUI
import MapKit

struct DetailsScreenView: View {
    @StateObject var presenter: DetailsScreenPresenter
    @ObservedObject private var authManager = AuthManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        mainView
    }
    
    var mainView: some View{
        ScrollViewReader { proxy in
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading){
                        GeometryReader { geometry in
                            let minY = geometry.frame(in: .global).minY
                            let isScrollingDown = minY > 0
                            
                            AsyncImage(
                                url: URL(string: "\(StringConstants.shared.base)/\(presenter.entity.mainScreenImagePath ?? "")")
                            ) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height + (isScrollingDown ? minY : 0))
                            .offset(y: isScrollingDown ? -minY : 0)
                            .clipShape(Rectangle())
                        }
                        .frame(height: 350)
                        
                        starRatingsView
                        
                        VStack{
                            HStack{
                                Button(action: {
                                    presenter.navigateBack()
                                }, label: {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .foregroundStyle(StaticColor.shared.color())
                                        .background(.white)
                                        .font(.system(size: 30, weight: .bold))
                                        .clipShape(Circle())
                                    
                                })
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation{
                                        proxy.scrollTo("calendarView", anchor: .center)
                                    }
                                }, label: {
                                    Image(systemName: "calendar.circle.fill")
                                        .foregroundStyle(StaticColor.shared.color())
                                        .background(.white)
                                        .font(.system(size: 30, weight: .bold))
                                        .clipShape(Circle())
                                })
                            }.padding(.horizontal,20)
                                .padding(.top, 50)
                            
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        titleView
                        Divider()
                        priceTagView
                        specificationsListView
                        facilitiesListView
                        aboutView
                        cancellationPolicyView
                        callNowButtonView
                        galleryView
                        
                        if presenter.isCalendarLoadingCompleted{
                            CustomCalendarView(databaseBookings: presenter.bookedDates,
                                               navigateToAddNewBookingScreen: presenter.navigateToAddNewBookingScreen)
                            .id("calendarView")
                        }
                        
                        if presenter.refetchBooking{
                            refreshButtonView
                        }
                        if authManager.isAdmin{
                            addBookingButton
                        }
                        locationView
                        feedbackView
                        feedbackListView
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .offset(y: -30)
                    .padding(.bottom, -30)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .sheet(isPresented: $presenter.openSheet) {
                GalleryView(openSheet: $presenter.openSheet,
                            images: presenter.galleryImages)
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: { presenter.selectedIndex != nil },
                    set: { value in if !value { presenter.selectedIndex = nil } }
                )
            ) {
                if let index = presenter.selectedIndex {
//                    FullScreenImageViewer(image: image)
                    ZoomableImageView(images: presenter.galleryImages, initialIndex: index)
                }
            }
        }
    }
    private var starRatingsView: some View{
        ZStack{
            
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                .frame(maxWidth: .infinity)
                .frame(height: 80)
            
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
                .padding(.leading, 24)
                
                Spacer()
                
                if let viewCount = presenter.viewCount?.getViewsCount(){
                    Text(viewCount)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.trailing, 24)
                }
                
            }.padding(.bottom, 30)
        }
    }
    
    private var titleView: some View{
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(presenter.entity.hallName?.getDetails() ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(presenter.entity.locationAddress?.getDetails() ?? "")
                }
                .font(.callout)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    presenter.isLiked.toggle()
                    presenter.handleLikeButtonTapped(hallId: presenter.entity.id ?? 0, currentLikeState: presenter.isLiked)
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
            if let price = presenter.entity.pricePerDay {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationManager.shared.localized("Price Per Day"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            if let lightBill = presenter.entity.lightBillPerUnit {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(LocalizationManager.shared.localized("Electricity/Unit"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(String(format: "%.2f", lightBill))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var specificationsListView: some View{
        VStack(alignment: .leading, spacing: 12) {
            Text("\(LocalizationManager.shared.localized("Specifications"))")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 12) {
                if let seating = presenter.entity.seatingAvailability {
                    specificationCellView(icon: "person.3.fill", title: "\(LocalizationManager.shared.localized("Seating"))", value: "\(seating) \(LocalizationManager.shared.localized("People"))")
                }
                if let size = presenter.entity.hallSize {
                    specificationCellView(icon: "square.split.bottomrightquarter", title: "\(LocalizationManager.shared.localized("Hall Size"))", value: size)
                }
                if let rooms = presenter.entity.roomCount {
                    specificationCellView(icon: "door.left.hand.open", title: "\(LocalizationManager.shared.localized("Rooms Available"))", value: "\(rooms) \(LocalizationManager.shared.localized("Rooms"))")
                }
                if presenter.entity.parkingCars != nil || presenter.entity.parkingBikes != nil {
                    let cars = presenter.entity.parkingCars ?? 0
                    let bikes = presenter.entity.parkingBikes ?? 0
                    specificationCellView(icon: "car.2.fill", title: "\(LocalizationManager.shared.localized("Parking Capacity"))", value: "\(LocalizationManager.shared.localized("Cars")): \(cars) | \(LocalizationManager.shared.localized("Bikes")): \(bikes)")
                }
            }
        }
    }
    private var facilitiesListView: some View{
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.localized("Facilities"))
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 10) {
                facilitiesCellView(title: "\(LocalizationManager.shared.localized("Air Conditioning (AC)"))", isAvailable: presenter.entity.isACAvailable ?? false, systemIcon: "snowflake")
                facilitiesCellView(title: "\(LocalizationManager.shared.localized("Power Backup"))", isAvailable: presenter.entity.isPowerBackupAvailable ?? false, systemIcon: "bolt.shield")
                facilitiesCellView(title: "\(LocalizationManager.shared.localized("External Catering"))", isAvailable: presenter.entity.allowsExternalCatering ?? false, systemIcon: "fork.knife")
                facilitiesCellView(title: "\(LocalizationManager.shared.localized("Sound System"))", isAvailable: presenter.entity.hasSoundSystem ?? false, systemIcon: "speaker.wave.2")
            }
        }
    }
    private var aboutView: some View{
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationManager.shared.localized("About"))
                .font(.title3)
                .fontWeight(.bold)
            
            Text(presenter.entity.description?.getDetails() ?? "")
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    private var cancellationPolicyView: some View{
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationManager.shared.localized("Cancellation Policy"))
                .font(.headline)
            Text(LocalizationManager.shared.localized("\(presenter.entity.cancellationPolicy ?? "")"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(12)
        }
    }
    
    private var callNowButtonView: some View{
        Button(action: {
            presenter.onTapCallButton(number: presenter.entity.ownerContact ?? "")
        }) {
            HStack {
                Image(systemName: "phone.fill")
                Text(LocalizationManager.shared.localized("Call Now"))
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
    
    private var galleryView: some View{
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
    private var refreshButtonView: some View{
        Button {
            presenter.fetchBookings()
            presenter.refetchBooking = false
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                
                // add this text in the Localizable
                Text("Refresh Bookings")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    private var locationView: some View{
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizationManager.shared.localized("Location"))
                .font(.title3)
                .fontWeight(.bold)
            
            Map(position: .constant(.region(MKCoordinateRegion(
                center: presenter.entity.getCoordinate(),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))) {
                Marker(presenter.entity.hallName?.getDetails() ?? "", coordinate: presenter.entity.getCoordinate())
                    .tint(.blue)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Text(presenter.entity.locationAddress?.getDetails() ?? "")
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
        
        destination.name = presenter.entity.hallName?.getDetails()
        
        MKMapItem.openMaps(
            with: [destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
    
    private var addBookingButton: some View {
        Button(action: {
            presenter.navigateToAddNewBookingScreen(bookingId: nil,startDate: nil, endDate: nil)
        }) {
            HStack {
                Image(systemName: "plus")
                Text(LocalizationManager.shared.localized("Add New Booking"))
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
    
    func specificationCellView(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    func facilitiesCellView(title: String, isAvailable: Bool, systemIcon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemIcon)
                .font(.footnote)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAvailable ? .green : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isAvailable ? Color.green.opacity(0.05) : Color(UIColor.secondarySystemBackground).opacity(0.6))
        .foregroundColor(isAvailable ? .primary : .secondary)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isAvailable ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
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




