//
//  PublicReportsView.swift
//  RepNet
//
//  Created by Angel Bosquez on 29/09/25.
//
//hecho por ia, necesita cambios

import SwiftUI

struct PublicReportsView: View {
    
    @StateObject private var viewModel = PublicReportsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView
                    //filtro trending
                    SegmentedPickerComponent(options: viewModel.filterOptions, selectedOption: $viewModel.selectedFilter)
                    //filtro cateogria
                    HStack {
                        FilterButtonComponent(
                            selection: $viewModel.selectedCategory,
                            options: viewModel.categoryOptions,
                            iconName: "line.3.horizontal.decrease"
                        )
                        Spacer()
                    }

                  //se meustra un spinner si la pantalla esta cargando
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
                      
                        ForEach(viewModel.filteredReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report, currentUserId: nil)) {
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

//preview con ia
struct PublicReportsView_Previews: PreviewProvider {
    static var previews: some View {
        PublicReportsView()
    }
}
