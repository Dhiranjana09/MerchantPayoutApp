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

    var form = FormState()
    private(set) var screen: Screen = .form
    private(set) var submissionState: SubmissionState = .idle

    private let repository: MerchantPayoutRepository
    private let deviceIdentityService: DeviceIdentityProviding

    init(
        repository: MerchantPayoutRepository = RemoteMerchantPayoutRepository(),
        deviceIdentityService: DeviceIdentityProviding = DeviceIdentityService()
    ) {
        self.repository = repository
        self.deviceIdentityService = deviceIdentityService
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

    func continueToConfirmation() {
        guard isFormValid else { return }
        submissionState = .idle
        screen = .confirmation
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
