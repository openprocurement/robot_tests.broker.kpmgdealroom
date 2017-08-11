*** Settings ***
Library  String
Library  Selenium2Library
Library  Collections
Library  kpmgdealroom_service.py

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

Wait And Click Element
  [Arguments]  ${locator}  ${delay}
  Wait Until Element Is Visible  ${locator}  ${delay}
  Click Element  ${locator}

JQuery Ajax Should Complete
  ${active}=  Execute Javascript  return jQuery.active
  Should Be Equal  "${active}"  "0"

Setup Team
  [Arguments]  ${team_name}  ${team_user}
  Click Element  ${locator.exchangeToolbar.Admin} 
  Click Element  ${locator.AddTeam.AddEditTeams}
  Click Element  ${locator.AddTeam.AddNewTeam}
  Input Text  ${locator.AddTeam.Name}  ${team_name}
  Click Element  ${locator.AddTeam.Save}
  Click Element  ${locator.Addusers.Addusers}
  Input Text  ${locator.Addusers.Email}  ${team_user}
  Click Element  ${locator.Addusers.AssignTeamDropdown}  
  Click Element  link=${team_name}
  Click Element  ${locator.Addusers.Add}

Setup User Bids
  Click Element  ${locator.Bids.Bids}
  Wait Until Page Contains Element  ${locator.Bids.Buyer1Eligible}  10
  Click Element  ${locator.Bids.Buyer1Eligible}
  Click Element  ${locator.Bids.Buyer1Qualified}
  Click Element  ${locator.Bids.Buyer2Eligible}
  Click Element  ${locator.Bids.Buyer2Qualified}
  Click Element  ${locator.Bids.Save}

Add Item
  [Arguments]  ${item}  ${index}
  Run Keyword If  ${index} != 0  Click Element  ${locator.addAsset.AddButton} 
  Wait Until Element Is Visible  ${locator.assetDetails.items.description}  20
  Input Text  ${locator.assetDetails.items.description}  ${item.description}
  Input Text  ${locator.assetDetails.items.quantity}  ${item.quantity}
  Click Element  xpath=//*[@id="_AssetUnit${index}_dropdown"]/div[2]
  Click Element  xpath=//*[@id="_AssetUnit${index}_dropdown"]/descendant::a[@data-value="${item.unit.code}"]
  Input Text  ${locator.assetDetails.items.classification.description}  ${item.classification.description}
  Input Text  ${locator.assetDetails.items.classification.code}  ${item.classification.id}
  Input Text  ${locator.assetDetails.items.address1}  ${item.deliveryAddress.streetAddress}
  Input Text  ${locator.assetDetails.items.region}  ${item.deliveryAddress.region}
  Input Text  ${locator.assetDetails.items.city}  ${item.deliveryAddress.locality}
  Input Text  ${locator.assetDetails.items.country}  ${item.deliveryAddress.countryName_en}
  Input Text  ${locator.assetDetails.items.postcode}  ${item.deliveryAddress.postalCode}

#------------------------------------------------------------------------------
#  LOT OPERATIONS - СТВОРЕННЯ ТЕНДЕРУ
#------------------------------------------------------------------------------

# Prepare client for user
Підготувати клієнт для користувача
  [Arguments]  ${username}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'kpmgdealroom_Viewer'  Login  ${username}

# Prepare data for tender announcement
Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=  kpmgdealroom_service.adapt_tender_data  ${tender_data}
  [Return]  ${tender_data}

