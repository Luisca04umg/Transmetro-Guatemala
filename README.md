# Transmetro de Guatemala

Proyecto académico de Luis Carlos Barrera Ramírez, Universidad Mariano Gálvez de Guatemala.

Sistema ASP.NET Core MVC (.NET 8), C#, Entity Framework Core y SQL Server. La aplicación se publicó en Azure App Service y Azure SQL Database.

## Enlaces

- Repositorio: https://github.com/Luisca04umg/Transmetro-Guatemala
- Aplicación web: https://transmetro-luis-web-2026-gxemdbbcenf9hwcf.canadacentral-01.azurewebsites.net

## Contenido

- `TransmetroGestion/TransmetroGestion.sln`: solución de Visual Studio.
- `TransmetroGestion/src/TransmetroGestion.Web/`: código fuente, vistas y recursos.
- `Script_Base_Datos_TransmetroGestionDB.sql`: esquema inicial y objetos SQL.
- `Actualizacion_2026_10.sql`, `Actualizacion_Transmetro_V2.sql` y `Actualizacion_Transmetro_V3.sql`: actualizaciones incluidas.
- `Carga_Transmetro_2025.sql`: carga de líneas y estaciones.
- `Datos_Prueba_Transmetro.sql`: datos de demostración.
- `LEEME_CAMBIOS.md`: historial e instrucciones de las actualizaciones.

## Ejecución local

1. Instalar SDK .NET 8, SQL Server y Visual Studio Community con Desarrollo de ASP.NET y web.
2. Crear la base con el script inicial y aplicar las actualizaciones siguiendo `LEEME_CAMBIOS.md`. Revisar los scripts antes de ejecutarlos sobre una base existente.
3. Abrir `TransmetroGestion/TransmetroGestion.sln`.
4. Configurar la conexión `TransmetroDb`. La copia incluye una conexión local con autenticación de Windows; se debe adaptar a la instancia disponible.
5. Para autenticación SQL, guardar la cadena con contraseña en Administrar secretos de usuario. Para Azure, usar Variables de entorno / Cadenas de conexión del App Service, nombre `TransmetroDb`, tipo SQLAzure.
6. Restaurar paquetes, compilar y ejecutar. Si no hay usuarios, utilizar la pantalla de inicialización para crear el primer administrador.

## Módulos

Resumen; rutas y flota; personal y accesos; operación y recorridos; registro de tarjetas; reportes; usuarios y roles. Portal ciudadano con saldo, recargas, pagos, seguimiento por línea y mapa.

Los reportes de la aplicación se encuentran en `Controllers/ReportesController.cs` y `Views/Reportes/`, dentro del proyecto web. Las vistas SQL se encuentran en el script de base de datos.

## Configuración y entregables

Las contraseñas, los perfiles privados de publicación y los archivos de compilación no se incluyen. Los documentos PDF, presentación y enlace del video se incorporarán al completar la entrega académica. No se incluyen credenciales de acceso público en este README.
