#!/bin/bash
#
# if [ $# -ne  1 ];then
#     echo "Usage: $0 <URL>"
#     exit 1
# fi
#
# if [ ! -f "$1" ];then
#     echo "Erreur: le ficher $1 n'existe pas."
#     exit 1
# fi
#
# FICHIER_URLS=$1
#
# i=0
# while read -r LINE;do
#     i=$(expr $i + 1)
#     code=$(curl -s -o /dev/null -w "%{http_code}" "$LINE")
#     encodage=$(curl -sI "$LINE" | grep -i "charset=" | cut -d= -f2 | tr -d '\r')
#     nb_mots=$(lynx -dump -nolist "$LINE" | wc -w)
#     echo -e "${i}\t${LINE}}\t${code}\t${encodage}\t${nb_mots}"
# done < "$1"

# CORRIGER
if [ $# -ne 2 ];then
   echo"Le script attend exactement 2 arguments."
   exit
fi

FICHIER_URLS=$1     #le fichier d’URL
FICHIER_SORTIE=$2   #le fichier de sortie
lineno=1            #compteur de lignes (numéro)

echo -e "Numéro\tUrl\tHttp response\tEncodage\tNb_Mots">$FICHIER_SORTIE
# Cette ligne écrit les en-têtes des colonnes dans le fichier de sortie :
# Numéro | URL | Code HTTP | Encodage | Nombre de mots.
echo -e "
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Résultats du mini-projet</title>
</head>

<body>
  <h1>Résultats du mini-projet</h1>
  <table border="1">
    <tr>
      <th>Numéro</th>
      <th>Url</th>
      <th>Http response</th>
      <th>Encodage</th>
      <th>Nb_Mots</th>"

while read -r line;
do
    curl -o tmp.txt -k -i -s -L -w "%{content_type}\n%{http_code}" ${line} > metadata.tmp
# -o tmp.txt：网页正文保存到 tmp.txt
# -k：忽略 SSL 证书错误
# -i：包括 HTTP 头
# -s：静默模式（不显示进度）
# -L：自动跟随重定向
# -w "%{content_type}\n%{http_code}"：在输出中写出内容类型和 HTTP 状态码（分别为两行）content_type:/html; charset=UTF-8  http_code:200
#  metadata.tmp：把上面的信息（content_type + code）写进 一个临时文件metadata.tmp
#  把网页正文放进 tmp.txt，把头部信息（编码和状态码）单独写入 metadata.tmp。
    encodage=$(cat metadata.tmp | head -n 1 | grep -E -o "charset=.*" | cut -d= -f2)
# grep：查找匹配正则表达式的字符串
# -E：启用“扩展正则表达式”（Extended regex）
# -o：只输出匹配到的部分，而不是整行
    response=$(cat metadata.tmp | tail -n 1)
    nb_mots=$(cat tmp.txt | lynx -dump -stdin -nolist | wc -w)
    echo -e "
    <tr>
      <td>$lineno</td>
      <td>$line</td>
      <td>$response</td>
      <td>$encodage</td>
      <td>$nb_mots</td>
    </tr>"

echo -e "${lineno}\t${line}\t${response}\t${encodage}\t${nb_mots}">>$FICHIER_SORTIE

lineno=$(expr $lineno + 1)
done < "$1"
echo -e "
  </table>
</body>
</html>
"
