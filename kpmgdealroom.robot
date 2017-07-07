*** Settings ***
Library           String
Library           Selenium2Library
Library           Collections
Library           kpmgdealroom_service.py

Resource          locators.robot

*** Keywords ***
#------------------------------------------------------------------------------
#  GENERIC FUNCTIONS
#------------------------------------------------------------------------------
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

# Updated for KDR
Login
    [Arguments]   @{ARGUMENTS}
    Wait Until Element Is Visible    ${locator.login.EmailField}    10
    Input text    ${locator.login.EmailField}    ${USERS.users['${ARGUMENTS[0]}'].login}
    Input text    ${locator.login.PasswordField}    ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Element    ${locator.login.LoginButton}
    Sleep    2

# Get text from auction info field
Get Field Value
    [Arguments]    ${fieldname}
    ${return_value}=    Get Text    ${locator.viewExchange.${fieldname}}
    [Return]    ${return_value}


#------------------------------------------------------------------------------
#  LOT OPERATIONS
#------------------------------------------------------------------------------
# Create a tender (KDR-1072)
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
    ${tenderAttempts}=    Get From Dictionary    ${ARGUMENTS[1].data}   tenderAttempts
    #${tenderAttempts}=    get_tenderAttempts    ${ARGUMENTS[1].data}
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
    Wait Until Page Contains Element    ${locator.toolbar.CreateExchangeButton}    20
    
    #  1. Click Create Exchange button
    Click Element    ${locator.toolbar.CreateExchangeButton}
    Wait Until Page Contains Element ${locator.createExchange.SubmitButton}  20    
    
    # 2. Fill in form details
    Click Element ${locator.createExchange.ClientProZorro}
    Input Text ${locator.createExchange.Name} ${title}
    Input Text ${locator.createExchange.SponsorEmail} ${ARGUMENTS[0]}
    Input Text ${locator.createExchange.AdminEmails} ${ARGUMENTS[0]}
    Wait Until Page Contains Element ${locator.createExchange.TypeSelectorProzorro} 10
    Click Element ${locator.createExchange.TypeSelectorProzorro}
    Wait Until Page Contains Element ${locator.createExchange.StartDate} 10
    Input Text ${locator.createExchange.StartDate} ${start_day_auction}
    Click Element ${locator.createExchange.DgfCategorySelectorDgfFinancialAssets}
    Input Text ${locator.createExchange.GuaranteeAmount} ${budget}
    Input Text ${locator.createExchange.StartPrice} 0

    # 3. Submit exchange creations
    Click Element ${locator.createExchange.SubmitButton}

    # 4. Now we must add items before Prozorro actually accepts our submitted auction
    :FOR  ${index}  IN RANGE  ${number_of_items} 
    \  Додати предмет  ${items[${index}]} ${index}
    Click Element ${locator.addAsset.SaveButton}

    # 5. FIXME & TODO: On page load find the created tender ID and return it
    Wait Until Page Contains    Аукціон збережено як чернетку    10
    ${tender_id}=    Get Text    id = auction-id
    ${TENDER}=    Get Text    id= auction-id
    log to console    ${TENDER}
    [Return]    ${TENDER}
    
# Add item/asset (KDR-1129)
Додати предмет
    [Arguments]    ${item}    ${index}
    Run Keyword If  ${index} != 0    Click Element  ${locator.addAsset.AddButton} 
    Wait Until Page Contains Element id=Assets_${index}__Description 5
    Input Text  id=Assets_${index}__Description ${item.description}
    Input Text  id=Assets_${index}__Quantity    ${item.quantity}
    Input Text  id=Assets_${index}__Classification_Scheme   ${item.classification.id}
    Input Text  id=Assets_${index}__Classification_Description  ${item.unit.code}
    Input Text  id=Assets_${index}__ClassificationCode ${item.unit.code}
    Input Text  id=Assets_${index}__Address_AddressLineOne  ${item.deliveryAddress.streetAddress}
    Input Text  id=Assets_${index}__Address_AddressLineTwo  ${item.deliveryAddress.region}
    Input Text  id=Assets_${index}__Address_AddressCity    ${item.deliveryAddress.locality}
    Input Text  id=Assets_${index}__Address_AddressCountry  ${item.deliveryAddress.countryName}
    Input Text  id=Assets_${index}__Address_AddressPostCode    ${item.deliveryAddress.postalCode}
    # FIXME
    Click Element    id = submit-item-btn

