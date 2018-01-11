# This script is provided by KPMG to ProZorro for the purpose of carrying out automated tests on
# the KPMG Deal Room testing system, in accordance with the rules of compliance for participating
# in the ProZorro.Sale process, as set out by the Ministry of Economic Development and Trade of
# Ukraine, Transparency International Ukraine, the Deposit Guarantee Fund and the National Bank of
# Ukraine - https://prozorro.sale/en/aim. For more information on the transparent public testing
# procedures please visit here https://github.com/openprocurement/

*** Settings ***
Library  String
Library  Selenium2Library
Library  Collections
Library  OperatingSystem
Library  kpmgdealroom_service.py
Library  op_robot_tests.tests_files.service_keywords

Resource  locators.robot

*** Keywords ***
#--------------------------------------------------------------------------------------
#  Support keywords
#--------------------------------------------------------------------------------------
Login
  [Arguments]  ${username}
  Wait Until Element Is Visible  ${locator.login.EmailField}  10
  Input text  ${locator.login.EmailField}  ${USERS.users['${username}'].login}
  Input text  ${locator.login.PasswordField}  ${USERS.users['${username}'].password}
  Click Element  ${locator.login.LoginButton}

Signin If Logged Out
  [Arguments]  ${username}
  Reload Page
  ${is_logged}=  Run Keyword And Return Status  Page Should Contain Element  ${locator.toolbar.LoginButton}
  Run Keyword If  ${is_logged} and "${username}" != "kpmgdealroom_Viewer"  Run Keywords
  ...  Click Element  ${locator.toolbar.LoginButton}
  ...  AND  Login  ${username}

Wait And Click Element
  [Arguments]  ${locator}  ${delay}
  Wait Until Keyword Succeeds  ${delay} x  1 s  Element Should Be Visible  ${locator}
  Click Element  ${locator}

Scroll To Element
  [Arguments]  ${locator}
  Wait Until Page Contains Element  ${locator}  10
  ${elem_vert_pos}=  Get Vertical Position  ${locator}
  Execute Javascript  window.scrollTo(0,${elem_vert_pos - 200});

Scroll And Click
  [Arguments]  ${locator}
  Scroll To Element  ${locator}
  Click Element  ${locator}

Click If Page Contains Element
  [Arguments]  ${locator}
  ${status}=  Run Keyword And Return Status  Element Should Be Visible  ${locator}
  Wait Modal Animation  ${locator}
  Run Keyword If  ${status}  Click Element  ${locator}

JQuery Ajax Should Complete
  ${active}=  Execute Javascript  return jQuery.active
  Should Be Equal  "${active}"  "0"

Wait Modal Animation
  [Arguments]  ${locator}
  Set Test Variable  ${prev_vert_pos}  0
  Wait Until Keyword Succeeds  20 x  500 ms  Position Should Equals  ${locator}

Position Should Equals
  [Arguments]  ${locator}
  ${current_vert_pos}=  Get Vertical Position  ${locator}
  ${status}=  Run Keyword And Return Status  Should Be Equal  ${prev_vert_pos}  ${current_vert_pos}
  Set Test Variable  ${prev_vert_pos}  ${current_vert_pos}
  Should Be True  ${status}

Select From KPMG List By Data-Value
  [Arguments]  ${element_id}  ${data_value}
  Click Element  xpath=//div[@id="${element_id}"]/div[2]
  Wait Until Page Contains Element  ${locator.PageElements.Dropdown.Opened} 
  Click Element  xpath=//*[@id="${element_id}"]/descendant::a[@data-value="${data_value}"]

