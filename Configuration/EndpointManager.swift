//
//  AppConfig.swift
// Igual a URLSettings pero con otro nombre
//  RepNet
//
//  Created by Angel Bosquez on 30/09/25.
//


import Foundation

// centraliza toda la configuracion de la aplicacion
// si la ip del servidor cambia solo se cambia en este archivo

struct AppConfig {
    
    // MARK: - Base URL
        static let server = "http://10.48.232.42:3000"
    
    // MARK: - Autenticacion
    
    // para iniciar sesion
    static let loginURL = server + "/auth/login"
    
    // para registrar un nuevo usuario
    static let registerURL = server + "/users"
    
    // MARK: - Usuario
    
    // para obtener o modificar el perfil del usuario logueado
    static let userProfileURL = server + "/users/me"
    
    // MARK: - Reportes
    
    // endpoint base para reportes
    static let reportsURL = server + "/reports"
    
    // para buscar sitios
    static let sitesURL = server + "/sites"
    
    // para obtener la lista de tags
    static let tagsURL = server + "/tags"
    
    // para obtener la lista de impactos
    static let impactsURL = server + "/impacts"
    
    // para registrar votos en los reportes
    static let votesURL = server + "/votes"
    
    static func evidencesURL(forReportId reportId: Int) -> String {
        return reportsURL + "/\(reportId)/evidences"
    }
}
