namespace Workly.Models;

public class Resultado
{
    public bool Exito { get; set; }
    public string Mensaje { get; set; } = "";
    public string Tipo { get; set; } = "exito";

    public static Resultado Bien(string mensaje) => new() { Exito = true, Mensaje = mensaje, Tipo = "exito" };

    public static Resultado Mal(string mensaje, string tipo = "error") => new() { Exito = false, Mensaje = mensaje, Tipo = tipo };

    public static Resultado Segun(bool exito, string siSale, string siNoSale, string tipoSiNoSale = "error") =>
        exito ? Bien(siSale) : Mal(siNoSale, tipoSiNoSale);
}