Add Item
  [Arguments]  ${item}  ${index}
  Run Keyword If  ${index} != 0  Click Element  ${locator.addAsset.AddButton} 
  Wait Until Element Is Visible  ${locator.assetDetails.items.description}  20
  Input Text  ${locator.assetDetails.items.description}  ${item.description}
  Input Text  ${locator.assetDetails.items.quantity}  ${item.quantity}
  Click Element  xpath=//*[@id="_AssetUnit_${index}___dropdown"]/div[2]
  Click Element  xpath=//*[@id="_AssetUnit_${index}___dropdown"]/descendant::a[@data-value="${item.unit.code}"]
  Input Text  ${locator.assetDetails.items.classification.code}  ${item.classification.id}
  Input Text  ${locator.assetDetails.items.address1}  ${item.deliveryAddress.streetAddress}
  Input Text  ${locator.assetDetails.items.region}  ${item.deliveryAddress.region}
  Input Text  ${locator.assetDetails.items.city}  ${item.deliveryAddress.locality}
  Input Text  ${locator.assetDetails.items.country}  ${item.deliveryAddress.countryName_en}
  Input Text  ${locator.assetDetails.items.postcode}  ${item.deliveryAddress.postalCode}

Dismiss Exchange Rules Dialog
  Click If Page Contains Element  ${locator.Dataroom.RulesDialogYes}
  Wait Until Element Is Not Visible  ${locator.Dataroom.RulesDialogYes}

Open Dataroom
  [Arguments]  ${username}  ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  Wait And Click Element  ${locator.Dataroom.UploadIcon}  60
  Wait Modal Animation  ${locator.Dataroom.SelectFiles}

#------------------------------------------------------------------------------
#  LOT OPERATIONS - СТВОРЕННЯ ТЕНДЕРУ
#------------------------------------------------------------------------------

# Prepare client for user
Підготувати клієнт для користувача
  [Arguments]  ${username}
  Set Suite Variable  ${my_alias}  ${username + 'CUSTOM'}
  Set Global Variable   ${KPMG_MODIFICATION_DATE}   ${EMPTY}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${my_alias}
  Set Window Position  @{USERS.users['${username}']['position']}
  Set Window Size      @{USERS.users['${username}']['size']}
  Run Keyword If  '${username}' != 'kpmgdealroom_Viewer'  Login  ${username}

# Prepare data for tender announcement
Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=  kpmgdealroom_service.adapt_tender_data  ${tender_data}  ${role_name}
  [Return]  ${tender_data}

# Create a tender (KDR-1072)
Створити тендер
  [Arguments]  ${username}  ${tender_data}
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  ${number_of_items}=  Get Length  ${items}
  ${guarantee}=  convert_number_to_currency_str  ${tender_data.data.guarantee.amount}
  ${budget}=  convert_number_to_currency_str  ${tender_data.data.value.amount}
  ${step_rate}=  convert_number_to_currency_str  ${tender_data.data.minimalStep.amount}
  ${dp_auction_start_date}=  convert_date_to_dp_format  ${tender_data.data.auctionPeriod.startDate}  Date
  ${dp_dgf_decision_date}=  convert_date_to_dp_format  ${tender_data.data.dgfDecisionDate}  Date
  Switch Browser  ${my_alias}
  Wait And Click Element  ${locator.toolbar.CreateExchangeButton}  5
  Wait And Click Element  ${locator.createExchange.ClientSelector}  5
  Wait Until Element Is Visible  ${locator.createExchange.ClientSelector.Prozorro}  2
  Click Element  ${locator.createExchange.ClientSelector.Prozorro}
  Wait Until Keyword Succeeds  10 x  3 s  JQuery Ajax Should Complete
  Input Text  ${locator.createExchange.Name}  ${tender_data.data.title}
  Input Text  ${locator.createExchange.SponsorEmail}  ${USERS.users['${username}'].login}
  Input Text  ${locator.createExchange.AdminEmails}  ${USERS.users['${username}'].login}
  Click Element  ${locator.createExchange.TypeSelector}
  Wait Until Page Contains Element  ${locator.PageElements.Dropdown.Opened} 
  Click Element  ${locator.createExchange.TypeSelector.Prozorro}
  Wait Until Element Is Visible  ${locator.createExchange.StartDate}  2
  Input Text  ${locator.createExchange.StartDate}  ${dp_auction_start_date}
  Click Element  xpath=//*[@id="ExchangeDetails.ProzorroCategory"]/descendant::*[@data-toggle="dropdown"][2]
  Wait Until Page Contains Element  ${locator.PageElements.Dropdown.Opened} 
  Wait And Click Element  ${locator.createExchange.DgfCategorySelector.${tender_data.data.procurementMethodType}}   5
  Input Text  ${locator.createExchange.GuaranteeAmount}  ${guarantee}
  Input Text  ${locator.createExchange.StartPrice}  ${budget}
  Run Keyword If  ${tender_data.data.value.valueAddedTaxIncluded}  Select Checkbox  ${locator.createExchange.VatIncluded}
  Input Text  ${locator.createExchange.MinimumStepValue}  ${step_rate}
  Input Text  ${locator.createExchange.dgfID}  ${tender_data.data.dgfID}
  Input Text  ${locator.createExchange.dgfDecisionID}  ${tender_data.data.dgfDecisionID}
  Input Text  ${locator.createExchange.dgfDecisionDate}  ${dp_dgf_decision_date}
  Input Text  ${locator.createExchange.description}  ${tender_data.data.description}
  Select From KPMG List By Data-Value  _ExchangeDetails.TenderAttempts_dropdown  ${tender_data.data.tenderAttempts}
  Click Element  ${locator.createExchange.SubmitButton}
  Dismiss Exchange Rules Dialog
  :FOR  ${index}  IN RANGE  ${number_of_items}
  \  Add Item  ${items[${index}]}  ${index}
  Click Element  ${locator.addAsset.SaveButton}
  Click Element  ${locator.exchangeToolbar.Admin}
  Publish Auction
  Wait Until Keyword Succeeds  10 x  30 s  Check Auction Status  ${username}  Tendering
  Click Element  ${locator.toolbar.ExchangesButton}
  [Return]  ${auction_id}

