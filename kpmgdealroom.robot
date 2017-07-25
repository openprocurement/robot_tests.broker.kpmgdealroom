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
    Set Browser Implicit Wait   10
    Run Keyword If    '${ARGUMENTS[0]}' != 'kpmgdealroom_Viewer'    Login    ${ARGUMENTS[0]}

# Prepare data for tender announcement
Підготувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}    ${role_name}
    ${tender_data}=     kpmgdealroom_service.adapt_tender_data      ${tender_data}
    [Return]    ${tender_data}

# Updated for KDR
Login
    [Arguments]   @{ARGUMENTS}
    Wait Until Element Is Visible    ${locator.login.EmailField}    10
    Input text    ${locator.login.EmailField}    ${USERS.users['${ARGUMENTS[0]}'].login}
    Input text    ${locator.login.PasswordField}    ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Element    ${locator.login.LoginButton}
    Sleep    2


Input Date
  [Arguments]  ${elem_name_locator}  ${date}
  ${date}=   kpmgdealroom_service.convert_date_to_slash_format   ${date}
  Log To Console    ${date}
  Focus   ${elem_name_locator}
  Execute Javascript   $("#${elem_name_locator}").val('${date}');
  #Input Text    id=${elem_name_locator}  ${date}

#
#Write Form Field
#    [Arguments]     ${locator}  ${value}
#    Focus           ${locator}
#    Sleep   2
#    Input Text      ${locator}  ${value}
#    Sleep   2

# Get text from auction info field
Get Field Value
    [Arguments]    ${fieldname}
    ${return_value}=    Get Text    ${locator.viewExchange.${fieldname}}
    [Return]    ${return_value}

Wait And Click Element
    [Arguments]     ${locator}  ${delay}
    Wait Until Page Contains Element    ${locator}  ${delay}
    Click Element   ${locator}

# Setup team
Setup Team 
    [Arguments]                         ${team_name}    ${team_user}
    Click Element                       ${locator.exchangeToolbar.Admin} 
    Click Element                       ${locator.AddTeam.AddEditTeams}
    Click Element                       ${locator.AddTeam.AddNewTeam}
    Input Text                          ${locator.AddTeam.Name}  ${team_name}
    Click Element                       ${locator.AddTeam.Save}
    Click Element                       ${locator.Addusers.Addusers}
    Input Text                          ${locator.Addusers.Email}   ${team_user}
    Click Element                       ${locator.Addusers.AssignTeamDropdown}    
    Click Element                       link=${team_name}
    Click Element                       ${locator.Addusers.Add}

# Add users to bids
Setup User Bids
    [Arguments]    @{ARGUMENTS}
    Click Element                       ${locator.Bids.Bids}
    Wait Until Page Contains Element    ${locator.Bids.Buyer1Eligible}   10
    Click Element                       ${locator.Bids.Buyer1Eligible}
    Click Element                       ${locator.Bids.Buyer1Qualified}
    Click Element                       ${locator.Bids.Buyer2Eligible}
    Click Element                       ${locator.Bids.Buyer2Qualified}
    Click Element                       ${locator.Bids.Save}

