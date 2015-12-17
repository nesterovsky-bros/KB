namespace KB
{
  using System;
  using System.Collections.Generic;
  using System.IO;
  using System.Text;

  class Program
  {
    static void Main(string[] args)
    {
      var encoding = args[0];
      var cvs = args[1];
      var output = args[2];
      var rowsWritten = 0;
      var metadataWritten = false;

      using(var file = 
        new StreamWriter(
          Path.Combine(output, "data.txt"),
          false,
          Encoding.Unicode))
      {
        foreach(var row in Rows(Lines(GetEncoding(encoding), cvs)))
        {
          if (!metadataWritten)
          {
            metadataWritten = true;

            var j = 0;

            using(var meta = 
              new StreamWriter(
                Path.Combine(output, "metadata.txt"), 
                false, 
                Encoding.Unicode))
            {
              foreach(var value in row.Titles)
              {
                ++j;
                meta.Write("\"");
                meta.Write(j);
                meta.Write("\" \"");
                meta.Write(value);
                meta.Write("\" \"");
                meta.Write(row.Types[j - 1]);
                meta.WriteLine("\"");
              }
            }
          }

          var i = 0;

          foreach(var value in row.Values)
          {
            ++i;

            if (value != "NULL")
            {
              if (value.StartsWith("{") && value.EndsWith("}"))
              {
                var multivalues = 
                  value.Substring(1, value.Length - 2).Split('|');

                foreach(var multivalue in multivalues)
                {
                  file.Write("\"");
                  file.Write(row.RowNumber);
                  file.Write("\" \"");
                  file.Write(i);
                  file.Write("\" \"");
                  file.Write(multivalue);
                  file.WriteLine("\"");
                }
              }
              else
              {
                file.Write("\"");
                file.Write(row.RowNumber);
                file.Write("\" ");
                file.Write(i);
                file.Write("\" \"");
                file.Write(value);
                file.WriteLine("\"");
              }
            }
          }

          ++rowsWritten;

          if (rowsWritten % 10000 == 0)
          {
            Console.WriteLine("{0} rows has been written.", rowsWritten);
          }
        }
      }

      Console.WriteLine("Total {0} rows has been written.", rowsWritten);
    }

    public struct Row
    {
      public long RowNumber;
      public string[] Titles;
      public string[] Types;
      public string[] Values;
    }

    public static IEnumerable<Row> Rows(IEnumerable<string> lines)
    {
      var row = 0L;
      var titles = null as string[];
      var types = null as string[];

      foreach(var line in lines)
      {
        ++row;

        var values = SplitLine(line);

        switch(row)
        {
          case 1:
          {
            titles = values;

            break;
          }
          case 2:
          case 3:
          {
            break;
          }
          case 4:
          {
            types = values;

            break;
          }
          default:
          {
            yield return new Row
            {
              RowNumber = row,
              Titles = titles,
              Types = types,
              Values = values
            };

            break;
          }
        }
      }
    }

    public static Encoding GetEncoding(string encoding)
    {
      if (string.IsNullOrWhiteSpace(encoding))
      {
        return Encoding.Default;
      }

      try
      {
        return Encoding.GetEncoding(encoding);
      }
      catch
      {
        return Encoding.GetEncoding(int.Parse(encoding));
      }
    }

    public static IEnumerable<string> Lines(Encoding encoding, string cvs)
    {
      using(var stream =
       new FileStream(cvs, FileMode.Open, FileAccess.Read, FileShare.Read))
      using(var reader = new StreamReader(stream, encoding))
      {
        while (true)
        {
          var line = reader.ReadLine();

          if (line == null)
          {
            break;
          }

          yield return line;
        }
      }
    }

    private static string[] Delimiters = new[] { "\",\"" };

    public static string[] SplitLine(string line)
    {
      return line.Substring(1, line.Length - 2).Split(Delimiters, StringSplitOptions.None);
    }
  }
}
