namespace Workly.Models;

public static class Moderacion
{
    public static string Aceptar(int idOferta) => BD.RevisarOferta(idOferta, true, null)
        ? "Aceptaste la búsqueda: ya está publicada."
        : "Esa búsqueda ya estaba revisada.";

    public static async Task<Resultado> Rechazar(int idOferta, string? motivo, string? enlacePublicaciones, Correo correo)
    {
        var texto = (motivo ?? "").Replace("\r\n", "\n").Trim();
        if (texto.Length is < 10 or > 500)
        {
            return Resultado.Mal("Escribí el motivo del rechazo (entre 10 y 500 caracteres): se lo vamos a mostrar a quien la publicó.");
        }
        if (!BD.RevisarOferta(idOferta, false, texto))
        {
            return Resultado.Bien("Esa búsqueda ya estaba revisada.");
        }

        var oferta = BD.ObtenerOferta(idOferta, 0);
        var publicador = oferta?.IDUsuario_Publicador is int idPublicador ? BD.ObtenerUsuarioPorId(idPublicador) : null;
        var mandado = oferta != null && publicador != null && await correo.EnviarRechazo(publicador, oferta, texto, enlacePublicaciones);
        return Resultado.Bien(mandado
            ? "Rechazaste la búsqueda. Le mandamos un mail con el motivo a quien la publicó, y también lo ve en Mis publicaciones."
            : "Rechazaste la búsqueda. Quien la publicó va a ver el motivo en Mis publicaciones.");
    }
}
