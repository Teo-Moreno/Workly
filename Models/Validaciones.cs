using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace Workly.Models;

public static class Validaciones
{
    public static string? Limpiar(string? texto) => string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();

    public static string? Telefono(string? telefonoLocal, Pais? pais, string campo, ModelStateDictionary estado)
    {
        if (string.IsNullOrWhiteSpace(telefonoLocal))
        {
            return null;
        }
        var digitos = Telefonos.SoloDigitos(telefonoLocal);
        if (telefonoLocal.Any(c => !char.IsAsciiDigit(c) && c != ' ' && c != '-'))
        {
            estado.AddModelError(campo, "Ingresá solo números");
        }
        else if (digitos.Length != Telefonos.Digitos || digitos.StartsWith('0'))
        {
            estado.AddModelError(campo, "Ingresá el código de área y el número: 10 números, sin el 0 ni el 15");
        }
        else if (pais != null)
        {
            return $"{pais.Codigo_Telefono} {Telefonos.Formatear(digitos)}";
        }
        return null;
    }

    public static Preferencia Preferencia(string? puesto, List<string> niveles, List<string> modalidades, string? jornada, string? contratacion,
                                          int? idProvincia, int? salarioMinimo, int? salarioMaximo, string? disponibilidad,
                                          List<Provincia> provincias, string campoSalario, ModelStateDictionary estado)
    {
        if (salarioMinimo.HasValue && salarioMaximo.HasValue && salarioMaximo < salarioMinimo)
        {
            estado.AddModelError(campoSalario, "El máximo tiene que ser mayor o igual al mínimo");
        }
        return new Preferencia
        {
            Puesto_Buscado = Limpiar(puesto),
            Niveles = Models.Preferencia.Unir(niveles, Catalogos.Niveles),
            Modalidades = Models.Preferencia.Unir(modalidades, Catalogos.Modalidades),
            Jornada = Catalogos.Jornadas.Contains(jornada) ? jornada : null,
            Contratacion = Catalogos.Contrataciones.Contains(contratacion) ? contratacion : null,
            IDProvincia = provincias.Any(p => p.ID == idProvincia) ? idProvincia : null,
            Salario_Minimo = salarioMinimo,
            Salario_Maximo = salarioMaximo,
            Disponibilidad = Catalogos.Disponibilidades.Contains(disponibilidad) ? disponibilidad : null
        };
    }

    public static List<string> Habilidades(List<string> habilidades, string campo, ModelStateDictionary estado)
    {
        var limpias = habilidades.Select(h => (h ?? "").Trim()).Where(h => h.Length > 0)
                                 .Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        if (limpias.Any(h => h.Length > 60))
        {
            estado.AddModelError(campo, "Cada habilidad puede tener hasta 60 caracteres");
        }
        if (limpias.Count > 40)
        {
            estado.AddModelError(campo, "Podés cargar hasta 40 habilidades");
        }
        return limpias.Where(h => h.Length <= 60).Take(40).ToList();
    }

    public static List<(int, string)> Idiomas(List<int> ids, List<string> niveles, List<Idioma> catalogo, string campo, ModelStateDictionary estado)
    {
        var idiomas = new List<(int, string)>();
        for (var i = 0; i < ids.Count; i++)
        {
            var nivel = i < niveles.Count ? niveles[i] : null;
            if (!catalogo.Any(c => c.ID == ids[i]) || !Catalogos.NivelesIdioma.Contains(nivel))
            {
                estado.AddModelError(campo, "Elegí el idioma y el nivel de cada fila");
                continue;
            }
            idiomas.Add((ids[i], nivel!));
        }
        return idiomas;
    }

    public static bool Periodo(string? inicioTexto, string? finTexto, bool finPuedeSerFuturo, out DateTime inicio, out DateTime? fin, out string? error)
    {
        inicio = default;
        fin = null;
        var desde = Fechas.ParsearMesAnio(inicioTexto);
        if (desde == null)
        {
            error = "Elegí el mes y el año de inicio";
            return false;
        }
        if (desde > Fechas.MesActual)
        {
            error = "La fecha de inicio no puede ser futura";
            return false;
        }
        inicio = desde.Value;
        if (!string.IsNullOrWhiteSpace(finTexto))
        {
            fin = Fechas.ParsearMesAnio(finTexto);
            if (fin == null)
            {
                error = "Elegí el mes y el año de finalización";
                return false;
            }
            if (fin < inicio)
            {
                error = "La finalización tiene que ser después del inicio";
                return false;
            }
            if (!finPuedeSerFuturo && fin > Fechas.MesActual)
            {
                error = "La fecha de finalización no puede ser futura";
                return false;
            }
        }
        error = null;
        return true;
    }
}