# Create a tender (KDR-1072)
Створити тендер
  [Arguments]  ${username}  ${tender_data}
  ${procurementMethodType}=  Get From Dictionary  ${tender_data.data}  procurementMethodType
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  ${number_of_items}=  Get Length  ${items}
  ${guarantee}=  convert_number_to_currency_str  ${tender_data.data.guarantee.amount}
  ${budget}=  convert_number_to_currency_str  ${tender_data.data.value.amount}
  ${step_rate}=  convert_number_to_currency_str  ${tender_data.data.minimalStep.amount}
  ${dp_auction_start_date}=  convert_date_to_dp_format  ${tender_data.data.auctionPeriod.startDate}
  ${dp_dgf_decision_date}=  convert_date_to_dp_format  ${tender_data.data.auctionPeriod.startDate}
  Switch Browser  ${username}
  Wait And Click Element  ${locator.toolbar.CreateExchangeButton}  5
  Wait And Click Element  ${locator.createExchange.ClientSelector}  5
  Wait Until Element Is Visible  ${locator.createExchange.ClientSelector.Prozorro}  2
  Click Element  ${locator.createExchange.ClientSelector.Prozorro}
  Wait Until Keyword Succeeds  10 x  1 s  JQuery Ajax Should Complete
  Input Text  ${locator.createExchange.Name}  ${tender_data.data.title}
  Input Text  ${locator.createExchange.SponsorEmail}  ${USERS.users['${username}'].login}
  Input Text  ${locator.createExchange.AdminEmails}  ${USERS.users['${username}'].login}
  Execute Javascript  window.scroll(2500,2500);
  Click Element  ${locator.createExchange.TypeSelector}
  Wait Until Page Contains Element  xpath=//*[contains(@class, "dropdown") and contains(@class, "open")]
  Click Element  ${locator.createExchange.TypeSelector.Prozorro}
  Wait Until Element Is Visible  ${locator.createExchange.StartDate}  2
  Input Text  id=AuctionStartDateInput  ${dp_auction_start_date}
  Click Element  xpath=//*[@id="ExchangeDetails.ProzorroCategory"]/descendant::*[@data-toggle="dropdown"][2]
  Wait Until Page Contains Element  xpath=//*[contains(@class, "dropdown") and contains(@class, "open")]
  Wait And Click Element  xpath=//a[contains(text(),'dgfFinancialAssets')]  5
  Input Text  ${locator.createExchange.GuaranteeAmount}  ${guarantee}
  Input Text  ${locator.createExchange.StartPrice}  ${budget}
  Run Keyword If  ${tender_data.data.value.valueAddedTaxIncluded}  Select Checkbox  name=ExchangeDetails.VatIncluded
  Input Text  ${locator.createExchange.MinimumStepValue}  ${step_rate}
  Input Text  ${locator.createExchange.dgfID}  ${tender_data.data.dgfID}
  Input Text  ${locator.createExchange.dgfDecisionID}  ${tender_data.data.dgfDecisionID}
  Input Text  id=DgfDecisionDateInput  ${dp_dgf_decision_date}
  Input Text  ${locator.createExchange.description}  ${tender_data.data.description}
  Input Text  ${locator.createExchange.tenderAttempts}  ${tender_data.data.tenderAttempts}
  Click Element  ${locator.createExchange.SubmitButton}
  Wait And Click Element  ${locator.Dataroom.RulesDialogYes}  20
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
  Filter Auction  ${auction_id}  ${locator.exchangeList.FilterByIdButton}
  ${status}=  Get Text  xpath=//*[@id='exchangeDashboardTable']/table/tbody/tr[2]/td[3]
  Should Be Equal  ${expected_status}  ${status}

# Search for a bid identifier (KDR-1077)
Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  Switch Browser  ${username}
  Go to  ${USERS.users['${username}'].default_page}
  Run Keyword  Search Auction As ${ROLE}  ${tender_uaid}
  Wait And Click Element  ${locator.exchangeToolbar.Details}  5

Search Auction As Viewer
  [Arguments]  ${tender_uaid}
  Filter Auction  ${tender_uaid}  xpath=//*[contains(@id,"IdCol")]/a[contains(@class,"k-grid-filter")]
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/following-sibling::td/a[contains(@href,"/ExternalExchangeDetails/")]  10

Search Auction As Provider1
  [Arguments]  ${tender_uaid}
  ${status}=  Run Keyword And Return Status  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton}
  Run Keyword If  not ${status}  Set Interested And Filter Auction In My Auctions   ${tender_uaid}
  Wait Until Keyword Succeeds  20 x  2 s  JQuery Ajax Should Complete
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/preceding-sibling::td/a[contains(@href,"ExternalExchange")]  10

Search Auction As Tender_owner
  [Arguments]  ${tender_uaid}
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton}
  Wait And Click Element  xpath=//*[text()="${tender_uaid}"]/preceding-sibling::td[text()="Prozorro"]/preceding-sibling::td/a[contains(@href,"/Exchange/")]  10

