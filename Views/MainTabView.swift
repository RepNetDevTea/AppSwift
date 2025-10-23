//
//  MainTabView.swift
//  RepNet
//
//  Created by Angel Bosquez on 28/09/25.
//

import SwiftUI

// esta es la vista principal de la aplicacion una vez que el usuario inicia sesion.
// es un `tabview` que contiene las cuatro secciones principales de la app.

// -- vistas utilizadas como tabs --
// - myreportsview
// - publicreportsview
// - searchview
// - accountview
struct MainTabView: View {
    
    // con `@stateobject`, esta vista crea y se convierte en la "duena" de estos viewmodels.
    // al crearlos aqui y pasarlos a las vistas hijas, nos aseguramos de que el estado
    // de cada tab (como la lista de reportes cargada) no se pierda al cambiar de pestana.
    @StateObject private var myReportsViewModel = MyReportsViewModel()
    @StateObject private var publicReportsViewModel = PublicReportsViewModel()
    
    var body: some View {
        TabView {
            // -- tab 1: mis reportes --
            // a `myreportsview` se le inyecta el viewmodel que creamos arriba.
            MyReportsView(viewModel: myReportsViewModel)
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("mis reportes")
                }
            
            // -- tab 2: reportes publicos --
            // lo mismo para `publicreportsview`.
            PublicReportsView(viewModel: publicReportsViewModel)
                .tabItem {
                    Image(systemName: "globe")
                    Text("re. publicos")
                }
            
            // -- tab 3: busqueda --
            // `searchview` crea y maneja su propio viewmodel internamente.
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("busqueda")
                }
            
            // -- tab 4: mi cuenta --
            // `accountview` tambien maneja su propio viewmodel.
            // la envolvemos en un `navigationview` para que pueda tener su propia barra de navegacion
            // con el titulo "mi cuenta" y el boton de editar/guardar.
            NavigationView { AccountView() }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("mi cuenta")
                }
        }
        // establece el color de los iconos y texto de la pestana seleccionada.
        .accentColor(.primaryBlue)
    }
}

// mark: - preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // la vista previa necesita el `authenticationmanager` porque una de sus vistas hijas
        // (`accountview`) lo requiere en su entorno.
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}
