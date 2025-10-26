RepNet 

RepNet es una aplicación móvil para iOS diseñada para crear una comunidad de ciberseguridad. Permite a los usuarios reportar sitios web maliciosos de diversas cateogiras y consultar los reportes de otros para navegar de forma más segura.

    Nota Importante:

        Esta es una descripción del proyecto.

        Para saber cómo hacer un deploy del proyecto, ve al archivo deployreadme.md.

        Para hacer pruebas (unitarias y de mocks), ve al archivo readme_for_testing.md dentro de la carpeta RepNetTests.

Características Principales

    Autenticación de Usuarios: Sistema completo de registro e inicio de sesión con manejo seguro de tokens (JWT) y almacenamiento en Keychain.

    Gestión de Reportes (CRUD): Los usuarios pueden crear, ver, editar y eliminar sus propios reportes.

    Reportes Públicos: Una sección para ver todos los reportes que han sido "Aprobados" por un administrador, permitiendo a la comunidad ver las amenazas activas.

    Sistema de Votación: Los usuarios pueden votar (upvote/downvote) en los reportes públicos para ayudar a validar su relevancia.

    Búsqueda de Sitios: Permite a los usuarios buscar un dominio específico (ej. sitio-malo.com) para ver un resumen del sitio y todos los reportes asociados a él.

    Gestión de Evidencias: Sistema de subida de múltiples imágenes (PhotosPicker) con redimensionamiento del lado del cliente para adjuntar pruebas a los reportes.

    Feedback de Administrador: Los usuarios pueden recibir comentarios directos de un administrador en sus reportes (visible solo para el autor del reporte).

    Gestión de Cuenta: Los usuarios pueden actualizar su información de perfil y eliminar su cuenta.

Stack de Tecnología

    Frontend (iOS): SwiftUI, Combine, PhotosUI.

    Backend (API): NestJS 

    Arquitectura: MVVM (Model-View-ViewModel).
----------------------------------------------------------------- ENGLISH -----------------------------------------------

RepNet 

RepNet is an iOS mobile application designed to build a cybersecurity community. It allows users to report malicious websites (phishing, malware, fraud) and consult reports from other users to browse more safely.

    Important Note:

        This is a project description.

        For deployment instructions, please see the deployreadme.md file.

        For testing (unit tests and mocks), please see the readme_for_testing.md file inside the RepNetTests folder.

Key Features

    User Authentication: Complete registration and login system with secure JWT handling and Keychain storage.

    Report Management (CRUD): Users can create, view, edit, and delete their own reports.

    Public Reports: A section to view all reports that have been "Approved" by an administrator, allowing the community to see active threats.

    Voting System: Users can upvote/downvote public reports to help validate their relevance.

    Site Search: Allows users to search for a specific domain (e.g., bad-site.com) to see a site summary and all associated reports.

    Evidence Management: Multi-image upload system (PhotosPicker) with client-side resizing to attach proof to reports.

    Admin Feedback: Users can receive direct comments from an administrator on their reports (visible only to the report's author).

    Account Management: Users can update their profile information and delete their account.

Tech Stack

    Frontend (iOS): SwiftUI, Combine, PhotosUI.

    Backend (API): NestJS 

    Architecture: MVVM (Model-View-ViewModel).
