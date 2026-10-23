using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
namespace TransmetroGestion.Web.Services;

public class DirectorioService(TransmetroDbContext db)
{
    public static bool Permite(string area,string tipo) => area=="Personal" ? tipo is "Piloto" or "Operador" or "Guardia" or "Acceso"
        : area=="Catalogos" && tipo is "Municipalidad" or "Linea" or "Estacion" or "Bus" or "Parqueo";
    public async Task<DirectorioVm> ConsultarAsync(string tipo,string? q,int pagina,CancellationToken ct=default)
    {
        q=(q??"").Trim();if(q.Length>80)q=q[..80];
        IQueryable<FilaDirectorioVm> consulta=tipo switch
        {
            "Piloto"=>db.Pilotos.AsNoTracking().Where(x=>q==""||x.CodigoEmpleado.Contains(q)||(x.Nombres+" "+x.Apellidos).Contains(q)||x.Telefono.Contains(q)||x.Licencia.Contains(q))
                .OrderBy(x=>x.Apellidos).ThenBy(x=>x.PilotoID).Select(x=>new FilaDirectorioVm{ID=x.PilotoID,Titulo=x.CodigoEmpleado+" · "+x.Nombres+" "+x.Apellidos,Resumen=x.Activo?"Activo":"Inactivo"}),
            "Operador"=>db.Operadores.AsNoTracking().Where(x=>q==""||x.CodigoEmpleado.Contains(q)||(x.Nombres+" "+x.Apellidos).Contains(q)||(x.Telefono!=null&&x.Telefono.Contains(q))||(x.Correo!=null&&x.Correo.Contains(q)))
                .OrderBy(x=>x.Apellidos).ThenBy(x=>x.OperadorID).Select(x=>new FilaDirectorioVm{ID=x.OperadorID,Titulo=x.CodigoEmpleado+" · "+x.Nombres+" "+x.Apellidos,Resumen=x.Activo?"Activo":"Inactivo"}),
            "Guardia"=>db.Guardias.AsNoTracking().Where(x=>q==""||x.CodigoEmpleado.Contains(q)||(x.Nombres+" "+x.Apellidos).Contains(q)||(x.Empresa!=null&&x.Empresa.Contains(q)))
                .OrderBy(x=>x.Apellidos).ThenBy(x=>x.GuardiaID).Select(x=>new FilaDirectorioVm{ID=x.GuardiaID,Titulo=x.CodigoEmpleado+" · "+x.Nombres+" "+x.Apellidos,Resumen=x.Activo?"Activo":"Inactivo"}),
            "Acceso"=>db.Accesos.AsNoTracking().Where(x=>q==""||x.Codigo.Contains(q)||x.Nombre.Contains(q)||db.Estaciones.Any(e=>e.EstacionID==x.EstacionID&&e.Nombre.Contains(q)))
                .OrderBy(x=>x.Codigo).ThenBy(x=>x.AccesoID).Select(x=>new FilaDirectorioVm{ID=x.AccesoID,Titulo=x.Codigo+" · "+x.Nombre,Resumen=x.Estado=="A"?"Activo":x.Estado=="I"?"Inactivo":"Pendiente"}),
            "Linea"=>db.Lineas.AsNoTracking().Where(x=>q==""||x.Codigo.Contains(q)||x.Nombre.Contains(q))
                .OrderBy(x=>x.Codigo).ThenBy(x=>x.LineaID).Select(x=>new FilaDirectorioVm{ID=x.LineaID,Titulo=x.Codigo+" · "+x.Nombre,Resumen=x.Estado=="A"?"Activa":x.Estado=="I"?"Inactiva":"Pendiente"}),
            "Estacion"=>db.Estaciones.AsNoTracking().Where(x=>q==""||x.Codigo.Contains(q)||x.Nombre.Contains(q)||(x.Direccion!=null&&x.Direccion.Contains(q)))
                .OrderBy(x=>x.Nombre).ThenBy(x=>x.EstacionID).Select(x=>new FilaDirectorioVm{ID=x.EstacionID,Titulo=x.Codigo+" · "+x.Nombre,Resumen=x.Estado=="A"?"Activa":x.Estado=="I"?"Mantenimiento / inactiva":"Pendiente"}),
            "Bus"=>db.Buses.AsNoTracking().Where(x=>q==""||x.CodigoInterno.Contains(q)||x.Placa.Contains(q)||(x.Marca!=null&&x.Marca.Contains(q))||db.LineasBuses.Any(a=>a.BusID==x.BusID&&db.Lineas.Any(l=>l.LineaID==a.LineaID&&l.Nombre.Contains(q))))
                .OrderBy(x=>x.CodigoInterno).ThenBy(x=>x.BusID).Select(x=>new FilaDirectorioVm{ID=x.BusID,Titulo=x.CodigoInterno+" · "+x.Placa,Resumen=x.Estado}),
            "Parqueo"=>db.Parqueos.AsNoTracking().Where(x=>q==""||x.Codigo.Contains(q)||x.Nombre.Contains(q))
                .OrderBy(x=>x.Codigo).ThenBy(x=>x.ParqueoID).Select(x=>new FilaDirectorioVm{ID=x.ParqueoID,Titulo=x.Codigo+" · "+x.Nombre,Resumen=x.Activo?"Activo":"Inactivo"}),
            "Municipalidad"=>db.Municipalidades.AsNoTracking().Where(x=>q==""||x.Codigo.Contains(q)||x.Nombre.Contains(q))
                .OrderBy(x=>x.Nombre).ThenBy(x=>x.MunicipalidadID).Select(x=>new FilaDirectorioVm{ID=x.MunicipalidadID,Titulo=x.Codigo+" · "+x.Nombre,Resumen=x.Activa?"Activa":"Inactiva"}),
            _=>throw new InvalidOperationException("Tipo de directorio inválido.")
        };
        var vm=new DirectorioVm{Tipo=tipo,Q=q,Total=await consulta.CountAsync(ct)};
        vm.Pagina=Math.Clamp(pagina,1,vm.Paginas);
        vm.Filas=await consulta.Skip((vm.Pagina-1)*DirectorioVm.Tamano).Take(DirectorioVm.Tamano).ToListAsync(ct);
        return vm;
    }
    public async Task<PersonalVm> PersonalInicio(CancellationToken ct=default) => new()
    {Totales=new(){["Piloto"]=await db.Pilotos.CountAsync(ct),["Operador"]=await db.Operadores.CountAsync(ct),["Guardia"]=await db.Guardias.CountAsync(ct),["Acceso"]=await db.Accesos.CountAsync(ct)}};
    public async Task<CatalogosVm> CatalogosInicio(CancellationToken ct=default) => new()
    {Totales=new(){["Linea"]=await db.Lineas.CountAsync(ct),["Estacion"]=await db.Estaciones.CountAsync(ct),["Bus"]=await db.Buses.CountAsync(ct),["Parqueo"]=await db.Parqueos.CountAsync(ct),["Municipalidad"]=await db.Municipalidades.CountAsync(ct)}};
    public async Task<PersonalVm> PersonalFormulario(string accion,CancellationToken ct=default)
    {
        var vm=new PersonalVm{Formulario=accion};
        if(accion is "CrearAcceso" or "AsignarOperador")vm.Estaciones=await db.Estaciones.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
        if(accion=="AsignarOperador")vm.Operadores=await db.Operadores.AsNoTracking().Where(x=>x.Activo).OrderBy(x=>x.Apellidos).ToListAsync(ct);
        if(accion=="AsignarGuardia")
        {
            vm.Guardias=await db.Guardias.AsNoTracking().Where(x=>x.Activo).OrderBy(x=>x.Apellidos).ToListAsync(ct);
            vm.Accesos=await db.Accesos.AsNoTracking().Where(x=>x.Estado!="I").OrderBy(x=>x.Codigo).ToListAsync(ct);
        }
        return vm;
    }
    public async Task<CatalogosVm> CatalogosFormulario(string accion,CancellationToken ct=default)
    {
        var vm=new CatalogosVm{Formulario=accion};
        if(accion is "CrearLinea" or "CrearEstacion")vm.Municipalidades=await db.Municipalidades.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
        if(accion is "GuardarRelacion" or "AsignarBus")vm.Lineas=await db.Lineas.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
        if(accion is "GuardarRelacion" or "CrearParqueo")vm.Estaciones=await db.Estaciones.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
        if(accion=="CrearBus")vm.Parqueos=await db.Parqueos.AsNoTracking().Where(x=>x.Activo).OrderBy(x=>x.Nombre).ToListAsync(ct);
        if(accion=="AsignarBus")vm.Buses=await db.Buses.AsNoTracking().Where(x=>!db.LineasBuses.Any(a=>a.BusID==x.BusID)).OrderBy(x=>x.CodigoInterno).ToListAsync(ct);
        return vm;
    }
    public async Task<PersonalVm> PersonalFicha(string tipo,int id,CancellationToken ct=default)
    {
        var vm=new PersonalVm{TipoFicha=tipo,RegistroID=id};
        switch(tipo)
        {
            case "Piloto":
                vm.Pilotos=await db.Pilotos.AsNoTracking().Where(x=>x.PilotoID==id).ToListAsync(ct);
                vm.Educacion=await db.HistorialEducativoPilotos.AsNoTracking().Where(x=>x.PilotoID==id).ToListAsync(ct);break;
            case "Operador":
                vm.Operadores=await db.Operadores.AsNoTracking().Where(x=>x.OperadorID==id).ToListAsync(ct);
                vm.AsignacionesOperador=await db.AsignacionesOperadorEstacion.AsNoTracking().Where(x=>x.OperadorID==id).ToListAsync(ct);
                vm.Estaciones=await db.Estaciones.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);break;
            case "Guardia":
                vm.Guardias=await db.Guardias.AsNoTracking().Where(x=>x.GuardiaID==id).ToListAsync(ct);
                vm.AsignacionesGuardia=await db.AsignacionesGuardiaAcceso.AsNoTracking().Where(x=>x.GuardiaID==id).ToListAsync(ct);
                vm.Accesos=await db.Accesos.AsNoTracking().OrderBy(x=>x.Codigo).ToListAsync(ct);break;
            case "Acceso":
                vm.Accesos=await db.Accesos.AsNoTracking().Where(x=>x.AccesoID==id).ToListAsync(ct);
                vm.AsignacionesGuardia=await db.AsignacionesGuardiaAcceso.AsNoTracking().Where(x=>x.AccesoID==id).ToListAsync(ct);
                var guardias=vm.AsignacionesGuardia.Select(x=>x.GuardiaID).Distinct().ToList();
                vm.Guardias=await db.Guardias.AsNoTracking().Where(x=>guardias.Contains(x.GuardiaID)).ToListAsync(ct);
                var estaciones=vm.Accesos.Select(x=>x.EstacionID).ToList();
                vm.Estaciones=await db.Estaciones.AsNoTracking().Where(x=>estaciones.Contains(x.EstacionID)).ToListAsync(ct);break;
        }
        if((tipo=="Piloto"?vm.Pilotos.Count:tipo=="Operador"?vm.Operadores.Count:tipo=="Guardia"?vm.Guardias.Count:vm.Accesos.Count)==0)throw new KeyNotFoundException("El registro no existe.");
        return vm;
    }
    public async Task<CatalogosVm> CatalogosFicha(string tipo,int id,CancellationToken ct=default)
    {
        var vm=new CatalogosVm{TipoFicha=tipo,RegistroID=id};
        switch(tipo)
        {
            case "Linea":
                if(!await db.Lineas.AnyAsync(x=>x.LineaID==id,ct))throw new KeyNotFoundException();
                vm.Lineas=await db.Lineas.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
                vm.LineasEstaciones=await db.LineasEstaciones.AsNoTracking().Where(x=>x.LineaID==id).OrderBy(x=>x.Orden).ToListAsync(ct);
                var estaciones=vm.LineasEstaciones.Select(x=>x.EstacionID).ToList();
                vm.Estaciones=await db.Estaciones.AsNoTracking().Where(x=>estaciones.Contains(x.EstacionID)).ToListAsync(ct);
                vm.LineasBuses=await db.LineasBuses.AsNoTracking().Where(x=>x.LineaID==id).ToListAsync(ct);
                var buses=vm.LineasBuses.Select(x=>x.BusID).ToList();
                vm.Buses=await db.Buses.AsNoTracking().Where(x=>buses.Contains(x.BusID)).ToListAsync(ct);
                vm.Tramos=await db.TramosLinea.AsNoTracking().Where(x=>x.LineaID==id).ToListAsync(ct);
                var municipalidad=vm.Lineas.Single(x=>x.LineaID==id).MunicipalidadID;
                vm.Municipalidades=await db.Municipalidades.AsNoTracking().Where(x=>x.MunicipalidadID==municipalidad).ToListAsync(ct);break;
            case "Estacion":
                vm.Estaciones=await db.Estaciones.AsNoTracking().Where(x=>x.EstacionID==id).ToListAsync(ct);
                vm.Lineas=await db.Lineas.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
                vm.LineasEstaciones=await db.LineasEstaciones.AsNoTracking().Where(x=>x.EstacionID==id).ToListAsync(ct);
                var muniIDs=vm.Estaciones.Select(x=>x.MunicipalidadID).ToList();
                vm.Municipalidades=await db.Municipalidades.AsNoTracking().Where(x=>muniIDs.Contains(x.MunicipalidadID)).ToListAsync(ct);break;
            case "Bus":
                vm.Buses=await db.Buses.AsNoTracking().Where(x=>x.BusID==id).ToListAsync(ct);
                vm.LineasBuses=await db.LineasBuses.AsNoTracking().Where(x=>x.BusID==id).ToListAsync(ct);
                vm.Lineas=await db.Lineas.AsNoTracking().OrderBy(x=>x.Nombre).ToListAsync(ct);
                var parkIDs=vm.Buses.Select(x=>x.ParqueoID).ToList();
                vm.Parqueos=await db.Parqueos.AsNoTracking().Where(x=>parkIDs.Contains(x.ParqueoID)).ToListAsync(ct);break;
            case "Parqueo":
                vm.Parqueos=await db.Parqueos.AsNoTracking().Where(x=>x.ParqueoID==id).ToListAsync(ct);
                var stationIDs=vm.Parqueos.Select(x=>x.EstacionID).ToList();
                vm.Estaciones=await db.Estaciones.AsNoTracking().Where(x=>stationIDs.Contains(x.EstacionID)).ToListAsync(ct);break;
            case "Municipalidad":vm.Municipalidades=await db.Municipalidades.AsNoTracking().Where(x=>x.MunicipalidadID==id).ToListAsync(ct);break;
        }
        bool existe=tipo switch{"Linea"=>vm.Lineas.Any(x=>x.LineaID==id),"Estacion"=>vm.Estaciones.Count>0,"Bus"=>vm.Buses.Count>0,"Parqueo"=>vm.Parqueos.Count>0,_=>vm.Municipalidades.Count>0};
        if(!existe)throw new KeyNotFoundException("El registro no existe.");
        return vm;
    }
}
