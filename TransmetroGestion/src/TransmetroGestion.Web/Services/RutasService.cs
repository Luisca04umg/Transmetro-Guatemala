using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
namespace TransmetroGestion.Web.Services;

public class RutasService(TransmetroDbContext db)
{
    public async Task<string> GuardarEstacionAsync(int origenLineaID,int estacionID,int destinoLineaID,short posicion,short? minutos)
    {
        if(posicion<1 || minutos<0)throw new InvalidOperationException("Revise el orden y los minutos.");
        var estacion=await db.Estaciones.FindAsync(estacionID) ?? throw new InvalidOperationException("La estación no existe.");
        var ids=new[]{origenLineaID,destinoLineaID}.Where(x=>x>0).Distinct().ToList();
        var lineas=await db.Lineas.Where(x=>ids.Contains(x.LineaID)).ToListAsync();
        if(!lineas.Any(x=>x.LineaID==destinoLineaID&&x.Estado!="I"))throw new InvalidOperationException("Seleccione una línea existente y no inactiva.");
        var estados=lineas.ToDictionary(x=>x.LineaID,x=>x.Estado);
        foreach(var l in lineas)if(l.Estado=="A")l.Estado="P";
        await db.SaveChangesAsync();
        var original=origenLineaID>0?await db.LineasEstaciones.FindAsync(origenLineaID,estacionID):null;
        if(origenLineaID>0&&original is null)throw new InvalidOperationException("La asignación original ya no existe.");
        var destino=await db.LineasEstaciones.FindAsync(destinoLineaID,estacionID);
        if(destino is not null&&origenLineaID!=destinoLineaID)throw new InvalidOperationException("La estación ya pertenece a esa línea. Edite su asignación existente.");
        if(destino is null)
        {
            var ordenes=await db.LineasEstaciones.Where(x=>x.LineaID==destinoLineaID).Select(x=>(int)x.Orden).ToListAsync();
            var libre=Enumerable.Range(1,32767).First(x=>!ordenes.Contains(x));
            destino=new LineaEstacion{LineaID=destinoLineaID,EstacionID=estacionID,Orden=(short)libre,TiempoMinuto=minutos,FechaAlta=DateTime.UtcNow};
            db.LineasEstaciones.Add(destino);
            // Primero la nueva membresía: nunca deja a una estación activa sin línea.
            await db.SaveChangesAsync();
        }
        if(original is not null&&origenLineaID!=destinoLineaID)
        {
            db.TramosLinea.RemoveRange(await db.TramosLinea.Where(x=>x.LineaID==origenLineaID&&(x.EstacionOrigenID==estacionID||x.EstacionDestinoID==estacionID)).ToListAsync());
            await db.SaveChangesAsync();
            db.LineasEstaciones.Remove(original);await db.SaveChangesAsync();
        }
        var lista=await db.LineasEstaciones.Where(x=>x.LineaID==destinoLineaID).OrderBy(x=>x.Orden).ToListAsync();
        lista.Remove(destino);if(posicion>lista.Count+1)throw new InvalidOperationException($"El orden debe estar entre 1 y {lista.Count+1}.");
        lista.Insert(posicion-1,destino);destino.TiempoMinuto=minutos;
        await Ordenar(lista);
        if(origenLineaID>0&&origenLineaID!=destinoLineaID)await Ordenar(await db.LineasEstaciones.Where(x=>x.LineaID==origenLineaID).OrderBy(x=>x.Orden).ToListAsync());
        // Conserva sólo las distancias cuyos extremos siguen siendo consecutivos.
        foreach(var l in lineas)
        {
            var ruta=await db.LineasEstaciones.Where(x=>x.LineaID==l.LineaID).ToListAsync();var orden=ruta.ToDictionary(x=>x.EstacionID,x=>x.Orden);
            var tramos=await db.TramosLinea.Where(x=>x.LineaID==l.LineaID).ToListAsync();
            db.TramosLinea.RemoveRange(tramos.Where(t=>!orden.ContainsKey(t.EstacionOrigenID)||!orden.ContainsKey(t.EstacionDestinoID)||orden[t.EstacionDestinoID]!=orden[t.EstacionOrigenID]+1));
        }
        await db.SaveChangesAsync();
        return await Restaurar(lineas,estados,"Asignación y orden guardados. Los viajes existentes conservan su itinerario; los nuevos usan esta configuración.");
    }
    private async Task Ordenar(List<LineaEstacion> lista)
    {
        if(lista.Count==0)return;
        if(lista.Count>15000)throw new InvalidOperationException("Demasiadas estaciones para reordenar.");
        var ocupados=lista.Select(x=>(int)x.Orden).Concat(Enumerable.Range(1,lista.Count)).ToHashSet();
        var temporales=Enumerable.Range(1,32767).Where(x=>!ocupados.Contains(x)).Take(lista.Count).ToList();
        for(int i=0;i<lista.Count;i++)lista[i].Orden=(short)temporales[i];
        await db.SaveChangesAsync();
        for(int i=0;i<lista.Count;i++)lista[i].Orden=(short)(i+1);
        await db.SaveChangesAsync();
    }
    public async Task<string> AsignarBusAsync(int busID,int? lineaID)
    {
        if(await db.Viajes.AnyAsync(x=>x.BusID==busID&&x.Estado=="EN_CURSO"))throw new InvalidOperationException("No puede cambiar la línea de un bus con viaje en curso.");
        if(!await db.Buses.AnyAsync(x=>x.BusID==busID))throw new InvalidOperationException("El bus no existe.");
        var actual=await db.LineasBuses.FindAsync(busID);
        if(actual?.LineaID==lineaID)return "La asignación ya estaba configurada.";
        var ids=new[]{actual?.LineaID,lineaID}.Where(x=>x.HasValue).Select(x=>x!.Value).Distinct().ToList();
        var lineas=await db.Lineas.Where(x=>ids.Contains(x.LineaID)).ToListAsync();
        if(lineaID.HasValue&&!lineas.Any(x=>x.LineaID==lineaID&&x.Estado!="I"))throw new InvalidOperationException("La línea destino no existe o está inactiva.");
        if(lineaID.HasValue)
        {
            int estaciones=await db.LineasEstaciones.CountAsync(x=>x.LineaID==lineaID);
            int buses=await db.LineasBuses.CountAsync(x=>x.LineaID==lineaID);
            if(estaciones==0||buses+1>2*estaciones)throw new InvalidOperationException("La asignación supera el máximo de dos buses por estación.");
        }
        var estados=lineas.ToDictionary(x=>x.LineaID,x=>x.Estado);foreach(var l in lineas)if(l.Estado=="A")l.Estado="P";
        await db.SaveChangesAsync();
        if(actual is not null){db.LineasBuses.Remove(actual);await db.SaveChangesAsync();}
        if(lineaID.HasValue){db.LineasBuses.Add(new LineaBus{BusID=busID,LineaID=lineaID.Value,FechaAsignacion=DateTime.UtcNow});await db.SaveChangesAsync();}
        return await Restaurar(lineas,estados,"Línea del bus actualizada.");
    }
    private async Task<string> Restaurar(List<Linea> lineas,Dictionary<int,string> estados,string mensaje)
    {
        foreach(var l in lineas.Where(x=>estados[x.LineaID]=="A"))
        {
            var ruta=await db.LineasEstaciones.Where(x=>x.LineaID==l.LineaID).OrderBy(x=>x.Orden).ToListAsync();
            int buses=await db.LineasBuses.CountAsync(x=>x.LineaID==l.LineaID);
            var tramos=await db.TramosLinea.Where(x=>x.LineaID==l.LineaID).ToListAsync();
            bool distancias=ruta.Where(x=>x.Orden<ruta.Count).All(x=>tramos.Any(t=>t.EstacionOrigenID==x.EstacionID));
            if(ruta.Count>0&&buses>=ruta.Count&&buses<=2*ruta.Count&&distancias)
                await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_ActivarLinea @LineaID={l.LineaID}");
            else mensaje+=$" {l.Nombre} quedó pendiente: revise flota y distancias y vuelva a activarla.";
        }
        return mensaje;
    }
}
