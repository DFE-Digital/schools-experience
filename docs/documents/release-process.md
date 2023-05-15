# Release process

1. Raising a PR on GitHub will generate a review instance of the application that can be used for end user testing/sharing with other team members
   
   * When deploying a review application a script is run to find the first available static route (review-school-experience[1-20] ) and attach that to the review, via terraform. This enables the DFE Sign In process to work.

1. Merging the PR will deploy the changes to the staging environment and, if successful, the production environment
