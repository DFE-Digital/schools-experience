Feature: Feedback
    So I can help improve the experience offered by schools
    As a candidate
    I want to be able to leave my feedback

  Background:
    Given I have an attended booking

    Scenario: Page contents
      When I visit the booking feedback link
      Then I should see radio buttons for 'Do you feel you gained a realistic impression of school life?' with the following options:
          | Yes |
          | No  |

        And I should see radio buttons for 'Did you get to see how schools teach your subject of interest?' with the following options:
          | Yes |
          | No  |

        And I should see radio buttons for 'Has your experience helped you decide whether or not to apply for teacher training?' with the following options:
          | Yes |
          | No  |

        And I should see radio buttons for 'How has your experience affected your decision to apply for teacher training?' with the following options:
          | Positively                      |
          | Negatively                      |
          | It has not affected my decision |

        And I should see radio buttons for 'Do you want to apply for teacher training?' with the following options:
          | Yes |
          | No  |

    Scenario: Submitting feedback with an error
      When I visit the booking feedback link
      And I choose 'Yes' from the 'Do you feel you gained a realistic impression of school life?' radio buttons
      And I choose 'No' from the 'Did you get to see how schools teach your subject of interest?' radio buttons
      When I click the 'Submit feedback' button
      Then I should see an error

    Scenario: Completing the form successfully
      When I visit the booking feedback link
      And I choose 'Yes' from the 'Do you feel you gained a realistic impression of school life?' radio buttons
      And I choose 'No' from the 'Did you get to see how schools teach your subject of interest?' radio buttons
      And I choose 'Yes' from the 'Has your experience helped you decide whether or not to apply for teacher training?' radio buttons
      And I choose 'Positively' from the 'How has your experience affected your decision to apply for teacher training?' radio buttons
      And I choose 'No' from the 'Do you want to apply for teacher training?' radio buttons
      When I click the 'Submit feedback' button
      Then I should see the text 'Thank you for your feedback'
