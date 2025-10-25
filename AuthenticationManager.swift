//
//  AuthenticationManager.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    

    @Published var isAuthenticated = false
    
    
    @Published var user: UserDTO? = nil

  
    func login(user: UserDTO) {
        self.user = user
        isAuthenticated = true
        print("usuario autenticado.")
    }

    func logout() {
        self.user = nil
       
        isAuthenticated = false
        try? KeychainService.deleteTokens()
        print("sesion del usuario cerrada.")
    }
}
