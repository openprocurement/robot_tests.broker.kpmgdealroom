*** Settings ***
Library           String
Library           Selenium2Library
Library           Collections
Library           kpmgdealroom_service.py

Resource          locators.robot

*** Keywords ***
# Prepare client for user
Підготувати клієнт для користувача
    [Arguments]    @{ARGUMENTS}
    Open Browser    ${USERS.users['${ARGUMENTS[0]}'].homepage}    ${USERS.users['${ARGUMENTS[0]}'].browser}    alias=${ARGUMENTS[0]}
    Set Window Size    @{USERS.users['${ARGUMENTS[0]}'].size}
    Set Window Position    @{USERS.users['${ARGUMENTS[0]}'].position}
    Run Keyword If    '${ARGUMENTS[0]}' != 'kpmgdealroom_Viewer'    Login    ${ARGUMENTS[0]}

# Prepare data for tender announcement
Підготувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}    ${role_name}
    [Return]    ${tender_data}

# Edwin - Updated for KDR
Login
    [Arguments]   @{ARGUMENTS}
    Wait Until Element Is Visible    ${locator.emailField}    10
    Input text    ${locator.login.emailField}    ${USERS.users['${ARGUMENTS[0]}'].login}
    Input text    ${locator.login.passwordField}    ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Element    ${locator.login.loginButton}
    Sleep    2

# Edwin - Added for KDR
Logout
    [Arguments]   @{ARGUMENTS}
    Wait Until Element Is Visible   ${locator.logoutButton}   10
    Click Element   ${locator.toolbar.logoutButton}
    Sleep   2

# Create a tender
Створити тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tender_data
    ...    ${ARGUMENTS[2]} == ${filepath}
    Set Global Variable    ${TENDER_INIT_DATA_LIST}    ${ARGUMENTS[1]}
    ${title}=    Get From Dictionary    ${ARGUMENTS[1].data}    title
    ${dgf}=    Get From Dictionary    ${ARGUMENTS[1].data}    dgfID
    ${dgfDecisionDate}=    convert_ISO_DMY    ${ARGUMENTS[1].data.dgfDecisionDate}
    ${dgfDecisionID}=    Get From Dictionary    ${ARGUMENTS[1].data}    dgfDecisionID
    ${tenderAttempts}=    get_tenderAttempts    ${ARGUMENTS[1].data}
    ${description}=    Get From Dictionary    ${ARGUMENTS[1].data}    description
    ${procuringEntity_name}=    Get From Dictionary    ${ARGUMENTS[1].data.procuringEntity}    name
    ${items}=    Get From Dictionary    ${ARGUMENTS[1].data}    items
    ${number_of_items}=  Get Length  ${items}
    ${budget}=    get_budget    ${ARGUMENTS[1]}
    ${step_rate}=    get_step_rate    ${ARGUMENTS[1]}
    ${currency}=    Get From Dictionary    ${ARGUMENTS[1].data.value}    currency
    ${valueAddedTaxIncluded}=    Get From Dictionary    ${ARGUMENTS[1].data.value}    valueAddedTaxIncluded
    ${start_day_auction}=    get_tender_dates    ${ARGUMENTS[1]}    StartDate
    ${start_time_auction}=    get_tender_dates    ${ARGUMENTS[1]}    StartTime
    ${item0}=    Get From List    ${items}    0
    ${descr_lot}=    Get From Dictionary    ${item0}    description
    ${unit}=    Get From Dictionary    ${items[0].unit}    code
    ${cav_id}=    Get From Dictionary    ${items[0].classification}    id
    ${quantity}=    get_quantity    ${items[0]}
    
    Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element    ${locator.createExchangeButton}    20
    
    #  1. Click Create Exchange button
    Click Element    ${locator.createExchangeButton}
    Wait Until Page Contains Element ${locator.createExchange.submitButton}  20    
    
    # 2. Fill in form details
    Click Element ${locator.createExchange.Client.ProZorro}
    Input Text ${locator.createExchange.name} ${title}
    Input Text ${locator.createExchange.sponsorEmail} ${ARGUMENTS[0]}
    Input Text ${locator.createExchange.adminEmails} ${ARGUMENTS[0]}
    Wait Until Page Contains Element ${locator.createExchange.typeSelector.Prozorro} 10
    Click Element ${locator.createExchange.typeSelector.Prozorro}
    Wait Until Page Contains Element ${locator.createExchange.startDate} 10
    Input Text ${locator.createExchange.startDate} ${start_day_auction}
    Click Element ${locator.createExchange.dgfCategorySelector.dgfFinancialAssets}
    Input Text ${locator.createExchange.guaranteeAmount} ${budget}
    Input Text ${locator.createExchange.startPrice} 0

    # 3. Submit exchange creations
    Click Element ${locator.createExchange.submitButton}

    # 4. Now we must add items before Prozorro actually accepts our submitted auction
    :FOR  ${index}  IN RANGE  ${number_of_items} 
    \  Додати предмет  ${items[${index}]} 
    Click Element ${locator.addAsset.saveButton}

    # 5. On page load find the created tender ID and return it
    Wait Until Page Contains    Аукціон збережено як чернетку    10
    ${tender_id}=    Get Text    id = auction-id
    ${TENDER}=    Get Text    id= auction-id
    log to console    ${TENDER}
    [Return]    ${TENDER}
    
