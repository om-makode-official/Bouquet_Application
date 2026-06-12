//
//  CalendarView.swift
//  Project_B
//
//  Created by Sai Krishna on 6/5/26.
//

import Foundation
import SwiftUI

enum DayStatus {
    case available
    case booked
}

struct CalendarDay: Identifiable {
    let id: String
    let date: Date?
    let dayNumber: String
    let isToday: Bool
    var status: DayStatus
}

struct BookingSession: Hashable {
    let id: Int
    let startDate: Date
    let endDate: Date
}

struct CustomCalendarView: View {
    
    let databaseBookings: [(Int?, Double?, Double?)]?
    let navigateToAddNewBookingScreen: ((_ bookingId: Int?,_ startDate: Date?,_ endDate: Date?) -> Void)
    
    @State var currentMonth: Date = Date()
    @State var calendarDays: [CalendarDay] = []
    @State var selectedBookings: [BookingSession]? = nil
    @State var selectedDateHeader: String = ""
    @State var bookingsByDate: [Date: [BookingSession]] = [:]
    let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        return cal
    }()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = [
        LocalizationManager.shared.localized("Sun"),
        LocalizationManager.shared.localized("Mon"),
        LocalizationManager.shared.localized("Tue"),
        LocalizationManager.shared.localized("Wed"),
        LocalizationManager.shared.localized("Thu"),
        LocalizationManager.shared.localized("Fri"),
        LocalizationManager.shared.localized("Sat")
    ]
    var monthYearHeaderString: String {
        let formatter = DateFormatter()
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                previousMonth()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(Color.black.opacity(0.06)))
                        }
                        
                        Spacer()
                        
                        Text(monthYearHeaderString)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black.opacity(0.5))
                            .id(monthYearHeaderString)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                nextMonth()
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(Color.black.opacity(0.06)))
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 6)
                    
                    HStack {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(calendarDays) { day in
                            Group {
                                if day.dayNumber.isEmpty {
                                    Color.clear
                                } else {
                                    CalendarDayCell(day: day)
                                        .onTapGesture {
                                            if day.status == .booked {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                    selectDay(day)
                                                }
                                            }
                                        }
                                }
                            }
                            .frame(height: 45)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.09), lineWidth: 1)
                        )
                )
                StatusInfoView()
            }
            
            if let bookings = selectedBookings {
                BookingPopupView(
                    dateHeader: selectedDateHeader,
                    bookings: bookings,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedBookings = nil
                        }
                    },
                    navigateToAddNewBookingScreen: navigateToAddNewBookingScreen
                )
            }
        }
        
        .onAppear{
            let components = calendar.dateComponents([.year, .month], from: Date())
            if let firstOfCurrentMonth = calendar.date(from: components) {
                self.currentMonth = firstOfCurrentMonth
            }
            self.generateDaysForCurrentMonth()
        }
    }
    func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
            generateDaysForCurrentMonth()
        }
    }
    
    func previousMonth() {
        if let previous = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previous
            generateDaysForCurrentMonth()
        }
    }
    
    func selectDay(_ day: CalendarDay) {
        guard day.status == .booked, let date = day.date else { return }
        let normalizedDate = calendar.startOfDay(for: date)
        
        let formatter = DateFormatter()
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        
        self.selectedDateHeader = formatter.string(from: date)
        self.selectedBookings = bookingsByDate[normalizedDate]
    }
    
    func generateDaysForCurrentMonth() {
        self.bookingsByDate.removeAll()
        if let bookings = databaseBookings{
            for booking in bookings {
                let startDate = Date(timeIntervalSince1970: (booking.1 ?? 0) / 1000.0)
                let endDate = Date(timeIntervalSince1970: (booking.2 ?? 0) / 1000.0)
                
                let session = BookingSession(id: booking.0 ?? 0, startDate: startDate, endDate: endDate)
                var currentDate = calendar.startOfDay(for: startDate)
                let finalDate = calendar.startOfDay(for: endDate)
                while currentDate <= finalDate {
                    bookingsByDate[currentDate, default: []].append(session)
                    if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                        currentDate = nextDay
                    } else {
                        break
                    }
                }
            }
        }
        
        
        
        let currentMonthComponents = calendar.dateComponents(
            [.year, .month, .timeZone],
            from: currentMonth
        )
        
        guard let firstDayOfMonth = calendar.date(from: currentMonthComponents),
              let monthRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return }
        
        let weekdayOfFirst = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = weekdayOfFirst - 1
        
        var days: [CalendarDay] = []
        for i in 0..<leadingSpaces {
            let uniqueEmptyId = "empty-\(currentMonthComponents.year!)-\(currentMonthComponents.month!)-\(i)"
            days.append(CalendarDay(id: uniqueEmptyId, date: nil, dayNumber: "", isToday: false, status: .available))
        }
        
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        for day in monthRange {
            var components = currentMonthComponents
            components.day = day
            components.timeZone = calendar.timeZone

            guard let date = calendar.date(from: components) else { continue }

            let isToday = todayComponents.year == currentMonthComponents.year &&
                          todayComponents.month == currentMonthComponents.month &&
                          todayComponents.day == day

            let normalizedDate = calendar.startOfDay(for: date)
            
            let status: DayStatus = bookingsByDate[normalizedDate] != nil ? .booked : .available

            let dayId = "\(currentMonthComponents.year!)-\(currentMonthComponents.month!)-\(day)"
            days.append(CalendarDay(
                id: dayId,
                date: date,
                dayNumber: "\(day)",
                isToday: isToday,
                status: status
            ))
        }
        
        self.calendarDays = days
    }
}

