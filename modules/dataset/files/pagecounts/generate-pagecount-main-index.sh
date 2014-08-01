#!/bin/bash

# Generate main index.html page for all pagecount/projectcount files.
# Run this from within the top level directory which contains
# all subdirectories per year; these subdirs should have the form
# 2006 2007 2008  etc.

dir=`pwd`
year=`basename "$dir"`
years=`ls -d 2[0-9][0-9][0-9] 2>/dev/null`

echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
  <head>
    <title>Page view statistics for Wikimedia projects</title>
  </head>
  <body bgcolor="#ffffff">
  <h1>Page view statistics for Wikimedia projects</h1>

  <h2>Pagecount files per year</h2>

  <p>
' > index.html

echo "    <ul>" >> index.html

if [ ! -z "$years" ]; then
    for y in $years; do
        echo "  <li><a href=\"$y\">$y</a></li>" >> index.html
    done
fi

echo "    </ul>" >> index.html

echo '  </p>

  <h2>What are the page view statistics files and what do they contain?</h2>
  <p>
    Each request of a page, whether for editing or reading, whether a "special page" such as a log of
    actions generated on the fly, or an article from Wikipedia or one of the other projects, reaches one
    of our squid caching hosts and the request is sent via udp to a filter which tosses requests from our internal
    hosts, as well as requests for wikis that aren'"'"'t among our general projects.  This filter writes out
    the project name, the size of the page requested, and the title of the page requested.
  </p>
  <p>
    Here are a few sample lines from one file:
    <pre>

      fr.b Special:Recherche/Achille_Baraguey_d%5C%27Hilliers 1 624
      fr.b Special:Recherche/Acteurs_et_actrices_N 1 739
      fr.b Special:Recherche/Agrippa_d/%27Aubign%C3%A9 1 743
      fr.b Special:Recherche/All_Mixed_Up 1 730
      fr.b Special:Recherche/Andr%C3%A9_Gazut.html 1 737
    </pre>
  <p/>
  <p>
    In the above, the first column "fr.b" is the project name.  The following abbreviations are used:
    <ul>
      <li>wikibooks: ".b"</li>
      <li>wiktionary: ".d"</li>
      <li>wikimedia: ".m"</li>
      <li>wikipedia mobile: ".mw"</li>
      <li>wikinews: ".n"</li>
      <li>wikiquote: ".q"</li>
      <li>wikisource: ".s"</li>
      <li>wikiversity: ".v"</li>
      <li>mediawiki: ".w"</li>
    </ul>

    Projects without a period and a following character are wikipedia projects.
  </p>
  <p>
    The second column is the title of the page retrieved, the third column is the number of requests,
    and the fourth column is the size of the content returned.
  </p>
  <p>
    These are hourly statistics, so in the line
    <pre>
      en Main_Page 242332 4737756101
    </pre>
    we see that the main page of the English language Wikipedia was requested over 240 thousand times
    during the specific hour.  <strong>These are not unique visits.</strong>
  </p>

  <p>
    In some directories you will see files which have names starting with "projectcount".  These are
    total views per hour per project, generated by summing up the entries in the pagecount files.
    The first entry in a line is the project name, the second is the number of non-unique views, and the
    third is the total number of bytes transferred.
  </p>

  <h2>Who came up with this stuff anyways?  (Alternatively, who can I nag about it?)</h2>
  <p>
    Domas Mituzas, a long-time volunteer db admin for WMF, started generating these statistics in
    <a href="http://lists.wikimedia.org/pipermail/wikitech-l/2007-December/035435.html">2007</a>.
    Some of the older files (from 2010 through at least mid-2011) are also available at the
    <a href="http://www.archive.org/search.php?query=wikipedia_visitor_stats">Internet Archive</a>

    thanks to <a href"http://lists.wikimedia.org/pipermail/toolserver-l/2011-August/004300.html">Federico Leva</a>.
  </p>
  <hr />
  <p><a href="../../index.html">Return to the main index of public data sets provided on this server.</a></p>
  <p><a href="../../backup-index.html">Return to the main index of project dumps in XML format.</a></p>
  <p><a href="../">Return to the main index of other content</a></p>
  </body>

</html>
' >> index.html

chmod 644 index.html
