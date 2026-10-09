//
//  BiometricAuthenticationService.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 09/10/2026.
//

import LocalAuthentication

nonisolated enum BiometricOutcome: Sendable {
    case authenticated
    case cancelled
    case unavailable(String)
}

nonisolated protocol BiometricAuthenticating: Sendable {
    func authenticate() async -> BiometricOutcome
}

nonisolated final class BiometricAuthenticationService: BiometricAuthenticating {
    func authenticate() async -> BiometricOutcome {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &evaluationError
        ) else {
            return .unavailable(
                evaluationError?.localizedDescription
                    ?? "Face ID or Touch ID is unavailable."
            )
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to continue with this payout."
            )
            return .authenticated
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                return .cancelled
            default:
                return .unavailable(error.localizedDescription)
            }
        } catch {
            return .unavailable(error.localizedDescription)
        }
    }
}
