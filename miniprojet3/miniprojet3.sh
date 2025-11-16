# !/bin/bash

if [ $# -ne 2 ];then
   echo"Le script attend exactement 2 arguments."
   exit
fi

FICHIER_URLS=$1
FICHIER_SORTIE=$2
lineno=1

echo -e '
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css">
  <link rel="stylesheet" href="assets/css/style.css">
  <title>Résultats du mini-projet</title>
</head>

<body>
  <section class="section">
    <div class="container has-background-white">
      <h1 class="title has-text-centered">Tableau des résultats</h1>
      <table border="1" class="table is-striped is-hoverable is-fullwidth">
        <tr>
          <th>Numéro</th>
          <th>Url</th>
          <th>Http response</th>
          <th>Encodage</th>
          <th>Nb_Mots</th>
        <tr>'>$FICHIER_SORTIE

while read -r line;
do
    curl -o tmp.txt -k -i -s -L -w "%{content_type}\n%{http_code}" ${line} > metadata.tmp
    encodage=$(cat metadata.tmp | head -n 1 | grep -E -o "charset=.*" | cut -d= -f2)
    response=$(cat metadata.tmp | tail -n 1)
    nb_mots=$(cat tmp.txt | lynx -dump -stdin -nolist | wc -w)
    echo -e "
        <tr>
          <td>$lineno</td>
          <td>$line</td>
          <td>$response</td>
          <td>$encodage</td>
          <td>$nb_mots</td>
        </tr>">>$FICHIER_SORTIE

lineno=$(expr $lineno + 1)
done < "$1"
echo -e '
     </table>
    </div>
  </section>
</body>
</html>
'>>$FICHIER_SORTIE