Set Interested And Filter Auction In My Auctions
  [Arguments]  ${tender_uaid}
  Click Element  ${locator.exchangeList.ProzorroExchangesTab}
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton}
  Click Element  xpath=//*[text()="${tender_uaid}"]/../../descendant::label[@class="prozorro-synch"]
  Wait Until Keyword Succeeds  20 x  2 s  JQuery Ajax Should Complete
  Click Element  xpath=//*[@aria-controls="exchangesTabStrip-1"]
  Wait Until Keyword Succeeds  20 x  2 s  JQuery Ajax Should Complete
  Filter Auction  ${tender_uaid}  ${locator.exchangeList.FilterByIdButton}

Filter Auction
  [Arguments]  ${tender_uaid}    ${search_btn_locator}
  Wait Until Keyword Succeeds  20 x  2 s  JQuery Ajax Should Complete
  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  css=div.k-loading-image
  Wait Until Element Is Visible  ${search_btn_locator}
  Click Element  ${search_btn_locator}
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator.exchangeList.FilterTextField}
  Input Text  ${locator.exchangeList.FilterTextField}  ${tender_uaid}
  Click Element  ${locator.exchangeList.FilterSubmitButton}
  Wait Until Keyword Succeeds  20 x  2 s  JQuery Ajax Should Complete
  Wait Until Keyword Succeeds  20 x  1 s  Element Should Not Be Visible  css=div.k-loading-image
  Page Should Contain  ${tender_uaid}

# Refresh the page with the tender
Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Reload Page

# Get information about the tender
Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  # get value
  Run Keyword If  'startDate' in '${field_name}' or 'endDate' in '${field_name}'  Click Element  xpath=//*[contains(@href,"Bids/")]
  ${value}=  Run Keyword If  'currency' in '${field_name}'  Get Text  ${locator.viewExchange.${field_name}}
  ...  ELSE IF  '${field_name}' == 'procuringEntity.name'  Get Text  ${locator.viewExchange.${field_name}}
  ...  ELSE  Get Value  ${locator.viewExchange.${field_name}}
  # post process
  ${return_value} =  post_process_field  ${field_name}  ${value}
  [Return]  ${return_value}

# Make changes to the tender
Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  Search KDR Auction  ${username}  ${tender_uaid}
  Run Keyword If  "dgfDecisionDate" not in "${fieldname}"
  ...  Input Text  ${locator.editExchange.${fieldname}}  ${fieldvalue}
  ...  ELSE  Input Date  DgfDecisionDate  ${fieldvalue}
  Click Element  ${locator.editExchange.SubmitButton}

### Get the number of documents in the tender
Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait and Click Element  xpath=//*[contains(@href, "/DataRoom/")]  5
  ${tender_doc_number}=  Get Matching Xpath Count  xpath=(//*[@id='externalDataroomDocumentPaneGrid']/table/tbody)
  [Return]  ${tender_doc_number}

#--------------------------------------------------------------------------
#  CANCELLATION - СКАСУВАННЯ 
#--------------------------------------------------------------------------
# Cancel a tender
Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}  ${new_description}
  Search KDR Auction  ${username}  ${tender_uaid}
  Wait And Click Element  ${locator.Dataroom.RulesDialogYes}  20
  Click Element  ${locator.exchangeToolbar.Admin}
  Wait And Click Element  ${locator.exchangeAdmin.nav.Cancel}  5
  Wait Until Element Is Visible  ${locator.exchangeAdmin.cancel.submitButton}  10
  Input Date  ${locator.exchangeAdmin.cancel.date} 
  Choose File  ${locatorexchangeAdming.cancel.file}  ${document}
  Click Element  ${locator.exchangeAdmin.cancel.submitButton}
  Wait And Click Element  ${locator.exchangeAdmin.cancel.confirmButton}  5

#--------------------------------------------------------------------------
#  ПИТАННЯ
#--------------------------------------------------------------------------
Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Sleep  120
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${url}=  Get Element Attribute  xpath=//a[contains(@href,"/auctions/")]
  [return]  ${url}

