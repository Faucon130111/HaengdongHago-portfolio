//
//  SplashView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/25/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.launchBackground).ignoresSafeArea()
            Image(.launchLogo)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SplashView()
}