# Add item
Додати предмет
    [Arguments]    ${item}    ${index}
    Run Keyword If  ${index} != 0    Click Element ${locator.addAsset.addButton} 
    Wait Until Page Contains Element id=Assets_${index}__Description ${item.description} 5
    Input Text  id=Assets_${index}__Description ${item.description}
    Input Text  id=Assets_${index}__Quantity ${item.quantity}
    Input Text  id=Assets_${index}__Classification_Scheme ${item.classification.id}
    Input Text  id=Assets_${index}__Classification_Description ${item.unit.code}
    Input Text  id=Assets_${index}__ClassificationCode ${item.unit.code}
    Input Text  id=Assets_${index}__Address_AddressLineOne ${item.deliveryAddress.streetAddress}
    Input Text  id=Assets_${index}__Address_AddressLineTwo ${item.deliveryAddress.region}
    Input Text  id=Assets_${index}__Address_AddressCity    ${item.deliveryAddress.locality}
    Input Text  id=Assets_${index}__Address_AddressCountry ${item.deliveryAddress.countryName}
    Input Text  id=Assets_${index}__Address_AddressPostCode    ${item.deliveryAddress.postalCode}
    Click Element    id = submit-item-btn

# Download document
Завантажити документ
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == ${filepath}
    ...    ${ARGUMENTS[2]} == ${TENDER}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[2]}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id=update-btn
    Select From List By Value    id = files-type    8
    Choose File    id = auction-file    ${ARGUMENTS[1]}
    Sleep    2
    Click Element    id=lot-document-upload-btn
    Reload Page

# Search for a bid identifier
Пошук тендера по ідентифікатору
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == ${TENDER}
    Switch Browser    ${ARGUMENTS[0]}
    Go to    ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Wait Until Page Contains Element    name = Auctions[auctionID]
    Input Text    name = Auctions[auctionID]    ${ARGUMENTS[1]}
    Click Element    name = Auctions[title]
    Sleep    2
    Wait Until Page Contains Element    id=auction-view-btn
    Click Element    id=auction-view-btn

# Go to the questions page
Перейти до сторінки запитань
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id = auction-view-btn
    Click Element    id = tab-2
    Wait Until Page Contains Element    id= create-question-btn

# Go to the cancellations page
Перейти до сторінки відмін
    Go To    https://proumstrade.com.ua/cancelations/index
    Wait Until Page Contains Element    id=decline-btn
    Click Element    id=decline-btn
    Wait Until Page Contains Element    id=decline-id

# Ask a question
Задати питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderUaId
    ...    ${ARGUMENTS[2]} == questionId
    ${title}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Wait Until Page Contains Element    id = auction-view-btn
    Click Element    id = auction-view-btn
    Click Element    id = tab-2
    Wait Until Page Contains Element    id= create-question-btn
    Click Element    id=create-question-btn
    Sleep    3
    Input text    id=questions-title    ${title}
    Input text    id=questions-description    ${description}
    Click Element    id= create-question-btn

# Get information about cancellations[0].status
Отримати інформацію про cancellations[0].status
    Перейти до сторінки відмін
    Wait Until Page Contains Element    id = status
    ${return_value}=    Get text    id = status
    [Return]    ${return_value}

# Get information about cancellations[0].reason
Отримати інформацію про cancellations[0].reason
    Перейти до сторінки відмін
    Wait Until Page Contains Element    id = modal-btn
    Click Element    id = modal-btn
    ${return_value}=    Get text    id = messages-notes
    [Return]    ${return_value}

# Refresh the page with the tender
Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    Switch Browser    ${ARGUMENTS[0]}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