# Upload document
Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]  ${ARGUMENTS[0]} == username
  ...  ${ARGUMENTS[1]} == ${filepath}
  ...  ${ARGUMENTS[2]} == ${TENDER}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Wait And Click Element  ${locator.Dataroom.Dataroom}  10
  Click Element  ${locator.Dataroom.RulesDialogYes}
  Wait And Click Element  ${locator.Dataroom.UploadIcon}  10
  Click Element  ${locator.Dataroom.SelectFiles}
  Input Text  ${locator.Dataroom.SelectFiles}  ${ARGUMENTS[1]}
  # TODO : Select file type: Document
  Click Element  ${locator.Dataroom.UploadFileButtond}
  Sleep  2
  Reload Page

# Upload a document in a tender with a type
Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element  id = update-btn
  Click Element  id=update-btn
  Select From List By Value  id = files-type  ${doc_type}
  Choose File  css = div.file-caption-name  ${filepath}
  Sleep  2
  Click Element  id=upload_button

# Upload the illustration
Завантажити ілюстрацію
  [Arguments]  @{ARGUMENTS}
  [Documentation]  ${ARGUMENTS[0]} == username
  ...  ${ARGUMENTS[1]} == \ ${filepath}
  ...  ${ARGUMENTS[2]} == ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Wait Until Page Contains Element  id = update-btn
  Click Element  id=update-btn
  Select From List By Value  id = files-type  6
  Choose File  id = auction-file  ${ARGUMENTS[1]}
  Sleep  2
  Click Element  id=upload_button
  Reload Page

# Upload the auction protocol
Завантажити протокол аукціону
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element  xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element  id=btnShowBid
  Sleep  1
  Wait Until Page Contains Element  xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element  id=btn_documents_add
  Select From List By Value  id=slFile_documentType  auctionProtocol
  Choose File  xpath=(//*[@id='upload_form']/input[2])  ${filepath}
  Sleep  2
  Click Element  id=upload_button

#Add virtual data room
Додати Virtual Data Room
  [Arguments]  @{ARGUMENTS}
  [Documentation]  ${ARGUMENTS[0]} == username
  ...  ${ARGUMENTS[1]} == tenderId
  ...  ${ARGUMENTS[2]} == ${vdr_url}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Wait Until Page Contains Element  id = update-btn
  Click Element  id=update-btn
  Select From List By Value  id = files-type  10
  Choose File  id = auction-file  ${ARGUMENTS[1]}
  Sleep  2
  Click Element  id=upload_button
  Reload Page

#Add a public passport to the asset
Додати публічний паспорт активу
  [Arguments]  @{ARGUMENTS}
  [Documentation]  ${ARGUMENTS[0]} == username
  ...  ${ARGUMENTS[1]} == tenderId
  ...  ${ARGUMENTS[2]} == ${vdr_url}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Wait Until Page Contains Element  id = update-btn
  Click Element  id=update-btn
  Select From List By Value  id = files-type  2
  Choose File  id = auction-file  ${ARGUMENTS[1]}
  Sleep  2
  Click Element  id=upload_button
  Reload Page

Додати офлайн документ
  [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}  ${title}=Familiarization with bank asset
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Клікнути по елементу  xpath=//a[contains(text(),'Редагувати')]
  Execute Javascript  $(".topFixed").remove(); $(".bottomFixed").remove();
  Клікнути по елементу  xpath=//h3[contains(text(),'Документація до лоту')]/following-sibling::a
  Клікнути по елементу  xpath=//a[@data-upload="accessDetails"]
  Ввести текст  name=accessDetails  ${accessDetails}
  Клікнути по елементу  xpath=//button[@class="bidAction"]
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  xpath=//button[@class="bidAction"]
  Клікнути по елементу  name=do
  Wait Until Element Is Not Visible  xpath=/html/body[@class="blocked"]

# Get information from a document
Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field_name}
  ${doc_value}=  Get Text  id = doc_id
  [Return]  ${doc_value}

# Get information from index document
Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${doc_value}=  Get Text  id = doc_id
  [Return]  ${doc_value}

# Get a document
Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  id = update-btn
  sleep  3
  ${file_name}=  Get Text  id = doc-id
  ${url}=  Get Element Attribute  id = doc-id@name
  Upload_file  ${url}  ${file_name.split('/')[-1]}  ${OUTPUT_DIR}
  [Return]  ${file_name.split('/')[-1]}

