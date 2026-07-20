//
//  FlowerBoutiqueListView.swift
//  Project_B
//
//  Created by Om on 6/15/26.
//

import SwiftUI

struct FlowerBoutiqueListView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject var presenter: HomeScreenPresenter
    @State var searchText: String = ""
    
    @State var selectedPriceRange: PriceRange = .all
    let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    var body: some View {
        
        switch presenter.bouquetLoadingState {
        case .idle:
            Color.white
            
        case .loading:
            ProgressView()
        case .loaded(let data):
            mainView(data: data)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        if authManager.isAdmin {
                            if !presenter.isLikedBouquetListView{
                                Button {
                                    presenter.navigateToAddBouquetScreen(bouquetEntity: nil)
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
                            if presenter.isLikedBouquetListView{
                                presenter.isLikedBouquetListView = false
                                presenter.getAllBouquetList()
                            }else{
                                presenter.isLikedBouquetListView = true
                                presenter.getLikedBouquetList()
                            }
                        },label: {
                            Image(systemName: presenter.isLikedBouquetListView ? "chevron.left.circle.fill" : "heart.circle.fill")
                                .foregroundStyle(StaticColor.shared.color())
                                .font(.system(size: 25, weight: .semibold))
                        })
                    }
                }
                .refreshable {
                    
                    if presenter.isLikedBouquetListView{
                        presenter.getLikedBouquetList()
                    }else{
                        presenter.fetchAllBouquets()
                    }
                }
                .alert(item: $presenter.bouquetAlertType) { alert in
                    
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
        case .error:
            VStack{
                Text("Please connect to server")
                Button(action: {
                    presenter.fetchAllBouquets()
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
    
    
    func mainView(data: [BouquetDetailsEntity]) -> some View{
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchAndHeaderSection
                
                ScrollView {
                    VStack(spacing: 16) {
                        priceRangeHorizontalRibbon
                        resultsCounterBar(dataCount: filteredBouquets(from: data).count)
                        
                        LazyVGrid(columns: columns,spacing: 16) {
                            ForEach(filteredBouquets(from: data)) { bouquet in
                                ZStack(alignment: .bottomTrailing){
                                    bouquetGridCard(bouquet: bouquet)
                                        .onTapGesture{
                                            presenter.navigateToBouquetDetailsScreen(bouquetEntity: bouquet)
                                        }
                                    Spacer()
                                    
                                    if authManager.isAdmin {
                                        HStack{
                                            Button(action: {
                                                presenter.navigateToAddBouquetScreen(bouquetEntity: bouquet)
                                            }, label: {
                                                Image(systemName: "square.and.pencil")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 15, weight: .bold))
                                            })
                                            
                                            Button(action: {
                                                
                                                presenter.deleteBouquetById(id: bouquet.id ?? 0)
                                            }, label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 15, weight: .bold))
                                            })
                                        }.padding()
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
                .padding(10)
            }
        }
    }
    
    func bouquetGridCard(bouquet: BouquetDetailsEntity) -> some View {
        VStack(alignment: .leading,spacing: 8) {
            
            imageView(bouquet: bouquet)
            Text(bouquet.name?.getDetails() ?? "")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .foregroundColor(.black)
            
            Text("₹\(Int(bouquet.price ?? 0))")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .foregroundColor(.gray)
        }
        .padding(8)
        .frame(width: 160)
        .frame(height: 220)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // Optional: gentle depth
    }
    func imageView(bouquet: BouquetDetailsEntity) -> some View{
        ZStack{
            AsyncImage(
                url: URL(string: "\(StringConstants.shared.base)/\(bouquet.mainScreenImage ?? "")")
            ) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack{
                    Image("placeholder")
                        .resizable()
                        .scaledToFill()
                    
                    ProgressView()
                }
            }
        }
        .frame(width: 140, height: 140)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var searchAndHeaderSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search by flower name (e.g. Roses, Orchids)...", text: $searchText)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    var priceRangeHorizontalRibbon: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PriceRange.allCases) { range in
                    let isSelected = selectedPriceRange == range
                    
                    PriceFilterChipView(range: range, isSelected: isSelected) {
                        withAnimation(.snappy(duration: 0.25)) {
                            selectedPriceRange = range
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func resultsCounterBar(dataCount: Int) -> some View {
        HStack {
            Text("\(dataCount) Arrangements Matching")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 4)
    }
    
    
    func filteredBouquets(from bouquets: [BouquetDetailsEntity]) -> [BouquetDetailsEntity] {
        
        bouquets.filter { bouquet in
            
            // Search Filter
            let matchesSearch: Bool
            
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch =
                bouquet.name?
                    .getDetails()
                    .localizedCaseInsensitiveContains(searchText) ?? false
            }
            
            let price = bouquet.price ?? 0
            
            let matchesPrice: Bool
            
            switch selectedPriceRange {
                
            case .all:
                matchesPrice = true
                
            case .under50:
                matchesPrice = price < 50
                
            case .fiftyTo100:
                matchesPrice = price >= 50 && price <= 100
                
            case .over100:
                matchesPrice = price > 100
            }
            
            return matchesSearch && matchesPrice
        }
    }
}

struct PriceFilterChipView: View {
    let range: PriceRange
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(range.rawValue)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primary : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : .secondary)
            .cornerRadius(20)
            .onTapGesture(perform: onTap)
    }
}
