Feature: Feedback
    So I can help improve the service
    As a candidate
    I want to be able to leave my feedback

    Scenario: Page contents
      Given I am on the 'new candidates feedback' page
      Then I should see radio buttons for 'What did you come to do on the service?' with the following options:
          | Make a school experience request       |
          | Withdraw a request or cancel a booking |
          | Something else                         |

        And I should see radio buttons for 'Overall, how did you feel about the service you received?' with the following options:
          | Very satisfied                    |
          | Satisfied                         |
          | Neither satisfied or dissatisfied |
          | Dissatisfied                      |
          | Very dissatisfied                 |

        And I should see radio buttons for 'Did you achieve what you wanted from your visit?' with the following options:
          | Yes |
          | No  |

        And there should be a 'How could we improve the service? (optional)' text area

    @javascript
    Scenario: Completing the form with error
      Given I am on the 'new candidates feedback' page
      And I choose 'Something else' from the 'What did you come to do on the service?' radio buttons
      And I choose 'Satisfied' from the 'Overall, how did you feel about the service you received?' radio buttons
      And I enter 'Keep up the good work' into the 'How could we improve the service? (optional)' field
      When I click the 'Submit feedback' button
      Then I should see an error

    @javascript
    Scenario: Completing the form successfully
      Given I am on the 'new candidates feedback' page
      And I choose 'Something else' from the 'What did you come to do on the service?' radio buttons
      And I enter 'Test the software' into the 'Tell us what you came here to do. Do not include any information that could identify you personally - such as your name' field
      And I choose 'Yes' from the 'Did you achieve what you wanted from your visit?' radio buttons
      And I choose 'Satisfied' from the 'Overall, how did you feel about the service you received?' radio buttons
      And I enter 'Keep up the good work' into the 'How could we improve the service? (optional)' field
      When I click the 'Submit feedback' button
      Then I should see the text 'Thank you for your feedback.'

    Scenario: Recording the referrer
        Given I am on the 'find a school' page prior to giving feedback
        When I click 'Give feedback', fill in and submit the candidate feedback form
        Then I should see the text 'Thank you for your feedback.'
        And my referrer should have been recorded
