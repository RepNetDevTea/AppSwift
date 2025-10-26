# Guía de Pruebas Unitarias para RepNet

Este documento explica cómo modificar la aplicación RepNet para implementar **Inyección de Dependencias**, un patrón de diseño esencial que nos permite reemplazar los servicios de red reales por simulacions para realizar pruebas unitarias.

----------------------------------- Advertencia: Este proceso implica modificar los archivos principales de tu aplicación. ------------------------------------

## Recomendación Importante: Duplica el proyecto

Antes de comenzar, es fuertemente recomendado duplicar la carpeta completa de tu proyecto y trabajar sobre esa copia.

1.  Cierra Xcode.
2.  Busca la carpeta de tu proyecto 
3.  Copia y pega la carpeta. Renombra la copia a RepNet_Testing.
4.  Abre el archivo .xcodeproj dentro de RepNet_Testing y trabaja sobre esa copia.

Esto te permite tener una versión funcional de tu app conectada a la API real y una versión separada para experimentar con las pruebas unitarias.

## Modificaciones al Proyecto Principal (App)

Para que las pruebas funcionen, debemos modificar la app para que los `ViewModels` no dependan de los servicios reales (`ReportsAPIService`), sino de un "contrato" (un protocolo, ej. `ReportsAPIServiceProtocol`).

### 1. Crear `Protocols.swift`

Crea un nuevo archivo llamado `Protocols.swift` en tu carpeta principal (cerca de `Networking`) y pega el contenido de protocols.swift

* **Propósito:** Este archivo define todos los protocolos que tus servicios de API deben cumplir.

### 2. Crear `KeychainServiceWrapper.swift`

Crea un nuevo archivo llamado `KeychainServiceWrapper.swift` (cerca de `KeychainService.swift`) y pega el contenido de keychainservicewrapper.swift

* **Propósito:** Tu `KeychainService` usa métodos estáticos, lo cual es difícil de probar. Este  wrapper conforma al protocolo `KeychainServiceProtocol` y redirige las llamadas a tus métodos estáticos.

### 3. Modificar TODOS tus ViewModels

Debes actualizar el `init` y las declaraciones de propiedades de **TODOS** tus ViewModels (`LoginViewModel`, `MyReportsViewModel`, `CreateReportViewModel`, etc.) para que dependan de los protocolos, no de las `structs`.

**Ejemplo - `LoginViewModel.swift`:**

// ANTES:
@MainActor
class LoginViewModel: ObservableObject {
    private let authAPIService = AuthAPIService() // Dependencia concreta
    private let keychain = KeychainService() // (O se usaba estáticamente)

    init() {
        // ...
    }
    // ...
}

// DESPUÉS (con Inyección de Dependencias):
@MainActor
class LoginViewModel: ObservableObject {
    private let authAPIService: AuthAPIServiceProtocol // <-- USA EL PROTOCOLO
    private let keychain: KeychainServiceProtocol   // <-- USA EL PROTOCOLO

    // Acepta los servicios en el init, con valores por defecto
    init(
        authAPIService: AuthAPIServiceProtocol = AuthAPIService(),
        keychain: KeychainServiceProtocol = KeychainServiceWrapper() // Usa el wrapper
    ) {
        self.authAPIService = authAPIService
        self.keychain = keychain
        // ...
    }
    // ...
}


### 3. Modificar TODOS tus ViewModels
Modificar TODOS tus Servicios de API

Finalmente, ve a cada uno de tus archivos de servicio (AuthAPIService.swift, ReportsAPIService.swift, etc.) y haz que conformen al protocolo correspondiente.

Ejemplo - AuthAPIService.swift:
// ANTES:
struct AuthAPIService {
    // ...
}

// DESPUÉS:
struct AuthAPIService: AuthAPIServiceProtocol { // <-- AÑADE LA CONFORMIDAD
    // ...
}


5. Crear Mocks.swift

Crea un archivo llamado Mocks.swift DENTRO de tu carpeta RepNetTests y pega el contenido de Mocks.swift

   Propósito: Este archivo contiene todas las simulaciones (Mocks) de tus servicios. Estas clases falsas nos permiten controlar las respuestas (ej. "simular un error 500" o "simular una respuesta exitosa") sin conectarnos a internet.

6. Usar los Mocks en tus Pruebas

Ahora puedes escribir pruebas unitarias reales que inyectan los mocks en tus ViewModels. Pega el contenido de y en tus archivos de prueba.





