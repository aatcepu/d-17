//
//  MainTabView.swift
//  bspeak
//
//  Created by Student on 20/08/26.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // Main content
                ZStack {
                    if selectedTab == 0 {
                        DetectView()
                            .transition(.opacity)
                    } else if selectedTab == 1 {
                        AACGridView()
                            .transition(.opacity)
                    } else {
                        SettingsView()
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)

                // Bottom tab bar
                bottomTabBar
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    // ── BOTTOM TAB BAR ────────────────────────────────────────
    var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "eye",      label: "DETECT",   index: 0)
            tabItem(icon: "keyboard", label: "AAC",      index: 1)
            tabItem(icon: "gearshape",label: "SETTINGS", index: 2)
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color.bsBackground
                .overlay(
                    Rectangle()
                        .fill(Color.bsBorder)
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    func tabItem(icon: String, label: String, index: Int) -> some View {
        let isActive = selectedTab == index

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: isActive ? icon + ".fill" : icon)
                    .font(.system(size: 19, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .bsPrimary : .bsTextDim)
                    .shadow(
                        color: isActive ? Color.bsPrimary.opacity(0.7) : .clear,
                        radius: 6
                    )
                    .frame(height: 24)

                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(isActive ? .bsLilac : .bsTextDim)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