# Obtain information from the subject
Отримати інформацію із предмету
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tender_uaid
    ...    ${ARGUMENTS[2]} == item_id
    ...    ${ARGUMENTS[3]} == field_name
    ${return_value}=    Run Keyword And Return    kpmgdealroom.Отримати інформацію із тендера    ${username}    ${tender_uaid}    ${field_name}
    [Return]    ${return_value}

# Get information from the tender
Отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[2]} == fieldname
    ${return_value}=    Run Keyword    Отримати інформацію про ${ARGUMENTS[2]}
    [Return]    ${return_value}

# Get text from the field and show on the page
Отримати текст із поля і показати на сторінці
    [Arguments]    ${fieldname}
    ${return_value}=    Get Text    ${locator.${fieldname}}
    [Return]    ${return_value}

# Get information from title
Отримати інформацію про title
    ${return_value}=    Отримати текст із поля і показати на сторінці    title
    [Return]    ${return_value}

# Get information from procurementMethodType
Отримати інформацію про procurementMethodType
    ${return_value}=    Отримати текст із поля і показати на сторінці    procurementMethodType
    [Return]    ${return_value}

# Get information from  dgfID
Отримати інформацію про dgfID
    ${return_value}=    Отримати текст із поля і показати на сторінці    dgf
    [Return]    ${return_value}

# Get information from dgfDecisionID
Отримати інформацію про dgfDecisionID
    ${return_value}=    Отримати текст із поля і показати на сторінці    dgfDecisionID
    [Return]    ${return_value}

# Get information from dgfDecisionDate
Отримати інформацію про dgfDecisionDate
    ${date_value}=    Отримати текст із поля і показати на сторінці    dgfDecisionDate
    ${return_value}=    kpmgdealroom_service.convert_date    ${date_value}
    [Return]    ${return_value}

# Get information from tenderAttempts
Отримати інформацію про tenderAttempts
    ${return_value}=    Отримати текст із поля і показати на сторінці    tenderAttempts
    ${return_value}=    Convert To Integer    ${return_value}
    [Return]    ${return_value}

# Get information from eligiblityCriteria
Отримати інформацію про eligibilityCriteria
    ${return_value}=    Отримати текст із поля і показати на сторінці    eligibilityCriteria

# Get information from status
Отримати інформацію про status
    Reload Page
    Wait Until Page Contains Element    id = status
    Sleep    2
    ${return_value}=    Get Text    id = status
    [Return]    ${return_value}

# Get information from description
Отримати інформацію про description
    ${return_value}=    Отримати текст із поля і показати на сторінці    description
    [Return]    ${return_value}

# Get information from value.amount
Отримати інформацію про value.amount
    ${return_value}=    Отримати текст із поля і показати на сторінці    value.amount
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from minimialStep.amount
Отримати інформацію про minimalStep.amount
    ${return_value}=    Отримати текст із поля і показати на сторінці    minimalStep.amount
    ${return_value}=    convert to number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Make changes to the tender
Внести зміни в тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    ...    ${ARGUMENTS[2]} == fieldname
    ...    ${ARGUMENTS[3]} == fieldvalue
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id = update-btn
    Input Text    ${locator.edit.${ARGUMENTS[2]}}    ${ARGUMENTS[3]}
    Click Element    id=submissive-btn
    Wait Until Page Contains    Успішно оновлено    5
    ${result_field}=    Get Value    ${locator.edit.${ARGUMENTS[2]}}
    Should Be Equal    ${result_field}    ${ARGUMENTS[3]}

# Get information from items[].quantity
Отримати інформацію про items[${index}].quantity
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].quantity
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from items[].unit.code
Отримати інформацію про items[${index}].unit.code
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].unit.code
    [Return]    ${return_value}

# Get information from items[].unit.name
Отримати інформацію про items[${index}].unit.name
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].unit.name
    [Return]    ${return_value}

# Get information from items[].description
Отримати інформацію про items[${index}].description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].description
    [Return]    ${return_value}

# Get information from items[].classification.id
Отримати інформацію про items[${index}].classification.id
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].classification.id
    [Return]    ${return_value}

# Get information from items[].classification.scheme
Отримати інформацію про items[${index}].classification.scheme
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].classification.scheme
    [Return]    ${return_value}

# Get information from items[].classification.description
Отримати інформацію про items[${index}].classification.description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[${index}].classification.description
    [Return]    ${return_value}

