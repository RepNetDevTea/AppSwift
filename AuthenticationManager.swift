//
//  AuthenticationManager.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import Foundation
import Combine

// este archivo es el corazon del estado de autenticacion de toda la app.
// el `authenticationmanager` es la "unica fuente de la verdad" para saber si un usuario
// ha iniciado sesion o no. al ser un `observableobject`, toda la ui de la app
// puede reaccionar instantaneamente a los cambios en `isauthenticated`.

// `@mainactor` para asegurar que los cambios que afectan la ui se hagan en el hilo principal.
@MainActor
class AuthenticationManager: ObservableObject {
    
    // el booleano principal que controla si se muestra la pantalla de login o el `maintabview`.
    @Published var isAuthenticated = false
    
    // aqui se guardan los datos del usuario que ha iniciado sesion.
    // es opcional porque es `nil` cuando nadie ha iniciado sesion.
    // cualquier vista puede acceder a `authmanager.user` para obtener el nombre, email, etc.
    @Published var user: UserDTO? = nil

    // esta funcion es llamada por el `loginviewmodel` *despues* de que la api confirma el login.
    // su trabajo es actualizar el estado global de la app.
    func login(user: UserDTO) {
        // guarda los datos del usuario.
        self.user = user
        // cambia el estado a autenticado, lo que provocara que la ui cambie a `maintabview`.
        isAuthenticated = true
        print("usuario autenticado.")
    }

    // esta funcion se llama para cerrar la sesion del usuario.
    func logout() {
        // 1. se borran los datos del usuario en memoria.
        self.user = nil
        // 2. se cambia el estado a no autenticado para mostrar la pantalla de login.
        isAuthenticated = false
        // 3. se intenta borrar los tokens guardados de forma segura en el keychain.
        // `try?` ignora cualquier error que pueda ocurrir al borrar del keychain.
        try? KeychainService.deleteTokens()
        print("sesion del usuario cerrada.")
    }
}
