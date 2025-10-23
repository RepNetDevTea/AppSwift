//
//  KeychainService.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import Security

class KeychainService {
    
    // Guardamos ambos tokens.
    static func saveTokens(accessToken: String, refreshToken: String) throws {
        try save(token: accessToken, identifier: "com.repnet.accessToken")
        try save(token: refreshToken, identifier: "com.repnet.refreshToken")
    }
    
    // Recuperamos el accessToken.
    static func getAccessToken() -> String? {
        return get(identifier: "com.repnet.accessToken")
    }
    
    // --- NUEVA FUNCIÓN AÑADIDA ---
    // Esta es la función que faltaba. Se encarga de eliminar los tokens
    // del Keychain cuando el usuario cierra la sesión.
    static func deleteTokens() throws {
        try delete(identifier: "com.repnet.accessToken")
        try delete(identifier: "com.repnet.refreshToken")
        print("Tokens eliminados del Keychain.")
    }
    
    // --- FUNCIONES PRIVADAS AUXILIARES ---
    // (Estas funciones ya las tenías, pero las incluyo para que el archivo esté completo)
    
    private static func save(token: String, identifier: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: identifier, kSecValueData as String: data]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
        print("✅ Token guardado exitosamente en el Keychain con el identificador: \(identifier)")
    }
    
    private static func get(identifier: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: identifier, kSecReturnData as String: kCFBooleanTrue!, kSecMatchLimit as String: kSecMatchLimitOne]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private static func delete(identifier: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: identifier]
        let status = SecItemDelete(query as CFDictionary)
        // Es un éxito si se borra o si el ítem no se encuentra.
        guard status == errSecSuccess || status == errSecItemNotFound else {
             throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