Publish Auction
  Wait And Click Element  ${locator.exchangeAdmin.nav.Publish}  20
  Wait And Click Element  ${locator.exchangeAdmin.publish.PublishButton}  5
  Wait Until Element Is Visible  ${locator.exchangeAdmin.publish.confirmButton}  5
  Click Element  ${locator.exchangeAdmin.publish.confirmButton}
  Wait Until Page Contains Element  ${locator.exchangeAdmin.publish.publishedID}  30
  ${auction_id}=  Get Text  ${locator.exchangeAdmin.publish.publishedID}
  Set Test Variable  ${auction_id}

Check Auction Status
  [Arguments]  ${username}  ${expected_status}
  Go to  ${USERS.users['${username}'].default_page}
  Filter Auction  ${auction_id}  ${locator.exchangeList.FilterByIdButton.authUser}
  ${status}=  Get Text  ${locator.exchangeList.OwnerProzorroAuctionStatus}
  Should Be Equal  ${expected_status}  ${status}

# Search for a bid identifier
Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}  ${alias}=${my_alias}
  Switch Browser  ${alias}
  Signin If Logged Out  ${username}
  Go to  ${USERS.users['${username}'].default_page}
  Wait Until Keyword Succeeds  5 x  5 s  Search Auction As ${ROLE.replace("1","")}  ${tender_uaid}
  Dismiss Exchange Rules Dialog
  Wait And Click Element  ${locator.exchangeToolbar.Details}  5

Search Auction As Viewer
  [Arguments]  ${tender_uaid}
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton.viewer}
  Execute Javascript  $('a').css({display: "block"})
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/following-sibling::td/a[contains(@href,"/ExternalExchangeDetails/")]  10

Search Auction As Provider
  [Arguments]  ${tender_uaid}
  ${status}=  Run Keyword And Return Status  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton.authUser}
  Run Keyword If  not ${status}  Set Interested And Filter Auction In My Auctions   ${tender_uaid}
  Wait Until Keyword Succeeds  40 x  5 s  JQuery Ajax Should Complete
  Execute Javascript  $('a').css({display: "block"})
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/preceding-sibling::td/a[contains(@href,"ExternalExchange")]  10

Search Auction As Tender_owner
  [Arguments]  ${tender_uaid}
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton.authUser}
  Execute Javascript  $('a').css({display: "block"})
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/preceding-sibling::td[text()="Prozorro"]/preceding-sibling::td/a[contains(@href,"/Exchange/")]  10

