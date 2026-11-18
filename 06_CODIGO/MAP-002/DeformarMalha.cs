using System;
using System.IO;
using System.Globalization;

public static class DeformarMalha
{
    public static int Rewrite(string input, string output)
    {
        var culture = CultureInfo.InvariantCulture;
        int total = 0;
        using (var writer = new StreamWriter(output))
        {
            foreach (string line in File.ReadLines(input))
            {
                if (line.StartsWith("v ", StringComparison.Ordinal))
                {
                    string[] f = line.Split(new[] {' ', '\t'}, StringSplitOptions.RemoveEmptyEntries);
                    double x = double.Parse(f[1], culture), y = double.Parse(f[2], culture), z = double.Parse(f[3], culture);
                    double dx = (x + 790) / 84, dz = (z + 145) / 68;
                    double q = dx * dx + dz * dz;
                    if (q < 1 && y >= -16 && y <= 24)
                    {
                        writer.WriteLine(string.Format(culture, "v {0:F7} {1:F7} {2:F7}", x, y + 8 * (1 - q) * (1 - q), z));
                        ++total;
                        continue;
                    }
                }
                writer.WriteLine(line);
            }
        }
        return total;
    }
}
