# Release process

1. Raising a PR on GitHub will generate a review instance of the application that can be used for end user testing/sharing with other team members
   
   * When deploying a review application a script is run to find the first available static route (review-school-experience[1-20] ) and attach that to the review, via terraform. This enables the DFE Sign In process to work.

2. Merging the PR will deploy the changes to the staging environment and, if successful, the production environment

## Configuring a school profile in a review app or local deployment for testing

When starting from a freshly seeded database, you must manually set up a school profile before you can start making bookings for the school. 

1. Ensure you have a login to DfE Sign In (pre-prod) with permission to manage any of the schools listed in `db/data/example_schools.csv`. [See this page](https://technical-guidance.education.gov.uk/infrastructure/support/#dfe-sign-in) for support and access to DfE Sign In. 
2. In a School Experience app running locally or as review app, click on [Manage school experience](/schools) on the right-hand menu
3. Click on "Start now >" and you will be directed to login to DfE Sign In
4. Login to DfE Sign In
5. After signing in, you will be re-directed back to the School Experience website
6. Click on "Complete your school profile"
7. Fill in each of the sections:
   1. School experience subjects and education phase
   2. Candidate requirements and school experience details
   3. Safeguarding and fees
   4. Disability and access
   5. Admin contact details
   6. Click on check and submit your profile
   7. Accept the conditions and click on "Accept and set up profile"
8. Add some placement dates to the school profile
9. Ensure the profile is set to "on"

You should now be able to find the school and apply for placements by searching for it from the [candidates search page](/candidates/school_searches/new)

