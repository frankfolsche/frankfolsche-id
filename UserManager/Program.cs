using Azure.Identity;
using Microsoft.Graph;
using Microsoft.Graph.Models;
using Microsoft.Identity.Client;

class Program
{
    private const string TenantId = "818c3c00-7b37-4849-b8b3-a1467f04618f";
    private const string ClientId = "9bd2005d-ae4e-4027-a714-aec941b43492";
    private static readonly string[] OidcOnlyScopes = ["openid", "profile", "email", "offline_access", "User.ReadWrite"];
    private static GraphServiceClient? _graphServiceClient;

    static async Task Main()
    {
        // Will open the system browser the first time; then uses the token cache silently
        var credential = new InteractiveBrowserCredential(new InteractiveBrowserCredentialOptions
        {
            TenantId = TenantId,
            ClientId = ClientId,
            AuthorityHost = new Uri("https://frankfolscheid.ciamlogin.com"),
            RedirectUri = new Uri("http://localhost") 
        });

        _graphServiceClient = new GraphServiceClient(credential, OidcOnlyScopes);
        var me = await GetMe();
        if (me == null)
        {
            Console.WriteLine($"Me Failed");
        }

        Console.WriteLine($"Hello {me!.DisplayName}");
        Console.Write("Enter new display name: ");
        var newDisplayName = Console.ReadLine();
        await UpdateDisplayName(me.Id, newDisplayName ?? "Frank update");
        me = await GetMe();
        Console.WriteLine($"Hello updated me: {me!.DisplayName}");

        Console.Write("Get Auth token y/n");
        var getAuthToken = Console.ReadLine();
        if (getAuthToken?.Equals("y", StringComparison.OrdinalIgnoreCase) == true)
        {
            await Login();
        }
    }

    private static async Task<User?> GetMe()
    {
        var me = await _graphServiceClient!.Me.GetAsync(cfg =>
        {
            cfg.QueryParameters.Select = new[]
            {
                "id","identities","displayName","givenName","surname","country","city",
                "accountEnabled","createdDateTime","lastPasswordChangeDateTime",
                "extension_00000000000000000000000000000000_SpecialDiet" // schema extension (example)
            };
            cfg.QueryParameters.Expand = new[] { "extensions" }; // open extensions
        });
        return me;
    }

    public static async Task UpdateDisplayName(string? userObjectId, string displayName)
    {
        if (userObjectId == null)
        {
            Console.WriteLine($"The account update cannot be processed because the access token lacks the necessary 'userObjectId'.");
        }

        var requestBody = new User
        {
            DisplayName = displayName,
        };

        var result = await _graphServiceClient!.Me.PatchAsync(requestBody);
    }

    private static async Task Login()
    {
        // External ID authority on your ciamlogin host (v2.0 is implied by endpoints)
        var authority = $"https://frankfolscheid.ciamlogin.com/{TenantId}";

        var app = PublicClientApplicationBuilder.Create(ClientId)
            .WithAuthority(authority)
            .WithRedirectUri("http://localhost")    // loopback system browser
            .Build();

        try
        {
            // Choose the scopes you need:
            var scopes = OidcOnlyScopes; // or use ApiScopes

            // Pops the system browser, uses PKCE and a local loopback listener
            var result = await app.AcquireTokenInteractive(scopes)
                .WithPrompt(Microsoft.Identity.Client.Prompt.SelectAccount)   // helpful if multiple identities
                .WithUseEmbeddedWebView(false)      // force system browser
                .ExecuteAsync();

            Console.WriteLine("Signed in.");
            Console.WriteLine($"Account: {result.Account?.Username}");
            Console.WriteLine($"IdToken (first 40 chars): {Truncate(result.IdToken)}");
            Console.WriteLine($"AccessToken (first 40 chars): {Truncate(result.AccessToken)}");

            // Later silent calls (no browser) reuse the cache:
            var silent = await app.AcquireTokenSilent(scopes, result.Account).ExecuteAsync();
            Console.WriteLine("Silent token acquired.");
        }
        catch (MsalException ex)
        {
            Console.WriteLine($"Auth error: {ex.ErrorCode} - {ex.Message}");
        }
    }

    static string Truncate(string s) => string.IsNullOrEmpty(s) ? "" : s.Substring(0, Math.Min(40, s.Length)) + "...";
}