# Get information from value.currency
Отримати інформацію про value.currency
    ${return_value}=    Get Selected List Value    slPosition_value_currency
    [Return]    ${return_value}

# Get information from value.valueAddedTaxIncluded
Отримати інформацію про value.valueAddedTaxIncluded
    ${return_value}=    is_checked    cbPosition_value_valueAddedTaxIncluded
    [Return]    ${return_value}

# Get information from auctionID
Отримати інформацію про auctionID
    ${return_value}=    Отримати текст із поля і показати на сторінці    tenderId
    [Return]    ${return_value}

# Get information from procuringEntity.name
Отримати інформацію про procuringEntity.name
    ${return_value}=    Отримати текст із поля і показати на сторінці    procuringEntity.name
    [Return]    ${return_value}

# Get information from items[0].deliveryLocation.latitude
Отримати інформацію про items[0].deliveryLocation.latitude
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryLocation.latitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

# Get information from items[0].deliveryLocation.longitude
Отримати інформацію про items[0].deliveryLocation.longitude
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryLocation.longitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

# Get information from auctionPeriod.startDate
Отримати інформацію про auctionPeriod.startDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from auctionPeriod.endDate
Отримати інформацію про auctionPeriod.endDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}

# Get information from tenderPeriod.startDate
Отримати інформацію про tenderPeriod.startDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from tenderPeriod.endDate
Отримати інформацію про tenderPeriod.endDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.startDate
Отримати інформацію про enquiryPeriod.startDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.endDate
Отримати інформацію про enquiryPeriod.endDate
    ${date_value}=    Get Text    css = div.table > tr : nth-child(5) > td
    ${return_value}=    convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from items[0].deliveryAddress.countryName
Отримати інформацію про items[0].deliveryAddress.countryName
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.countryName
    [Return]    ${return_value.split(', ')[0]}

# Get information from items[0].deliveryAddress.postalCode
Отримати інформацію про items[0].deliveryAddress.postalCode
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.postalCode
    [Return]    ${return_value.split(', ')[1]}

# Get information from items[0].deliveryAddress.region
Отримати інформацію про items[0].deliveryAddress.region
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.region
    [Return]    ${return_value.split(', ')[2]}

# Get information from items[0].deliveryAddress.locality
Отримати інформацію про items[0].deliveryAddress.locality
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.locality
    [Return]    ${return_value.split(', ')[3]}

# Get information from items[0].deliveryAddress.streetAddress
Отримати інформацію про items[0].deliveryAddress.streetAddress
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.streetAddress
    [Return]    ${return_value.split(', ')[4]}

