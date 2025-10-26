--------------------------- SPANISH -----------------------------------


Guía de Despliegue:

Requisito Indispensable: Tener un backend encendido 

Para que la aplicación funcione, el servidor del backend debe estar ejecutándose y ser accesible desde la red del iPhone.

  Asegúrate de que la computadora que corre el servidor NestJS (ej. http://0.0.0.0:3000) esté encendida.

  El iPhone debe estar conectado a la misma red Wi-Fi que el servidor.

  Verifica que la IP en el archivo AppConfig.swift sea la correcta para esa red.

Requisitos (Hardware/Software)

  Mac con Xcode (versión 14 o superior).

  iPhone 14 en adelante (con iOS 16 o superior).

  Un cable USB (Lightning o USB-C).

  Un Apple ID .

Pasos para Instalar en tu iPhone

  Conectar el Dispositivo:

   Conecta tu iPhone a tu Mac con el cable USB.

   Desbloquea tu iPhone y presiona "Confiar" si aparece el mensaje "¿Confiar en esta computadora?".

   Añadir tu Apple ID a Xcode (Solo la primera vez):

  En Xcode, ve a Xcode > Settings....

  Ve a la pestaña Accounts.

  Haz clic en el + y selecciona "Apple ID" para iniciar sesión.

  Configurar la Firma del Proyecto:

  En el navegador de archivos, haz clic en el icono azul del proyecto RepNet.

   Selecciona el Target RepNet.

   Ve a la pestaña "Signing & Capabilities".

  Marca la casilla "Automatically manage signing".

  En el menú desplegable "Team", selecciona tu Apple ID (ej. "Tu Nombre (Personal Team)").

 Seleccionar tu iPhone como Destino:

  En la barra de herramientas superior de Xcode, haz clic en el selector de dispositivo (donde eliges el simulador).

  Selecciona el nombre de tu iPhone en la sección "iOS Devices".

Ejecutar la Aplicación:

  Presiona el botón de Play o presiona Cmd + R.

Confiar en el Desarrollador (Solo la primera vez):

   En tu iPhone, ve a Configuración > General > VPN y Administración de dispositivos.

  Bajo "APP DE DESARROLLADOR", toca tu Apple ID.

   Toca el botón azul "Confiar en [tu Apple ID]" y confirma.

   Vuelve a presionar Play en Xcode. La app se abrirá

----------- ENGLISH ------------------

Deployment Guide (On-Device Testing)

This guide explains how to build and install the RepNet application on a physical iPhone for testing and demonstration.

Backend Prerequisite

For the application to function, the backend server must be running and accessible from the iPhone's network.

   Ensure the computer running the NestJS server (e.g., http://0.0.0.0:3000) is on.

  The iPhone must be connected to the same Wi-Fi network as the server.

  Verify that the IP address in the AppConfig.swift file is correct for that network.

Requirements (Hardware/Software)

  A Mac with Xcode (Version 14 or later).

  An iPhone 14 or newer (running iOS 16 or later).

   A USB Cable (Lightning or USB-C).

  An Apple ID (a free, personal account is sufficient).

Steps to Install on Your iPhone

   Connect Device:

  Connect your iPhone to your Mac via USB cable.

  Unlock your iPhone and tap "Trust" if the "Trust This Computer?" alert appears.

  Add Apple ID to Xcode (First Time Only):

  In Xcode, go to Xcode > Settings... (or Cmd + ,).

  Go to the Accounts tab.

  Click the + button and select "Apple ID" to sign in.

Configure Project Signing:

   In the Xcode file navigator, click the blue RepNet project icon.

   Select the RepNet Target.

   Go to the "Signing & Capabilities" tab.

  Check the "Automatically manage signing" box.

   From the "Team" dropdown, select the Apple ID you just added (e.g., "Your Name (Personal Team)").

 Select Your iPhone as the Target:

  In the top toolbar of Xcode, click the device selector (where you choose the simulator).

  Select your iPhone's name from the "iOS Devices" section.

Run the Application:

  Press the Play button or press Cmd + R.

Trust the Developer (First Time Only):

  On your iPhone, go to Settings > General > VPN & Device Management.

  Under "DEVELOPER APP", tap your Apple ID.

  Tap the blue "Trust [Your Apple ID]" button and confirm.

  Press Play (▶) in Xcode again. The app will now launch.
