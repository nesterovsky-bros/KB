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
<p>Preprocessor is run like this:</p>
<blockquote>Preprocessor.exe {encoding} {path to person.cvs} {path to output folder}</blockquote>
<p>where</p>
<ul>
  <li><code>{encoding}</code> - cvs's file encoding; place there 1252.</li>
  <li><code>{path to person.cvs}</code> - path to input cvs file.</li>
  <li><code>{path to output folder}</code> - path to output folder.</li>
</ul>
<p>This step will run for 5 to 10 minutes.</p>
<h4>Load data</h4>
<p>At the next step we load persons into the database <a href="#bulk_insert.sql">bulk_insert.sql</a>.</p>
<p>This is long running task, so be prepared it will work a hour of two.</p>
<h4>Define predicates</h4>
<p>Execut following scripts:</p>
<ul>
  <li><a href="predicate_functions.sql">predicate_functions.sql</a> - to define predefined predicates;</li>
  <li><a href="predicates.sql">predicates.sql</a> - to populate <code>Data.PredicateType</code> (usually it's done with <code>execute Data.DefinePredicate</code>);</li>
  <li><a href="invaliate_predicates.sql">invaliate_predicates.sql</a> - to refresh predicates in <code>Data.Predicate</code> (this is length step too);</li>
</ul>
