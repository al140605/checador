using System;
using NetTopologySuite.Geometries;  // Para el campo geometry

namespace MiApiDotNet.Models
{
    public class Registro
    {
    public string Usuario { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Empresa { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
        public TimeSpan Hora { get; set; }
        public Geometry? Ubicacion { get; set; }  // Usamos NetTopologySuite
        public int? Id_usuario { get; set; }  // Puede ser null
    }
}

