//
//  TimerView.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 23.07.2025.
//

import SwiftUI

struct TimerView: View {
    let duration: String
    
    var body: some View {
        ZStack {
            Capsule()
            HStack {
                    Image(.timer)
                        .foregroundStyle(.backgroundGradientBottom)
                    Text(duration)
            }
            
        }
    }
}

#Preview {
    TimerView(duration: "0:0")
}
