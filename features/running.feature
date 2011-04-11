Feature: Running
  As a pragmatic developer
  In order to consolidate my resources
  I want to be able to migrate my Lighthouse tickets to GitHub issues

  Scenario: Finding out the version
    When I run `lh2gh version`
    Then the output should contain "Lighthouse 2 Github v0.0.1"

  Scenario: Asking for help
    When I run `lh2gh help`
    Then the output should contain "Tasks:"
    And the output should contain "lh2gh help"
    And the output should contain "lh2gh version"
