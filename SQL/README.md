<p>To setup the solution you should:</p>
<ul>
  <li>create a database;</li>
  <li>run <a href="scripts.sql">scripts.sql</a> to create tables, views, and other SQL related objects</li>
  <li>run  <a href="page_compression.sql">page_compression.sql</a>, to change compression scheme for the tables (optional step, which requires advanced SQL Server editions);</li>
  <li>Continue to <a href="Persons">Persons</a>, if you want to populate data with DBpedia Persons data set.</li>
</ul>

<p>Play the game.</p>
<p>The initial call is like this:</p>
<blockquote><pre>declare @params xml;
declare @result xml;

execute Data.GetNextPredicates  @params = @params,  @result = @result output;

select @result;
</pre></blockquote>
<p>This returns the first offers like this:</p>
<blockquote><pre>&lt;question name="IsLivingPerson" /></pre></blockquote>

<p>Then the second  request can be like this</p>
<blockquote><pre>declare @params xml = '
 &lt;request>
   &lt;question name="IsLivingPerson" answer="1"/>
 &lt;/request>';

declare @result xml;

execute Data.GetNextPredicates  @params = @params,  @result = @result output;

select @result;
</pre></blockquote>
<p>This returns the second offers like this:</p>
<blockquote><pre>&lt;question name="IsFootballPlayer" /></pre></blockquote>

<p>So, you will continue to and questions to request and fill answers until there is nothing to offer.</p>
