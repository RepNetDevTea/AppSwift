import XCTest
import UIKit
@testable import RepNet 

@MainActor
class ReportTests: XCTestCase {

    var mockReportsService: ReportsAPIServiceMock!
    var mockTagsImpactsService: TagsAndImpactsAPIServiceMock!
    
    // --- Datos de Ejemplo Globales ---
    let sampleTags = [Tag(id: 2, tagName: "Phishing", tagScore: 38, tagDescription: "robar credenciales")]
    let sampleImpacts = [Impact(id: 1, impactName: "Robo de credenciales", impactScore: 33, impactDescription: "robo de credenciales")]
    
    // --- setup ---
    override func setUp() {
        super.setUp()
        mockReportsService = ReportsAPIServiceMock()
        mockTagsImpactsService = TagsAndImpactsAPIServiceMock()
        
        // Configura los mocks de tags/impacts para que siempre devuelvan datos
        mockTagsImpactsService.fetchAllTagsResult = .success(sampleTags)
        mockTagsImpactsService.fetchAllImpactsResult = .success(sampleImpacts)
    }
    
    // --- tearDown ---
    override func tearDown() {
        mockReportsService = nil
        mockTagsImpactsService = nil
        super.tearDown()
    }

    // --- Caso de Prueba CP_07: Crear Reporte Exitoso ---
    func testCreateReport_Success() async {
        // 1. Arrange
        let viewModel = CreateReportViewModel(
            reportsAPIService: mockReportsService,
            tagsAndImpactsAPIService: mockTagsImpactsService
        )
        // Espera a que el 'fetchInitialData' del init termine
        await viewModel.fetchInitialData() // Llama explicitamente para 'await'

        // Configura el formulario
        viewModel.reportTitle = "Test Phishing Report"
        viewModel.reportUrl = "https://test-phishing-site-example.com"
        viewModel.reportDescription = "test report"
        viewModel.selectedTags = Set(sampleTags)
        viewModel.selectedImpacts = Set(sampleImpacts)
        
        // Simula la seleccion de 2 imagenes
        viewModel.evidenceItems = [
            .new(image: SelectedImage(uiImage: UIImage())),
            .new(image: SelectedImage(uiImage: UIImage()))
        ]
        
        // Configura las respuestas exitosas de los mocks
        mockReportsService.createReportResult = .success(CreateReportResponseDTO(id: 10))
        mockReportsService.fetchReportResult = .success(makeSampleReportResponseDTO()) // Devuelve el reporte completo

        // 2. Act
        await viewModel.submitReport()

        // 3. Assert
        XCTAssertNil(viewModel.errorMessage, "errorMessage deberia ser nil")
        XCTAssertTrue(mockReportsService.createReportCalled, "createReport no fue llamado")
        XCTAssertEqual(mockReportsService.addEvidenceCallCount, 2, "addEvidence no se llamo 2 veces")
        XCTAssertTrue(mockReportsService.calculateSeverityScoreCalled, "calculateSeverityScore no fue llamado")
        XCTAssertNotNil(viewModel.successfullyCreatedReport, "El reporte creado no se asigno para la navegacion")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }
    
    // --- Caso de Prueba CP_08: Crear Reporte Fallido (Validacion) ---
    func testCreateReport_Failure_MissingTitle() async {
        // 1. Arrange
        let viewModel = CreateReportViewModel(
            reportsAPIService: mockReportsService,
            tagsAndImpactsAPIService: mockTagsImpactsService
        )
        await viewModel.fetchInitialData()

        // Configura el formulario (falta el titulo)
        viewModel.reportTitle = "" // <-- Vacio
        viewModel.reportUrl = "https://test-phishing-site-example.com"
        viewModel.reportDescription = "test report"
        viewModel.selectedTags = Set(sampleTags)
        viewModel.selectedImpacts = Set(sampleImpacts)

        // 2. Act
        await viewModel.submitReport()

        // 3. Assert
        XCTAssertFalse(viewModel.isFormValid, "isFormValid deberia ser false")
        XCTAssertFalse(mockReportsService.createReportCalled, "createReport no debio ser llamado")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }

    // --- Caso de Prueba CP_04: Editar Reporte Fallido (Error de API) ---
    func testEditReport_Failure_APIError() async {
        // 1. Arrange
        let originalReport = makeSampleReport() // Usa el helper
        let expectedError = "El servidor fallo"
        
        // Configura el mock para fallar
        mockReportsService.updateReportResult = .failure(.serverError(message: expectedError))
        
        let viewModel = EditReportViewModel(
            report: originalReport,
            reportsAPIService: mockReportsService,
            tagsAndImpactsAPIService: mockTagsImpactsService
        )
        await viewModel.fetchInitialDataAndPopulateSaves() // Carga datos
        
        // Simula un cambio
        viewModel.reportTitle = "Titulo Nuevo"
        
        // 2. Act
        await viewModel.saveChanges()
        
        // 3. Assert
        XCTAssertFalse(viewModel.updateSuccessful, "updateSuccessful deberia ser false")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage no puede ser nil")
        XCTAssertEqual(viewModel.errorMessage, expectedError, "El mensaje de error no es el esperado")
        XCTAssertTrue(mockReportsService.updateReportCalled, "updateReport debio ser llamado")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }
    
    // --- Caso de Prueba CP_05: Consultar Mis Reportes Exitoso ---
    func testGetMyReports_Success() async {
        // 1. Arrange
        let viewModel = MyReportsViewModel(
            reportsAPIService: mockReportsService,
            tagsAndImpactsAPIService: mockTagsImpactsService
        )
        
        // Configura el mock para devolver datos
        mockReportsService.fetchPublicReportsResult = .success([makeSampleReportResponseDTO()])
        // Asegura que los lookups esten listos (aunque se llaman en fetchReports)
        await viewModel.fetchInitialLookups(showLoading: false)

        // 2. Act
        await viewModel.fetchReports(status: "Todos", category: "Categoría", sortBy: "Ordenar", userId: 1)

        // 3. Assert
        XCTAssertNil(viewModel.errorMessage, "errorMessage deberia ser nil")
        XCTAssertFalse(viewModel.reports.isEmpty, "La lista de reportes no debio quedar vacia")
        XCTAssertEqual(viewModel.reports.first?.displayId, "10", "El reporte no se mapeo correctamente")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }
    
    // --- Caso de Prueba CP_06: Consultar Mis Reportes (Resultado Vacio) ---
    func testGetMyReports_EmptyResult() async {
        // 1. Arrange
        let viewModel = MyReportsViewModel(
            reportsAPIService: mockReportsService,
            tagsAndImpactsAPIService: mockTagsImpactsService
        )
        
        // Configura el mock para devolver una lista vacia
        mockReportsService.fetchPublicReportsResult = .success([])
        await viewModel.fetchInitialLookups(showLoading: false)

        // 2. Act
        // Simulamos filtrar por un usuario que no tiene reportes
        await viewModel.fetchReports(status: "Todos", category: "Categoría", sortBy: "Ordenar", userId: 99) 
        
        // 3. Assert
        XCTAssertNil(viewModel.errorMessage, "errorMessage deberia ser nil")
        XCTAssertTrue(viewModel.reports.isEmpty, "La lista de reportes debio quedar vacia")
        XCTAssertTrue(viewModel.filteredAndSortedReports.isEmpty, "La lista filtrada debio quedar vacia")
        XCTAssertFalse(viewModel.isLoading, "isLoading deberia ser false")
    }
}
