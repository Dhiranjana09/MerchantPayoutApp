import Foundation
import Security

nonisolated protocol DeviceIdentityProviding: Sendable {
    func deviceID() throws -> String
}

nonisolated enum DeviceIdentityError: LocalizedError, Sendable {
    case keychainRead(OSStatus)
    case keychainWrite(OSStatus)
    case invalidStoredValue

    var errorDescription: String? {
        switch self {
        case let .keychainRead(status):
            return "Unable to read the device identity from the Keychain (\(status))."
        case let .keychainWrite(status):
            return "Unable to store the device identity in the Keychain (\(status))."
        case .invalidStoredValue:
            return "The stored device identity is invalid."
        }
    }
}

nonisolated final class DeviceIdentityService: DeviceIdentityProviding, Sendable {
    private let service = "com.checkout.merchant-payout"
    private let account = "device-identity"

    func deviceID() throws -> String {
        switch readDeviceID() {
        case let .success(identifier):
            return identifier
        case .notFound:
            return try createDeviceID()
        case let .failure(error):
            throw error
        }
    }

    private func createDeviceID() throws -> String {
        let identifier = UUID().uuidString
        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: Data(identifier.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            return try deviceID()
        }
        guard status == errSecSuccess else {
            throw DeviceIdentityError.keychainWrite(status)
        }
        return identifier
    }

    private func readDeviceID() -> ReadResult {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard
                let data = result as? Data,
                let identifier = String(data: data, encoding: .utf8),
                !identifier.isEmpty
            else {
                return .failure(.invalidStoredValue)
            }
            return .success(identifier)
        case errSecItemNotFound:
            return .notFound
        default:
            return .failure(.keychainRead(status))
        }
    }

    private enum ReadResult {
        case success(String)
        case notFound
        case failure(DeviceIdentityError)
    }
}
