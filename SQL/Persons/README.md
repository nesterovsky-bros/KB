<h4>Test data</h4>
<p>We use <a href="http://wiki.dbpedia.org/" target="_blank">DBpedia's</a> <a href="http://web.informatik.uni-mannheim.de/DBpediaAsTables/csv/Person.csv.gz">Person.csv</a> dataset to train the engine.</p>

<h4>Preprocessor</h4>
<p>We preprocess Person.csv before loading it into the database.</p>
<p>Preprocessor outputs two files:</p>
<ul>
  <li>Properties.txt - file containing property definitions;</li>
  <li>Data.txt - file containing properties for each person;</li>
</ul>
<p>Preprocessor is implemented as a simple C# program (see <a href="Processor">Preprocessor</a> project).</p>
