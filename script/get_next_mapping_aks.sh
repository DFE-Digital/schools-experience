pr_number=${1}
pr_name=${2}
maximun_ing_num=20

get_all_relevant_ingresses() {
  # Find if it is already in the list of ingresses
  ings=($(kubectl get ing -n git-development -o json | \
    jq -r '.items[] | select(.metadata.name | startswith("get-school-experience-review-pr")) | .metadata.name'))

  echo "${ings[@]}"
}

check_existing_dsi_ingress() {
  # Find if it is already in the list of existing linked DSI  ingresses
  servicename="get-school-experience-review-pr-${pr_number}"
  ings=($(kubectl get ing -o=custom-columns='NAME:.metadata.name,SVCs:..service.name'  -n git-development | grep  "${servicename}" | grep  -v "${pr_name}"))
  echo "${ings}"
}

extract_numbers_from_list() {
  local all_existing_ings=$1
  local pattern="get-school-experience-review-pr-([0-9]+)\.test\.teacherservices\.cloud"
  local all_existing_review_ings=()
  for input_string in ${all_existing_ings}; do
    if [[ "$input_string" =~ $pattern ]]; then
      itemval="${BASH_REMATCH[1]}"
      if ((1 <= itemval && itemval <= maximun_ing_num)); then
        all_existing_review_ings+=("${BASH_REMATCH[1]}")
      fi
    fi
  done
  echo "${all_existing_review_ings[@]}"
}

is_number_in_list() {
  local number=$1
  shift
  local all_list=$*
  for i in ${all_list}; do
    if [ "$i" = "$number" ]; then
      return 0
    fi
  done
  return 1
}

# check if there is an existing linked ingress --------------------
existing_ing=$(check_existing_dsi_ingress)

if [ -n "$existing_ing" ]; then
  echo "$existing_ing"
else
  # get all existing ingresses
  ings_list_result=$(get_all_relevant_ingresses)

  # extract the number part of the ingresses from ingress lists
  numbers_from_ings=$(extract_numbers_from_list "${ings_list_result[@]}")
  all_possible_ings=$(seq 1 $maximun_ing_num)
  selectednumber=0
  for possible_ing in ${all_possible_ings}; do
    if ! is_number_in_list "$possible_ing" "${numbers_from_ings[@]}"  ; then
      selectednumber=$possible_ing
      break
    fi
  done
  if [ "$selectednumber" = 0 ]; then
    echo ""
  else
    echo "get-school-experience-review-pr-$selectednumber.test.teacherservices.cloud"
  fi
fi
