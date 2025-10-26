import Foundation
import UIKit
@testable import RepNet // Reemplaza RepNet por el nombre de tu app

// este archivo contiene todas las simulaciones (mocks) de tus servicios
// nos permiten controlar las respuestas (exito o fallo) sin conectarnos a internet

// --- MOCK PARA AUTHAPISERVICE ---
class AuthAPIServiceMock: AuthAPIServiceProtocol {
    // Variable para controlar la respuesta (exito o fallo)
    var loginResult: Result<LoginResponseDTO, APIError> = .failure(.serverError(message: "Mock no configurado"))
    var signUpResult: Result<Void, APIError> = .failure(.serverError(message: "Mock no configurado"))
    
    // Variables para espiar (spy)
    var loginCalled = false
    var signUpCalled = false
    var capturedCredentials: LoginRequestDTO?
    var capturedUserData: SignUpRequestDTO?

    func login(credentials: LoginRequestDTO) async throws -> LoginResponseDTO {
        loginCalled = true
        capturedCredentials = credentials
        return try loginResult.get() // Falla si loginResult es .failure
    }

    func signUp(userData: SignUpRequestDTO) async throws {
        signUpCalled = true
        capturedUserData = userData
        return try signUpResult.get() // Falla si signUpResult es .failure
    }
}

// --- MOCK PARA KEYCHAINSERVICE ---
class KeychainServiceMock: KeychainServiceProtocol {
    var savedAccessToken: String?
    var savedRefreshToken: String?
    var deleteTokensCalled = false
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        savedAccessToken = accessToken
        savedRefreshToken = refreshToken
    }
    
    func getAccessToken() -> String? {
        return savedAccessToken
    }
    
    func deleteTokens() throws {
        deleteTokensCalled = true
        savedAccessToken = nil
        savedRefreshToken = nil
    }
}

// --- MOCK PARA REPORTSAPISERVICE ---
class ReportsAPIServiceMock: ReportsAPIServiceProtocol {
    // Variables para controlar respuestas
    var fetchMyReportsResult: Result<[ReportResponseDTO], APIError> = .success([])
    var createReportResult: Result<CreateReportResponseDTO, APIError> = .success(CreateReportResponseDTO(id: 1)) // ID por defecto 1
    var fetchPublicReportsResult: Result<[ReportResponseDTO], APIError> = .success([])
    var fetchReportResult: Result<ReportResponseDTO, APIError>? // Opcional, debe configurarse
    var updateReportResult: Result<Void, APIError> = .success(())
    var addEvidenceResult: Result<Void, APIError> = .success(())
    var fetchEvidencesResult: Result<[EvidenceResponseDTO], APIError> = .success([])
    var deleteEvidenceResult: Result<Void, APIError> = .success(())
    var calculateSeverityScoreResult: Result<Void, APIError> = .success(())
    
    // Variables para espiar
    var createReportCalled = false
    var addEvidenceCalled = false
    var calculateSeverityScoreCalled = false
    var updateReportCalled = false
    var fetchMyReportsCalled = false
    
    // Contadores de llamadas
    var addEvidenceCallCount = 0
    
    // Variables para capturar datos
    var capturedUpdateDTO: UpdateReportRequestDTO?
    var capturedCreateDTO: CreateReportRequestDTO?

    func fetchMyReports(userId: Int, status: String, category: String, sortBy: String) async throws -> [ReportResponseDTO] {
        fetchMyReportsCalled = true
        return try fetchMyReportsResult.get()
    }
    
    func createReport(data: CreateReportRequestDTO) async throws -> CreateReportResponseDTO {
        createReportCalled = true
        capturedCreateDTO = data
        return try createReportResult.get()
    }
    
    func fetchPublicReports() async throws -> [ReportResponseDTO] {
        return try fetchPublicReportsResult.get()
    }
    
    func fetchReport(withId reportId: Int) async throws -> ReportResponseDTO {
        if let result = fetchReportResult {
            return try result.get()
        }
        fatalError("fetchReport(withId:) no configurado para este test")
    }
    
