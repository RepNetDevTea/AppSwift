//
//  AppConfig.swift
// Igual a URLSettings pero con otro nombre
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//
// este archivo centraliza toda la configuracion de la aplicacion,
// especialmente los endpoints de la api.


import Foundation
struct AppConfig {
    
    // la direccion base del servidor backend. si la ip cambia, solo se cambia aqui.
    
    static let server = "http://10.48.208.190:3000"
    
    // -- endpoints de autenticacion --
    
    // para iniciar sesion.
    
    static let loginURL = server + "/auth/login"
   
    // para registrar un nuevo usuario.
    
    static let registerURL = server + "/users"
    
    // -- endpoint de perfil de usuario --
    
    // para obtener o modificar el perfil del usuario logueado.
    static let userProfileURL = server + "/users/me"
    
    // -- endpoint de sitios --
    
    // para buscar o interactuar con sitios web.
    static let sitesURL = server + "/sites"
    
    // En AppConfig.swift

    static let tagsURL = server + "/tags"
    static let impactsURL = server + "/impacts"
    
    // Una función auxiliar para construir la URL de las evidencias de un reporte específico.
    // Esto mantiene toda la lógica de construcción de URLs en un solo lugar.
    static func evidencesURL(forReportId reportId: Int) -> String {
        return reportsURL + "/\(reportId)/evidences"
       }
        
    // -- endpoints de reportes --
    
    // para crear u obtener reportes.
    static let reportsURL = server + "/reports"
        
    // -- endpoints de votos --
    
    // para registrar votos en los reportes.
    static let votesURL = server + "/votes"
    
    //
    
    
}