#------------------------------------------------------------------------------
#  LOT OPERATIONS
#------------------------------------------------------------------------------
# Create a tender (KDR-1072)
Створити тендер
    [Arguments]    ${username}  ${tender_data}
    Set Global Variable    ${TENDER_INIT_DATA_LIST}     ${tender_data}
    ${title}=                   Get From Dictionary     ${tender_data.data}    title
    ${dgfID}=                   Get From Dictionary     ${tender_data.data}    dgfID
    ${dgfDecisionDate}=         convert_ISO_DMY         ${tender_data.data.dgfDecisionDate}
    ${tenderAttempts}=          Get From Dictionary     ${tender_data.data}    tenderAttempts
    ${procurementMethodType}=   Get From Dictionary     ${tender_data.data}    procurementMethodType
    ${procuringEntity_name}=    Get From Dictionary     ${tender_data.data.procuringEntity}    name
    ${items}=                   Get From Dictionary     ${tender_data.data}    items
    ${number_of_items}=         Get Length              ${items}
    ${guarantee}=               convert_number_to_currency_str   ${tender_data.data.guarantee.amount}
    ${budget}=                  convert_number_to_currency_str   ${tender_data.data.value.amount}
    ${step_rate}=               convert_number_to_currency_str   ${tender_data.data.minimalStep.amount}
    ${currency}=                Get From Dictionary     ${tender_data.data.value}    currency
    ${valueAddedTaxIncluded}=   Get From Dictionary     ${tender_data.data.value}    valueAddedTaxIncluded
    ${admin_email}=             kpmgdealroom_service.convert_string_to_fake_email   ${username}
    ${sponsor_email}=           kpmgdealroom_service.convert_string_to_fake_email   ${username}
    ${start_day_auction}=       kpmgdealroom_service.get_tender_dates               ${tender_data}    StartDate
    ${start_time_auction}=      kpmgdealroom_service.get_tender_dates               ${tender_data}    StartTime
    ${dgfDecisionID}=           Get From Dictionary     ${tender_data.data}    dgfDecisionID
    ${description}=             Get From Dictionary     ${tender_data.data}    description

    Switch Browser    ${username}
    
    #  1. Click Create Exchange button
    Wait And Click Element    ${locator.toolbar.CreateExchangeButton}   5
            
    # 2. Fill in form details
    Wait And Click Element              ${locator.createExchange.ClientSelector}    5
    Wait Until Element Is Visible       ${locator.createExchange.ClientSelector.Prozorro}  2
    Click Element                       ${locator.createExchange.ClientSelector.Prozorro}
    
    Input Text                          ${locator.createExchange.Name}  ${title}
    Input Text                          ${locator.createExchange.SponsorEmail}  ${sponsor_email}
    Input Text                          ${locator.createExchange.AdminEmails}   ${admin_email}
    Wait And Click Element              ${locator.createExchange.TypeSelector}  10
    Wait Until Element Is Visible       ${locator.createExchange.TypeSelector.Prozorro}  2
    Click Element                       ${locator.createExchange.TypeSelector.Prozorro}
    Sleep                               1
    Wait Until Element Is Visible       ${locator.createExchange.StartDate}     2
    Input Date                          ${locator.createExchange.StartDateField}     ${tender_data.data.auctionPeriod.startDate}
    Wait Until Element Is Visible       ${locator.createExchange.DgfCategorySelector}  5
    Click Element                       ${locator.createExchange.DgfCategorySelector}
    Wait Until Element Is Visible       ${locator.createExchange.DgfCategorySelector.${procurementMethodType}}  2
    Click Element                       ${locator.createExchange.DgfCategorySelector.${procurementMethodType}}
    
    Wait Until Element is Visible       ${locator.createExchange.GuaranteeAmount}   20
    Input Text                          ${locator.createExchange.GuaranteeAmount}   ${guarantee}
    Input Text                          ${locator.createExchange.StartPrice}        ${budget}
    Input Text                          ${locator.createExchange.MinimumStepValue}  ${step_rate} 
    Input Text                          ${locator.createExchange.dgfID}             ${dgfID}
    Input Text                          ${locator.createExchange.dgfDecisionID}     ${dgfDecisionID}
    Input Date                          ${locator.createExchange.dgfDecisionDateField}   ${tender_data.data.dgfDecisionDate}
    Input Text                          ${locator.createExchange.description}       ${description}    
    Input Text                          ${locator.createExchange.tenderAttempts}    ${tenderAttempts}

    # 3. Submit exchange creation
    Click Element   ${locator.createExchange.SubmitButton}
    Wait And Click Element  ${locator.Dataroom.T&CYes}  20

    # 4. Now we must add items before Prozorro actually accepts our submitted auction
    :FOR  ${index}  IN RANGE  ${number_of_items} 
    \  Додати предмет  ${items[${index}]}   ${index}
    Click Element   ${locator.addAsset.SaveButton}

    # 5. Publish 
    Click Element                   ${locator.exchangeToolbar.Admin}
    Wait And Click Element          ${locator.exchangeAdmin.nav.Publish}    20
    Wait And Click Element          ${locator.exchangeAdmin.publish.PublishButton}  5
    Wait Until Element Is Visible   ${locator.exchangeAdmin.publish.confirmButton}  5
    Click Element                   ${locator.exchangeAdmin.publish.confirmButton}

    Wait Until Page Contains Element   ${locator.exchangeAdmin.publish.publishedID}  30
    ${TENDER}=          Get Text    ${locator.exchangeAdmin.publish.publishedID}
    
    # team and user setup
    Click Element                       ${locator.toolbar.ExchangesButton}
    kpmgdealroom.Пошук тендера по ідентифікатору  ${username}     ${TENDER}
    Setup Team                          Buyer Team 1        pzProvider@kpmg.co.uk
    Setup Team                          Buyer Team 2        pzProvider1@kpmg.co.uk
    Setup User Bids
    
    [Return]    ${TENDER}
    
