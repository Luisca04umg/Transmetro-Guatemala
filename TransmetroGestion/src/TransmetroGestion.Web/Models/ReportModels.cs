using Microsoft.EntityFrameworkCore;

namespace TransmetroGestion.Web.Models;

[Keyless]
public class VistaEstacion
{
    public int EstacionID { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string? Direccion { get; set; }
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    public short CapacidadReferencia { get; set; }
    public string Estado { get; set; } = "";
    public string Municipalidad { get; set; } = "";
    public int CantidadLineas { get; set; }
    public int CantidadAccesos { get; set; }
}

[Keyless]
public class VistaLinea
{
    public int LineaID { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Estado { get; set; } = "";
    public string Municipalidad { get; set; } = "";
    public int CantidadEstaciones { get; set; }
    public int CantidadBuses { get; set; }
    public decimal DistanciaTotalKm { get; set; }
}

[Keyless]
public class VistaBusPorLinea
{
    public int LineaID { get; set; }
    public string CodigoLinea { get; set; } = "";
    public string Linea { get; set; } = "";
    public int BusID { get; set; }
    public string CodigoInterno { get; set; } = "";
    public string Placa { get; set; } = "";
    public string? Marca { get; set; }
    public string? Modelo { get; set; }
    public short CapacidadMaxima { get; set; }
    public string Estado { get; set; } = "";
    public string CodigoParqueo { get; set; } = "";
    public string Parqueo { get; set; } = "";
    public string EstacionParqueo { get; set; } = "";
}

[Keyless]
public class VistaEstacionPorLinea
{
    public int LineaID { get; set; }
    public string CodigoLinea { get; set; } = "";
    public string Linea { get; set; } = "";
    public short Orden { get; set; }
    public int EstacionID { get; set; }
    public string CodigoEstacion { get; set; } = "";
    public string Estacion { get; set; } = "";
    public decimal? DistanciaSiguienteKm { get; set; }
}

[Keyless]
public class VistaAlertaPendiente
{
    public long AlertaID { get; set; }
    public DateTime FechaGeneracion { get; set; }
    public string CodigoEstacion { get; set; } = "";
    public string Estacion { get; set; } = "";
    public int CantidadPasajeros { get; set; }
    public short CapacidadEvaluada { get; set; }
    public decimal Porcentaje { get; set; }
    public bool RequiereUnidad { get; set; }
    public string Estado { get; set; } = "";
}
