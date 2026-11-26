using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace Workly.Models;

public class Errores
{
    private readonly ModelStateDictionary _estado;

    public Errores(ModelStateDictionary estado)
    {
        _estado = estado;
    }

    public bool Tiene(string campo) =>
        _estado.TryGetValue(campo, out var entrada) && entrada.Errors.Count > 0;

    public string Mensaje(string campo, string porDefecto) =>
        Tiene(campo) ? _estado[campo]!.Errors[0].ErrorMessage : porDefecto;

    public List<string> Generales =>
        _estado.TryGetValue(string.Empty, out var entrada)
            ? entrada.Errors.Select(e => e.ErrorMessage).ToList()
            : new List<string>();

    public bool HayGenerales => Generales.Count > 0;
}