# Add item/asset (KDR-1129)
Додати предмет
    [Arguments]    ${item}    ${index}
    Run Keyword If  ${index} != 0  Click Element  ${locator.addAsset.AddButton} 
    Wait Until Element Is Visible   ${locator.addAsset.items[${index}].description}    20
    Input Text  ${locator.addAsset.items[${index}].description}                 ${item.description}
    Input Text  ${locator.addAsset.items[${index}].quantity}                    ${item.quantity}
    Input Text  ${locator.addAsset.items[${index}].classification.description}  ${item.classification.description}
    Input Text  ${locator.addAsset.items[${index}].classification.code}         ${item.classification.id}
    Input Text  ${locator.addAsset.items[${index}].address1}                    ${item.deliveryAddress.streetAddress}
    Input Text  ${locator.addAsset.items[${index}].region}                      ${item.deliveryAddress.region}
    Input Text  ${locator.addAsset.items[${index}].city}                        ${item.deliveryAddress.locality}
    Input Text  ${locator.addAsset.items[${index}].country}                     ${item.deliveryAddress.countryName_en}
    Input Text  ${locator.addAsset.items[${index}].postcode}                    ${item.deliveryAddress.postalCode}

Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  kpmgdealroom.Пошук тендера по ідентифікатору      ${username}   ${tender_uaid}
  # ${index}=     need to get index where to add item 
  Run Keyword And Ignore Error  Додати предмет      ${item}  ${index}
  Run Keyword And Ignore Error  Click Element       ${locator.addAsset.SaveButton}
  
Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  dzo.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Клікнути по елементу   xpath=//a[./text()='Редагувати']
  Execute Javascript   $(".topFixed").remove(); $('.blockedId').removeClass('blockedId');
  Run Keyword And Ignore Error  Клікнути по елементу   xpath=//input[contains(@value, '${item_id}')]/ancestor::div[@class="tenderItemElement tenderItemPositionElement"]/descendant::a[@class="deleteMultiItem"]
  Run Keyword And Ignore Error  Підтвердити дію
  Run Keyword And Ignore Error  Клікнути по елементу   xpath=//button[@value="save"]



# Refresh the page with the tender
Оновити сторінку з тендером
    [Arguments]     ${username}  ${tender_uaid}
    Switch Browser  ${username}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}     ${tender_uaid}
    Reload Page

# Search for a bid identifier (KDR-1077)
kpmgdealroom.Пошук тендера по ідентифікатору
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser    ${username}
    Go to                               ${USERS.users['${username}'].default_page}
    Wait Until Element Is Visible       ${locator.exchangeList.FilterByIdButton}
    Wait Until Element Is Not Visible   css=div.k-loading-image
    Click Element                       ${locator.exchangeList.FilterByIdButton}
    Wait Until Element Is Enabled       ${locator.exchangeList.FilterTextField}    10
    Input Text                          ${locator.exchangeList.FilterTextField}    ${tender_uaid}
    Click Element                       ${locator.exchangeList.FilterSubmitButton}
    Sleep                               1
    Wait Until Element Is Not Visible   css=div.k-loading-image
    Click Element                       ${locator.exchangeList.FilteredResult}



    Wait And Click Element              ${locator.exchangeToolbar.Details}  10

# Get information about the tender
kpmgdealroom.Отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[2]} == fieldname
    ${return_value}=    Run Keyword    Отримати інформацію про ${ARGUMENTS[2]}
    [Return]    ${return_value}