# Add item to auction
Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${index}=  Get Matching Xpath Count  //*[@id="AssetList"]/descendant::*[contains(@id,"at-asset-container")]
  Run Keyword And Ignore Error  Add Item  ${item}  ${index}
  Run Keyword And Ignore Error  Click Element  ${locator.addAsset.SaveButton}

# Obtain information from field
Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
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
  ${number_of_items}=  Get Matching Xpath Count  //div[@class="tenderItemElement"]
  [return]  ${number_of_items}

#--------------------------------------------------------------------------
# QUESTIONS - СКАРГИ ТА ВИМОГИ 
#--------------------------------------------------------------------------
# Ask a question about an item
Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Задати питання  ${username}  ${tender_uaid}  ${question}

# Ask a question about the tender
Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Задати питання  ${username}  ${tender_uaid}  ${question}

# Get info from the question
Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(@href,"Question") or contains(@href,"/Faq/")]
  Click Element  xpath=//a[contains(text(),"${question_id}")]
  ${return_value}=  Get Text  ${locator.Questions.${field_name}}
  [Return]  ${return_value}

# Answer a question
Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(@href,"Question")]
  Click Element  xpath=//a[contains(text(),"${question_id}")]
  Input Text  xpath=//*[contains(text(),"${question_id}")]/../descendant::*[@id="Question_Answer"]  ${answer_data.data.answer}
  Click Element  xpath=//button[@type="submit"]
  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[contains(@class,"alert-success")]

#--------------------------------------------------------------------------
#  BIDDING - 
#--------------------------------------------------------------------------
# Submit a bid
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  ${amount}=  add_second_sign_after_point  ${bid.data.value.amount}
  ${eligibilityDocPath}=  get_upload_file_path  eligibility.doc
  ${qualificationDocPath}=  get_upload_file_path  qualification.doc

  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Wait Until Element Is Visible  ${locator.Bidding.UploadFilesButton}  10
  Choose File  ${locator.Bidding.EligibilityFile}  kpmgdealroom_service.get_upload_file_path  eligibility.doc
  Choose File  ${locator.Bidding.QualificationFile}  kpmgdealroom_service.get_upload_file_path  qualification.doc
  Click Element  ${locator.Bidding.SubmitFilesButton}
  Sleep  20
  Click Element  ${locator.Bidding.InitialBiddingLink}
  Wait until Element Is Visible  ${locator.Bidding.BiddingAmount}  10
  Input Text  ${locator.Bidding.BiddingAmount}  ${amount}
  Click Element  ${locator.Bidding.SubmitBidButton}
  Wait Until Element Is Visible  ${locator.Bidding.ConfirmBidPassword}  10
  Input Text  Admin1234
  Click Element  ${locator.Bidding.ConfirmBidButton}
  Wait Until Page Contains  ${locator.Bidding.CancelBidButton}
  [return]  ${bid}

# Change bid proposal
Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]  ${ARGUMENTS[0]} == ${test_bid_data}
  ${amount}=  get_str  ${ARGUMENTS[0].data.value.amount}
  Go To  https://proumstrade.com.ua/bids/index
  Wait Until Page Contains Element  id= update-bids-btn
  Click Element  id= update-bids-btn
  sleep  3s
  Input Text  id=bids-value_amount  ${amount}
  Click Element  id= update-bid-btn

# Cancel your bid
Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  ${locator.exchangeToolbar.Bids}
  Sleep  20
  Wait And Click Element  ${locator.Bidding.InitialBiddingLink} 5
  Wait And Click Element  ${locator.Bidding.CancelBidButton} 10
  Wait And Click Element  ${locator.Bidding.CancelBidYesButton} 5
  Wait Until Element Is Visible  ${locator.Bidding.SubmitBidButton}

# Upload a financial license
Завантажити фінансову ліцензію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  kpmgdealroom.Завантажити документ в ставку  ${username}  ${filepath}  ${tender_uaid}

Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
  kpmgdealroom.Завантажити документ в ставку  ${username}  ${path}  ${tender_uaid}

