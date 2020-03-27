# Release process

1. Merge any PRs which should be getting released into the `master` branch
2. Ensure [CI passes](https://dev.azure.com/dfe-ssp/S105-School-Experience/_build?definitionId=127) 
3. Ensure the Development phase of the [Releases Pipelines](https://dev.azure.com/dfe-ssp/S105-School-Experience/_release?_a=releases&view=mine&definitionId=38) passes
4. Release to Staging 
   1. Go into the latest release
   2. Approve the release for the Staging step
5. QA the release on Staging
6. Update the [Release notes](https://dfedigital.atlassian.net/wiki/spaces/SE/pages/1111916587/Release+Notes)
   1. First find the release in Azure Pipelines currently in production
   2. Navigate into that release
   3. Note the git sha for the master branch in the artifacts listed on the left
   4. Check out `master` locally and ensure it is current with GitHub (`git pull origin master`)
   5. Get a list of all PRs merged between the current production release and the proposed production release (`git log --merges <CURRENT_SHA1>..origin/master | less`)
   6. Add a new entry to the Release notes on Confluence as necessary
7. Approve the release
   1. Find the latest release in [Releases Pipelines](https://dev.azure.com/dfe-ssp/S105-School-Experience/_release?_a=releases&view=mine&definitionId=38)
   2. Approve the release
8. Post to the **twd_schoolexperience** slack channel with details of the latest
   release.

