using Microsoft.EntityFrameworkCore;
using MiApiDotNet.Models;

namespace MiApiDotNet.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        { }

        public DbSet<Registro> Registros { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Mapea la tabla si el nombre real es diferente
            modelBuilder.Entity<Registro>().ToTable("Usuarios");
            base.OnModelCreating(modelBuilder);
        }
    }
}
