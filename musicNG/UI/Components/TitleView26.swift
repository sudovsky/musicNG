//
//  TitleView26.swift
//  musicNG
//
//  Created by Max Sudovsky on 05.10.2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct TitleView26: View {

    @Binding var backButtonVisible: Bool
    @Binding var title: String
    @Binding var currentFrame: CurrentFrameID

    @State var backButtonImage: Image? = nil

    var addAction = {}
    var networkAction = {}

    @State var expanded: [Bool] = [false, false, false, false]

    var body: some View {
        
        HStack(alignment: .top) {
            
            HStack(alignment: .center, spacing: 0) {
                if backButtonVisible {
//                    Button {
//                        PlaylistCoordinator.shared.current = nil
//                    } label: {
//                        (backButtonImage ?? Image(systemName: "chevron.backward"))
//                            .frame(width: 36, height: 36)
//                            .font(.system(size: 25))
//                            .padding(.leading, 4)
//                    }
//                    .frame(width: 36, alignment: .center)
//                    .transition(.opacity.combined(with: .move(edge: .trailing)))
//                    .buttonStyle(.plain)
                   
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 36, height: 36, alignment: .center)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .background {
                            (backButtonImage ?? Image(systemName: "chevron.backward"))
                                .frame(width: 36, height: 36)
                                .font(.system(size: 25))
                                .padding(.leading, 4)
                        }
                        .onTapGesture {
                            PlaylistCoordinator.shared.current = nil
                        }
                }

                Text(currentFrame == .settings ? "Settings".localized : currentFrame == .search ? "Search".localized : title)
                    .font(titleFont)
                    .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .padding(.leading, backButtonVisible ? 0 : 16)
                    .padding(.trailing, 16)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .glassEffect(.regular)
            .clipShape(.capsule)
            .contentShape(.capsule)
            .onTapGesture {
                if backButtonVisible {
                    PlaylistCoordinator.shared.current = nil
                }
            }
            Spacer()
            
            GlassEffectContainer(spacing: 20) {
                VStack(spacing: 0) {
                    Button {
                        if currentFrame != .settings, currentFrame != .search {
                            toggleExpand()
                        } else {
                            currentFrame = .playlist
                            UIApplication.shared.endEditing()
                        }
                    } label: {
                        Image(systemName: (currentFrame == .settings || currentFrame == .search ?  "xmark" : "line.3.horizontal.circle"))
                            .menuButton()
                    }
                    .buttonStyle(.plain)
                    
                    if expanded[0] {
                        Button {
                            toggleExpand()
                            addAction()
                        } label: {
                            Image(systemName: "plus")
                                .menuButton()
                        }
                        .buttonStyle(.plain)
                        .offset(y: expanded[0] ? 20 : 0)
                        .transition(.move(edge: .top))
                    }
                    
                    if expanded[1] {
                        Button {
                            toggleExpand()
                            networkAction()
                        } label: {
                            Image(systemName: "network")
                                .menuButton()
                        }
                        .buttonStyle(.plain)
                        .offset(y: expanded[0] ? 40 : 0)
                        .transition(.move(edge: .top))
                    }
                    
                    if expanded[2] {
                        Button {
                            currentFrame = .settings
                            toggleExpand()
                        } label: {
                            Image(systemName: "gearshape")
                                .menuButton()
                        }
                        .buttonStyle(.plain)
                        .offset(y: expanded[0] ? 60 : 0)
                        .transition(.move(edge: .top))
                    }
                    
                    if expanded[3] {
                        Button {
                            currentFrame = .search
                            toggleExpand()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .menuButton()
                        }
                        .buttonStyle(.plain)
                        .offset(y: expanded[0] ? 80 : 0)
                        .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.62), value: expanded[0])
        .animation(.spring(response: 0.3, dampingFraction: 0.62), value: expanded[1])
        .animation(.spring(response: 0.3, dampingFraction: 0.62), value: expanded[2])
        .animation(.spring(response: 0.3, dampingFraction: 0.62), value: expanded[3])
    }
    
    func toggleExpand() {
        if expanded[0] {
            expanded[3].toggle()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.expanded[2].toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.expanded[1].toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.expanded[0].toggle()
            }
        } else {
            expanded[0].toggle()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.expanded[1].toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.expanded[2].toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.expanded[3].toggle()
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        TitleView26(backButtonVisible: .constant(true), title: .constant("Title"), currentFrame: .constant(.playlist))
    } else {
        EmptyView()
    }
}

struct MenuButton: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            return content
                .frame(width: 36, height: 36)
                .font(.system(size: 25))
                .padding(8)
                .glassEffect(.regular.interactive())
                .clipShape(.circle)
                .contentShape(.circle)
        } else {
            return content
                .frame(width: 36, height: 36)
                .font(.system(size: 25))
        }
    }
}

extension View {
    func menuButton() -> some View {
        modifier(MenuButton())
    }
}
