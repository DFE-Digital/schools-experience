# Input variables
pr_number=${1}

##########################new code starts######################################
check_existing_ingress() {
  local current="get-school-experience-review-pr-2973.test.teacherservices.cloud"

  # Find if it is already in the list of ingresses
  INGS=($(kubectl get ing -n git-development -o json | \
    jq -r '.items[] | select(.metadata.name | startswith("get-school-experience-review-pr")) | .metadata.name'))

  ings1_list=()

  for ((i = 0; i < ${#INGS[@]}; i += 1)); do
    itemname="${INGS[i]}"
    ings1_list+=("$itemname")  # Add itemname to the list
    # if [ "$itemname" == "$current" ]; then
    #   echo  "Found existing ${itemname} ${backend_service} "
    # fi
  done
  echo "${ings1_list[@]}"
}

extract_numbers_from_list() {
  local input_strings=("$@")
  local pattern="get-school-experience-review-pr-([0-9]+)\.test\.teacherservices\.cloud"
  local numbers=()

  for input_string in "${input_strings[@]}"; do
  echo "input_string is $input_string"
    if [[ "$input_string" =~ $pattern ]]; then
      numbers+=("${BASH_REMATCH[1]}")
    else
      numbers+=("Number not found")
    fi
  done

  echo "${numbers[@]}"
}

find_largest_not_in_result() {
  local input_list=("$@")
  local available_numbers=($(seq 1 20))
  echo "input_list is $input_list"
  new_numbers=()
  numbers=()
  for ((i = 1; i <= 20; i++)); do
   numbers+=("$i")
  done


  for number in "${numbers[@]}"; do
  #  if [ "$number" -ne "$number_to_remove" ]; then
  #    new_numbers+=("$number")
  #  fi
   #inner loop

      found=false
      for n in $input_list; do
          echo "n is $n is in list"
          if [ "$n" -eq "$number" ]; then
            found=true
            break
          fi
      done

      if [ "$found" = false ]; then
        echo "$number number not  in list"
        new_numbers+=("$number")
      fi

    #       for input_list_number in "${input_list[@]}"; do
    # # Remove any number found in the input list from the available_numbers array
    #          if [ "$number" -ne "$number_to_remove" ]; then
    #            new_numbers+=("$number")
    #          fi
  done

  if [ ${#new_numbers[@]} -gt 0 ]; then
    # Sort the remaining available numbers and return the minimum
    sorted_numbers=($(printf "%s\n" "${new_numbers[@]}" | sort -n))
    echo "${sorted_numbers[0]}"
  else
    # All numbers from 1 to 20 are in the input list, so return 0
    echo "0"
  fi
  # done
  # new_numbers=()
  # echo "available numbers beginning $available_numbers"
  # for input_list_number in "${input_list[@]}"; do
  #   # Remove any number found in the input list from the available_numbers array
  #   available_numbers=(${available_numbers[@]/$number})
  #   if [ "$number" -ne "$number_to_remove" ]; then
  #    new_numbers+=("$number")
  #  fi
  # done

  # if [ ${#available_numbers[@]} -gt 0 ]; then
  #   # Sort the remaining available numbers and return the minimum
  #   sorted_numbers=($(printf "%s\n" "${available_numbers[@]}" | sort -n))
  #   echo "${sorted_numbers[0]}"
  # else
  #   # All numbers from 1 to 20 are in the input list, so return 0
  #   echo "0"
  # fi
}

calculate_return_value() {
  local numbers_from_ings1=("$@")
  local largest_not_in_result=$(find_largest_not_in_result "${numbers_from_ings1[@]}")

  if [ -z "$largest_not_in_result" ]; then
    echo ""
  else
    echo "get-school-experience-review-pr-$largest_not_in_result.test.teacherservices.cloud"
  fi
}

# Call the function
ings1_list_result=($(check_existing_ingress))

echo "ings1_list_result is $ings1_list_result"
echo "======"
# Pass ings1_list_result as input to extract_numbers_from_list
numbers_from_ings1=($(extract_numbers_from_list "${ings1_list_result[@]}"))
numbers_from_ings1+=(1 2 3 5)
# find out if pr number is in extracted number
existing=""
returnval=""
for number in "${numbers_from_ings1[@]}"; do
  echo "$number"
  if [ "$number" == "$pr_number" ]; then
      echo  "Found existing ${number}"
      existing=$number
    fi
done

if [ -z "$existing" ]; then

  echo "Existing is still empty after the loop."
  largest_not_in_result=$(find_largest_not_in_result "${numbers_from_ings1[@]}")
  echo "largest_not_in_result is $largest_not_in_result"
  if [ -z "$largest_not_in_result" ]; then
     returnval=""
  else
     returnval="get-school-experience-review-pr-$largest_not_in_result.test.teacherservices.cloud"
  fi
else
  echo "Existing is not empty so we have an existing"
  returnval="get-school-experience-review-pr-$pr_number.test.teacherservices.cloud"
fi
echo "$returnval"
