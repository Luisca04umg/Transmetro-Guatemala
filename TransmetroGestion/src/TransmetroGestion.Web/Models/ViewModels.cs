namespace TransmetroGestion.Web.Models;

public class DashboardVm
{
    public int Lineas { get; set; }
    public int Estaciones { get; set; }
    public int Buses { get; set; }
    public int Pilotos { get; set; }
    public int AlertasPendientes { get; set; }
    public int TarjetasActivas { get; set; }
    public List<VistaAlertaPendiente> Alertas { get; set; } = [];
}

public class CatalogosVm
{
    public Dictionary<string,int> Totales { get; set; } = [];
    public int RegistroID { get; set; }
    public string TipoFicha { get; set; } = "";
    public string Formulario { get; set; } = "";
    public List<TramoLinea> Tramos { get; set; } = [];
    public List<Municipalidad> Municipalidades { get; set; } = [];
    public List<Linea> Lineas { get; set; } = [];
    public List<Estacion> Estaciones { get; set; } = [];
    public List<Parqueo> Parqueos { get; set; } = [];
    public List<Bus> Buses { get; set; } = [];
    public List<LineaEstacion> LineasEstaciones { get; set; } = [];
    public List<LineaBus> LineasBuses { get; set; } = [];
}

public class PersonalVm
{
    public Dictionary<string,int> Totales { get; set; } = [];
    public int RegistroID { get; set; }
    public string TipoFicha { get; set; } = "";
    public string Formulario { get; set; } = "";
    public List<AsignacionOperadorEstacion> AsignacionesOperador { get; set; } = [];
    public List<HistorialEducativoPiloto> Educacion { get; set; } = [];
    public List<Piloto> Pilotos { get; set; } = [];
    public List<Operador> Operadores { get; set; } = [];
    public List<Guardia> Guardias { get; set; } = [];
    public List<Acceso> Accesos { get; set; } = [];
    public List<Estacion> Estaciones { get; set; } = [];
    public List<AsignacionGuardiaAcceso> AsignacionesGuardia { get; set; } = [];
}

public class OperacionVm
{
    public int? LineaSeleccionada { get; set; }
    public List<Estacion> Estaciones { get; set; } = [];
    public List<Bus> Buses { get; set; } = [];
    public List<Operador> Operadores { get; set; } = [];
    public List<VistaAlertaPendiente> Alertas { get; set; } = [];
    public List<ConteoEstacion> Conteos { get; set; } = [];
    public List<RegistroOcupacionBus> Ocupaciones { get; set; } = [];
    public List<EsperaAdicional> Esperas { get; set; } = [];
}

public class TarjetasVm
{
    public string Q { get; set; } = "";
    public int Pagina { get; set; } = 1;
    public int Total { get; set; }
    public const int TamanoPagina = 25;
    public int Paginas => Math.Max(1, (int)Math.Ceiling(Total / (double)TamanoPagina));
    public List<TitularTarjeta> Titulares { get; set; } = [];
    public List<TarjetaAcceso> Tarjetas { get; set; } = [];
    public List<TransaccionTarjeta> Transacciones { get; set; } = [];
    public List<Estacion> Estaciones { get; set; } = [];
}

public class UsuariosVm
{
    public List<Usuario> Usuarios { get; set; } = [];
    public List<Rol> Roles { get; set; } = [];
    public List<UsuarioRol> Asignaciones { get; set; } = [];
}

public class ReportesVm
{
    public string Reporte { get; set; } = "";
    public List<VistaLinea> Lineas { get; set; } = [];
    public List<VistaEstacion> Estaciones { get; set; } = [];
    public List<VistaBusPorLinea> Buses { get; set; } = [];
    public List<VistaEstacionPorLinea> Recorridos { get; set; } = [];
    public List<Bitacora> Bitacora { get; set; } = [];
}

public class LoginVm
{
    public string NombreUsuario { get; set; } = "";
    public string Contrasena { get; set; } = "";
    public bool Recordarme { get; set; }
}

public class InicializarVm
{
    public string NombreUsuario { get; set; } = "admin";
    public string Correo { get; set; } = "";
    public string Contrasena { get; set; } = "";
    public string ConfirmarContrasena { get; set; } = "";
}

public class RecorridosVm
{
    public int? LineaSeleccionada { get; set; }
    public string Seccion { get; set; } = "seguimiento";
    public List<Bus> BusesDisponibles { get; set; } = [];
    public List<Piloto> PilotosDisponibles { get; set; } = [];
    public List<Linea> Lineas { get; set; } = [];
    public List<Bus> Buses { get; set; } = [];
    public List<Piloto> Pilotos { get; set; } = [];
    public List<Estacion> Estaciones { get; set; } = [];
    public List<LineaEstacion> Ruta { get; set; } = [];
    public List<Viaje> Viajes { get; set; } = [];
    public List<VisitaEstacionViaje> Visitas { get; set; } = [];
    public List<AsignacionPilotoBus> Asignaciones { get; set; } = [];
    public List<RegistroParadaViaje> Paradas { get; set; } = [];
    public OperacionVm Operacion { get; set; } = new();
}
public class CiudadanoVm
{
    public TarjetaAcceso Tarjeta { get; set; } = new();
    public List<TransaccionTarjeta> Movimientos { get; set; } = [];
    public List<Estacion> Estaciones { get; set; } = [];
    public RecorridosVm Recorridos { get; set; } = new();
    public List<Linea> Lineas { get; set; } = [];
    public List<LineaEstacion> Ruta { get; set; } = [];
    public PaseLineaTarjeta? PaseActivo { get; set; }
    public int? LineaSeleccionada { get; set; }
}

public class CampoEdicionVm
{
    public string Nombre { get; set; } = "";
    public string Etiqueta { get; set; } = "";
    public string Valor { get; set; } = "";
    public string Tipo { get; set; } = "text";
    public bool Obligatorio { get; set; }
    public int? Maximo { get; set; }
    public Dictionary<string,string> Opciones { get; set; } = [];
}
public class EdicionVm
{
    public string Tipo { get; set; } = "";
    public int ID { get; set; }
    public string Titulo { get; set; } = "";
    public string Revision { get; set; } = "";
    public List<CampoEdicionVm> Campos { get; set; } = [];
}
public class RegistroVistaVm
{
    public object Entidad { get; set; } = new();
    public Dictionary<string,string> Relaciones { get; set; } = [];
}

public class FilaDirectorioVm
{
 public int ID { get; set; }
 public string Titulo { get; set; } = "";
 public string Resumen { get; set; } = "";
}
public class DirectorioVm
{
 public string Tipo { get; set; } = "";
 public string Q { get; set; } = "";
 public int Pagina { get; set; } = 1;
 public int Total { get; set; }
 public const int Tamano = 20;
 public int Paginas => Math.Max(1,(int)Math.Ceiling(Total/(double)Tamano));
 public List<FilaDirectorioVm> Filas { get; set; } = [];
}
