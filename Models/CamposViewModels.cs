namespace Workly.Models;

public class CampoUbicacion
{
    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();
    public int? IDPais { get; set; }
    public int? IDProvincia { get; set; }
    public string NombrePais { get; set; } = "IDPais";
    public string NombreProvincia { get; set; } = "IDProvincia";
    public string EtiquetaProvincia { get; set; } = "Provincia";
    public string Prefijo { get; set; } = "";

    public bool TodoElPais { get; set; }

    public bool Requerido { get; set; } = true;
}

public class CampoTelefono
{
    public string Nombre { get; set; } = "Telefono";
    public string Id { get; set; } = "Telefono";
    public string? Valor { get; set; }
    public string Prefijo { get; set; } = "+54";
}

public class CampoMes
{
    public string Nombre { get; set; } = "";
    public string Id { get; set; } = "";
    public string Etiqueta { get; set; } = "";
    public string? Valor { get; set; }
    public bool Requerido { get; set; }

    public bool PermitirFuturo { get; set; }

    public string? Error { get; set; }
}

public class CamposBusqueda
{
    public string Prefijo { get; set; } = "";
    public bool IncluirEstado { get; set; } = true;
    public string? EstadoBusqueda { get; set; }
    public string? PuestoBuscado { get; set; }
    public List<string> Niveles { get; set; } = new();
    public List<string> Modalidades { get; set; } = new();
    public string? Jornada { get; set; }
    public string? Contratacion { get; set; }
    public int? IDProvinciaPreferida { get; set; }
    public int? SalarioMinimo { get; set; }
    public int? SalarioMaximo { get; set; }
    public string? Disponibilidad { get; set; }
    public List<string> Habilidades { get; set; } = new();
    public List<(int IDIdioma, string Nivel)> Idiomas { get; set; } = new();

    public List<Habilidad> CatalogoHabilidades { get; set; } = new();
    public List<Idioma> CatalogoIdiomas { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();
    public int? IDPais { get; set; }

    public static CamposBusqueda Desde(RegistroPersonaViewModel m) => new()
    {
        Prefijo = "reg",
        IncluirEstado = false,
        PuestoBuscado = m.PuestoBuscado,
        Niveles = m.Niveles,
        Modalidades = m.Modalidades,
        Jornada = m.Jornada,
        Contratacion = m.Contratacion,
        IDProvinciaPreferida = m.IDProvinciaPreferida,
        SalarioMinimo = m.SalarioMinimo,
        SalarioMaximo = m.SalarioMaximo,
        Disponibilidad = m.Disponibilidad,
        Habilidades = m.Habilidades,
        Idiomas = m.IdiomaIds.Select((id, i) => (id, i < m.IdiomaNiveles.Count ? m.IdiomaNiveles[i] : "")).ToList(),
        CatalogoHabilidades = m.CatalogoHabilidades,
        CatalogoIdiomas = m.CatalogoIdiomas,
        Provincias = m.Provincias,
        IDPais = m.IDPais
    };

    public static CamposBusqueda Desde(MiPerfilViewModel m, BusquedaFormulario? enviado)
    {
        var p = m.Preferencia;
        var c = new CamposBusqueda
        {
            Prefijo = "cfg",
            EstadoBusqueda = m.Perfil.Estado_Busqueda,
            PuestoBuscado = p.Puesto_Buscado,
            Niveles = p.ListaNiveles,
            Modalidades = p.ListaModalidades,
            Jornada = p.Jornada,
            Contratacion = p.Contratacion,
            IDProvinciaPreferida = p.IDProvincia,
            SalarioMinimo = p.Salario_Minimo,
            SalarioMaximo = p.Salario_Maximo,
            Disponibilidad = p.Disponibilidad,
            Habilidades = m.Habilidades,
            Idiomas = m.Idiomas.Select(i => (i.IDIdioma, i.Nivel)).ToList(),
            CatalogoHabilidades = m.CatalogoHabilidades,
            CatalogoIdiomas = m.CatalogoIdiomas,
            Provincias = m.Provincias,
            IDPais = m.Perfil.IDPais ?? m.Paises.FirstOrDefault()?.ID
        };
        if (enviado != null)
        {
            c.EstadoBusqueda = enviado.EstadoBusqueda;
            c.PuestoBuscado = enviado.PuestoBuscado;
            c.Niveles = enviado.Niveles;
            c.Modalidades = enviado.Modalidades;
            c.Jornada = enviado.Jornada;
            c.Contratacion = enviado.Contratacion;
            c.IDProvinciaPreferida = enviado.IDProvinciaPreferida;
            c.SalarioMinimo = enviado.SalarioMinimo;
            c.SalarioMaximo = enviado.SalarioMaximo;
            c.Disponibilidad = enviado.Disponibilidad;
            c.Habilidades = enviado.Habilidades;
            c.Idiomas = enviado.IdiomaIds.Select((id, i) => (id, i < enviado.IdiomaNiveles.Count ? enviado.IdiomaNiveles[i] : "")).ToList();
        }
        return c;
    }
}
