find . -type f -name "*.feature" > features.txt

split -n r/5 features.txt

ls -l

index=1
matrix="{"
for browser in chrome firefox
do
  for filename in x*; do
    data=$(
    while read line
    do
      echo -n " ${line}"
    done < $filename)
    if [ $index -ne 1 ]
    then
      matrix+=","
    fi
    matrix+="'$browser_$index':{'browser':'$browser', 'features':'$data'}"
    echo $index $data
    ((index++))
  done
done
matrix+="}"
echo $matrix

echo "##vso[task.setVariable variable=legs;isOutput=true]${matrix}"
