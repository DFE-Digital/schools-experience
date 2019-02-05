Feature: Check everything's working
	In order to establish that components are working correctly
	As a developer
	I want to visit the application's temporary landing page

	Scenario: Visiting the landing page
		Given I visit the landing page
		Then I should see text 'Lorem'

    @javascript
	Scenario: Visiting the landing page
		Given I visit the landing page
		Then I should see text 'Lorem'
