//
//  ResortsListView.swift
//  Project_B
//
//  Created by Om on 6/15/26.
//

import SwiftUI

struct ResortsListView: View {
    @ObservedObject var presenter: HomeScreenPresenter
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        
        switch presenter.loadingState {
        case .idle:
            Color.white
                .ignoresSafeArea()
        case .loading:
            ProgressView()
            //            listView(halls: HallResponseModel.getDummyData())
            //                .redacted(reason: .placeholder)
        case .loaded(let resortData):
            listView(resortData: resortData)
            
        case .error:
            VStack{
                Text("Please connect to server")
                Button(action: {
                    presenter.fetchAllEntities()
                }, label: {
                    Text("Refresh")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(20)
                })
            }
        }
    }
    func listView(resortData: [HallResponseModel]) -> some View{
        VStack{
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    ForEach(resortData, id: \.id) { entity in
                        entityCardView(entity: entity)
                            .onTapGesture{
                                presenter.navigateToDetailsScreen(entity: entity)
                            }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 15)
            }
        }.refreshable {
            presenter.checkRoleStatus()
            
            if presenter.isLikedHallsListView{
                presenter.getLikedHallList()
            }else{
                presenter.fetchAllEntities()
            }
        }
        .alert(item: $presenter.alertType) { alert in
            
            switch alert {
            case let .message(title,message):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    dismissButton: .default(
                        Text("OK")
                    )
                )
                
            case let .action(title,message,action):
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton:
                            .destructive(Text("Yes")){ action() },
                    secondaryButton:
                            .cancel()
                )
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                if authManager.isAdmin {
                    if !presenter.isLikedHallsListView{
                        Button {
                            presenter.navigateToAddResortScreen(entity: nil)
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(StaticColor.shared.color())
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading){
                Button(action: {
                    if presenter.isLikedHallsListView{
                        presenter.isLikedHallsListView = false
                        presenter.getAllHallList()
                    }else{
                        presenter.isLikedHallsListView = true
                        presenter.getLikedHallList()
                    }
                },label: {
                    Image(systemName: presenter.isLikedHallsListView ? "chevron.left.circle.fill" : "heart.circle.fill")
                        .foregroundStyle(StaticColor.shared.color())
                        .font(.system(size: 25, weight: .semibold))
                })
            }
        }
    }
    func entityCardView(entity: HallResponseModel) -> some View{
        ZStack(alignment: .bottom) {
            
            AsyncImage(url: URL(string: "\(StringConstants.shared.base)/\(entity.mainScreenImagePath ?? "")")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height:200)
            .frame(maxWidth:.infinity)
            .clipShape(RoundedRectangle(cornerRadius:24))
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entity.hallName?.getDetails() ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(entity.locationAddress?.getDetails() ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if authManager.isAdmin {
                        Button(action: {
                            presenter.navigateToAddResortScreen(entity: entity)
                        }, label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.green)
                                .font(.system(size: 18, weight: .bold))
                        })
                        
                        Button(action: {
                            
                            presenter.deleteEntityById(id: entity.id ?? 0)
                        }, label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 18, weight: .bold))
                        })
                    }
                }
            }
            .padding(20)
        }
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .contentShape(.rect)
    }
}