Set Interested And Filter Auction In My Auctions
  [Arguments]  ${tender_uaid}
  Click Element  ${locator.exchangeList.ProzorroExchangesTab}
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton.authUser}
  Click Element  xpath=//*[text()="${tender_uaid}"]/../../descendant::label[@class="prozorro-synch"]
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  Wait Until Element Is Visible  xpath=//*[text()="${tender_uaid}"]/../../descendant::label[@class="prozorro-synch"]
  Click Element  ${locator.exchangeList.MyExchangesTab}
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  Reload Page
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton.authUser}

Filter Auction
  [Arguments]  ${tender_uaid}  ${search_btn_locator}
  Wait Until Keyword Succeeds  40 x  5 s  JQuery Ajax Should Complete
  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  ${locator.PageElements.LoadingImage}
  Wait Until Element Is Visible  ${search_btn_locator}
  Click Element  ${search_btn_locator}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.exchangeList.FilterTextField}
  Clear Element Text  ${locator.exchangeList.FilterTextField}
  Input Text  ${locator.exchangeList.FilterTextField}  ${tender_uaid}
  Click Element  ${locator.exchangeList.FilterSubmitButton}
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  ${locator.PageElements.LoadingImage}
  Focus  ${search_btn_locator}
  Element Should Be Visible  xpath=//td[contains(text(), ${tender_uaid})]

Search Auction If Modified
  [Arguments]  ${last_mod_date}  ${username}  ${tender_uaid}
  ${status_mod}=  Run Keyword And Return Status   Should Not Be Equal   ${KPMG_MODIFICATION_DATE}   ${last_mod_date}
  ${url}=  Get Location
  ${status_url}=  Run Keyword And Return Status  Should Contain  ${url}  /Bids/
  Run Keyword If  ${status_mod} or ${status_url}   kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Set Global Variable  ${KPMG_MODIFICATION_DATE}  ${last_mod_date}

# Refresh the page with the tender
Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Switch Browser  ${my_alias}
  Reload Page

# Get information about the tender
Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  Switch Browser  ${my_alias}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  # get value
  Run Keyword If  'startDate' in '${field_name}' or 'endDate' in '${field_name}'  Click Element  ${locator.exchangeToolbar.Bids}
  ...  ELSE IF  'status' in '${field_name}'  Reload Page
  ${value}=  Run Keyword If  'currency' in '${field_name}'  Get Text  ${locator.viewExchange.${field_name}}
  ...  ELSE IF  '${field_name}' == 'procuringEntity.name'  Get Text  ${locator.viewExchange.${field_name}}
  ...  ELSE IF  'cancellations' in '${field_name}'  Get Value  ${locator.viewExchange.${field_name.replace('[0]','')}}
  ...  ELSE IF  'awards' in '${field_name}'  Отримати інформацію про авард  ${username}  ${tender_uaid}  ${field_name}
  ...  ELSE IF  'contracts' in '${field_name}'  Отримати інформацію про контракт  ${username}  ${tender_uaid}  ${field_name}
  ...  ELSE  Get Value  ${locator.viewExchange.${field_name}}
  # post process
  ${return_value} =  post_process_field  ${field_name}  ${value}
  [Return]  ${return_value}

Отримати інформацію про авард
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  Click Element  ${locator.exchangeToolbar.Bids}
  ${award_index}=  Convert To Integer  ${field_name[7:8]}
  ${value}=  Get Text  xpath=//*[text()="Award Bidders"]/../descendant::tbody/tr[${award_index + 1}]/td[5]
  [Return]  ${value}

Отримати інформацію про контракт
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  Click Element  ${locator.exchangeToolbar.Bids}
  Click Element  xpath=//td[contains(text(),"Active")]/following-sibling::td/b[@id="unregistered-user-award-dialog"]
  Wait Modal Animation  xpath=//*[@data-test-id="public_documents"]
  ${is_contract}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@data-test-id="public_documents"]/descendant::*[contains(text(),"Contract signed")]
  ${return_value}=  Set Variable If  ${is_contract}  active  damn
  [Return]  ${return_value}

# Make changes to the tender
Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${fieldvalue}=  convert_date_to_dp_format  ${fieldvalue}  ${fieldname}
  Run Keyword If  '${fieldname}' == 'tenderAttempts'  Select From KPMG List By Data-Value  _ExchangeDetails.TenderAttempts_dropdown  ${fieldvalue}
  ...  ELSE  Input Text  ${locator.editExchange.${fieldname}}  ${fieldvalue}
  Choose File  ${locator.editExchange.clarificationDocument}  ${file_path}
  Click Element  ${locator.editExchange.SubmitButton}
  Remove File  ${file_path}