# Obtain information from field
Отримати інформацію із предмету
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tender_uaid
    ...    ${ARGUMENTS[2]} == item_id
    ...    ${ARGUMENTS[3]} == field_name
    ${return_value}=    Run Keyword And Return  kpmgdealroom.Отримати інформацію із тендера    ${username}    ${tender_uaid}    ${field_name}
    [Return]    ${return_value}

# Get information from title
Отримати інформацію про title
    ${return_value}=    Get Text    ${locator.viewExchange.title}
    [Return]    ${return_value}

# Get information from description
Отримати інформацію про description
    ${return_value}=    Get Field Value    description
    [Return]    ${return_value}

# Get information from procurementMethodType
Отримати інформацію про procurementMethodType
    ${return_value}=    Get Value    ${locator.viewExchange.procurementMethodType}
    [Return]    ${return_value}

# Get information from  dgfID
Отримати інформацію про dgfID
    ${return_value}=    Get Field Value    dgfID
    [Return]    ${return_value}

# Get information from dgfDecisionID
Отримати інформацію про dgfDecisionID
    ${return_value}=    Get Field Value    dgfDecisionID
    [Return]    ${return_value}

# Get information from dgfDecisionDate
Отримати інформацію про dgfDecisionDate
    ${date_value}=    Get Field Value    dgfDecisionDate
    ${return_value}=    kpmgdealroom_service.convert_date    ${date_value}
    [Return]    ${return_value}

# Get information from tenderAttempts
Отримати інформацію про tenderAttempts
    ${return_value}=    Get Field Value    tenderAttempts
    ${return_value}=    Convert To Integer    ${return_value}
    [Return]    ${return_value}

# Get information from eligiblityCriteria
Отримати інформацію про eligibilityCriteria
    ${return_value}=    Get Field Value    eligibilityCriteria

# Get information from value.amount
Отримати інформацію про value.amount
    ${return_value}=    Get Value    ${locator.viewExchange.value.amount}
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from minimialStep.amount
Отримати інформацію про minimalStep.amount
    ${return_value}=    Get Value    ${locator.viewExchange.minimalStep.amount}
    ${return_value}=    Convert To Number    ${return_value.replace(' ', '').replace(',', '.')}
    [Return]    ${return_value}

# Get information from value.currency
Отримати інформацію про value.currency
    ${return_value}=    Get Field Value    value.currency
    [Return]    ${return_value}

# Get information from value.valueAddedTaxIncluded
#TODO & FIXME
Отримати інформацію про value.valueAddedTaxIncluded
    ${return_value}=    kpmgdealroom_service.is_checked    ${locator.viewExchange.value.valueAddedTaxIncluded}
    [Return]    ${return_value}

# Get information from auctionID
Отримати інформацію про auctionID
    ${return_value}=    Get Field Value    tenderId
    [Return]    ${return_value}

# Get information from procuringEntity.name
Отримати інформацію про procuringEntity.name
    ${return_value}=    Get Field Value    procuringEntity.name
    [Return]    ${return_value}

# Get information from auctionPeriod.startDate
Отримати інформацію про auctionPeriod.startDate
    ${date_value}=    Get Value    ${locator.viewExchange.auctionPeriod.startDate}
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from auctionPeriod.endDate
Отримати інформацію про auctionPeriod.endDate
    ${date_value}=    Get Value    ${locator.viewExchange.auctionPeriod.endDate}
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from tenderPeriod.startDate
Отримати інформацію про tenderPeriod.startDate
    ${date_value}=    Get Value    ${locator.viewExchange.tenderPeriod.startDate}
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from tenderPeriod.endDate
Отримати інформацію про tenderPeriod.endDate
    ${date_value}=    Get Value    ${locator.viewExchange.tenderPeriod.endDate}
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.startDate
Отримати інформацію про enquiryPeriod.startDate
    ${date_value}=    Get Value    ${locator.viewExchange.enquiryPeriod.startDate}
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from enquiryPeriod.endDate
Отримати інформацію про enquiryPeriod.endDate
    ${return_value}=    Get Value    ${locator.viewExchange.enquiryPeriod.endDate}
    # ${date_value}=    Get Field Value    enquiryPeriod.endDate
    ${return_value}=    kpmgdealroom_service.convert_date_to_iso    ${date_value}    ${time_value}
    [Return]    ${return_value}