# Search for a bid identifier (KDR-1077)
Пошук тендера по ідентифікатору
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == ${TENDER}
    Switch Browser    ${ARGUMENTS[0]}
    Go to    ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Wait Until Page Contains Element    ${locator.exchangeList.FilterByIdButton}
    Click Element   ${locator.exchangeList.FilterByIdButton}
    Input Text  ${locator.exchangeList.FilterTextField}    ${ARGUMENTS[1]}
    Click Element   ${locator.exchangeList.FilterSubmitButton}
    Sleep    2
    Wait Until Page Contains Element    ${locator.exchangeList.FilteredResult}
    Click Element    ${locator.exchangeList.FilteredResult}

# Refresh the page with the tender
Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    Switch Browser    ${ARGUMENTS[0]}
    Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

# Obtain information from field
Отримати інформацію із предмету
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tender_uaid
    ...    ${ARGUMENTS[2]} == item_id
    ...    ${ARGUMENTS[3]} == field_name
    ${return_value}=    Run Keyword And Return  Отримати інформацію із тендера    ${username}    ${tender_uaid}    ${field_name}
    [Return]    ${return_value}

# Get information about the tender
Отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[2]} == fieldname
    ${return_value}=    Run Keyword    Отримати інформацію про ${ARGUMENTS[2]}
    [Return]    ${return_value}

# Get information from title
Отримати інформацію про title
    ${return_value}=    Get Field Value    title
    [Return]    ${return_value}

# Get information from description
Отримати інформацію про description
    ${return_value}=    Get Field Value    description
    [Return]    ${return_value}

# Get information from procurementMethodType
Отримати інформацію про procurementMethodType
    ${return_value}=    Get Field Value    procurementMethodType
    [Return]    ${return_value}

# Get information from  dgfID
Отримати інформацію про dgfID
    ${return_value}=    Get Field Value    dgfID
    [Return]    ${return_value}

# Get information from dgfDecisionID
Отримати інформацію про dgfDecisionID
    ${return_value}=    Get Field Value    dgfDecisionID
    [Return]    ${return_value}

# Get information from dgfDecisionDate
Отримати інформацію про dgfDecisionDate
    ${date_value}=    Get Field Value    dgfDecisionDate
    ${return_value}=    kpmgdealroom_service.convert_date    ${date_value}
    [Return]    ${return_value}

# Get information from tenderAttempts
Отримати інформацію про tenderAttempts
    ${return_value}=    Get Field Value    tenderAttempts
    ${return_value}=    Convert To Integer    ${return_value}
    [Return]    ${return_value}

# Get information from eligiblityCriteria
Отримати інформацію про eligibilityCriteria
    ${return_value}=    Get Field Value    eligibilityCriteria

# Get information from value.amount
Отримати інформацію про value.amount
    ${return_value}=    Get Field Value    value.amount
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from minimialStep.amount
Отримати інформацію про minimalStep.amount
    ${return_value}=    Get Field Value    minimalStep.amount
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from value.currency
Отримати інформацію про value.currency
    ${return_value}=    Get Field Value    value.currency
    [Return]    ${return_value}

# Get information from value.valueAddedTaxIncluded
#TODO & FIXME
Отримати інформацію про value.valueAddedTaxIncluded
    ${return_value}=    kpmgdealroom_service.is_checked    ${locator.viewExchange.value.valueAddedTaxIncluded}
    [Return]    ${return_value}

# Get information from auctionID
Отримати інформацію про auctionID
    ${return_value}=    Get Field Value    tenderId
    [Return]    ${return_value}

# Get information from procuringEntity.name
Отримати інформацію про procuringEntity.name
    ${return_value}=    Get Field Value    procuringEntity.name
    [Return]    ${return_value}

# Get information from auctionPeriod.startDate
Отримати інформацію про auctionPeriod.startDate
    ${date_value}=    Get Field Value    auctionPeriod.startDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from auctionPeriod.endDate