struct CalendarDayCell: View {
    let day: CalendarDay
    
    var body: some View {
        ZStack {
            if day.isToday {
                Circle()
                    .fill(StaticColor.shared.color())
                    .shadow(color: .blue.opacity(0.4), radius: 6, x: 0, y: 3)
                
                Text(day.dayNumber)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
            } else if day.status == .booked {
                Circle()
                    .fill(Color.red.opacity(0.14))
                    .overlay(
                        Circle()
                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                    )
                
                Text(day.dayNumber)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.red.opacity(0.85))
                
            } else {
                Circle()
                    .stroke(StaticColor.shared.color(), lineWidth: 1.5)
                    .background(Circle().fill(Color.blue.opacity(0.02)))
                
                Text(day.dayNumber)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
    }
}

struct BookingPopupView: View {
//    @State var isAdmin: Bool = false
    @ObservedObject private var authManager = AuthManager.shared
    let dateHeader: String
    let bookings: [BookingSession]
    let onDismiss: () -> Void
    let navigateToAddNewBookingScreen: ((_ bookingId: Int?,_ startDate: Date?,_ endDate: Date?) -> Void)
    
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        formatter.dateFormat = "MMM d, hh:mm a"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .onTapGesture { onDismiss() }
                .blur(radius: 20)
            
            
            VStack(spacing: 20) {
                HStack {
                    Text(LocalizationManager.shared.localized("Booked Slots"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.black.opacity(0.3))
                            .font(.title2)
                    }
                }
                
                Text(dateHeader)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(bookings, id: \.self) { booking in
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack{
                                        Text(LocalizationManager.shared.localized("CONFIRMED BOOKING"))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(4)
                                        Spacer()
                                        
                                        
                                        if authManager.isAdmin {
                                            Button(action: {
                                                openAddNewBookingScreen(bookingId: booking.id, startDate: booking.startDate, endDate: booking.endDate)
                                            }, label: {
                                                Image(systemName: "square.and.pencil")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(Color.green)
                                            })
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(LocalizationManager.shared.localized("From")): **\(dateTimeFormatter.string(from: booking.startDate))**")
                                        Text("\(LocalizationManager.shared.localized("To")): **\(dateTimeFormatter.string(from: booking.endDate))**")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: 250)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }
    
    func openAddNewBookingScreen(bookingId: Int, startDate: Date, endDate: Date){
        navigateToAddNewBookingScreen(bookingId, startDate, endDate)
    }
}

struct StatusInfoView: View {
    var body: some View {
        HStack(spacing: 24) {
            statusItem(title: LocalizationManager.shared.localized("Today"), isToday: true)
            statusItem(title: LocalizationManager.shared.localized("Available"), isAvailable: true)
            statusItem(title: LocalizationManager.shared.localized("Booked"), isBooked: true)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(Capsule().fill(Color.black.opacity(0.03)))
    }
    
    @ViewBuilder
    private func statusItem(title: String, isToday: Bool = false, isAvailable: Bool = false, isBooked: Bool = false) -> some View {
        HStack(spacing: 8) {
            if isToday {
                Circle()
                    .fill(StaticColor.shared.color())
                    .frame(width: 12, height: 12)
            } else if isAvailable {
                Circle()
                    .stroke(StaticColor.shared.color(), lineWidth: 2)
                    .frame(width: 12, height: 12)
            } else if isBooked {
                Circle()
                    .fill(Color.red.opacity(0.4))
                    .frame(width: 12, height: 12)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
