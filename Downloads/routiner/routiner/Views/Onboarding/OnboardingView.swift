import SwiftUI

// MARK: - What is this file?
// The very first screen a new user sees — matches the purple/indigo
// gradient "Create Good Habits" screens in the Figma file. It's 3 swipeable
// pages, then a "Continue with E-mail" button that finishes onboarding.
//
// There's no real Model/ViewModel needed here — this screen has no
// business logic, just some text per page and "have we onboarded yet?"
// state, so it's fine for a simple screen like this to keep its own @State.
// Not every screen in MVVM needs its own ViewModel class.

// A tiny local model just for the 3 pages of marketing copy.
private struct OnboardingPage: Identifiable {
    let id = UUID()
    let headline: String
    let subtext: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(headline: "Create\nGood Habits",
                   subtext: "Change your life by slowly adding new healthy habits and sticking to them."),
    OnboardingPage(headline: "Track\nYour Progress",
                   subtext: "See your streaks and daily goals at a glance, right from the home screen."),
    OnboardingPage(headline: "Stay Together\nand Strong",
                   subtext: "Invite friends, join challenges, and keep each other accountable.")
]

struct OnboardingView: View {
    // Which page (0, 1, or 2) is currently showing.
    @State private var currentPage = 0

    // Controls whether LoginView is currently covering the screen.
    // Toggled to true by the "Continue with E-mail" button below.
    @State private var isShowingLogin = false

    var body: some View {
        ZStack {
            // The diagonal purple-to-indigo background from the design.
            LinearGradient(colors: [AppTheme.gradientTop, AppTheme.gradientBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xxl) {
                // TabView with .page style gives us free swipeable pages.
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Spacer()

                            Text(page.headline)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                                // Guarantees the three-line headline can't be
                                // truncated on a small phone or at large
                                // Dynamic Type sizes.
                                .minimumScaleFactor(0.7)

                            Text(page.subtext)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                        .tag(index) // tag() links this page to `currentPage`'s value
                    }
                }
                // The built-in dots are switched OFF and drawn by hand below.
                //
                // Why: styling the system dots requires mutating
                // `UIPageControl.appearance()`, which is a GLOBAL, app-wide,
                // permanent change to every page control in the process. The
                // old code did that inside `.onAppear` and never undid it — so
                // onboarding quietly repainted page dots for the whole app,
                // including any added later on a white background, where white
                // dots are invisible. Drawing our own keeps the change local.
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator

                // "Continue with E-mail" opens LoginView on top of this
                // screen. LoginView itself is what eventually sets
                // hasCompletedOnboarding = true once the (fake) sign-in
                // passes validation.
                Button {
                    isShowingLogin = true
                } label: {
                    Text("Continue with E-mail")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)

                Text("By continuing you agree to our Terms of Service and Privacy Policy")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        // .fullScreenCover slides LoginView up to cover the ENTIRE screen
        // (unlike .sheet, which leaves a peek of what's behind it) —
        // the right choice for an auth screen like this one.
        .fullScreenCover(isPresented: $isShowingLogin) {
            LoginView()
        }
    }

    /// Hand-drawn page dots. The active one is a stretched capsule rather than
    /// a bigger circle — the same treatment the Figma design uses.
    private var pageIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(index == currentPage ? 1 : 0.35))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
        .animation(.snappy, value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")
    }
}

#Preview {
    OnboardingView()
}
