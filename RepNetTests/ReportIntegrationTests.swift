//
//  ReportIntegrationTests.swift
//  RepNet
//
//  Created by Angel Bosquez on 23/10/25.
//

import XCTest
@testable import RepNet // Replace RepNet with your actual project name

@MainActor
class ReportIntegrationTests: XCTestCase {

    // --- Helper Functions ---

    // Helper to log in and get token
    // IMPORTANT: Use valid credentials for your test environment
    private func getAuthToken(email: String, pass: String) async -> String? {
        let loginVM = LoginViewModel() // Assumes default init uses real services
        loginVM.email = email
        loginVM.password = pass
        let authManager = AuthenticationManager() // Use real AuthManager
        await loginVM.login(with: authManager)
        let token = KeychainService.getAccessToken() // Assumes real KeychainService
        if token == nil {
            print("Login failed for test user: \(loginVM.errorMessage ?? "Unknown error")")
        }
        return token
    }

    // Helper to fetch Tags/Impacts needed by ViewModel
    private func fetchLookups() async -> (tags: [Tag], impacts: [Impact]) {
        let service = TagsAndImpactsAPIService() // Use real service
        do {
            async let tags = service.fetchAllTags()
            async let impacts = service.fetchAllImpacts()
            return (try await tags, try await impacts)
        } catch {
            XCTFail("Failed to fetch tags/impacts for test setup: \(error)")
            return ([], [])
        }
    }

    // --- Test Cases ---

    // Test Case for Successfully Fetching Reports
    func testGetMyReports_Success() async throws {
        // --- Arrange ---
        let testEmail = "nuevo@ejemplo.com" // User known to have reports
        let testPassword = "V4lidPassw0rd123!"
        let expectedUserId = 11 // ⚠️ Replace with the actual ID for this user

        // 1. Login
        guard let token = await getAuthToken(email: testEmail, pass: testPassword) else {
            XCTFail("Login failed for \(testEmail).")
            return
        }

        // 2. Create ViewModel
        let viewModel = MyReportsViewModel() // Uses real services

        // --- Act ---
        // Fetch reports with default filters ("Todos")
        await viewModel.fetchReports(status: "Todos", category: "Categoría", sortBy: "Ordenar", userId: expectedUserId)

        // --- Assert ---
        XCTAssertNil(viewModel.errorMessage, "Fetching reports failed: \(viewModel.errorMessage ?? "Unknown error")")
        XCTAssertFalse(viewModel.isLoading, "ViewModel should not be loading after fetch")
        XCTAssertFalse(viewModel.reports.isEmpty, "Expected reports for user \(expectedUserId), but found none.")
        // Example check: Ensure at least one report was fetched
        print("Fetched \(viewModel.reports.count) reports successfully.")
    }

    // Test Case for Fetching with Filters Resulting in Empty List
    func testGetMyReports_EmptyResult() async throws {
        // --- Arrange ---
        let testEmail = "nuevo@ejemplo.com"
        let testPassword = "V4lidPassw0rd123!"
        let expectedUserId = 11 // ⚠️ Replace with the actual ID for this user
        let filterStatus = "Rechazado" // ⚠️ Use a status for which this user has NO reports

        // 1. Login
        guard let token = await getAuthToken(email: testEmail, pass: testPassword) else {
            XCTFail("Login failed for \(testEmail).")
            return
        }

        // 2. Create ViewModel
        let viewModel = MyReportsViewModel()

        // --- Act ---
        // Fetch reports filtering by a status known to have no results for this user
        await viewModel.fetchReports(status: filterStatus, category: "Categoría", sortBy: "Ordenar", userId: expectedUserId)

        // --- Assert ---
        XCTAssertNil(viewModel.errorMessage, "Fetching reports failed unexpectedly: \(viewModel.errorMessage ?? "Unknown error")")
        XCTAssertFalse(viewModel.isLoading, "ViewModel should not be loading after fetch")
        XCTAssertTrue(viewModel.reports.isEmpty, "Expected NO reports for status '\(filterStatus)', but found some.")
        // Also check the computed property used by the View
        XCTAssertTrue(viewModel.filteredAndSortedReports.isEmpty, "Filtered list should also be empty.")
        print("Successfully fetched 0 reports for status '\(filterStatus)' as expected.")
    }

    // --- (Include other tests like create/edit report if they are in the same file) ---

} // End Test Class