#--------------------------------------------------------------------------
#  CANCELLATION - СКАСУВАННЯ 
#--------------------------------------------------------------------------
# Cancel a tender
Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}  ${new_description}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Dismiss Exchange Rules Dialog
  Wait And Click Element  ${locator.exchangeToolbar.Admin}  10
  Wait And Click Element  ${locator.exchangeAdmin.nav.Cancel}  5
  Wait Until Element Is Visible  ${locator.exchangeAdmin.cancel.submitButton}  10
  Input Text  ${locator.exchangeAdmin.cancel.reason}  ${cancellation_reason}
  Input Text  ${locator.exchangeAdmin.cancel.date}  28/08/2017
  Choose File  ${locator.exchangeAdmin.cancel.file}  ${document}
  Click Element  ${locator.exchangeAdmin.cancel.submitButton}
  Wait And Click Element  ${locator.exchangeAdmin.cancel.confirmButton}  5
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}

#--------------------------------------------------------------------------
#  ПИТАННЯ
#--------------------------------------------------------------------------
Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}  
  Wait Until Keyword Succeeds  20 x  60 s  Run Keywords
  ...  Reload Page
  ...  AND  Wait Until Page Contains Element  ${locator.viewExchange.auctionUrl}  1
  ${url}=  Get Element Attribute  ${locator.viewExchange.auctionUrl}@href
  [Return]  ${url}

# Upload document
Завантажити документ
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${documentType}=technicalSpecifications
  Wait Until Keyword Succeeds   10 x  5 s  Run Keyword  Open Dataroom  ${username}  ${tender_uaid}
  Choose File  ${locator.Dataroom.SelectFiles}  ${filepath}
  Wait And Click Element  xpath=//*[@id="UploadDocumentTypeDropdown"]/descendant::*[@data-toggle="dropdown"][2]  10
  Wait Until Page Contains Element  ${locator.PageElements.Dropdown.Opened} 
  Wait And Click Element  xpath=//a[@data-value='${documentType.replace("tenderNotice","notice")}']  10
  Wait And Click Element  ${locator.Dataroom.UploadFileButton}  10
  Wait Until Element Is Visible  ${locator.Dataroom.UploadCompleteMessage}  30
  Wait And Click Element  ${locator.Dataroom.CloseButton}  10
  Wait Until Keyword Succeeds  180 x  2 s  Element Should Not Be Visible  ${locator.Dataroom.BusyIndicator}
  #Sleep  180s   Delay to allow KDR -> CDB file transfer queue to empty
  Capture Page Screenshot

# Upload a document in a tender with a type
Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  kpmgdealroom.Завантажити документ  ${username}  ${filepath}  ${tender_uaid}  ${doc_type}

# Upload the illustration
Завантажити ілюстрацію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  kpmgdealroom.Завантажити документ  ${username}  ${filepath}  ${tender_uaid}  illustration

#Add virtual data room
Додати Virtual Data Room
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}  ${title}=Sample Virtual Data Room
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Input Text  ${locator.editExchange.VirtualDataRoomLink}  ${vdr_url}
  Click Element  ${locator.editExchange.SubmitButton}

#Add a public passport to the asset
Додати публічний паспорт активу
  [Arguments]  ${username}  ${tender_uaid}  ${certificate_url}  ${title}=Public Asset Certificate
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Input Text  ${locator.editExchange.PublicEquityPassportLink}  ${certificate_url}
  Click Element  ${locator.editExchange.SubmitButton}

Додати офлайн документ
  [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}  ${title}=Familiarization with bank asset
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Input Text  ${locator.editExchange.AssetFamiliarizationMessage}  ${accessDetails}
  Click Element  ${locator.editExchange.SubmitButton}

