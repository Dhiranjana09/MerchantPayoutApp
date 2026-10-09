//
//  MerchantPayoutRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 08/10/2026.
//
import Foundation
import Observation

@Observable
@MainActor
final class PayoutViewModel {
    struct FormState {
        var amount = ""
        var currency: Currency = .GBP
        var iban = ""
    }

    enum Screen {
        case form
        case confirmation
        case success(PayoutResponse)
    }

    enum SubmissionState {
        case idle
        case submitting
        case failed(String)
    }

    enum BiometricState {
        case idle
        case authenticating
        case cancelled
        case unavailable(String)
    }

    var form = FormState()
    private(set) var screen: Screen = .form
    private(set) var submissionState: SubmissionState = .idle
    private(set) var biometricState: BiometricState = .idle

    private let repository: MerchantPayoutRepository
    private let deviceIdentityService: DeviceIdentityProviding
    private let biometricService: BiometricAuthenticating

    init(
        repository: MerchantPayoutRepository = RemoteMerchantPayoutRepository(),
        deviceIdentityService: DeviceIdentityProviding = DeviceIdentityService(),
        biometricService: BiometricAuthenticating = BiometricAuthenticationService()
    ) {
        self.repository = repository
        self.deviceIdentityService = deviceIdentityService
        self.biometricService = biometricService
    }

    var amountInPence: Int? {
        PayoutInputValidator.amountInPence(from: form.amount)
    }

    var normalizedIBAN: String {
        PayoutInputValidator.normalizedIBAN(form.iban)
    }

    var isIBANValid: Bool {
        PayoutInputValidator.isValidIBAN(form.iban)
    }

    var isFormValid: Bool {
        amountInPence != nil && isIBANValid
    }

    var isAuthenticating: Bool {
        if case .authenticating = biometricState { return true }
        return false
    }

    var biometricAlertMessage: String? {
        switch biometricState {
        case .cancelled:
            return AppStrings.Payout.payoutAuthenticationCancelled
        case let .unavailable(message):
            return AppStrings.Payout.biometricUnavailableMessage(message)
        case .idle, .authenticating:
            return nil
        }
    }

    var formattedAmount: String {
        CurrencyFormatter.string(pence: amountInPence ?? 0, currency: form.currency)
    }

    var maskedIBAN: String {
        let iban = normalizedIBAN
        guard iban.count > 8 else { return iban }
        return AppStrings.Payout.maskedIBAN(
            prefix: String(iban.prefix(4)),
            suffix: String(iban.suffix(4))
        )
    }

    func continueToConfirmation() async {
        guard isFormValid else { return }

        biometricState = .idle

        guard let amountInPence, amountInPence > 100000 else {
            submissionState = .idle
            screen = .confirmation
            return
        }

        biometricState = .authenticating
        let outcome = await biometricService.authenticate()

        switch outcome {
        case .authenticated:
            biometricState = .idle
            submissionState = .idle
            screen = .confirmation

        case .cancelled:
            biometricState = .cancelled

        case let .unavailable(message):
            biometricState = .unavailable(message)
        }
    }

    func dismissBiometricAlert() {
        guard !isAuthenticating else { return }
        biometricState = .idle
    }

    func returnToForm() {
        screen = .form
    }

    func submit() async {
        guard
            case .confirmation = screen,
            isFormValid,
            let amountInPence else {
            return
        }
        submissionState = .submitting

        do {
            let deviceID = try deviceIdentityService.deviceID()
            let response = try await repository.sendPayout(
                amount: amountInPence,
                currency: form.currency,
                iban: normalizedIBAN,
                deviceId: deviceID
            )
            screen = .success(response)
        } catch {
            submissionState = .failed(error.localizedDescription)
        }
    }
}
