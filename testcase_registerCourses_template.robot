*** Settings ***
Documentation    Example test suite for parallel API testing
Library          RequestsLibrary
Library          JSONLibrary
Library          String
Library          OperatingSystem
Library          pabot.PabotLib

*** Variables ***
${base_url}           https://kuniv.tech/api
${token}
${username}
${password}
${courseIdList}       {"courseIdList": ["648ac0bde9739865190517e4", "64911058d092dc0107fa6d4e", "64911058d092dc0107fa6d4e"]}

*** Test Cases ***
Register Courses
    Acquire Lock   MyLock
    Release Lock   MyLock
    ${valuesetname}=    Acquire Value Set
    ${username}=     Get Value From Set   USERNAME
    ${password}=     Get Value From Set   PASSWORD
    Log    ${username}: ${password}
    Login function    ${username}    ${password}
    &{headers}          Create Dictionary        Content-Type=application/json 
    ...    x-client-id=android-test-app    
    ...    x-app-platform=ANDROID    
    ...    x-app-version=1.0.0.0    
    ...    x-device-id=Test-Device-01
    ...    Authorization=Bearer ${token}
    ${jsonTransfer}      Convert String To Json    ${courseIdList}
    ${response}          Post On Session      myssion    /registration/register-course     
    ...                  headers=${headers}             json=${jsonTransfer}    expected_status=200
    
    # Count Courses from Json
    ${json}                Split String      ${courseIdList}  ,
    ${course_count}        Get Length        ${json}
    Log To Console         ${course_count}

    ${quantity}            Set Variable      ${course_count}

    # Check register courses success
    FOR    ${index}    IN RANGE    0    ${quantity}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response.json()['result'][${index}]['status']}     success
    END
    
*** Keywords ***
Create Env
    Create Session      myssion                  ${base_url}           verify=false        disable_warnings=1
    &{headers}          Create Dictionary        Content-Type=application/x-www-form-urlencoded   
    ...    x-client-id=android-test-app    
    ...    x-app-platform=ANDROID    
    ...    x-app-version=1.0.0.0    
    ...    x-device-id=Test-Device-01
    ${headers}          Set Global Variable      ${headers}

Login function
    [Arguments]            ${username}              ${password}
    Create Env
    ${data}                Create Dictionary        username=${username}                             password=${password}
    ${response}            POST On Session          myssion        /authentication/user-login        data=${data}      headers=${headers}    expected_status=200
    ${json}=               Set Variable             ${response.json()}
    Set Global Variable    ${json}
    ${resourceId}          Get Variable Value       ${json['result']['userRoles'][0]['resourceId']}
    ${token}               Get Variable Value       ${json['result']['token']}
    Set Global Variable    ${token}
    Log To Console         ${username}