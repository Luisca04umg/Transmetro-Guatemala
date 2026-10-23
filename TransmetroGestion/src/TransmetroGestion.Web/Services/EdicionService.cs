using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
namespace TransmetroGestion.Web.Services;

public record ConfigEdicion(Type Entidad, string Clave, string Titulo, string Permiso, string Controlador, string[] Campos);
public class EdicionService(TransmetroDbContext db)
{
    public static readonly Dictionary<string,ConfigEdicion> Configuraciones = new()
    {
        ["Municipalidad"] = new(typeof(Municipalidad),"MunicipalidadID","municipalidad","LINEAS_EDITAR","Catalogos",["Codigo","Nombre","Departamento","Telefono","Correo","Direccion","Activa"]),
        ["Linea"] = new(typeof(Linea),"LineaID","línea","LINEAS_EDITAR","Catalogos",["MunicipalidadID","Codigo","Nombre","Descripcion","Estado"]),
        ["Estacion"] = new(typeof(Estacion),"EstacionID","estación","ESTACIONES_EDITAR","Catalogos",["MunicipalidadID","Codigo","Nombre","Direccion","Latitud","Longitud","CapacidadReferencia","Estado"]),
        ["Bus"] = new(typeof(Bus),"BusID","bus","FLOTA_EDITAR","Catalogos",["ParqueoID","CodigoInterno","Placa","Marca","Modelo","Anio","CapacidadMaxima","Estado"]),
        ["Parqueo"] = new(typeof(Parqueo),"ParqueoID","parqueo","ESTACIONES_EDITAR","Catalogos",["EstacionID","Codigo","Nombre","CapacidadBuses","Activo"]),
        ["Piloto"] = new(typeof(Piloto),"PilotoID","piloto","PERSONAL_EDITAR","Personal",["CodigoEmpleado","Nombres","Apellidos","Direccion","Municipio","Departamento","Telefono","Correo","Licencia","FechaVencimientoLicencia","Activo"]),
        ["Operador"] = new(typeof(Operador),"OperadorID","operador","PERSONAL_EDITAR","Personal",["CodigoEmpleado","Nombres","Apellidos","Telefono","Correo","Activo"]),
        ["Guardia"] = new(typeof(Guardia),"GuardiaID","guardia","PERSONAL_EDITAR","Personal",["CodigoEmpleado","Nombres","Apellidos","Telefono","Empresa","Activo"]),
        ["Acceso"] = new(typeof(Acceso),"AccesoID","acceso","ESTACIONES_EDITAR","Personal",["EstacionID","Codigo","Nombre","Descripcion","TipoAcceso","Estado"]),
        ["Educacion"] = new(typeof(HistorialEducativoPiloto),"HistorialEducativoID","historial educativo","PERSONAL_EDITAR","Personal",["PilotoID","Nivel","Institucion","Titulo","AnioFinalizacion","Observacion"])
    };
    public static string Etiqueta(string campo) => campo switch
    {
        "MunicipalidadID"=>"Municipalidad", "LineaID"=>"Línea", "EstacionID"=>"Estación", "ParqueoID"=>"Parqueo", "BusID"=>"Bus", "PilotoID"=>"Piloto",
        "Codigo"=>"Código", "CodigoInterno"=>"Código interno", "CodigoEmpleado"=>"Código de empleado", "Anio"=>"Año", "Descripcion"=>"Descripción", "Direccion"=>"Dirección",
        "Telefono"=>"Teléfono", "CapacidadReferencia"=>"Capacidad de referencia", "CapacidadMaxima"=>"Capacidad máxima de pasajeros", "CapacidadBuses"=>"Capacidad de buses",
        "FechaVencimientoLicencia"=>"Vencimiento de licencia", "FechaRegistro"=>"Fecha de registro", "FechaCreacion"=>"Fecha de creación", "TipoAcceso"=>"Tipo de acceso",
        "DPIHash"=>"Documento del piloto", "VersionFila"=>"Versión automática", "FechaInicio"=>"Inicio", "FechaFin"=>"Fin", "AnioFinalizacion"=>"Año de finalización",
        "Institucion"=>"Institución", "Titulo"=>"Título", "Observacion"=>"Observación", _=>campo
    };
    public static string Mostrar(object? valor) => valor switch
    {
        null => "—", byte[] bytes => bytes.Length == 0 ? "Sin registrar" : "Registrado",
        bool activo => activo ? "Sí" : "No", DateOnly fecha => fecha.ToString("dd/MM/yyyy"),
        DateTime fecha => fecha.AddHours(-6).ToString("dd/MM/yyyy HH:mm"), _ => Convert.ToString(valor, CultureInfo.InvariantCulture) ?? "—"
    };
    private static string Formato(object? value) => value switch
    {
        null => "", DateOnly d => d.ToString("yyyy-MM-dd"), DateTime d => d.ToString("yyyy-MM-dd"),
        bool b => b ? "true" : "false", _=>Convert.ToString(value,CultureInfo.InvariantCulture) ?? ""
    };
    private static string Revision(object entidad, ConfigEdicion c)
    {
        var valores = c.Campos.ToDictionary(x=>x,x=>Formato(c.Entidad.GetProperty(x)!.GetValue(entidad)));
        var version = c.Entidad.GetProperty("VersionFila")?.GetValue(entidad) as byte[];
        valores["_version"] = version is null ? "" : Convert.ToBase64String(version);
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(valores))));
    }
    public async Task<EdicionVm> CargarAsync(string tipo,int id)
    {
        var c=Configuraciones[tipo];
        var entidad=await db.FindAsync(c.Entidad,id) ?? throw new InvalidOperationException("El registro no existe.");
        var vm=new EdicionVm{Tipo=tipo,ID=id,Titulo="Editar "+c.Titulo,Revision=Revision(entidad,c)};
        foreach(var nombre in c.Campos)
        {
            var prop=c.Entidad.GetProperty(nombre)!;var type=Nullable.GetUnderlyingType(prop.PropertyType)??prop.PropertyType;
            var campo=new CampoEdicionVm{Nombre=nombre,Etiqueta=Etiqueta(nombre),Valor=Formato(prop.GetValue(entidad)),
                Obligatorio=prop.IsDefined(typeof(RequiredAttribute)) || (type!=typeof(string) && Nullable.GetUnderlyingType(prop.PropertyType)==null),
                Maximo=prop.GetCustomAttribute<StringLengthAttribute>()?.MaximumLength,
                Tipo=type==typeof(DateOnly)?"date":type==typeof(string)?(nombre=="Correo"?"email":"text"):"number"};
            if(type==typeof(bool))campo.Opciones=new(){["true"]="Activo",["false"]="Inactivo"};
            if(nombre=="MunicipalidadID")campo.Opciones=(await db.Municipalidades.OrderBy(x=>x.Nombre).ToListAsync()).ToDictionary(x=>x.MunicipalidadID.ToString(),x=>x.Nombre);
            if(nombre=="EstacionID")campo.Opciones=(await db.Estaciones.OrderBy(x=>x.Nombre).ToListAsync()).ToDictionary(x=>x.EstacionID.ToString(),x=>x.Nombre);
            if(nombre=="ParqueoID")campo.Opciones=(await db.Parqueos.OrderBy(x=>x.Nombre).ToListAsync()).ToDictionary(x=>x.ParqueoID.ToString(),x=>x.Codigo+" · "+x.Nombre);
            if(nombre=="PilotoID")campo.Opciones=(await db.Pilotos.OrderBy(x=>x.Apellidos).ToListAsync()).ToDictionary(x=>x.PilotoID.ToString(),x=>x.Nombres+" "+x.Apellidos);
            if(nombre=="Estado")campo.Opciones=tipo=="Bus"?new(){["DISPONIBLE"]="Disponible",["EN_RUTA"]="En ruta",["MANTENIMIENTO"]="Mantenimiento",["INACTIVO"]="Inactivo"}:new(){["P"]="Pendiente",["A"]="Activo",["I"]="Inactivo / mantenimiento"};
            if(nombre=="TipoAcceso")campo.Opciones=new(){["PEATONAL"]="Peatonal",["VEHICULAR"]="Vehicular",["MIXTO"]="Mixto",["EMERGENCIA"]="Emergencia"};
            if(nombre=="Nivel")campo.Opciones=new(){["PRIMARIA"]="Primaria",["BASICOS"]="Básicos",["DIVERSIFICADO"]="Diversificado",["TECNICO"]="Técnico",["UNIVERSITARIO"]="Universitario",["OTRO"]="Otro"};
            vm.Campos.Add(campo);
        }
        if(tipo=="Piloto")vm.Campos.Add(new CampoEdicionVm{Nombre="DocumentoNuevo",Etiqueta="Actualizar documento del piloto (opcional)",Maximo=50});
        return vm;
    }
    public async Task GuardarAsync(string tipo,int id,string revision,IFormCollection formulario)
    {
        var c=Configuraciones[tipo];var entidad=await db.FindAsync(c.Entidad,id) ?? throw new InvalidOperationException("El registro no existe.");
        if(Revision(entidad,c)!=revision)throw new InvalidOperationException("Otro usuario modificó este registro. Vuelva a abrirlo antes de guardar.");
        string? estadoAnterior=c.Entidad.GetProperty("Estado")?.GetValue(entidad) as string;
        foreach(var nombre in c.Campos)
        {
            if(!formulario.ContainsKey(nombre))throw new InvalidOperationException("Falta el campo "+Etiqueta(nombre));
            var prop=c.Entidad.GetProperty(nombre)!;var type=Nullable.GetUnderlyingType(prop.PropertyType)??prop.PropertyType;var valor=formulario[nombre].ToString().Trim();
            object? convertido;
            try
            {
                convertido=type==typeof(string)?(valor==""&&!prop.IsDefined(typeof(RequiredAttribute))?null:valor):
                    valor==""&&Nullable.GetUnderlyingType(prop.PropertyType)!=null?null:
                    type==typeof(DateOnly)?DateOnly.ParseExact(valor,"yyyy-MM-dd",CultureInfo.InvariantCulture):Convert.ChangeType(valor,type,CultureInfo.InvariantCulture);
            }
            catch { throw new InvalidOperationException("Valor inválido en "+Etiqueta(nombre)); }
            prop.SetValue(entidad,convertido);
        }
        if(entidad is Piloto p && formulario.TryGetValue("DocumentoNuevo",out var documento) && !string.IsNullOrWhiteSpace(documento))
        {
            if(documento.ToString().Length>50)throw new InvalidOperationException("El documento admite hasta 50 caracteres.");
            p.DPIHash=SHA256.HashData(Encoding.UTF8.GetBytes(documento.ToString().Trim()));
        }
        var errores=new List<ValidationResult>();
        if(!Validator.TryValidateObject(entidad,new ValidationContext(entidad),errores,true))throw new InvalidOperationException(string.Join("; ",errores.Select(x=>x.ErrorMessage)));
        await ValidarNegocio(entidad);
        var estadoFinal=c.Entidad.GetProperty("Estado")?.GetValue(entidad) as string;
        if(estadoFinal=="A")c.Entidad.GetProperty("Estado")!.SetValue(entidad,estadoAnterior);
        await db.SaveChangesAsync();
        // La activación pasa siempre por las reglas del procedimiento, también al editar.
        if(estadoFinal=="A")
        {
            if(tipo=="Linea")await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_ActivarLinea @LineaID={id}");
            if(tipo=="Estacion")await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_ActivarEstacion @EstacionID={id}");
            if(tipo=="Acceso")await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_ActivarAcceso @AccesoID={id}");
        }
    }
    private async Task ValidarNegocio(object entidad)
    {
        var estado=entidad.GetType().GetProperty("Estado")?.GetValue(entidad) as string;
        if(entidad is Linea or Estacion or Acceso && estado is not ("P" or "A" or "I"))throw new InvalidOperationException("Estado inválido.");
        if(entidad is Bus && estado is not ("DISPONIBLE" or "EN_RUTA" or "MANTENIMIENTO" or "INACTIVO"))throw new InvalidOperationException("Estado de bus inválido.");
        if(entidad is Estacion e && (e.CapacidadReferencia<=0 || e.Latitud is < -90 or >90 || e.Longitud is < -180 or >180))throw new InvalidOperationException("Revise la capacidad y las coordenadas de la estación.");
        if(entidad is Linea l && l.Estado!="A" && await db.Viajes.AnyAsync(v=>v.LineaID==l.LineaID&&v.Estado=="EN_CURSO"))throw new InvalidOperationException("Finalice los recorridos antes de desactivar la línea.");
        if(entidad is Bus b)
        {
            if(b.CapacidadMaxima<=0 || b.Anio is <2000 or >2100)throw new InvalidOperationException("Revise la capacidad y el año del bus.");
            bool enRuta=await db.Viajes.AnyAsync(v=>v.BusID==b.BusID&&v.Estado=="EN_CURSO");
            if(enRuta!=(b.Estado=="EN_RUTA"))throw new InvalidOperationException("El estado En ruta lo controla el recorrido. Finalice el viaje antes de dejar el bus en mantenimiento o inactivo.");
            if(enRuta && await db.RegistrosOcupacionBus.Where(r=>r.BusID==b.BusID).OrderByDescending(r=>r.FechaRegistro).Take(1).AnyAsync(r=>r.CantidadPasajeros>b.CapacidadMaxima))throw new InvalidOperationException("La capacidad no puede ser menor a los pasajeros a bordo.");
        }
        if(entidad is Parqueo p && (p.CapacidadBuses<=0 || (!p.Activo && await db.Buses.AnyAsync(b=>b.ParqueoID==p.ParqueoID)) || await db.Buses.CountAsync(b=>b.ParqueoID==p.ParqueoID)>p.CapacidadBuses))throw new InvalidOperationException("Reasigne los buses antes de desactivar o reducir la capacidad del parqueo.");
        if(entidad is Piloto piloto && (!piloto.Activo || piloto.FechaVencimientoLicencia<DateOnly.FromDateTime(DateTime.UtcNow)))
        {
            if(await db.Viajes.AnyAsync(v=>v.PilotoID==piloto.PilotoID&&v.Estado=="EN_CURSO"))throw new InvalidOperationException("El piloto tiene un recorrido en curso. Finalícelo antes de desactivarlo o registrar una licencia vencida.");
            if(!piloto.Activo){foreach(var a in await db.AsignacionesPilotoBus.Where(x=>x.PilotoID==piloto.PilotoID&&x.FechaFin==null).ToListAsync())a.FechaFin=DateTime.UtcNow;}
        }
        if(entidad is Operador operador && !operador.Activo)
        {
            var asignaciones=await db.AsignacionesOperadorEstacion.Where(x=>x.OperadorID==operador.OperadorID&&x.FechaFin==null).ToListAsync();
            var ids=asignaciones.Select(x=>x.EstacionID).ToList();
            if(await db.Estaciones.AnyAsync(e=>ids.Contains(e.EstacionID)&&e.Estado=="A"))throw new InvalidOperationException("Reemplace al operador o deje su estación en mantenimiento antes de desactivarlo.");
            foreach(var a in asignaciones)a.FechaFin=DateTime.UtcNow;
        }
        if(entidad is Guardia guardia && !guardia.Activo)
        {
            var asignaciones=await db.AsignacionesGuardiaAcceso.Where(x=>x.GuardiaID==guardia.GuardiaID&&x.FechaFin==null).ToListAsync();
            foreach(var a in asignaciones)
            {
                if(await db.Accesos.AnyAsync(x=>x.AccesoID==a.AccesoID&&x.Estado=="A") && !await db.AsignacionesGuardiaAcceso.AnyAsync(x=>x.AccesoID==a.AccesoID&&x.GuardiaID!=guardia.GuardiaID&&x.FechaFin==null))
                    throw new InvalidOperationException("Asigne un guardia sustituto o desactive el acceso antes de quitar a su único guardia.");
                a.FechaFin=DateTime.UtcNow;
            }
        }
    }
}
