//
//  MyReportsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import SwiftUI

struct MyReportsView: View {

    // Use @StateObject if the View CREATES the ViewModel
    // Use @ObservedObject if the ViewModel is PASSED IN from a parent
    @ObservedObject var viewModel: MyReportsViewModel
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView

                    SegmentedPickerComponent(options: viewModel.statusOptions, selectedOption: $viewModel.selectedStatus)

                    HStack {
                        FilterButtonComponent(selection: $viewModel.selectedCategory, options: viewModel.categoryOptions, iconName: "line.3.horizontal.decrease")
                        FilterButtonComponent(selection: $viewModel.selectedSort, options: viewModel.sortOptions, iconName: "arrow.up.arrow.down")
                        Spacer()
                    }

                    // --- Main Content Logic ---
                    // Show loader only on initial load AND if reports are empty
                    if viewModel.isLoading && viewModel.reports.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    // Check the FILTERED list for emptiness
                    } else if viewModel.filteredAndSortedReports.isEmpty {
                         Text("No se encontraron reportes que coincidan con tus filtros.")
                             .foregroundColor(.textSecondary)
                             .frame(maxWidth: .infinity, alignment: .center)
                             .padding()
                    } else {
                        // ✨ CORRECTED: Iterate over filteredAndSortedReports ✨
                        ForEach(viewModel.filteredAndSortedReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report, currentUserId: authManager.user?.id )) {
                                ReportCardComponent(report: report)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.fetchReports(
                    status: viewModel.selectedStatus,
                    category: viewModel.selectedCategory,
                    sortBy: viewModel.selectedSort,
                    userId: authManager.user?.id
                )
            }
            .onAppear {
                if viewModel.reports.isEmpty {
                    Task {
                        await viewModel.fetchReports(
                            status: viewModel.selectedStatus,
                            category: viewModel.selectedCategory,
                            sortBy: viewModel.selectedSort,
                            userId: authManager.user?.id
                        )
                    }
                }
            }
        }
    }

    // --- Auxiliary Views ---
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hola,").font(.title2).foregroundColor(.textSecondary)
                Text("\(authManager.user?.name ?? "Usuario") \(authManager.user?.fathersLastName ?? "")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Spacer()
            NavigationLink(destination: CreateReportView()) {
                Text("Crear Reporte")
                    .font(.buttonFont).foregroundColor(.white).padding(.horizontal, 20)
                    .padding(.vertical, 10).background(Color.primaryBlue).cornerRadius(12)
            }
        }
    }
}
