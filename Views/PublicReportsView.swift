//
//  PublicReportsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//hecho por ia, necesita cambios

import SwiftUI

struct PublicReportsView: View {
    
    @ObservedObject var viewModel: PublicReportsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView
                    
                    /// --- COMPONENTE DE FILTRO REINTRODUCIDO ---
                    /// El picker ahora está de vuelta y conectado al 'selectedFilter' del ViewModel.
                    SegmentedPickerComponent(options: viewModel.filterOptions, selectedOption: $viewModel.selectedFilter)
                    
                    /// --- VISTA DE CONTENIDO ---
                    /// Se usa un 'switch' para mostrar la UI correcta según el estado.
                    /// Esto también ayuda al compilador a procesar la vista más fácilmente.
                    switch viewModel.isLoading {
                    case true:
                        ProgressView().frame(maxWidth: .infinity)
                    case false:
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage).foregroundColor(.red).padding()
                        } else if viewModel.filteredReports.isEmpty {
                            Text("No se encontraron reportes que coincidan con tus filtros.")
                                .foregroundColor(.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            /// La lista ahora itera sobre 'filteredReports', por lo que se
                            /// actualizará automáticamente cuando el usuario cambie de filtro.
                            ForEach(viewModel.filteredReports) { report in
                                NavigationLink(destination: ReportDetailView(report: report, currentUserId: nil)) {
                                    ReportCardComponent(report: report)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .refreshable {
                            // Llama a la función del ViewModel para recargar
                            await viewModel.fetchPublicReports()
                        }
            .onAppear {
                if viewModel.reports.isEmpty {
                    Task {
                        await viewModel.fetchPublicReports()
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Reportes Públicos").font(.largeTitle).fontWeight(.bold)
            Spacer()
        }
    }
}

// La vista previa se mantiene igual.
struct PublicReportsView_Previews: PreviewProvider {
    static var previews: some View {
        PublicReportsView(viewModel: PublicReportsViewModel())
    }
}
