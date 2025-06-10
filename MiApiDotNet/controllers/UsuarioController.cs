using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiApiDotNet.Data;
using MiApiDotNet.Models;

namespace MiApiDotNet.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RegistrosController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RegistrosController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/registros
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Registro>>> GetRegistros()
        {
            return await _context.Registros.ToListAsync();
        }

        // GET: api/registros/usuario
        [HttpGet("{usuario}")]
        public async Task<ActionResult<Registro>> GetRegistro(string usuario)
        {
            var registro = await _context.Registros.FindAsync(usuario);

            if (registro == null)
                return NotFound();

            return registro;
        }

        // POST: api/registros
        [HttpPost]
        public async Task<ActionResult<Registro>> PostRegistro(Registro registro)
        {
            _context.Registros.Add(registro);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetRegistro), new { usuario = registro.Usuario }, registro);
        }

        // PUT: api/registros/usuario
        [HttpPut("{usuario}")]
        public async Task<IActionResult> PutRegistro(string usuario, Registro registro)
        {
            if (usuario != registro.Usuario)
                return BadRequest();

            _context.Entry(registro).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!RegistroExists(usuario))
                    return NotFound();
                else
                    throw;
            }

            return NoContent();
        }

        // DELETE: api/registros/usuario
        [HttpDelete("{usuario}")]
        public async Task<IActionResult> DeleteRegistro(string usuario)
        {
            var registro = await _context.Registros.FindAsync(usuario);
            if (registro == null)
                return NotFound();

            _context.Registros.Remove(registro);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool RegistroExists(string usuario)
        {
            return _context.Registros.Any(e => e.Usuario == usuario);
        }
    }
}
