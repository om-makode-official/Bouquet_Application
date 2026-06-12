//
//  AddNewBookingView.swift
//  Project_B
//
//  Created by Sai Krishna on 6/6/26.
//

import Foundation
import SwiftUI

struct AddNewBookingView: View{
    
    @StateObject var presenter: AddNewBookingPresenter
    
    var body: some View{
        VStack{
            HStack{
                Button(action: {
                    presenter.navigateBack()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }).padding(.leading,20)
                
                Spacer()
            }
            
            Form {
                Section(header: Text("Select Appointment Slot")) {
                    
                    DatePicker(
                        "From",
                        selection: $presenter.startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .environment(\.timeZone, presenter.istTimeZone)
                    .onChange(of: presenter.startDate) { newStart in
                        if newStart >= presenter.endDate {
                            presenter.endDate = newStart.addingTimeInterval(3600)
                        }
                    }
                
                    DatePicker(
                        "To",
                        selection: $presenter.endDate,
                        in: presenter.startDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .environment(\.timeZone, presenter.istTimeZone)
                }
                
                Section {
                        Button(action: {
                                presenter.processAndSaveBooking()
                        }, label: {
                            Text(presenter.isUpdateScreen ? "Update Booking" : "Create Booking")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }).listRowBackground(Color.blue)
                        
                        
                }
                if presenter.isUpdateScreen{
                    Section{
                        Button(action: {
                            presenter.deleteBooking()
                        }, label: {
                            Text("Delete Booking")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }).listRowBackground(Color.red)
                    }
                }
            }
        }
        
    }
}