Отримати інформацію про auctionPeriod.endDate
    ${date_value}=    Get Field Value    auctionPeriod.endDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from tenderPeriod.startDate
Отримати інформацію про tenderPeriod.startDate
    ${date_value}=    Get Field Value    tenderPeriod.startDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from tenderPeriod.endDate
Отримати інформацію про tenderPeriod.endDate
    ${date_value}=    Get Field Value    tenderPeriod.endDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.startDate
Отримати інформацію про enquiryPeriod.startDate
    ${date_value}=    Get Field Value    enquiryPeriod.startDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.endDate
Отримати інформацію про enquiryPeriod.endDate
    ${date_value}=    Get Field Value    enquiryPeriod.endDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from status
Отримати інформацію про status
    Reload Page
    Wait Until Page Contains Element    ${locator.viewExchange.status}
    Sleep    2
    ${return_value}=    Get Field Value    status
    [Return]    ${return_value}


#------------------------------------------------------------------------------
#  WORK WITH EXCHANGE ASSETS
#------------------------------------------------------------------------------
# Get information from items[0].deliveryAddress.countryName
Отримати інформацію про items[0].deliveryAddress.countryName
    ${return_value}=    Get Field Value    items[0].deliveryAddress.countryName
    [Return]    ${return_value.split(', ')[0]}

# Get information from items[0].deliveryAddress.postalCode
Отримати інформацію про items[0].deliveryAddress.postalCode
    ${return_value}=    Get Field Value    items[0].deliveryAddress.postalCode
    [Return]    ${return_value.split(', ')[1]}

# Get information from items[0].deliveryAddress.region
Отримати інформацію про items[0].deliveryAddress.region
    ${return_value}=    Get Field Value    items[0].deliveryAddress.region
    [Return]    ${return_value.split(', ')[2]}

# Get information from items[0].deliveryAddress.locality
Отримати інформацію про items[0].deliveryAddress.locality
    ${return_value}=    Get Field Value    items[0].deliveryAddress.locality
    [Return]    ${return_value.split(', ')[3]}

# Get information from items[0].deliveryAddress.streetAddress
Отримати інформацію про items[0].deliveryAddress.streetAddress
    ${return_value}=    Get Field Value    items[0].deliveryAddress.streetAddress
    [Return]    ${return_value.split(', ')[4]}

# Get information from items[0].deliveryDate.endDate
Отримати інформацію про items[0].deliveryDate.endDate
    ${date_value}=    Get Field Value    items[0].deliveryDate.endDate
    ${return_value}=    kpmgdealroom_service.convert_date    ${date_value}
    [Return]    ${return_value}

# Get information from items[0].deliveryLocation.latitude
Отримати інформацію про items[0].deliveryLocation.latitude
    ${return_value}=    Get Field Value    items[0].deliveryLocation.latitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

# Get information from items[0].deliveryLocation.longitude
Отримати інформацію про items[0].deliveryLocation.longitude
    ${return_value}=    Get Field Value    items[0].deliveryLocation.longitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

# Get information from items[].quantity
Отримати інформацію про items[${index}].quantity
    ${return_value}=    Get Field Value    items[${index}].quantity
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from items[].unit.code
Отримати інформацію про items[${index}].unit.code
    ${return_value}=    Get Field Value    items[${index}].unit.code
    [Return]    ${return_value}

# Get information from items[].unit.name
Отримати інформацію про items[${index}].unit.name
    ${return_value}=    Get Field Value    items[${index}].unit.name
    [Return]    ${return_value}

# Get information from items[].description
Отримати інформацію про items[${index}].description
    ${return_value}=    Get Field Value    items[${index}].description
    [Return]    ${return_value}

# Get information from items[].classification.id
Отримати інформацію про items[${index}].classification.id
    ${return_value}=    Get Field Value    items[${index}].classification.id
    [Return]    ${return_value}

# Get information from items[].classification.scheme
Отримати інформацію про items[${index}].classification.scheme
    ${return_value}=    Get Field Value    items[${index}].classification.scheme
    [Return]    ${return_value}

# Get information from items[].classification.description
Отримати інформацію про items[${index}].classification.description
    ${return_value}=    Get Field Value    items[${index}].classification.description
    [Return]    ${return_value}
