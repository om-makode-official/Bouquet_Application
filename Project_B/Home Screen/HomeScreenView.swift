//
//  HomeScreenView.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

struct HomeScreenView: View{
    @StateObject var presenter: HomeScreenPresenter
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        ZStack{
            CommonBackgroundView()
            VStack(spacing: 0){
                if !presenter.isLikedHallsListView && !presenter.isLikedBouquetListView{
                    tabView()
                }
                tabViewContents()
                Spacer()
            }
            .navigationTitle(presenter.selectedTab.title)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                
                ToolbarItem(placement: .topBarTrailing){
                    if !presenter.isLikedHallsListView{
                        Button(action: {
                            presenter.navigateToProfileScreen()
                        }, label: {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundStyle(StaticColor.shared.color())
                                .font(.system(size: 25, weight: .semibold))
                        })
                    }
                }
                
            }
        }
    }
    
    private func tabView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(presenter.contentTabs, id: \.id) { content in
                    ZStack {
                        Image(content.image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(16/9)
                        
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom))
                        
                        VStack{
                            Spacer()
                            Text(content.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                        }
                        
                    }
                    .frame(width: 140, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .contentShape(Rectangle())
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(presenter.selectedTab == content ? StaticColor.shared.color() : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom) , lineWidth: 3)
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            presenter.selectedTab = content
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func tabViewContents() -> some View{
        switch presenter.selectedTab {
        case .halls:
            ResortsListView(presenter: presenter)
        case .bouquet:
            FlowerBoutiqueListView(presenter: presenter)
        case .items:
            Text("3rd")
        case .other:
            Text("Others...")
        }
    }
}

