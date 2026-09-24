*** Settings ***
Documentation    Test cases for lightning-talk-gong snap
Resource         kvm.resource


*** Test Cases ***
Lightning Talk Gong Launches And Renders
    [Documentation]    Verify lightning-talk-gong snap launches and renders a UI on Mir
    [Tags]    smoke    yarf:certification_status: blocker
    Log Screenshot
