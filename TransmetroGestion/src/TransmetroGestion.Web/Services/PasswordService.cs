using System.Security.Cryptography;

namespace TransmetroGestion.Web.Services;

public class PasswordService
{
    private const int Iteraciones = 120_000;
    private const int HashSize = 64;

    public (byte[] Hash, byte[] Salt) CrearHash(string contrasena)
    {
        var salt = RandomNumberGenerator.GetBytes(32);
        var hash = Rfc2898DeriveBytes.Pbkdf2(
            contrasena, salt, Iteraciones, HashAlgorithmName.SHA512, HashSize);
        return (hash, salt);
    }

    public bool Verificar(string contrasena, byte[] hashGuardado, byte[] salt)
    {
        var hashCalculado = Rfc2898DeriveBytes.Pbkdf2(
            contrasena, salt, Iteraciones, HashAlgorithmName.SHA512, HashSize);
        return CryptographicOperations.FixedTimeEquals(hashCalculado, hashGuardado);
    }
}