# Get information from items[0].deliveryDate.endDate
Отримати інформацію про items[0].deliveryDate.endDate
    ${date_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryDate.endDate
    ${return_value}=    kpmgdealroom_service.convert_date    ${date_value}
    [Return]    ${return_value}

# Get information from questions[].title
Отримати інформацію про questions[${index}].title
    ${index}=    inc    ${index}
    Wait Until Page Contains Element    id =
    ${return_value}=    Get text    id =
    [Return]    ${return_value}

# Get information from questions[].description
Отримати інформацію про questions[${index}].description
    ${index}=    inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
    [Return]    ${return_value}

# Get information from questions[].answer
Отримати інформацію про questions[${index}].answer
    ${index}=    inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
    [Return]    ${return_value}

# Get information from questions[].date
Отримати інформацію про questions[${index}].date
    ${index}=    inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
    ${return_value}=    convert_date_time_to_iso    ${return_value}
    [Return]    ${return_value}

# Answer a question
Відповісти на питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    ...    ${ARGUMENTS[2]} = 0
    ...    ${ARGUMENTS[3]} = answer_data
    ${answer}=    Get From Dictionary    ${ARGUMENTS[3].data}    answer
    Перейти до сторінки запитань
    Click Element    id = create-answer-btn
    Sleep    3
    Input Text    id=questions-answer    ${answer}
    Click Element    id=create-question-btn

# Submit a quote
Подати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${test_bid_data}
    ...    ${ARGUMENTS[3]} == ${filepath}
    ${amount}=    get_str    ${ARGUMENTS[2].data.value.amount}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    id = view-btn
    Click Element    id= view-btn
    sleep    3s
    Click Element    id = create-bid-btn
    sleep    5s
    Input Text    id=bids-value_amount    ${amount}
    Choose File    id = upload-file-input
    Click Element    id= create-bid-btn
    sleep    3
    ${resp}=    Get Value    id=bids-value_amount
    [Return]    ${resp}

# Cancel your bid
Скасувати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    Go To    http://proumstrade.com.ua/bids/index
    Wait Until Page Contains Element    id = view-bids-btn
    Click Element    id = view-bids-btn
    Sleep    3
    Wait Until Page Contains Element    id = modal-btn
    Click Element    id=modal-btn
    Wait Until Page Contains Element    id = messages-notes
    Input Text    id = messages-notes    Some reason
    Click Element    id = decline-modal-id

# Get information from the offer
Отримати інформацію із пропозиції
    [Arguments]    ${username}    ${tender_uaid}    ${field}
    Go To    http://proumstrade.com.ua/bids/index    ${tender_uaid}
    Wait Until Page Contains Element    id = view-btn
    Click Element    id = view-btn
    Wait Until Page Contains Element    id=bids-value-amount
    ${value}=    Get Value    id=bids-value_amount
    ${value}=    Convert To Number    ${value}
    [Return]    ${value}

# Change bid proposal
Змінити цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == ${test_bid_data}
    ${amount}=    get_str    ${ARGUMENTS[0].data.value.amount}
    Go To    https://proumstrade.com.ua/bids/index
    Wait Until Page Contains Element    id= update-bids-btn
    Click Element    id= update-bids-btn
    sleep    3s
    Input Text    id=bids-value_amount    ${amount}
    Click Element    id= update-bid-btn

# Download a financial license
Завантажити фінансову ліцензію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${test_bid_data}
    ...    ${ARGUMENTS[3]} == ${filepath}
    ${amount}=    get_str    ${ARGUMENTS[2].data.value.amount}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id= update-btn
    sleep    3s
    Click Element    id = create-bid-btn
    sleep    5s
    Choose File    css = div.file-caption-name    ${ARGUMENTS[3]}
    Click Element    id = create-bid-btn

# Get a link to the auction for the viewer
Отримати посилання на аукціон для глядача
    [Arguments]    @{ARGUMENTS}
    Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element    xpath=(//*[@id='aPosition_auctionUrl' and not(contains(@style,'display: none'))])
    Sleep    5
    ${result} =    Get Text    id=aPosition_auctionUrl
    [Return]    ${result}

# Get a link to the auction for a member
Отримати посилання на аукціон для учасника
    [Arguments]    @{ARGUMENTS}
    Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element    xpath=(//*[@id='aPosition_auctionUrl' and not(contains(@style,'display: none'))])
    Sleep    5
    ${result}=    Get Text    id=aPosition_auctionUrl
    [Return]    ${result}

# Download a document in a tender with a type
Завантажити документ в тендер з типом
    [Arguments]    ${username}    ${tender_uaid}    ${filepath}    ${doc_type}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id=update-btn
    Select From List By Value    id = files-type    ${doc_type}
    Choose File    css = div.file-caption-name    ${filepath}
    Sleep    2
    Click Element    id=upload_button

# Download the illustration
Завантажити ілюстрацію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == \ ${filepath}
    ...    ${ARGUMENTS[2]} == ${tender_uaid}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[2]}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id=update-btn
    Select From List By Value    id = files-type    6
    Choose File    id = auction-file    ${ARGUMENTS[1]}
    Sleep    2
    Click Element    id=upload_button
    Reload Page

#Add virtual data room
Додати Virtual Data Room
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${vdr_url}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[2]}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id=update-btn
    Select From List By Value    id = files-type    10
    Choose File    id = auction-file    ${ARGUMENTS[1]}
    Sleep    2
    Click Element    id=upload_button
    Reload Page

#Add a public passport to the asset
Додати публічний паспорт активу
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${vdr_url}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[2]}
    Wait Until Page Contains Element    id = update-btn
    Click Element    id=update-btn
    Select From List By Value    id = files-type    2
    Choose File    id = auction-file    ${ARGUMENTS[1]}
    Sleep    2
    Click Element    id=upload_button
    Reload Page

# Get information from index document
Отримати інформацію із документа по індексу
    [Arguments]    ${username}    ${tender_uaid}    ${document_index}    ${field}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    ${doc_value}=    Get Text    id = doc_id
    [Return]    ${doc_value}

# Get information from a document
Отримати інформацію із документа
    [Arguments]    ${username}    ${tender_uaid}    ${doc_id}    ${field_name}
    ${doc_value}=    Get Text    id = doc_id
    [Return]    ${doc_value}

