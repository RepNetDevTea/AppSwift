//
//  LoginIntegrationTests.swift
//  RepNet
//
//  Created by Angel Bosquez on 23/10/25.
//


import XCTest
@testable import RepNet // Reemplaza RepNet con el nombre de tu app

@MainActor
class LoginIntegrationTests: XCTestCase {

    // No necesitas mocks aquí

    func testLoginSuccess() async {
        // Arrange
        let viewModel = LoginViewModel() // Usa el init real, que usa los servicios reales
        let authManager = AuthenticationManager() // Usa el real si es necesario para el flujo

        // --- IMPORTANTE: Usa credenciales VÁLIDAS que existan en el backend ---
        viewModel.email = "nuevo@ejemplo.com"
        viewModel.password = "V4lidPassw0rd123!"
        // --- ---

        // Act
        await viewModel.login(with: authManager) // Llama a la función real

        // Assert (Verifica el estado del ViewModel DESPUÉS de la llamada a la API)
        XCTAssertNil(viewModel.errorMessage, "Login falló: \(viewModel.errorMessage ?? "Error desconocido")") // Falla si hay un mensaje de error
        XCTAssertFalse(viewModel.isLoading, "isLoading debería ser false después del login") // Falla si sigue cargando
        // Puedes añadir más XCTAsserts si quieres verificar otros estados del ViewModel
        // XCTAssertNotNil(authManager.user, "AuthManager no recibió el usuario") // Verifica si AuthManager se actualizó
    }

    func testLoginFailure() async {
        // Arrange
        let viewModel = LoginViewModel()
        let authManager = AuthenticationManager()

        // --- IMPORTANTE: Usa credenciales INVÁLIDAS ---
        viewModel.email = "nuevo@ejemplo.com "
        viewModel.password = "inV4lidPassw0rd123!"
        // --- ---

        // Act
        await viewModel.login(with: authManager)

        // Assert
        XCTAssertNotNil(viewModel.errorMessage, "Login debería fallar, pero errorMessage es nil") // Falla si NO hay error
        XCTAssertFalse(viewModel.isLoading, "isLoading debería ser false después del fallo")
        // Opcional: Verifica el mensaje de error específico si lo conoces
        // XCTAssertEqual(viewModel.errorMessage, "Invalid credentials", "Mensaje de error inesperado")
    }

    // Puedes añadir más pruebas para otros escenarios (email incorrecto, campos vacíos, etc.)
}
