//
//  ContentView.swift
//  InfiniteScrollView
//
//  Created by Ronjie Man-on on 11/9/25.
//

import SwiftUI
import InfiniteScrollView

struct ContentView: View {
    @State private var selectedIndex = MonthIndex(offset: 0)
    @State private var updateTrigger = false
    
    private let calendar = Calendar(identifier: .gregorian)
    private let baseDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                InfiniteScrollView(
                    spacing: 24,
                    changeIndex: selectedIndex,
                    contentMultiplier: 3,
                    updateBinding: $updateTrigger,
                    orientation: .vertical,
                    increaseIndexAction: { MonthIndex(offset: $0.offset + 1) },
                    decreaseIndexAction: { MonthIndex(offset: $0.offset - 1) },
                    onCenteredIndexChanged: { selectedIndex = $0 }
                ) { index in
                    MonthCard(
                        monthIndex: index,
                        calendar: calendar,
                        baseDate: baseDate
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical, 32)
                .background(Color(white: 0.95))
            }
            .navigationTitle("Infinite Calendar")
            .ignoresSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Go to Current Month") {
                        selectedIndex = MonthIndex(offset: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            updateTrigger = true
                        }
                    }
                    .font(.headline)
                }
            }
        }
    }
}

struct MonthIndex: Equatable, Hashable {
    let offset: Int
}

private struct MonthCard: View {
    let monthIndex: MonthIndex
    let calendar: Calendar
    let baseDate: Date
    
    private var monthDate: Date {
        calendar.date(
            byAdding: .month,
            value: monthIndex.offset,
            to: calendar.startOfMonth(for: baseDate)
        ) ?? baseDate
    }
    
    private var title: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: monthDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            WeekdayHeader(calendar: calendar)
            
            LazyVGrid(
                columns: Array(repeating: .init(.flexible(), spacing: 6), count: 7),
                spacing: 6
            ) {
                ForEach(Array(gridEntries.enumerated()), id: \.offset) { entry in
                    if let day = entry.element {
                        DayCell(
                            day: day,
                            calendar: calendar,
                            monthDate: monthDate
                        )
                    } else {
                        Color.clear.aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
    }
    
    private var gridEntries: [Int?] {
        let firstWeekday = calendar.component(.weekday, from: monthDate)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        let days = calendar.range(of: .day, in: .month, for: monthDate) ?? (1..<31)
        var entries = Array(repeating: Optional<Int>.none, count: leadingEmpty)
        entries += days.map { Optional($0) }
        while entries.count % 7 != 0 {
            entries.append(nil)
        }
        return entries
    }
}

private struct WeekdayHeader: View {
    let calendar: Calendar
    
    var body: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        let ordered = symbols.shifted(startingAt: calendar.firstWeekday)
        HStack {
            ForEach(Array(ordered.enumerated()), id: \.offset) { entry in
                Text(entry.element.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct DayCell: View {
    let day: Int
    let calendar: Calendar
    let monthDate: Date
    
    private var isToday: Bool {
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)
        return components.year == monthComponents.year &&
        components.month == monthComponents.month &&
        components.day == day
    }
    
    var body: some View {
        Text("\(day)")
            .font(.body.weight(isToday ? .bold : .regular))
            .foregroundStyle(isToday ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Circle()
                    .fill(isToday ? Color.accentColor : Color.clear)
            )
            .aspectRatio(1, contentMode: .fit)
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

private extension Array where Element == String {
    func shifted(startingAt firstWeekday: Int) -> [String] {
        guard !isEmpty else { return [] }
        let index = (firstWeekday - 1) % count
        let head = Array(self[index...])
        let tail = Array(self[..<index])
        return head + tail
    }
}

#Preview {
    ContentView()
}
