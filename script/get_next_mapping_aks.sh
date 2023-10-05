# Input variables
pr_number=${1}

##########################new code starts######################################

# check_existing_ingress "${numbers_from_ings1[@]}"
check_existing_ingress() {
  local current="get-school-experience-review-pr-2973.test.teacherservices.cloud"

  # Find if it is already in the list of ingresses
  INGS=($(kubectl get ing -n git-development -o json | \
    jq -r '.items[] | select(.metadata.name | startswith("get-school-experience-review-pr")) | .metadata.name'))

  ings1_list=()

  for ((i = 0; i < ${#INGS[@]}; i += 1)); do
    itemname="${INGS[i]}"
    ings1_list+=("$itemname")  # Add itemname to the list
    if [ "$itemname" == "$current" ]; then
      echo  "Found existing ${itemname} ${backend_service} "
    fi
  done

  echo "ings1_list from the function is: ${ings1_list[@]}"
}

extract_numbers_from_list() {
  local input_strings=("$@")
  local prefix="review-get-into-teaching-app-"
  local suffix="-internal"
  local numbers=()

  for input_string in "${input_strings[@]}"; do
    if [[ "$input_string" =~ "${prefix}([0-9]+)${suffix}" ]]; then
      numbers+=("${BASH_REMATCH[1]}")
    else
      numbers+=("Number not found")
    fi
  done

  echo "${numbers[@]}"
}

get_ings1_list() {
  # Find if it is already in the list of ingresses
  INGS=($(kubectl get ing -n git-development -o json | \
    jq -r '.items[] | select(.metadata.name | startswith("get-school-experience-review-pr")) | .metadata.name, .spec.rules[0].http.paths[0].backend.service.name'))

  ings1_list=()

  for ((i = 1; i < ${#INGS[@]}; i += 1)); do
    ings1_list+=("${INGS[i]}")
  done

  echo "${ings1_list[@]}"
}

number_exists_in_list() {
  local number_to_check="$1"
  shift
  local number_list=("$@")

  for number in "${number_list[@]}"; do
    if [ "$number_to_check" -eq "$number" ]; then
      return 0  # Number found
    fi
  done

  return 1  # Number not found
}

# Example usage:
extract_numbers_from_list() {
  local input_strings=("$@")
  local prefix="get-school-experience-review-pr-"
  local suffix=".test.teacherservices.cloud"
  local numbers=()

  for input_string in "${input_strings[@]}"; do
    if [[ "$input_string" =~ "${prefix}([0-9]+)${suffix}" ]]; then
      numbers+=("${BASH_REMATCH[1]}")
    else
      numbers+=("Number not found")
    fi
  done

  echo "${numbers[@]}"
}

number_exists_in_list() {
  local number_to_check="$1"
  shift
  local number_list=("$@")

  for number in "${number_list[@]}"; do
    if [ "$number_to_check" -eq "$number" ]; then
      return 0  # Number found
    fi
  done

  return 1  # Number not found
}

# Example usage with extract_numbers_from_list and number_exists_in_list
# string_list=("review-get-into-teaching-app-2619-internal" "review-get-into-teaching-app-2685-internal" "review-get-into-teaching-app-2632-internal")

# # Extract numbers from the string list
# numbers_from_list=($(extract_numbers_from_list "${string_list[@]}"))

# Number to find
number_to_find=$pr_number

# Check if the number exists in the extracted list
# if number_exists_in_list "$number_to_find" "${numbers_from_list[@]}"; then
#   echo "$number_to_find exists in the list."
# else
#   echo "$number_to_find does not exist in the list."
# fi


# Get the INGS[1] values
#  ings1_list=$(check_existing_ingress)
 #echo "ings1_list is $ings1_list"
# # Use ings1_list as input to extract_numbers_from_list
 #numbers_from_ings1=$(extract_numbers_from_list "${ings1_list[@]}")
# echo "============================================================="
# echo "numbers_from_ings1 is $numbers_from_ings1"

# # Call the check_existing_ingress function with numbers_from_ings1 as input


# Call the function
#check_existing_ingress
extract_numbers_from_list() {
  local input_strings=("$@")
  local pattern="get-school-experience-review-pr-([0-9]+)\.test\.teacherservices\.cloud"
  local numbers=()

  for input_string in "${input_strings[@]}"; do
    if [[ "$input_string" =~ $pattern ]]; then
      numbers+=("${BASH_REMATCH[1]}")
    else
      numbers+=("Number not found")
    fi
  done

  echo "${numbers[@]}"
}

# Example usage with the input strings
input_strings=(
  "get-school-experience-review-pr-2972.test.teacherservices.cloud"
  "get-school-experience-review-pr-2973.test.teacherservices.cloud"
  "get-school-experience-review-pr-777.test.teacherservices.cloud"
)

# Extract numbers from the input strings
numbers_from_list=($(extract_numbers_from_list "${input_strings[@]}"))

# Print the extracted numbers
for number in "${numbers_from_list[@]}"; do
  echo "$number"
done


# ############################END NEW CODE####################################
