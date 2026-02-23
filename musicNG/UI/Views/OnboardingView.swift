//
//  OnboardingView.swift
//  musicNG
//
//  Created by Max Sudovsky on 23.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    
    var onDone: () -> Void = { }
    
    @State private var index = 0
    
    let pages: [OnboardingPage] = [
            .init("Hi!".localized,
             "onboarding_text_1".localized,
             Image(.note2)),
            .init("onboarding_title_1".localized,
             "onboarding_text_2".localized,
             Image(.share)),
            .init("onboarding_title_2".localized,
             "onboarding_text_3".localized,
             Image(.files)),
            .init("onboarding_title_3".localized,
             "onboarding_text_4".localized,
             Image(.files)),
            .init("onboarding_title_4".localized,
             "onboarding_text_5".localized,
             Image(.menuEn))
    ]
    
    private var topBar: some View {
        HStack {
            if index > 0 {
                Button("Back") {
                    withAnimation(.spring) {
                        index -= 1
                    }
                }
            }
            
            Spacer()
            
            if index < pages.count - 1 {
                Button("Skip") {
                    withAnimation(.spring) {
                        index = pages.count - 1
                    }
                }
            }
        }
        .font(.headline)
        .padding()
    }
    
    @ViewBuilder private func pageView(_ page: OnboardingPage) -> some View {
        
        VStack(spacing: 8) {
            
            Text(page.title)
                .font(.custom("avanti", size: 28))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)

            ScrollView {
                if let image = page.image {
                    //Corner radius two times to make work both .fill and .fit
                    image
                        .resizable()
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: (OrientationCoordinator.shared.vertical ? UIScreen.getSize().width : UIScreen.getSize().height / 1.5) - 164,
                               maxHeight: (OrientationCoordinator.shared.vertical ? UIScreen.getSize().width : UIScreen.getSize().height / 1.5) - 164)
                        .cornerRadius(15)
                        .padding(.vertical, 24)
                        .shadowed()
                }
                
                Spacer()
                
                Text(page.text)
                    .font(.custom("avanti", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding([.horizontal], 32)
            }
            .padding(.bottom, 8)
        }

    }
    
    //TODO: - move to reusable
    private var progressPills: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .frame(width: i == index ? 22 : 8, height: 8)
                    .animation(.spring, value: index)
                    .foregroundStyle(.secondary.opacity(i == index ? 1 : 0.35))
            }
        }
        .padding(.top, 4)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 16) {
            progressPills
            
            Button {
                if index < pages.count - 1 {
                    withAnimation(.spring) {
                        index += 1
                    }
                } else {
                    onDone()
                }
            } label: {
                Text(index < pages.count - 1 ? "Next" : "Got it!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.back)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 16))
        }
        .padding()
    }
    
    var body: some View {
        VStack {
            topBar
            
            TabView(selection: $index) {
                ForEach(pages.indices, id: \.self) { page in
                    pageView(pages[page])
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            bottomBar
        }
    }
}
