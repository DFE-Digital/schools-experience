pr_number=${1}
pr_name=${2}
minimun_ing_num=1
maximun_ing_num=20

get_all_relevant_ingresses() {
  # Find if it is already in the list of ingresses
  ings=($(kubectl get ing -n git-development -o json | \
    jq -r '.items[] | select(.metadata.name | startswith("get-school-experience-review-pr")) | .metadata.name'))
  ings_list=()
  for ((i = 0; i < ${#ings[@]}; i += 1)); do
    itemname="${ings[i]}"
    ings_list+=("$itemname")  # Add itemname to the list
  done
  echo "${ings_list[@]}"
}

check_existing_dsi_ingress() {
  # Find if it is already in the list of existing linked DSI  ingresses
  servicename="get-school-experience-review-pr-${pr_number}"
  ings=($(kubectl get ing -o=custom-columns='NAME:.metadata.name,SVCs:..service.name'  -n git-development | grep  "${servicename}" | grep  -v "${pr_name}"))
  echo "$ings"
}

extract_numbers_from_list() {
  local all_existing_ings=("$@")
  local pattern="get-school-experience-review-pr-([0-9]+)\.test\.teacherservices\.cloud"
  local all_existing_review_ings=()
  for input_string in "${all_existing_ings[@]}"; do
    if [[ "$input_string" =~ $pattern ]]; then
     all_existing_review_ings+=("${BASH_REMATCH[1]}")
    else
      all_existing_review_ings+=("Number not found")
    fi
  done
  echo "${all_existing_review_ings[@]}"
}

# check if there is an existing linked ingress
existing_ing=($(check_existing_dsi_ingress))

next_ingress=""
if [ -z "$existing_ing" ]; then
            # get all existing ingresses
            ings_list_result=($(get_all_relevant_ingresses))

            # extract the number part of the ingresses from ingress lists
            numbers_from_ings=($(extract_numbers_from_list "${ings_list_result[@]}"))
              available_numbers=()
              unavailable_numbers=()
              all_possible_ings_pr_num=()
              for ((i = $minimun_ing_num; i <= $maximun_ing_num; i++)); do
              all_possible_ings_pr_num+=("$i")
              done
                  for possible_ings_pr_num in "${all_possible_ings_pr_num[@]}"; do
                      found=false
                      for ((i = 0; i < ${#numbers_from_ings[@]}; i += 1)); do
                          itemname="${numbers_from_ings[i]}"
                          if [ "$itemname" == "$possible_ings_pr_num" ]; then
                              unavailable_numbers+=("$possible_ings_pr_num")
                              found=true
                              break
                          fi
                      done
                      if [ "$found" = false ]; then
                          available_numbers+=("$possible_ings_pr_num")
                      fi
                  done
                  if [ ${#available_numbers[@]} -gt 0 ]; then
                    sorted_numbers=($(printf "%s\n" "${available_numbers[@]}" | sort -n))
                    selectednumber=${sorted_numbers[0]}
                    next_ingress="get-school-experience-review-pr-$selectednumber.test.teacherservices.cloud"
                  else
                    next_ingress=""
                  fi
  else
      next_ingress="$existing_ing"
  fi
echo "$next_ingress"