# Get information from a document
Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field_name}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  Run Keyword If  'скасування' not in '${TEST_NAME}'  Run Keywords
  ...  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  ...  AND  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  ...  AND  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  ${locator.PageElements.LoadingImage}
  ${doc_value}=  Get Text  xpath=//*[contains(text(),"${doc_id}")]
  [Return]  ${doc_value}

# Get information from index document
Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  ${doc_value}=  Get Text  xpath=//*[contains(@id,"DataroomDocument")]/descendant::tbody/tr[${document_index + 1}]/td[2]
  [Return]  ${doc_value.replace("Platform Legal Details", "x_dgfPlatformLegalDetails")}

# Get a document
Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  ${file_name}=   Get Text   xpath=//*[contains(text(),"${doc_id}")]
  ${url}=   Get Element Attribute   xpath=//*[contains(text(),'${doc_id}')]@href
  kpmg_download_file   ${url}  ${file_name}  ${OUTPUT_DIR}
  [Return]  ${file_name}

# Get number of documents
Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  Wait Until Keyword Succeeds  20 x  3 s  JQuery Ajax Should Complete
  ${number_of_documents}=  Get Matching Xpath Count  ${locator.Dataroom.DocumentRaw}
  [Return]  ${number_of_documents}

# Add item to auction
Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${index}=  Get Matching Xpath Count  ${locator.editExchange.ItemBlock}
  Run Keyword And Ignore Error  Add Item  ${item}  ${index}
  Run Keyword And Ignore Error  Click Element  ${locator.addAsset.SaveButton}

# Obtain information from field
Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Search Auction If Modified  ${TENDER['LAST_MODIFICATION_DATE']}  ${username}  ${tender_uaid}
  ${value}=  Run Keyword If  '${field_name}' == 'unit.name'  Get Text  ${locator.viewExchange.item.${field_name}}
  ...  ELSE  Get Value  ${locator.viewExchange.item.${field_name}}
  ${return_value} =  post_process_field  ${field_name}  ${value}
  [Return]  ${return_value}

# remove item from auction
Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword And Ignore Error  Click Element  //*[contains(text(),"${item_id}")]/ancestor::*[contains(@id,"at-asset-container")]/descendant::*[contains(@class,"asset_delete")]
  Run Keyword And Ignore Error  Click Element  ${locator.addAsset.SaveButton}]

Отримати кількість предметів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${number_of_items}=  Get Matching Xpath Count  ${locator.editExchange.ItemBlock}
  [Return]  ${number_of_items}

#--------------------------------------------------------------------------
# QUESTIONS - СКАРГИ ТА ВИМОГИ 
#--------------------------------------------------------------------------
# Ask a question about an item
Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.FAQ}
  Wait And Click Element  xpath=//*[contains(@href,"Faq/Ask/")]  10
  Select From KPMG List By Data-Value  _QuestionOf_dropdown  2
  Click Element  xpath=//div[@id="_RelatedAssetId_dropdown"]/div[2]
  Wait Until Page Contains Element  ${locator.PageElements.Dropdown.Opened}
  Click Element  xpath=//*[@id="_RelatedAssetId_dropdown"]/descendant::a[contains(text(),"${item_id}")]
  Input Text  id=QuestionTitle  ${question.data.title}
  Input Text  id=QuestionDescription  ${question.data.description}
  Click Element  xpath=//button[@type="submit"]
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}

# Ask a question about the tender
Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.FAQ}
  Wait And Click Element  xpath=//*[contains(@href,"Faq/Ask/")]  10
  Input Text  id=QuestionTitle  ${question.data.title}
  Input Text  id=QuestionDescription  ${question.data.description}
  Click Element  xpath=//button[@type="submit"]
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}

# Get info from the question
Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.FAQ}
  Run Keyword If  '${ROLE}' == 'tender_owner'  Click Element  xpath=//a[contains(text(),"${question_id}")]
  ...  ELSE  Click If Page Contains Element  ${locator.Questions.expandButton}
  Wait Until Element Is Visible  ${locator.Questions.${field_name}}  10
  ${return_value}=  Get Text  ${locator.Questions.${field_name}}
  [Return]  ${return_value}

# Answer a question
Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.FAQ}
  Click Element  xpath=//a[contains(text(),"${question_id}")]
  Input Text  xpath=//*[contains(text(),"${question_id}")]/../descendant::*[@id="Question_Answer"]  ${answer_data.data.answer}
  Click Element  ${locator.Answers.Publish}
