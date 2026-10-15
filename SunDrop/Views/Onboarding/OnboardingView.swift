import SwiftUI

struct OnboardingView: View {
    @State private var vm = OnboardingViewModel()
    @AppStorage(SettingsKey.hasOnboarded) private var hasOnboarded = false
    @FocusState private var nameFocused: Bool
    @State private var isFinishing = false

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            GrainBackground(warmTop: true)

            VStack(spacing: 0) {
                TabView(selection: $vm.page) {
                    WelcomePage().tag(0)
                    NamePage(name: $vm.name, focused: $nameFocused).tag(1)
                    ReminderPage(time: $vm.reminderTime).tag(2)
                    CadencePage(cadence: $vm.cadence).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: vm.page) { _, _ in nameFocused = false }

                PageDots(count: OnboardingViewModel.pageCount, current: vm.page)
                    .padding(.bottom, 20)

                HStack(spacing: 12) {
                    if vm.page > 0 {
                        Button("Back") { vm.back() }
                            .buttonStyle(SunButtonStyle(fill: .sunSecondary, foreground: .sunOnSecondary))
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    Button(vm.isLastPage ? "Light up my jar ☀️" : "Continue") {
                        if vm.isLastPage {
                            guard !isFinishing else { return }
                            isFinishing = true
                            Task {
                                await vm.finish()
                                withAnimation { hasOnboarded = true }
                            }
                        } else {
                            vm.next()
                        }
                    }
                    .buttonStyle(SunButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.page)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Pages

private struct WelcomePage: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                SunBurst(size: 200)
                SparkleField(count: 10, tint: .raspberryRed)
                    .frame(width: 320, height: 320)
                    .allowsHitTesting(false)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 10) {
                Text("SunDrop")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.sunInk)
                Text("A cozy little jar for the good things.\nDrop in one moment of gratitude a day and watch it glow.")
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.sunInk.opacity(0.8))
                    .padding(.horizontal, 32)
            }
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.65)) { appeared = true }
        }
    }
}

private struct NamePage: View {
    @Binding var name: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            SunBurst(size: 110)
                .frame(height: 150)
            Text("What should we call you?")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Color.sunInk)
            Text("Your jar likes to say hello.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.sunInk.opacity(0.7))

            TextField("Your name", text: $name)
                .focused(focused)
                .textContentType(.givenName)
                .submitLabel(.done)
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.sunInk)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.sunSurface)
                        .shadow(color: Color.raspberryRed.opacity(0.25), radius: 10, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.raspberryRed.opacity(focused.wrappedValue ? 0.8 : 0.25), lineWidth: 2)
                )
                .padding(.horizontal, 36)
                .animation(.easeInOut(duration: 0.2), value: focused.wrappedValue)
            Spacer()
            Spacer()
        }
    }
}

private struct ReminderPage: View {
    @Binding var time: Date

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 54))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.sunflowerGold, Color.raspberryRed)
                .symbolEffect(.bounce, options: .repeating.speed(0.4))
            Text("A gentle daily nudge")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Color.sunInk)
            Text("When would you like to be reminded to drop in a SunDrop?")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.sunInk.opacity(0.75))
                .padding(.horizontal, 36)

            DatePicker("Reminder time", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.sunSurface)
                        .shadow(color: Color.raspberryRed.opacity(0.2), radius: 10, y: 4)
                )
                .padding(.horizontal, 60)
            Spacer()
            Spacer()
        }
    }
}

private struct CadencePage: View {
    @Binding var cadence: ReviewCadence

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("When should the jar open?")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Color.sunInk)
            Text("Pick how often you'd like to look back at your SunDrops.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.sunInk.opacity(0.75))
                .padding(.horizontal, 36)

            VStack(spacing: 14) {
                ForEach(ReviewCadence.allCases) { option in
                    CadenceCard(option: option, isSelected: cadence == option) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { cadence = option }
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 28)
            Spacer()
            Spacer()
        }
    }
}

private struct CadenceCard: View {
    let option: ReviewCadence
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: option.symbol)
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? Color.white : Color.sunSecondary)
                    .frame(width: 44)
                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text(option.blurb)
                        .font(.system(.subheadline, design: .rounded))
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(isSelected ? Color.white : Color.sunInk)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.white : Color.sunInk.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.raspberryRed : Color.sunSurface)
                    .shadow(color: (isSelected ? Color.raspberryRed : Color.black).opacity(0.25),
                            radius: isSelected ? 12 : 5, y: isSelected ? 6 : 2)
            )
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.raspberryRed : Color.sunInk.opacity(0.2))
                    .frame(width: i == current ? 26 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: current)
        .accessibilityHidden(true)
    }
}

#Preview("Day") {
    OnboardingView()
}

#Preview("Night") {
    OnboardingView()
        .preferredColorScheme(.dark)
}
