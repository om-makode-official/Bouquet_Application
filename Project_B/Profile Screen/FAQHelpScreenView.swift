//
//  FAQHelpScreenView.swift
//  Project_B
//
//  Created by Sai Krishna on 6/8/26.
//

import Foundation
import SwiftUI

struct FAQHelpScreenView: View {
    @State private var searchText: String = ""
    
    var filteredFAQs: [FAQItem] {
        FAQItem.sampleFAQs.filter { faq in
            let matchesSearch = searchText.isEmpty ||
            faq.question.localizedCaseInsensitiveContains(searchText) ||
            faq.answer.localizedCaseInsensitiveContains(searchText)
            
            return matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    LazyVStack(spacing: 14) {
                        if filteredFAQs.isEmpty {
                            questionNotAvailableView
                        } else {
                            ForEach(filteredFAQs) { faq in
                                FAQRowView(faq: faq)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .navigationTitle("Help & FAQ")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search topics or keywords...")
            }
        }
    }
    
    
    var questionNotAvailableView: some View{
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No Results Found")
                .font(.headline)
            Text("Try searching for different keywords.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 48)
    }
}
struct FAQRowView: View{
    @State private var isExpanded: Bool = false
    @State var faq: FAQItem
    
    var body: some View{
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(alignment: .center, spacing: 16) {
                        Text(faq.question)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14, weight: .bold))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded {
                    Text(faq.answer)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
    }
}


struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    
    static let sampleFAQs: [FAQItem] = [
        FAQItem(question: "Q1",
                answer: "A1"),
        FAQItem(question: "Q2",
                answer: "A2"),
        
    ]
}
