import Foundation
import CryptoKit

final class CryptoProvider {
    private var symmetricKey: SymmetricKey?
    private let keychain = KeychainManager()
    
    enum CryptoError: Error {
        case keyGenerationFailed
        case encryptionFailed
        case decryptionFailed
        case invalidKeySize
        case keyNotFound
    }
    
    func initialize() throws {
        if let existingKey = try? keychain.retrieveKey() {
            self.symmetricKey = existingKey
        } else {
            try generateNewKey()
        }
    }
    
    func encrypt(_ data: Data) throws -> Data {
        guard let key = symmetricKey else {
            throw CryptoError.keyNotFound
        }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            throw CryptoError.encryptionFailed
        }
    }
    
    func decrypt(_ data: Data) throws -> Data {
        guard let key = symmetricKey else {
            throw CryptoError.keyNotFound
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw CryptoError.decryptionFailed
        }
    }
    
    private func generateNewKey() throws {
        let newKey = SymmetricKey(size: .bits256)
        try keychain.storeKey(newKey)
        self.symmetricKey = newKey
    }
}

// MARK: - Keychain Manager
final class KeychainManager {
    enum KeychainError: Error {
        case storeError
        case retrieveError
        case deleteError
    }
    
    private let service = "com.cellularbridge.encryption"
    private let account = "main-key"
    
    func storeKey(_ key: SymmetricKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.withUnsafeBytes { Data($0) }
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeError
        }
    }
    
    func retrieveKey() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw KeychainError.retrieveError
        }
        
        return SymmetricKey(data: keyData)
    }
    
    func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.deleteError
        }
    }
}
