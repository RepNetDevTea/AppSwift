//
//  PublicReportsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//hecho por ia, necesita cambios

import SwiftUI

struct PublicReportsView: View {
    
    // ✨ CAMBIO: Usamos @StateObject porque esta vista (en un TabView) crea y posee su ViewModel.
    @StateObject private var viewModel = PublicReportsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView
                    
                    // Filtro principal (Trending, etc.)
                    SegmentedPickerComponent(options: viewModel.filterOptions, selectedOption: $viewModel.selectedFilter)
                    
                    // Filtro de Categoría
                    HStack {
                        FilterButtonComponent(
                            selection: $viewModel.selectedCategory,
                            options: viewModel.categoryOptions,
                            iconName: "line.3.horizontal.decrease"
                        )
                        Spacer()
                    }

                    // --- VISTA DE CONTENIDO ---
                    // Muestra el spinner solo si está cargando Y la lista está vacía
                    if viewModel.isLoading && viewModel.reports.isEmpty {
                        ProgressView().frame(maxWidth: .infinity)
                        
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            
                    } else if viewModel.filteredReports.isEmpty {
                        Text("No se encontraron reportes que coincidan con tus filtros.")
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            
                    } else {
                        // Itera sobre la lista ya filtrada y ordenada
                        ForEach(viewModel.filteredReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report, currentUserId: nil)) { // Pasa nil para el ID de usuario
                                ReportCardComponent(report: report)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            
            // --- MODIFICACIONES ---
            // 1. Se eliminó el modificador .refreshable
            
            // 2. .onAppear ahora SIEMPRE refresca los datos
            .onAppear {
                Task {
                    await viewModel.fetchPublicReports()
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
        PublicReportsView()
    }
}
