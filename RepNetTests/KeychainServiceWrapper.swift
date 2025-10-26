import Foundation

// este wrapper  nos permite usar nuestro keychainservice estatico
// con el patron de inyeccion de dependencias.
// conforma al protocolo 'keychainserviceprotocol' y simplemente
// redirige las llamadas a los metodos estaticos de 'keychainservice'.

struct KeychainServiceWrapper: KeychainServiceProtocol {

    func saveTokens(accessToken: String, refreshToken: String) throws {
        // llama al metodo estatico
        try KeychainService.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    func getAccessToken() -> String? {
        // llama al metodo estatico
        return KeychainService.getAccessToken()
    }
    
    // func getRefreshToken() -> String? {
    //     return KeychainService.getRefreshToken() // Descomenta si se anade al protooclo

    func deleteTokens() throws {
        // llama al metodo estatico
        try KeychainService.deleteTokens()
    }
}
