//
//  MyReportsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//

import SwiftUI

struct MyReportsView: View {
    
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

                    // muestra el spinner solo si está cargando Y la lista está vacía (carga inicial)
                    if viewModel.isLoading && viewModel.reports.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    // revisa la lista filtrada para el mensaje de "vacío"
                    } else if viewModel.filteredAndSortedReports.isEmpty {
                         Text("No se encontraron reportes que coincidan con tus filtros.")
                               .foregroundColor(.textSecondary)
                               .frame(maxWidth: .infinity, alignment: .center)
                               .padding()
                    } else {
                        // itera sobre la lista filtrada y ordenada
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
          
            .onAppear {
                // ya no revisamos si la lista está vacía.
                // siempre llamamos a fetchReports cuando la vista aparece.
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
