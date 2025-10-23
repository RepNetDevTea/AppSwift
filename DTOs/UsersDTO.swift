//
//  UsersDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 02/10/25.
//
//Nota para Emi: este tiene pedos con el JWTauthguard, como tal si se conecta pero no lo deja pasar
import Foundation

// Este DTO representa los datos del perfil de usuario que recibimos del backend.
// Este struct se mantiene sin cambios, ya que sigue representando los datos que nos llegan.
struct UserProfileResponseDTO: Decodable {
    let name: String
    let fathersLastName: String
    let mothersLastName: String
    let email: String
    let username: String
}

// --- ARCHIVO ACTUALIZADO ---
// Este DTO representa los datos que enviaremos para actualizar el perfil.
// Ha sido modificado para incluir todos los campos y la lógica de autorización.
struct UpdateProfileRequestDTO: Encodable {
    
    // --- Campos de Datos del Usuario (Opcionales) ---
    // El usuario puede enviar solo los campos que desea cambiar.
    var name: String? = nil
    var fathersLastName: String? = nil
    var mothersLastName: String? = nil
    var username: String? = nil
    var email: String? = nil
    var hashedPassword: String? = nil
}

/// --- NUEVO DTO AÑADIDO ---
/// Representa el JSON que enviaremos al backend para autorizar la eliminación de la cuenta.
/// Asumimos que el backend requiere la contraseña actual del usuario para confirmar la acción.
struct DeleteAccountRequestDTO: Encodable { }