# Get information from the offer
Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  Go To  http://proumstrade.com.ua/bids/index  ${tender_uaid}
  Wait Until Page Contains Element  id = view-btn
  Click Element  id = view-btn
  Wait Until Page Contains Element  id=bids-value-amountEnhanced bifurcated  _kdrtest
  ${value}=  Get Value  id=bids-value_amount
  ${value}=  Convert To Number  ${value}
  [Return]  ${value}

Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
#  Дочекатись синхронізації з майданчиком  ${username}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds  15 x  1 m  Run Keywords
  ...  Reload Page
  ...  AND  Execute Javascript  $(".topFixed").remove(); $(".bottomFixed").remove();
  ...  AND  Клікнути по елементу  xpath=//preceding-sibling::div[text()='На розгляді']/following-sibling::div/descendant::span[text()='Пропозиція']
  Wait Until Element Is Visible  xpath=//tr[@class="line docItem documents_url_documents"]
  ${bid_doc_number}=  Get Matching Xpath Count  //tr[@class="line docItem documents_url_documents"]
  [return]  ${bid_doc_number}

# Obtain data from the proposal document
Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  ${document_index}=  inc  ${document_index}
  ${result}=  Get Text  xpath=(//*[@id='pnAwardList']/div[last()]/div/div[1]/div/div/div[2]/table[${document_index}]//span[contains(@class, 'documentType')])
  [Return]  ${result}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Клікнути по елементу  xpath=//a[@class="reverse getAuctionUrl"]
  Wait Until Page Contains Element  xpath=//a[contains(text(),"Перейдіть до аукціону")]
  ${url}=  Get Element Attribute  xpath=//a[contains(text(),"Перейдіть до аукціону")]@href
  [return]  ${url}

#--------------------------------------------------------------------------
#  QUALIFICATION - 
#--------------------------------------------------------------------------
# Upload the decision document of the qualification commission
Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${award_num}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element  xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element  xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'award_docs')]//span[contains(@class, 'add_document')])
  Choose File  xpath=(//*[@id='upload_form']/input[2])  ${filepath}
  Sleep  2
  Click Element  id=upload_button
  Reload Page

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds  15 x  1 m  Run Keywords
  ...  Reload Page
  ...  AND  Execute Javascript  $(".topFixed").remove(); $(".bottomFixed").remove();
  ...  AND  Клікнути по елементу  xpath=//a[@data-bid-action="protocol"]
  Підтвердити дію
  Wait Until Page Contains  Підтвердження протоколу
  Wait Until Keyword Succeeds  10 x  30 s  Run Keywords
  ...  Reload Page
  ...  AND  Execute Javascript  $(".topFixed").remove(); $(".bottomFixed").remove();
  ...  AND  Клікнути по елементу  xpath=//a[@data-bid-action="paid"]
  Підтвердити дію
  Wait Until Element Is Not Visible  xpath=/html/body[@class="blocked"]
  Wait Until Page Contains  оплату отримано

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  Execute Javascript  $(".message").scrollTop(1000)
  Клікнути по елементу  xpath=(//label[@class="relative inp empty"])[2]
  Ввести текст  name=data[description]  ${description}
  Capture Page Screenshot
  Клікнути по елементу  xpath=//button[@class="bidAction"]
  Capture Page Screenshot
  Підтвердити дію
  Wait Until Element Is Not Visible  xpath=/html/body[@class="blocked"]
  Wait Until Keyword Succeeds  20 x  60 s  Дочекатися дискваліфікації учасника

# Cancellation of the decision of the qualification commission
Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element  xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])
  Sleep  1
  Click Element  xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])

#--------------------------------------------------------------------------
#  CONTRACT SINGING - 
#--------------------------------------------------------------------------
# Confirm the signing of the contract
Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  ${file_path}  ${file_title}  ${file_content}=  create_fake_doc
  Sleep  5
  kpmgdealroom.Завантажити угоду до тендера  ${username}  ${tender_uaid}  1  ${filepath}
  Wait Until Page Contains Element  xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element  xpath=(//*[@id='pnAwardList']/div[last()]//span[contains(@class, 'contract_register')])

# Upload an agreement to the tender
Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
  kpmgdealroom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element  xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element  xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'contract_docs')]//span[contains(@class, 'add_document')])
  Select From List By Value  id=slFile_documentType  contractSigned
  Choose File  xpath=(//*[@id='upload_form']/input[2])  ${filepath}
  Sleep  2
  Click Element  id=upload_button
  Reload Page