#  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}
   # commented on the lack of an element with class "alert-success" after form submitting

#--------------------------------------------------------------------------
#  BIDDING - 
#--------------------------------------------------------------------------
# Submit a bid
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  ${is_qualified}=  Get From Dictionary  ${bid['data']}  qualified
  Switch Browser  ${my_alias}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Bidding.InitialBiddingLink}
  Run Keyword If  'Insider' not in '${MODE}'  Input Bid Value  ${bid}
  Click Element  ${locator.Bidding.SubmitBidButton}
  Wait Until Element Is Visible  ${locator.Bidding.ConfirmBidPassword}  10
  Wait Modal Animation  ${locator.Bidding.ConfirmBidPassword}
  Input Text  ${locator.Bidding.ConfirmBidPassword}  ${USERS.users['${username}'].password}
  Click Element  ${locator.PageElements.ModalOk}
  Wait Until Keyword Succeeds  10 x  500 ms  Element Should Not Be Visible  ${locator.PageElements.ModalFadeIn}
  Click Element  ${locator.exchangeToolbar.Bids}
  Run Keyword If  '${MODE}' != 'dgfInsider'  Approve Bid  ${username}  ${tender_uaid}  ${is_qualified}
  [Return]  ${bid}

Input Bid Value
  [Arguments]  ${bid}
  ${amount}=  Convert To Integer  ${bid.data.value.amount}
  Wait until Element Is Visible  ${locator.Bidding.BiddingAmount}  10
  Input Text  ${locator.Bidding.BiddingAmount}  ${amount}

Approve Bid
  [Arguments]  ${username}  ${tender_uaid}  ${is_qualified}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=admin
  Set Window Position  @{USERS.users['${username}']['position']}
  Set Window Size      @{USERS.users['${username}']['size']}
  Switch Browser  admin
  Wait Until Element Is Visible  ${locator.login.EmailField}  10
  Input text  ${locator.login.EmailField}  Bhanu.pasham@kpmg.co.uk
  Input text  ${locator.login.PasswordField}  Admin1234
  Click Element  ${locator.login.LoginButton}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}  admin
  Run Keyword If  ${is_qualified}  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Admin.CheckBoxEligible}
  Scroll And Click  ${locator.Admin.CheckBoxQualified}
  Scroll And Click  ${locator.PageElements.SaveButton}
  Switch Browser  ${my_alias}

Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Bidding.InitialBiddingLink}
  ${bid_value}=   Get Value   id=ExternalExchangeBid_Amount
  ${return_value}=  Convert To Number  ${bid_value}
  [return]  ${return_value}

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  ${amount}=  Convert To Integer  ${fieldvalue}
  Switch Browser  ${my_alias}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Bidding.InitialBiddingLink}
  Wait until Element Is Visible  ${locator.Bidding.BiddingAmount}  10
  Input Text  ${locator.Bidding.BiddingAmount}  ${amount}
  Click Element  ${locator.Bidding.SubmitBidButton}
  Wait Until Element Is Visible  ${locator.Bidding.ConfirmBidPassword}  10
  Wait Modal Animation  ${locator.Bidding.ConfirmBidPassword}
  Input Text  ${locator.Bidding.ConfirmBidPassword}  ${USERS.users['${username}'].password}
  Click Element  ${locator.PageElements.ModalOk}
  Wait Until Keyword Succeeds  10 x  500 ms  Element Should Not Be Visible  ${locator.PageElements.ModalFadeIn}
  Click Element  ${locator.exchangeToolbar.Bids}

Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents
  Switch Browser  ${my_alias}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Bidding.InitialBiddingLink}
  Choose File  id=BidDocuments.QualificationDocument  ${path}
  Click Element  xpath=//*[@type="submit"]

Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
  kpmgdealroom.Завантажити документ в ставку  ${username}  ${path}  ${tender_uaid}

# Upload a financial license
Завантажити фінансову ліцензію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  Switch Browser  ${my_alias}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Scroll And Click  ${locator.Bidding.InitialBiddingLink}
  Choose File  ${locator.Bidding.FinancialFile}   ${filepath}
  Scroll And Click  ${locator.Bidding.UploadFilesButton}
  Approve Bid  ${username}  ${tender_uaid}  ${True}

