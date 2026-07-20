//
//  AddNewBookingPresenter.swift
//  Project_B
//
//  Created by Om on 6/6/26.
//

import Foundation

class AddNewBookingPresenter: ObservableObject{
    
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(3600)
    @Published var istTimeZone = TimeZone(identifier: "Asia/Kolkata")!
    @Published var isUpdateScreen: Bool = false
    
    let interactor: AddNewBookingInteractorProtocol
    let router: AddNewBookingRouterProtocol
    let hallId: Int
    let bookingId: Int?
    
    var refreshDelegate: RefreshBookingStatusDelegateProtocol?
    
    init(interactor: AddNewBookingInteractorProtocol,router: AddNewBookingRouterProtocol, hallId: Int,bookingId: Int?, startDate: Date?, endDate: Date?) {
        self.interactor = interactor
        self.router = router
        self.hallId = hallId
        self.bookingId = bookingId
        
        if let start = startDate, let end = endDate{
            self.startDate = start
            self.endDate = end
            self.isUpdateScreen = true
        }
    }
    
    func processAndSaveBooking() {
        let startMilliseconds = startDate.timeIntervalSince1970 * 1000.0
        let endMilliseconds = endDate.timeIntervalSince1970 * 1000.0
        
        print("Saving to DB -> Start: \(startMilliseconds), End: \(endMilliseconds)")
        
        let bookingData = Booking(hallId: self.hallId,startDateMs: startMilliseconds, endDateMs: endMilliseconds)
        
        if isUpdateScreen{
            updateBooking(bookingData: bookingData)
        }
        else{
            createNewBookings(bookingData: bookingData)
        }
    }
    
    func createNewBookings(bookingData: Booking){
        Task{
            do{
                
                let response = try await interactor.createBooking(forHallId: self.hallId, booking: bookingData)
                
                await MainActor.run{
                    refreshDelegate?.initialLoad()
                    navigateBack()
                }
                
                print("create booking response:++++++", response)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func updateBooking(bookingData: Booking){
        Task{
            do{
                let response = try await interactor.updateBooking(forHallId: self.hallId, bookingId: self.bookingId ?? 0, booking: bookingData)
                
                await MainActor.run{
                    refreshDelegate?.initialLoad()
                    navigateBack()
                }
                
                print("update booking response++++++++", response)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteBooking(){
        Task{
            do{
                let response = try await interactor.deleteBooking(forHallId: self.hallId, bookingId: self.bookingId ?? 0)
                
                await MainActor.run{
                    refreshDelegate?.initialLoad()
                    navigateBack()
                }
                print("delete booking response+++====+++++",response)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    func navigateBack(){
        self.router.navigateBack()
    }
}
