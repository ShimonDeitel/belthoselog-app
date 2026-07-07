import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: ComponentLogStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                ComponentLogTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ComponentLogTheme.accent)
                    Text("Unlock Belt and Hose Log Pro")
                        .font(ComponentLogTheme.titleFont)
                        .foregroundColor(ComponentLogTheme.textPrimary)
                    Text("Multi-component tracking with inspection photo notes")
                        .font(ComponentLogTheme.bodyFont)
                        .foregroundColor(ComponentLogTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task { await purchase() }
                    } label: {
                        Text(isPurchasing ? "Processing..." : "Subscribe $1.99/month")
                            .font(ComponentLogTheme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ComponentLogTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(isPurchasing)
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption)
                    }
                    Button("Not now") { dismiss() }
                        .foregroundColor(ComponentLogTheme.textSecondary)
                        .accessibilityIdentifier("dismissPaywallButton")
                }
                .padding()
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchases.purchasePro()
            if purchases.isPro {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
        .environmentObject(ComponentLogStore())
}
