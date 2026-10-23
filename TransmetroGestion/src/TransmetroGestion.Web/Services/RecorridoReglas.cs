using TransmetroGestion.Web.Models;
namespace TransmetroGestion.Web.Services;

public static class RecorridoReglas
{
    public static VisitaEstacionViaje? Siguiente(IEnumerable<VisitaEstacionViaje> visitas)
        => visitas.Where(x=>!x.OmitidaMantenimiento&&x.SalidaReal==null).OrderBy(x=>x.OrdenVisita).FirstOrDefault();
    public static List<VisitaEstacionViaje> Planificar(long viajeID,IEnumerable<LineaEstacion> ruta,IReadOnlyDictionary<int,string> estados,DateTime salida)
    {
        var visitas=new List<VisitaEstacionViaje>();var hora=salida;bool iniciado=false,conocido=true;
        foreach(var parada in ruta.OrderBy(x=>x.Orden))
        {
            bool activa=estados.GetValueOrDefault(parada.EstacionID)=="A";
            if(iniciado)
            {
                if(parada.TiempoMinuto is null)conocido=false;
                else hora=hora.AddMinutes(parada.TiempoMinuto.Value);
            }
            if(activa&&!iniciado){iniciado=true;hora=salida;}
            visitas.Add(new VisitaEstacionViaje{ViajeID=viajeID,EstacionID=parada.EstacionID,OrdenVisita=parada.Orden,
                OmitidaMantenimiento=!activa,LlegadaProgramada=iniciado&&conocido?hora:null});
        }
        return visitas;
    }
}
