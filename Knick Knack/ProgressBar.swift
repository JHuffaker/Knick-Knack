//
//  ProgressBar.swift
//  Knick Knack
//
//  Created by Jordan Huffaker on 2/26/22.
//

import SwiftUI

struct ProgressBar: View {
    @EnvironmentObject var progress: GameSettings
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color(red: 0.93, green: 0.76, blue: 0.22))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress.score, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(red: 0.93, green: 0.76, blue: 0.22))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress.score, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {    
    static var previews: some View {
        ProgressBar()
            .environmentObject(GameSettings())
    }
}
