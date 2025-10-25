//
//  MainTabView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//
import SwiftUI


struct MainTabView: View {
    
    @StateObject private var myReportsViewModel = MyReportsViewModel()
    

    var body: some View {
        TabView {
            
            // MARK: -  mis reportes

            MyReportsView(viewModel: myReportsViewModel)
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("mis reportes")
                }
            
            // MARK: - reportes publicos
            PublicReportsView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("re. publicos")
                }
            
            // MARK: - busqueda
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("busqueda")
                }
            
            // MARK: - mi cuenta
            NavigationView { AccountView() }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("mi cuenta")
                }
        }
 
        .accentColor(.primaryBlue)
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}
