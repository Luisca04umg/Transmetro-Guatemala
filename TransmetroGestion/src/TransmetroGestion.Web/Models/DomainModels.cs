using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TransmetroGestion.Web.Models;

[Table("Municipalidad", Schema = "cat")]
public class Municipalidad
{
    public int MunicipalidadID { get; set; }
    [Required, StringLength(20)] public string Codigo { get; set; } = "";
    [Required, StringLength(150)] public string Nombre { get; set; } = "";
    [Required, StringLength(100)] public string Departamento { get; set; } = "Guatemala";
    [StringLength(25)] public string? Telefono { get; set; }
    [StringLength(254), EmailAddress] public string? Correo { get; set; }
    [StringLength(300)] public string? Direccion { get; set; }
    public bool Activa { get; set; } = true;
    public DateTime FechaCreacion { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("Linea", Schema = "ops")]
public class Linea
{
    public int LineaID { get; set; }
    public int MunicipalidadID { get; set; }
    [Required, StringLength(20)] public string Codigo { get; set; } = "";
    [Required, StringLength(150)] public string Nombre { get; set; } = "";
    [StringLength(500)] public string? Descripcion { get; set; }
    [Required, StringLength(1)] public string Estado { get; set; } = "P";
    public DateTime FechaCreacion { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("Estacion", Schema = "ops")]
public class Estacion
{
    public int EstacionID { get; set; }
    public int MunicipalidadID { get; set; }
    [Required, StringLength(20)] public string Codigo { get; set; } = "";
    [Required, StringLength(150)] public string Nombre { get; set; } = "";
    [StringLength(300)] public string? Direccion { get; set; }
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    public short CapacidadReferencia { get; set; } = 80;
    [Required, StringLength(1)] public string Estado { get; set; } = "P";
    public DateTime FechaCreacion { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("LineaEstacion", Schema = "ops")]
public class LineaEstacion
{
    public int LineaID { get; set; }
    public int EstacionID { get; set; }
    public short Orden { get; set; }
    public short? TiempoMinuto { get; set; }
    public DateTime FechaAlta { get; set; }
}

[Table("TramoLinea", Schema = "ops")]
public class TramoLinea
{
    public long TramoID { get; set; }
    public int LineaID { get; set; }
    public int EstacionOrigenID { get; set; }
    public int EstacionDestinoID { get; set; }
    public decimal DistanciaKm { get; set; }
    public DateTime FechaActualizacion { get; set; }
}

[Table("Acceso", Schema = "ops")]
public class Acceso
{
    public int AccesoID { get; set; }
    public int EstacionID { get; set; }
    [Required, StringLength(30)] public string Codigo { get; set; } = "";
    [Required, StringLength(120)] public string Nombre { get; set; } = "";
    [StringLength(300)] public string? Descripcion { get; set; }
    [Required, StringLength(20)] public string TipoAcceso { get; set; } = "PEATONAL";
    [Required, StringLength(1)] public string Estado { get; set; } = "P";
    public DateTime FechaCreacion { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("Parqueo", Schema = "ops")]
public class Parqueo
{
    public int ParqueoID { get; set; }
    public int EstacionID { get; set; }
    [Required, StringLength(30)] public string Codigo { get; set; } = "";
    [Required, StringLength(120)] public string Nombre { get; set; } = "";
    public short CapacidadBuses { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; }
}

[Table("Bus", Schema = "ops")]
public class Bus
{
    public int BusID { get; set; }
    public int ParqueoID { get; set; }
    [Required, StringLength(30)] public string CodigoInterno { get; set; } = "";
    [Required, StringLength(20)] public string Placa { get; set; } = "";
    [StringLength(60)] public string? Marca { get; set; }
    [StringLength(60)] public string? Modelo { get; set; }
    public short? Anio { get; set; }
    public short CapacidadMaxima { get; set; }
    [Required, StringLength(20)] public string Estado { get; set; } = "DISPONIBLE";
    public DateTime FechaRegistro { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("LineaBus", Schema = "ops")]
public class LineaBus
{
    public int BusID { get; set; }
    public int LineaID { get; set; }
    public DateTime FechaAsignacion { get; set; }
}

[Table("HistorialParqueoBus", Schema = "ops")]
public class HistorialParqueoBus
{
    public long HistorialParqueoID { get; set; }
    public int BusID { get; set; }
    public int? ParqueoAnteriorID { get; set; }
    public int ParqueoNuevoID { get; set; }
    public DateTime FechaCambio { get; set; }
    public int? UsuarioCambioID { get; set; }
    [StringLength(300)] public string? Motivo { get; set; }
}

[Table("Viaje", Schema = "ops")]
public class Viaje
{
    public long ViajeID { get; set; }
    public int LineaID { get; set; }
    public int BusID { get; set; }
    public int? PilotoID { get; set; }
    public DateTime FechaSalida { get; set; }
    public DateTime? FechaLlegada { get; set; }
    [Required, StringLength(20)] public string Estado { get; set; } = "PROGRAMADO";
}

[Table("VisitaEstacionViaje", Schema = "ops")]
public class VisitaEstacionViaje
{
    public bool OmitidaMantenimiento { get; set; }
    public long ViajeID { get; set; }
    public int EstacionID { get; set; }
    public short OrdenVisita { get; set; }
    public DateTime? LlegadaProgramada { get; set; }
    public DateTime? LlegadaReal { get; set; }
    public DateTime? SalidaReal { get; set; }
}

[Table("ConteoEstacion", Schema = "ops")]
public class ConteoEstacion
{
    public int? LineaID { get; set; }
    public long ConteoEstacionID { get; set; }
    public int EstacionID { get; set; }
    public int CantidadPasajeros { get; set; }
    public short CapacidadEvaluada { get; set; }
    public DateTime FechaRegistro { get; set; }
    public int? OperadorID { get; set; }
}

[Table("AlertaOcupacion", Schema = "ops")]
public class AlertaOcupacion
{
    public long AlertaID { get; set; }
    public long ConteoEstacionID { get; set; }
    public int EstacionID { get; set; }
    public decimal Porcentaje { get; set; }
    public bool RequiereUnidad { get; set; }
    [Required, StringLength(20)] public string Estado { get; set; } = "PENDIENTE";
    public DateTime FechaGeneracion { get; set; }
    public DateTime? FechaAtencion { get; set; }
    [StringLength(500)] public string? Observacion { get; set; }
}

[Table("RegistroOcupacionBus", Schema = "ops")]
public class RegistroOcupacionBus
{
    public long RegistroOcupacionID { get; set; }
    public int BusID { get; set; }
    public int EstacionID { get; set; }
    public long? ViajeID { get; set; }
    public short CantidadPasajeros { get; set; }
    public short CapacidadEvaluada { get; set; }
    public decimal PorcentajeOcupacion { get; set; }
    public DateTime FechaRegistro { get; set; }
}

[Table("EsperaAdicional", Schema = "ops")]
public class EsperaAdicional
{
    public long EsperaID { get; set; }
    public long RegistroOcupacionID { get; set; }
    public byte MinutosAdicionales { get; set; } = 5;
    public bool Aplicada { get; set; }
    public DateTime FechaIndicacion { get; set; }
    public DateTime? FechaAplicacion { get; set; }
}

[Table("Piloto", Schema = "ops")]
public class Piloto
{
    public int PilotoID { get; set; }
    [Required, StringLength(30)] public string CodigoEmpleado { get; set; } = "";
    [Required, StringLength(100)] public string Nombres { get; set; } = "";
    [Required, StringLength(100)] public string Apellidos { get; set; } = "";
    public byte[]? DPIHash { get; set; }
    [Required, StringLength(300)] public string Direccion { get; set; } = "";
    [Required, StringLength(100)] public string Municipio { get; set; } = "";
    [Required, StringLength(100)] public string Departamento { get; set; } = "Guatemala";
    [Required, StringLength(25)] public string Telefono { get; set; } = "";
    [StringLength(254), EmailAddress] public string? Correo { get; set; }
    [Required, StringLength(30)] public string Licencia { get; set; } = "";
    public DateOnly FechaVencimientoLicencia { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaRegistro { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("HistorialEducativoPiloto", Schema = "ops")]
public class HistorialEducativoPiloto
{
    public int HistorialEducativoID { get; set; }
    public int PilotoID { get; set; }
    [Required, StringLength(30)] public string Nivel { get; set; } = "OTRO";
    [Required, StringLength(200)] public string Institucion { get; set; } = "";
    [StringLength(200)] public string? Titulo { get; set; }
    public short? AnioFinalizacion { get; set; }
    [StringLength(500)] public string? Observacion { get; set; }
}

[Table("Guardia", Schema = "ops")]
public class Guardia
{
    public int GuardiaID { get; set; }
    [Required, StringLength(30)] public string CodigoEmpleado { get; set; } = "";
    [Required, StringLength(100)] public string Nombres { get; set; } = "";
    [Required, StringLength(100)] public string Apellidos { get; set; } = "";
    [StringLength(25)] public string? Telefono { get; set; }
    [StringLength(150)] public string? Empresa { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaRegistro { get; set; }
}

[Table("AsignacionGuardiaAcceso", Schema = "ops")]
public class AsignacionGuardiaAcceso
{
    public long AsignacionGuardiaID { get; set; }
    public int GuardiaID { get; set; }
    public int AccesoID { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    [Required, StringLength(20)] public string Turno { get; set; } = "DIURNO";
}

[Table("Operador", Schema = "ops")]
public class Operador
{
    public int OperadorID { get; set; }
    [Required, StringLength(30)] public string CodigoEmpleado { get; set; } = "";
    [Required, StringLength(100)] public string Nombres { get; set; } = "";
    [Required, StringLength(100)] public string Apellidos { get; set; } = "";
    [StringLength(25)] public string? Telefono { get; set; }
    [StringLength(254), EmailAddress] public string? Correo { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaRegistro { get; set; }
}

[Table("AsignacionOperadorEstacion", Schema = "ops")]
public class AsignacionOperadorEstacion
{
    public long AsignacionOperadorID { get; set; }
    public int OperadorID { get; set; }
    public int EstacionID { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
}

[Table("Usuario", Schema = "seg")]
public class Usuario
{
    public int UsuarioID { get; set; }
    public int? OperadorID { get; set; }
    [Required, StringLength(100)] public string NombreUsuario { get; set; } = "";
    [Required, StringLength(254), EmailAddress] public string Correo { get; set; } = "";
    [Required] public byte[] ContrasenaHash { get; set; } = [];
    [Required] public byte[] ContrasenaSalt { get; set; } = [];
    public bool Activo { get; set; } = true;
    public byte IntentosFallidos { get; set; }
    public DateTime? BloqueadoHasta { get; set; }
    public DateTime? UltimoAcceso { get; set; }
    public DateTime FechaCreacion { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("Rol", Schema = "seg")]
public class Rol
{
    public short RolID { get; set; }
    [Required, StringLength(80)] public string Nombre { get; set; } = "";
    [StringLength(300)] public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;
}

[Table("Permiso", Schema = "seg")]
public class Permiso
{
    public short PermisoID { get; set; }
    [Required, StringLength(80)] public string Codigo { get; set; } = "";
    [Required, StringLength(300)] public string Descripcion { get; set; } = "";
}

[Table("UsuarioRol", Schema = "seg")]
public class UsuarioRol
{
    public int UsuarioID { get; set; }
    public short RolID { get; set; }
    public DateTime FechaAsignacion { get; set; }
}

[Table("RolPermiso", Schema = "seg")]
public class RolPermiso
{
    public short RolID { get; set; }
    public short PermisoID { get; set; }
}

[Table("Bitacora", Schema = "aud")]
public class Bitacora
{
    public long BitacoraID { get; set; }
    public int? UsuarioID { get; set; }
    [Required] public string Esquema { get; set; } = "";
    [Required] public string Tabla { get; set; } = "";
    [Required, StringLength(1)] public string Operacion { get; set; } = "";
    [StringLength(200)] public string? ClaveRegistro { get; set; }
    public string? DatosAnteriores { get; set; }
    public string? DatosNuevos { get; set; }
    public DateTime FechaHora { get; set; }
    [Required] public string UsuarioBD { get; set; } = "";
    [StringLength(48)] public string? DireccionIP { get; set; }
}

[Table("TitularTarjeta", Schema = "fin")]
public class TitularTarjeta
{
    [StringLength(9), RegularExpression(@"^[0-9]{8,9}$")] public string? DPI { get; set; }
    public long TitularID { get; set; }
    [Required, StringLength(100)] public string Nombres { get; set; } = "";
    [Required, StringLength(100)] public string Apellidos { get; set; } = "";
    [StringLength(254), EmailAddress] public string? Correo { get; set; }
    [StringLength(25)] public string? Telefono { get; set; }
    public byte[]? DocumentoHash { get; set; }
    public DateTime FechaRegistro { get; set; }
}

[Table("TarjetaAcceso", Schema = "fin")]
public class TarjetaAcceso
{
    public long TarjetaID { get; set; }
    public long? TitularID { get; set; }
    [Required, StringLength(64)] public string NumeroToken { get; set; } = "";
    public decimal Saldo { get; set; }
    [Required, StringLength(20)] public string Estado { get; set; } = "ACTIVA";
    public DateOnly FechaEmision { get; set; }
    public DateOnly? FechaVencimiento { get; set; }
    [Timestamp] public byte[] VersionFila { get; set; } = [];
}

[Table("TransaccionTarjeta", Schema = "fin")]
public class TransaccionTarjeta
{
    public long TransaccionID { get; set; }
    public long TarjetaID { get; set; }
    public int? EstacionID { get; set; }
    [Required, StringLength(1)] public string Tipo { get; set; } = "";
    public decimal Monto { get; set; }
    public decimal SaldoAnterior { get; set; }
    public decimal SaldoNuevo { get; set; }
    [Required, StringLength(80)] public string Referencia { get; set; } = "";
    public DateTime FechaHora { get; set; }
    public int? UsuarioID { get; set; }
}

[Table("AsignacionPilotoBus", Schema = "ops")]
public class AsignacionPilotoBus
{
    public long AsignacionID { get; set; }
    public int BusID { get; set; }
    public int PilotoID { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
}

[Table("RegistroParadaViaje", Schema = "ops")]
public class RegistroParadaViaje
{
    public long RegistroParadaID { get; set; }
    public long ViajeID { get; set; }
    public int EstacionID { get; set; }
    public short PasajerosAntes { get; set; }
    public short Suben { get; set; }
    public short Bajan { get; set; }
    public short PasajerosDespues { get; set; }
    public int EsperanEstacion { get; set; }
    public DateTime FechaRegistro { get; set; }
}
[Table("PaseLineaTarjeta", Schema = "fin")]
public class PaseLineaTarjeta
{
    public long PaseID { get; set; }
    public long TarjetaID { get; set; }
    public int LineaID { get; set; }
    public int EstacionID { get; set; }
    public long TransaccionID { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
}
