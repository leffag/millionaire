//
//  TimerView.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 26.07.2025.
//

import SwiftUI

enum TimerType {
    case normal, warning, critical
    
    var color: Color {
        switch self {
        case .normal: return .white
        case .warning: return .orange
        case .critical: return .red
        }
    }
    
    static func getType(for secondsLeft: Int) -> TimerType {
           switch secondsLeft {
           case 16...30: return .normal      // 30 до 16 сек
           case 6...15: return .warning      // 15 до 6 сек
           default: return .critical         // 5 сек и меньше
           }
       }
}

struct TimerView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    TimerView()
}
