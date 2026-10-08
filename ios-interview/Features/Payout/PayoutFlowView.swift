//
//  MerchantPayoutRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 08/10/2026.
//
import SwiftUI

struct PayoutFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PayoutViewModel()

    var body: some View {
        NavigationStack {
            switch viewModel.screen {
            case .form:
                PayoutFormView(viewModel: viewModel)
            case .confirmation:
                PayoutConfirmationView(viewModel: viewModel)
            case let .success(payout):
                PayoutSuccessView(payout: payout, dismiss: dismiss.callAsFunction)
            }
        }
    }
}

private struct PayoutFormView: View {
    @Bindable var viewModel: PayoutViewModel

    var body: some View {
        Form {
            Section(AppStrings.Payout.currencyTitle) {
                Picker(AppStrings.Payout.currencyTitle, selection: $viewModel.form.currency) {
                    Text(Currency.GBP.rawValue).tag(Currency.GBP)
                    Text(Currency.EUR.rawValue).tag(Currency.EUR)
                }
                .pickerStyle(.segmented)
            }

            Section(AppStrings.Payout.amountTitle) {
                TextField(AppStrings.Payout.amountPlaceholder, text: $viewModel.form.amount)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel(AppStrings.Payout.amountAccessibilityLabel)

                if !viewModel.form.amount.isEmpty && viewModel.amountInPence == nil {
                    Text(AppStrings.Payout.amountValidationMessage)
                        .foregroundStyle(.red)
                }
            }

            Section(AppStrings.Payout.ibanTitle) {
                TextField(AppStrings.Payout.ibanPlaceholder, text: $viewModel.form.iban)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityLabel(AppStrings.Payout.ibanAccessibilityLabel)

                Text(AppStrings.Payout.ibanHint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !viewModel.form.iban.isEmpty && !viewModel.isIBANValid {
                    Text(AppStrings.Payout.ibanValidationMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(AppStrings.Payout.sendNavigationTitle)
        .safeAreaInset(edge: .bottom) {
            Button(AppStrings.Payout.continueTitle) {
                viewModel.continueToConfirmation()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.bar)
            .disabled(!viewModel.isFormValid)
        }
    }
}

private struct PayoutConfirmationView: View {
    @Bindable var viewModel: PayoutViewModel

    var body: some View {
        VStack(spacing: 24) {
            List {
                confirmationRow(AppStrings.Payout.amountTitle, value: viewModel.formattedAmount)
                confirmationRow(AppStrings.Payout.currencyTitle, value: viewModel.form.currency.rawValue)
                confirmationRow(AppStrings.Payout.ibanTitle, value: viewModel.maskedIBAN)
            }
            .listStyle(.insetGrouped)

            if case let .failed(message) = viewModel.submissionState {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                Task { await viewModel.submit() }
            } label: {
                if case .submitting = viewModel.submissionState {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(AppStrings.Payout.confirmTitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(isSubmitting)
        }
        .navigationTitle(AppStrings.Payout.confirmNavigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(AppStrings.Payout.backTitle) { viewModel.returnToForm() }
            }
        }
    }

    private var isSubmitting: Bool {
        if case .submitting = viewModel.submissionState { return true }
        return false
    }

    @ViewBuilder
    private func confirmationRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

private struct PayoutSuccessView: View {
    let payout: PayoutResponse
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 54, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 132, height: 132)
                .background(.green, in: Circle())

            Text(AppStrings.Payout.submittedTitle)
                .font(.title.bold())
            Text(CurrencyFormatter.string(pence: payout.amount, currency: payout.currency))
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(AppStrings.Payout.destinationLabel(masked(payout.iban)))
                .foregroundStyle(.secondary)
            Text(AppStrings.Payout.referenceLabel(payout.id))
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()

            Button(AppStrings.Payout.doneTitle, action: dismiss)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
        }
        .padding()
        .navigationTitle(AppStrings.Payout.successNavigationTitle)
    }

    private func masked(_ iban: String) -> String {
        guard iban.count > 8 else { return iban }
        return AppStrings.Payout.maskedIBAN(
            prefix: String(iban.prefix(4)),
            suffix: String(iban.suffix(4))
        )
    }
}
