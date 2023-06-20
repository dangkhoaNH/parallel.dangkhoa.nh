*** Settings ***
Documentation    Example test suite for parallel API testing
Library          RequestsLibrary
Library          JSONLibrary
Library          String
Library          OperatingSystem
Library          pabot.PabotLib

*** Variables ***
${base_url}           https://kuniv.tech/api
${courseIdList}       ["648c700f85060b0c83ea8745"]
${token}
${username}
${password}

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
    ${jsonTransfer}      Convert String To Json    {"courseIdList": ["648c700f85060b0c83ea8745"]}
    ${response}          Post On Session      myssion    /registration/register-course     
    ...                  headers=${headers}             json=${jsonTransfer}    expected_status=200
    # Release Value Set
    
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
    # ${data}             Evaluate             {'username': 'teacher03' ,'password': '123456'}
    ${response}            POST On Session          myssion        /authentication/user-login        data=${data}      headers=${headers}    expected_status=200
    # Log To Console         \n${response.content}
    ${json}=               Set Variable             ${response.json()}
    Set Global Variable    ${json}
    ${resourceId}          Get Variable Value       ${json['result']['userRoles'][0]['resourceId']}
    ${token}               Get Variable Value       ${json['result']['token']}
    Set Global Variable    ${token}
    Log To Console         ${username}
    Log To Console         ${username}
