import Foundation
import UIKit 
// --- PROTOCOLOS PARA INYECCION DE DEPENDENCIAS ---
// estos son los "contratos" que tus servicios deben cumplir

// protocolo para el servicio de autenticacion
protocol AuthAPIServiceProtocol {
    func login(credentials: LoginRequestDTO) async throws -> LoginResponseDTO
    func signUp(userData: SignUpRequestDTO) async throws
}

// protocolo para el servicio de keychain
protocol KeychainServiceProtocol {
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() -> String?
    func deleteTokens() throws
    // func getRefreshToken() -> String? // anade si es necesario
}

// protocolo para el servicio de perfil de usuario
protocol UserAPIServiceProtocol {
    func fetchUserProfile() async throws -> UserProfileResponseDTO
    func updateUserProfile(data: UpdateProfileRequestDTO) async throws
    func deleteUser() async throws
}

// protocolo para el servicio de reportes
protocol ReportsAPIServiceProtocol {
    func fetchMyReports(userId: Int, status: String, category: String, sortBy: String) async throws -> [ReportResponseDTO]
    func createReport(data: CreateReportRequestDTO) async throws -> CreateReportResponseDTO
    func fetchPublicReports() async throws -> [ReportResponseDTO]
    func fetchReport(withId reportId: Int) async throws -> ReportResponseDTO
    func updateReport(reportId: Int, data: UpdateReportRequestDTO) async throws
    func addEvidence(toReportId reportId: Int, imageData: Data) async throws
    func fetchEvidences(forReportId reportId: Int) async throws -> [EvidenceResponseDTO]
    func deleteEvidence(evidenceId: Int, fromReportId reportId: Int) async throws
    func calculateSeverityScore(forReportId reportId: Int) async throws
}

// protocolo para el servicio de tags/impacts
protocol TagsAndImpactsAPIServiceProtocol {
    func fetchAllTags() async throws -> [Tag]
    func fetchAllImpacts() async throws -> [Impact]
}

// protocolo para el servicio de votos
protocol VotesAPIServiceProtocol {
     func castVote(reportId: Int, voteType: String) async throws
}

// protocolo para el servicio de busqueda
protocol SearchAPIServiceProtocol {
     func search(query: String) async throws -> SiteResponseDTO?
}

// protocolo para el networkclient (opcional, pero buena practica)
protocol NetworkClientProtocol {
    func request<T: Decodable>(endpoint: String, method: String, body: (any Encodable)?, isAuthenticated: Bool) async throws -> T
    func request(endpoint: String, method: String, body: (any Encodable)?, isAuthenticated: Bool) async throws
    func upload(endpoint: String, imageData: Data, fieldName: String, fileName: String, isAuthenticated: Bool) async throws
}