    func updateReport(reportId: Int, data: UpdateReportRequestDTO) async throws {
        updateReportCalled = true
        capturedUpdateDTO = data
        return try updateReportResult.get()
    }
    
    func addEvidence(toReportId reportId: Int, imageData: Data) async throws {
        addEvidenceCalled = true
        addEvidenceCallCount += 1
        return try addEvidenceResult.get()
    }
    
    func fetchEvidences(forReportId reportId: Int) async throws -> [EvidenceResponseDTO] {
        return try fetchEvidencesResult.get()
    }
    
    func deleteEvidence(evidenceId: Int, fromReportId reportId: Int) async throws {
        return try deleteEvidenceResult.get()
    }
    
    func calculateSeverityScore(forReportId reportId: Int) async throws {
        calculateSeverityScoreCalled = true
        return try calculateSeverityScoreResult.get()
    }
}

// --- MOCK PARA TAGS/IMPACTS ---
class TagsAndImpactsAPIServiceMock: TagsAndImpactsAPIServiceProtocol {
    var fetchAllTagsResult: Result<[Tag], APIError> = .success([])
    var fetchAllImpactsResult: Result<[Impact], APIError> = .success([])

    func fetchAllTags() async throws -> [Tag] {
        return try fetchAllTagsResult.get()
    }
    
    func fetchAllImpacts() async throws -> [Impact] {
        return try fetchAllImpactsResult.get()
    }
}

// --- SPY PARA AUTHMANAGER ---
class AuthManagerSpy: AuthenticationManager {
    var loginCalled = false
    var logoutCalled = false
    var loggedInUser: UserProfileResponseDTO?

    override func login(user: UserProfileResponseDTO) {
        loginCalled = true
        loggedInUser = user
    }
    
    override func logout() {
        logoutCalled = true
    }
}

// --- DTOS E EJEMPLO PARA PRUEBAS ---

func makeSampleUserDTO() -> UserProfileResponseDTO {
    return UserProfileResponseDTO(
        name: "Test",
        fathersLastName: "User",
        mothersLastName: "Mock", 
        email: "test@example.com",
        username: "testuser"
    )
}
func makeSampleLoginResponse() -> LoginResponseDTO {
    return LoginResponseDTO(
        accessToken: "fake_access_token",
        refreshToken: "fake_refresh_token",
        user: makeSampleUserDTO()
    )
}

func makeSampleTag() -> Tag {
    return Tag(id: 2, tagName: "Phishing", tagScore: 38, tagDescription: "...")
}

func makeSampleImpact() -> Impact {
    return Impact(id: 1, impactName: "Robo de credenciales", impactScore: 33, impactDescription: "...")
}

func makeSampleReportResponseDTO() -> ReportResponseDTO {
    // crea un dto de respuesta de reporte de ejemplo
    return ReportResponseDTO(
        id: 10,
        reportTitle: "Reporte de Prueba",
        reportUrl: "https://test.com",
        reportDescription: "Desc...",
        reportStatus: "pending",
        severity: 0,
        createdAt: "2025-10-23T22:29:44.304Z",
        adminFeedback: nil,
        siteId: 1,
        userId: 1,
        updatedAt: "2025-10-23T22:29:44.304Z",
        site: SiteDTO(id: 1, siteDomain: "test.com"),
        user: UserInReportDTO(username: "testuser"),
        votes: [],
        evidences: [],
        tags: [ReportTagIdDTO(tagId: 2)],
        impacts: [ReportImpactIdDTO(impactId: 1)]
    )
}

func makeSampleReport() -> Report {
    return Report(
        displayId: "10",
        title: "Reporte de Prueba",
        date: "23 October 2025",
        url: "https://test.com",
        description: "Desc...",
        category: "Phishing",
        severity: "Baja",
        user: UserInReportDTO(username: "testuser"),
        createdAt: Date(),
        evidences: [],
        impacts: ["Robo de credenciales"],
        severityScore: 0,
        statusText: "pending",
        statusColor: .statusReview, 
        voteScore: 0,
        userVoteStatus: nil,
        userId: 1,
        adminFeedback: nil
    )
}