# Cancel your bid
Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Wait And Click Element  ${locator.Bidding.InitialBiddingLink}  10
  Wait And Click Element  ${locator.Bidding.CancelBidButton}  10
  Wait And Click Element  ${locator.Bidding.CancelBidYesButton}  10
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Switch Browser  ${my_alias}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Wait Until Keyword Succeeds  20 x  60 s  Run Keywords
  ...  Reload Page
  ...  AND  Wait Until Page Contains Element  ${locator.viewExchange.auctionUrl}  1
  ${url}=  Get Element Attribute  ${locator.viewExchange.auctionUrl}@href
  [Return]  ${url}

#--------------------------------------------------------------------------
#  QUALIFICATION - 
#--------------------------------------------------------------------------

Завантажити протокол аукціону в авард
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  ${index}=  Convert To Integer  ${award_index}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Choose File  ${locator.Awarding.UploadProtocolInput}  ${filepath}
  Click Element  ${locator.Awarding.UploadFileButton}
  Click Element  ${locator.Awarding.NextStatusButton}
  Wait Until Keyword Succeeds  20 x  1 s  Page Should Contain Element  xpath=//*[@data-test-id='award-bidder-${index}']/td[contains(text(),"Payment")]
  #Page Should Contain Element  xpath=//*[@id="phasesPartial"]/descendant::tbody/tr[${index + 1}]/td[contains(text(),"Payment")]

Підтвердити наявність протоколу аукціону
  [Arguments]  ${username}  ${tender_uaid}  ${award_index}
  ${index}=  Convert To Integer  ${award_index}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Page Should Contain  Download Auction Protocol Document

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  ${index}=  Convert To Integer  ${award_num}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Click Element  ${locator.Awarding.NextStatusButton}
  Wait Until Keyword Succeeds  20 x  1 s  Page Should Contain Element  xpath=//*[@data-test-id='award-bidder-${index}']/td[contains(text(),"Active")]
  #Wait Until Keyword Succeeds  20 x  1 s  Page Should Contain Element  xpath=//*[@id="phasesPartial"]/descendant::tbody/tr[${index + 1}]/td[contains(text(),"Active")]
  

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${index}=  Convert To Integer  ${award_num}
  Signin If Logged Out  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Run Keyword And Ignore Error  Choose File  ${locator.Awarding.UploadDisqualInput}   ${file_path}
  Input Text  ${locator.Awarding.DisqualReason}  Some disqualification reason text
  Click Element  ${locator.Awarding.DisqualButton}
  Wait Until Keyword Succeeds  20 x  1 s  Page Should Contain Element  xpath=//*[@data-test-id='award-bidder-${index}']/td[contains(text(),"Unsuccessful")]
  #Wait Until Keyword Succeeds  20 x  1 s  Page Should Contain Element  xpath=//*[@id="phasesPartial"]/descendant::tbody/tr[${index + 1}]/td[contains(text(),"Unsuccessful")]
  Remove File  ${file_path}

# Cancellation of the decision of the qualification commission
Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Wait And Click Element  ${locator.Awarding.CancelAwardButton}  20
  Wait Modal Animation  ${locator.Awarding.CancelAwardDialogYes}
  Click Element  ${locator.Awarding.CancelAwardDialogYes}
  Wait Until Keyword Succeeds  30 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}


#--------------------------------------------------------------------------
#  CONTRACT SINGING - 
#--------------------------------------------------------------------------
# Confirm the signing of the contract
Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  Input Text  ${locator.Awarding.ContractNumberInput}  777
  Click Element  ${locator.Awarding.ContractNumberButton}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.Awarding.CompleteAuctionButton}
  Click Element  ${locator.Awarding.CompleteAuctionButton}
  #Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.PageElements.successActionAlert}

# Upload an agreement to the tender
Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Select From KPMG List By Data-Value  _contractType_dropdown  2
  Choose File  ${locator.Awarding.ContractUploadInput}  ${filepath}
  Click Element  ${locator.Awarding.ContractUploadButton}
