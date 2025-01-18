//
//  OnboardingSheetView.swift
//  musicNG
//
//  Created by Max Sudovsky on 17.01.2025.
//

import SwiftUI

struct OnboardingSheetView: View {
    
    var title: String
    var text: String
    var image: Image? = nil
    var buttonTitle: String = "Далее"
    
    var action: () -> Void = { }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text(title)
                    .font(.custom("avanti", size: 28))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                ScrollView {
                    if let image = image {
                        //Corner radius two times to make work both .fill and .fit
                        image
                            .resizable()
                            .cornerRadius(15)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: UIScreen.getSize().width - 164, maxHeight: UIScreen.getSize().width - 164)
                            .cornerRadius(15)
                            .padding(.vertical, 24)
                            .shadowed()
                    }
                    
                    Spacer()
                    
                    Text(text)
                        .font(.custom("avanti", size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding([.horizontal], 32)

                    //Spacer()
                }
                .padding(.bottom, 8)
                
                Button {
                    action()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .frame(maxHeight: 52)
                            .foregroundStyle(Color.main)
                        Text(buttonTitle)
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(.back)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                }
                .buttonStyle(GrowingButton())

            }
        }
    }
}

#Preview {
    OnboardingSheetView(title: "Wellcome!", text: "Hello", image: Image(.no))
}
