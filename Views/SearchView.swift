//
//  SearchView.swift
//  RepNet
//
//  Created by Angel Bosquez on 09/10/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Búsqueda")
                    .font(.largeTitle).bold()
                    .padding([.horizontal, .top])

                SearchBarComponent(text: $viewModel.searchQuery, placeholder: "Buscar por página...")
                    .padding(.horizontal)

                switch viewModel.state {
                case .initial:
                    SearchPlaceholderView(icon: "magnifyingglass", text: "Busca un sitio web para ver los resultados.")
                case .loading:
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let sites):
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(sites) { site in
                                
                                SiteCardComponent(site: site, currentUserId: authManager.user?.id)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                case .empty:
                    SearchPlaceholderView(icon: "questionmark.folder", text: "No se encontraron resultados para \"\(viewModel.searchQuery)\".")
                case .error(let message):
                    SearchPlaceholderView(icon: "exclamationmark.triangle", text: message, isError: true)
                }

                Spacer()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            
        }
        
    }
}

private struct SearchPlaceholderView: View {
    let icon: String
    let text: String
    var isError: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(isError ? .red : .textSecondary)
            Text(text)
                .font(.headline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        
        let authManager = AuthenticationManager()

        SearchView()
            .environmentObject(authManager)
    }
}