# Get information from status
Отримати інформацію про status
    Reload Page
    Wait Until Page Contains Element    ${locator.viewExchange.status}
    Sleep    2
    ${return_value}=    Get Field Value    status
    [Return]    ${return_value}

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

#------------------------------------------------------------------------------
#  QUESTIONS AND ANSWERS
#------------------------------------------------------------------------------
# Go to the questions page
Перейти до сторінки запитань
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}   
    Click Element   ${locator.Questions.FAQ}
  
# Ask a question
Задати питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderUaId
    ...    ${ARGUMENTS[2]} == questionId
    ${title}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Перейти до сторінки запитань    ${ARGUMENTS[0]}     ${ARGUMENTS[1]}

    Wait And Click Element              ${locator.Questions.DraftQuestionButton}   10
    Wait Until Page Contains Element    ${locator.Questions.Subject}
    Input Text                          ${locator.Questions.Question}   ${description}
    Click Element                       ${locator.Questions.SubmitQuestionButton}

# Answer a question
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

# Ask a question about the tender
Задати запитання на тендер
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Задати питання    ${username}    ${tender_uaid}    ${question}

#------------------------------------------------------------------------------
#  WORKING WITH DOCUMENTS
#------------------------------------------------------------------------------
# Upload document
Завантажити документ
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == ${filepath}
    ...    ${ARGUMENTS[2]} == ${TENDER}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}     ${ARGUMENTS[2]}
    Wait And Click Element      ${locator.Dataroom.Dataroom}            10
    Click Element               ${locator.Dataroom.T&CYes}
    Wait And Click Element      ${locator.Dataroom.UploadIcon}          10
    Click Element               ${locator.Dataroom.SelectFiles}
    Input Text                  ${locator.Dataroom.SelectFiles}         ${ARGUMENTS[1]}
    # TODO : Select file type: Document
    Click Element               ${locator.Dataroom.UploadFileButtond}
    Sleep                       2
    Reload Page
    

#------------------------------------------------------------------------------
#  BIDDING
#-----------------------------------------------------------------------------
# Submit a bid
Подати цінову пропозицію
    [Arguments]   ${username}  ${tender_uaid}  ${bid}
    ${amount}=   add_second_sign_after_point   ${bid.data.value.amount}
    ${eligibilityDocPath}=   get_upload_file_path   eligibility.doc
    ${qualificationDocPath}=    get_upload_file_path    qualification.doc

    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
    Click Element                                   ${locator.exchangeToolbar.Bids}
    Wait Until Element Is Visible                   ${locator.Bidding.UploadFilesButton}    10
    Choose File                                     ${locator.Bidding.EligibilityFile}      kpmgdealroom_service.get_upload_file_path   eligibility.doc
    Choose File                                     ${locator.Bidding.QualificationFile}    kpmgdealroom_service.get_upload_file_path   qualification.doc
    Click Element                                   ${locator.Bidding.SubmitFilesButton}
    Sleep                                           20
    Click Element                                   ${locator.Bidding.InitialBiddingLink}
    Wait until Element Is Visible                   ${locator.Bidding.BiddingAmount}    10
    Input Text                                      ${locator.Bidding.BiddingAmount}    ${amount}
    Click Element                                   ${locator.Bidding.SubmitBidButton}
    Wait Until Element Is Visible                   ${locator.Bidding.ConfirmBidPassword}   10
    Input Text                                      Admin1234
    Click Element                                   ${locator.Bidding.ConfirmBidButton}
    Wait Until Page Contains                        ${locator.Bidding.CancelBidButton}
    [return]  ${bid}

# Cancel your bid
Скасувати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
    Click Element                                   ${locator.exchangeToolbar.Bids}
    Sleep                                           20
    Wait And Click Element                          ${locator.Bidding.InitialBiddingLink} 5
    Wait And Click Element                          ${locator.Bidding.CancelBidButton} 10
    Wait And Click Element                          ${locator.Bidding.CancelBidYesButton} 5
    Wait Until Element Is Visible                   ${locator.Bidding.SubmitBidButton}