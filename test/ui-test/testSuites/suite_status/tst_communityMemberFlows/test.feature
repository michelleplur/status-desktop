#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    test.feature
# *
# * \test    Status Desktop - Community Member Flows
# * \date    August 2022
# **
# *****************************************************************************/

Feature: Status Desktop community members

    As a user I want to interact with members in a community


    Scenario: User invites a mutual contact
        Given the user starts the application with a specific data folder ../../../fixtures/mutual_contacts
        When the user tester123 logs in with password TesTEr16843/!@00
        Then the user lands on the signed in app
        When the user opens the community portal section
        Then the user lands on the community portal section
        When the user creates a community named test_community, with description Community description, intro community intro and outro commmunity outro
        Then the user lands on the community named test_community
        When the admin invites the user named Athletic to the community with message You are invited to my community
        And the user opens the chat section
        And the user clicks on Athletic chat
        Then the message You are invited to my community is displayed in the last message


    Scenario: User can kick a member
        Given the user starts the application with a specific data folder ../../../fixtures/community_members
        When the user Alice logs in with password TesTEr16843/!@00
        Then the user lands on the signed in app
        When the user opens the community named MyFriends
        Then the user lands on the community named MyFriends
        When the admin kicks the user named Bobby
        And the admin goes back to the community
        Then the number of members is 1