# Answer the question
Відповісти на запитання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    ...    ${ARGUMENTS[2]} = 0
    ...    ${ARGUMENTS[3]} = answer_data
    ${answer}=    Get From Dictionary    ${ARGUMENTS[3].data}    answer
    Перейти до сторінки запитань
    Click Element    id = create-answer-btn
    Sleep    3
    Input Text    id=questions-answer    ${answer}
    Click Element    id=create-question-btn
    sleep    1

# Get info from the question
Отримати інформацію із запитання
    [Arguments]    ${username}    ${tender_uaid}    ${question_id}    ${field_name}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Перейти до сторінки запитань
    ${return_value}=    Run Keyword If    '${field_name}' == 'title'    Get Text    xpath=(//span[contains(@class, 'qa_title') and contains(@class, '${item_id}')])
    ...    ELSE IF    '${field_name}' == 'answer'    Get Text    xpath=(//span[contains(@class, 'qa_answer') and contains(@class, '${item_id}')])
    ...    ELSE    Get Text    xpath=(//span[contains(@class, 'qa_description') and contains(@class, '${item_id}')])
    [Return]    ${return_value}

# Ask a question about the tender
Задати запитання на тендер
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Задати питання    ${username}    ${tender_uaid}    ${question}

# Get the number of documents in the tender
Отримати кількість документів в тендері
    [Arguments]    ${username}    ${tender_uaid}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    ${tender_doc_number}=    Get Matching Xpath Count    xpath=(//*[@id=' doc_id']/)
    [Return]    ${tender_doc_number}

# Get a document
Отримати документ
    [Arguments]    ${username}    ${tender_uaid}    ${doc_id}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Element    id = update-btn
    sleep    3
    ${file_name}=    Get Text    id = doc-id
    ${url}=    Get Element Attribute    id = doc-id@name
    download_file    ${url}    ${file_name.split('/')[-1]}    ${OUTPUT_DIR}
    [Return]    ${file_name.split('/')[-1]}

# Obtain data from the proposal document
Отримати дані із документу пропозиції
    [Arguments]    ${username}    ${tender_uaid}    ${bid_index}    ${document_index}    ${field}
    ${document_index}=    inc    ${document_index}
    ${result}=    Get Text    xpath=(//*[@id='pnAwardList']/div[last()]/div/div[1]/div/div/div[2]/table[${document_index}]//span[contains(@class, 'documentType')])
    [Return]    ${result}

# Cancellation of the decision of the qualification commission
Скасування рішення кваліфікаційної комісії
    [Arguments]    ${username}    ${tender_uaid}    ${award_num}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])
    Sleep    1
    Click Element    xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])

# Download the decision document of the qualification commission
Завантажити документ рішення кваліфікаційної комісії
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}    ${award_num}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
    Click Element    xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'award_docs')]//span[contains(@class, 'add_document')])
    Choose File    xpath=(//*[@id='upload_form']/input[2])    ${filepath}
    Sleep    2
    Click Element    id=upload_button
    Reload Page

# Download the auction protocol
Завантажити протокол аукціону
    [Arguments]    ${username}    ${tender_uaid}    ${filepath}    ${award_index}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
    Click Element    id=btnShowBid
    Sleep    1
    Wait Until Page Contains Element    xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
    Click Element    id=btn_documents_add
    Select From List By Value    id=slFile_documentType    auctionProtocol
    Choose File    xpath=(//*[@id='upload_form']/input[2])    ${filepath}
    Sleep    2
    Click Element    id=upload_button

# Download an agreement to the tender
Завантажити угоду до тендера
    [Arguments]    ${username}    ${tender_uaid}    ${contract_num}    ${filepath}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
    Click Element    xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'contract_docs')]//span[contains(@class, 'add_document')])
    Select From List By Value    id=slFile_documentType    contractSigned
    Choose File    xpath=(//*[@id='upload_form']/input[2])    ${filepath}
    Sleep    2
    Click Element    id=upload_button
    Reload Page

# Confirm the signing of the contract
Підтвердити підписання контракту
    [Arguments]    ${username}    ${tender_uaid}    ${contract_num}
    ${file_path}    ${file_title}    ${file_content}=    create_fake_doc
    Sleep    5
    kpmgdealroom.Завантажити угоду до тендера    ${username}    ${tender_uaid}    1    ${filepath}
    Wait Until Page Contains Element    xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
    Click Element    xpath=(//*[@id='pnAwardList']/div[last()]//span[contains(@class, 'contract_register')])