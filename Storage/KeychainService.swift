//
//  KeychainService.swift
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//

import Foundation
import Security

// este archivo define el 'keychainservice'
// es una clase 'helper' con metodos estaticos
// para guardar, obtener y borrar los tokens de autenticacion
// de forma segura en el keychain  del dispositivo


class KeychainService {
    
    // MARK: - metodos publicos
    
    // guarda el access token y el refresh token en el keychain
    static func saveTokens(accessToken: String, refreshToken: String) throws {
        try save(token: accessToken, identifier: "com.repnet.accessToken")
        try save(token: refreshToken, identifier: "com.repnet.refreshToken")
    }
    
    // recupera el access token del keychain
    // el networkclient lo usa para anadirlo a las peticiones autenticadas
    static func getAccessToken() -> String? {
        return get(identifier: "com.repnet.accessToken")
    }
    
    // elimina ambos tokens del keychain
    // se llama cuando el usuario cierra sesion (logout)
    static func deleteTokens() throws {
        try delete(identifier: "com.repnet.accessToken")
        try delete(identifier: "com.repnet.refreshToken")
        print("tokens eliminados del keychain.")
    }
    
    // MARK: - funciones privadas auxiliares
    
    // la funcion base para guardar un string en el keychain
    private static func save(token: String, identifier: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: data
        ]
        
        // borra cualquier item antiguo con el mismo identificador
        // esto es para asegurar que podamos sobrescribir
        SecItemDelete(query as CFDictionary)
        
        // anade el nuevo item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            // si falla, lanza un error
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        print("✅ token guardado exitosamente en el keychain con el identificador: \(identifier)")
    }
    
    // la funcion base para leer un string del keychain
    private static func get(identifier: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: kCFBooleanTrue!, // pide que devuelva los datos
            kSecMatchLimit as String: kSecMatchLimitOne // solo queremos un resultado
        ]
        
        var dataTypeRef: AnyObject?
        
        // busca el item en el keychain
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        // si lo encuentra (errsecsuccess) y los datos son validos,
        // los convierte de data a string
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        // si no, devuelve nil
        return nil
    }
    
    // la funcion base para borrar un item del keychain
    private static func delete(identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier
        ]
        
        // intenta borrar el item
        let status = SecItemDelete(query as CFDictionary)
        
        // si se borro (errsecsuccess) o si ya no existia (errsecitemnotfound),
        // se considera un exito
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
