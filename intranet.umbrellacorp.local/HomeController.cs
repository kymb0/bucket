
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using umbrella_intranet.Models;

namespace umbrella_intranet.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Articles()
        {
            // Fetch articles from the database and pass them to the view
            return View();
        }

        public IActionResult DocumentManagement()
        {
            return View();
        }
    }
}
