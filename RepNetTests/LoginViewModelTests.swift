import XCTest
@testable import RepNet // Reemplaza por el nombre de tu app

@MainActor
class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var mockAuthService: AuthAPIServiceMock!
    var mockKeychain: KeychainServiceMock!
    var mockAuthManager: AuthManagerSpy!

    // 'setUp' se ejecuta antes de cada prueba
    override func setUp() {
        super.setUp()
        // 1. Arrange (Comun)
        mockAuthService = AuthAPIServiceMock()
        mockKeychain = KeychainServiceMock()
        mockAuthManager = AuthManagerSpy()
        // 2. Inyecta los mocks
        viewModel = LoginViewModel(
            authAPIService: mockAuthService,
            keychain: mockKeychain
        )
    }

    // 'tearDown' se ejecuta despues de cada prueba
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        mockKeychain = nil
        mockAuthManager = nil
        super.tearDown()
    }

    // --- Caso de Prueba CP_01: Login Exitoso ---
    func testLoginSuccess() async {
        // 1. Arrange (Especifico)
        let loginResponse = makeSampleLoginResponse()
        mockAuthService.loginResult = .success(loginResponse) // Configura el mock
        
        viewModel.email = "nuevo@ejemplo.com"
        viewModel.password = "V4lidPassw0rd123!"

        // 2. Act
        await viewModel.login(with: mockAuthManager)

        // 3. Assert (Verificar)
        XCTAssertNil(viewModel.errorMessage, "errorMessage deberia ser nil en un login exitoso")
        XCTAssertEqual(mockKeychain.savedAccessToken, loginResponse.accessToken, "El access token no se guardo")
        XCTAssertEqual(mockKeychain.savedRefreshToken, loginResponse.refreshToken, "El refresh token no se guardo")
        XCTAssertTrue(mockAuthManager.loginCalled, "authManager.login() no fue llamado")
        XCTAssertEqual(mockAuthManager.loggedInUser?.username, "testuser", "Se paso el usuario incorrecto al authManager")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }

    // --- Caso de Prueba CP_02: Login Fallido ---
    func testLoginFailure_InvalidCredentials() async {
        // 1. Arrange
        let expectedError = "Credenciales invalidas"
        mockAuthService.loginResult = .failure(.serverError(message: expectedError))
        
        viewModel.email = "usuario@ejemplo.com"
        viewModel.password = "inV4lidPassw0rd123!"

        // 2. Act
        await viewModel.login(with: mockAuthManager)

        // 3. Assert
        XCTAssertEqual(viewModel.errorMessage, expectedError, "El mensaje de error no es el esperado")
        XCTAssertNil(mockKeychain.savedAccessToken, "No se deberia guardar ningun token (access)")
        XCTAssertNil(mockKeychain.savedRefreshToken, "No se deberia guardar ningun token (refresh)")
        XCTAssertFalse(mockAuthManager.loginCalled, "authManager.login() no debio ser llamado")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }
}
