#------------------------------------------------------------------------------
#  QUESTIONS AND ANSWERS
#------------------------------------------------------------------------------
# Get information from questions[].title
Отримати інформацію про questions[${index}].title
    ${index}=    kpmgdealroom_service.inc    ${index}
    Wait Until Page Contains Element    id =
    ${return_value}=    Get text    id =
    [Return]    ${return_value}

# Get information from questions[].description
Отримати інформацію про questions[${index}].description
    ${index}=    kpmgdealroom_service.inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
    [Return]    ${return_value}

# Get information from questions[].answer
Отримати інформацію про questions[${index}].answer
    ${index}=    kpmgdealroom_service.inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
    [Return]    ${return_value}

# Get information from questions[].date
Отримати інформацію про questions[${index}].date
    ${index}=    kpmgdealroom_service.inc    ${index}
    Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
    ${return_value}=    Get text    xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
    ${return_value}=    convert_date_time_to_iso    ${return_value}
    [Return]    ${return_value}

# Get info from the question
Отримати інформацію із запитання
    [Arguments]    ${username}    ${tender_uaid}    ${question_id}    ${field_name}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Перейти до сторінки запитань
    ${return_value}=    Run Keyword If    '${field_name}' == 'title'    Get Text    xpath=(//span[contains(@class, 'qa_title') and contains(@class, '${item_id}')])
    ...    ELSE IF    '${field_name}' == 'answer'    Get Text    xpath=(//span[contains(@class, 'qa_answer') and contains(@class, '${item_id}')])
    ...    ELSE    Get Text    xpath=(//span[contains(@class, 'qa_description') and contains(@class, '${item_id}')])
    [Return]    ${return_value}

#------------------------------------------------------------------------------
#  PRICE OFFERS
#------------------------------------------------------------------------------
# Go to the cancellations page
Перейти до сторінки відмін
    Go To    https://proumstrade.com.ua/cancelations/index
    Wait Until Page Contains Element    id=decline-btn
    Click Element    id=decline-btn
    Wait Until Page Contains Element    id=decline-id
    
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

#------- get field data ---------




# Get information from the offer
Отримати інформацію із пропозиції
    [Arguments]    ${username}    ${tender_uaid}    ${field}
    Go To    http://proumstrade.com.ua/bids/index    ${tender_uaid}
    Wait Until Page Contains Element    id = view-btn
    Click Element    id = view-btn
    Wait Until Page Contains Element    id=bids-value-amountEnhanced bifurcated  _kdrtest
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



# Get a document
Отримати документ
    [Arguments]    ${username}    ${tender_uaid}    ${doc_id}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Element    id = update-btn
    sleep    3
    ${file_name}=    Get Text    id = doc-id
    ${url}=    Get Element Attribute    id = doc-id@name
    Upload_file    ${url}    ${file_name.split('/')[-1]}    ${OUTPUT_DIR}
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

# Upload the decision document of the qualification commission
Завантажити документ рішення кваліфікаційної комісії
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}    ${award_num}
    kpmgdealroom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
    Click Element    xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'award_docs')]//span[contains(@class, 'add_document')])
    Choose File    xpath=(//*[@id='upload_form']/input[2])    ${filepath}
    Sleep    2
    Click Element    id=upload_button
    Reload Page



# Upload an agreement to the tender
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


#=====================Teams tests=============================================
//Login as a organiser and click on exchange


//Add provider
Click Element ${locator.Addusers.Addusers}
//need to input name of the users
Input Text ${locator.Addusers.Email}  ${title}

Click Element ${locator.Addusers.AssignTeamDropdown} 
Click Element ${locator.Addusers.AssignTeamBuyer}
Click Element ${locator.Addusers.Add}

// Add provider 1
Click Element ${locator.Addusers.Addusers}
//need to input name of the users
Input Text ${locator.Addusers.Email}  ${title}

Click Element ${locator.Addusers.AssignTeamDropdown} 
Click Element ${locator.Addusers.AssignTeamBuyer}
Click Element ${locator.Addusers.Add}

#//-----------------------------------------------------------
#//    remove this section
#//ManageUsers
#Click Element ${locator.ManageUsers.ManageUsers}

#//For provider 1
#Click Element ${locator.ManageUsers.EmailFilter}
#
#//need to input name of the user  provider 1
#Input Text ${locator.ManageUsers.Name}  ${title}
#
#Click Element ${locator.ManageUsers.Filter}
#Click Element ${locator.ManageUsers.Edit} 
#
#Click Element ${locator.ManageUsers.TeamDropDown}
#Click Element ${locator.ManageUsers.Team1} 
#
#Click Element ${locator.ManageUsers.BuyerQAApprover}
#Click Element ${locator.ManageUsers.BuyerBidder}
#Click Element ${locator.ManageUsers.Save}
#
#//For provider 2
#Click Element ${locator.ManageUsers.EmailFilter}
##//to remove the text from field
#Input Text (your web element locator ) ${empty}
#
#//need to input name of the user  provider 2
#Input Text ${locator.ManageUsers.Name}  ${title}
#
#Click Element ${locator.ManageUsers.Filter}
#Click Element ${locator.ManageUsers.Edit} 
#
#Click Element ${locator.ManageUsers.TeamDropDown}
#Click Element ${locator.ManageUsers.Team2} 
#
#Click Element ${locator.ManageUsers.BuyerQAApprover}
#Click Element ${locator.ManageUsers.BuyerBidder}
#Click Element ${locator.ManageUsers.Save}
#// end section to remove
#//-----------------------------------------------------------

//Adding Users to Bids

//Adding teams to Documents submissions bid
Click Element ${locator.Bids.Bids}

Click Element ${locator.Bids.DefaultDocumentSubmission}
Click Element ${locator.Bids.EditBid}

Click Element ${locator.Bids.BuyerTeam1} 
Click Element ${locator.Bids.BuyerTeam1} 
Click Element ${locator.Bids.Save} 

//Adding teams to Initail Bid phase
Click Element ${locator.Bids.Bids}
Click Element ${locator.Bids.DefaultInitialBidPhase}
Click Element ${locator.Bids.EditBid}

Click Element ${locator.Bids.BuyerTeam1} 
Click Element ${locator.Bids.BuyerTeam1} 
Click Element ${locator.Bids.Save} 

//Set Teams Eligibility
Click Element ${locator.Bids.Bids}


//Locators
${locator.Addusers.Addusers} xpath=//ul[@id='sidebar']/li[4]/a
${locator.Addusers.Email} id=Emails
${locator.Addusers.AssignTeamDropdown} //*

[@id='_SelectedTeamId_dropdown']/div[2]

// For the link we need to provide the name of the team
${locator.Addusers.AssignTeamBuyer} link=Buyer team

${locator.Addusers.Add} id=add-users-submit
${locator.ManageUsers.ManageUsers} xpath=//ul[@id='sidebar']/li[4]/a
${locator.ManageUsers.EmailFilter} //*[@id='exchangeUsersEmailCol']/a[1]/span
${locator.ManageUsers.Email} css=.k-textbox
${locator.ManageUsers.Filter} css=.k-button.k-primary
${locator.ManageUsers.Edit} xpath=//div[@id='exchangeUsersGrid']/div[2]/table/tbody/tr[1]/td[5]/a[1]
${locator.ManageUsers.TeamDropDown} //*[@id='_teamDropdown_3_dropdown']/div[2]
//Specify the name of the team 1
${locator.ManageUsers.Team1} link=

//Specify the name of the team 2
${locator.ManageUsers.Team2} link=

${locator.ManageUsers.BuyerQAApprover} //*[@id='exchangeUsersGrid']/div[2]/table/tbody/tr[1]/td[4]/form/div[2]/div/ul/div[3]/label/span
${locator.ManageUsers.BuyerBidder} //*[@id='exchangeUsersGrid']/div[2]/table/tbody/tr[1]/td[4]/form/div[2]/div/ul/div[6]/label/span
${locator.ManageUsers.Save} xpath=//div[@id='exchangeUsersGrid']/div[2]/table/tbody/tr[1]/td[5]/a[1]


// Adding users to Bids

${locator.Bids.Bids} id=li-exchange-toolbar-bids
${locator.Bids.DefaultDocumentSubmission}  xpath=//div[@id='phasesPartial']/div[1]/table/tbody/tr[1]/td[1]/a[1] 
${locator.Bids.DefaultInitialBidPhase}  xpath=//div[@id='phasesPartial']/div[1]/table/tbody/tr[2]/td[1]/a[1]
${locator.Bids.EditBid} //*[@id='edit-bid-phase']/span
${locator.Bids.BuyerTeam1} //*[@id='form-create-bid']/div[6]/div/div[1]/label/span
${locator.Bids.BuyerTeam2} //*[@id='form-create-bid']/div[6]/div/div[2]/label/span
${locator.Bids.Save} id=save-bid-submit

${locator.Bids.Team1Eligible} //*[@id='phasesPartial']/div/form/div/table/tbody/tr[1]/td[2]/label/span
${locator.Bids.Team2Eligible} //*[@id='phasesPartial']/div/form/div/table/tbody/tr[2]/td[2]/label/span

${locator.Bids.Team1Qualified} //*[@id='phasesPartial']/div/form/div/table/tbody/tr[1]/td[3]/label/span
${locator.Bids.Team2Qualified} //*[@id='phasesPartial']/div/form/div/table/tbody/tr[2]/td[3]/label/span
${locator.Bids.ElgibilitySave} //*[@id='phasesPartial']/div/form/div/div/button
#====================================================================================


#=====================Q&A tests=============================================
//Login as a Provider and click on exchange

Click Element ${locator.Questions.Q&A}
Wait Until Page Contains Element ${locator.Questions.DraftQuestions} 10
Click Element ${locator.Questions.DraftQuestions}
Input Text ${locator.Questions.Subject} ${title}
Input Text ${locator.Questions.Question}} ${ARGUMENTS[0]}
Input Text ${locator.Questions.DocumentReference} ${ARGUMENTS[0]}
Click Element ${locator.Questions.CategoryDropdown}
Click Element ${locator.Questions.CategoryDocuments}
Click Element ${locator.Questions.PriorityDropdown}
Click Element ${locator.Questions.PriorityMedium}
Click Element ${locator.Questions.ApproveQuestion}
Click Element ${locator.Questions.Confirm}

// We should find  a way to capture the id of newly created question id
/Login as a Organiser and click on exchange
Click Element ${locator.Questions.Q&A}
Wait Until Page Contains Element ${locator.Answers.PageTitle} 10
//Click on created question
Input Text ${locator.Answers.Answer} ${title}
Click Element ${locator.Answers.Publish}


${locator.Questions.Q&A} //*[@id='li-exchange-toolbar-qanda']	
${locator.Questions.DraftQuestions} //*[@id='questionsPartial']/div/div[1]/div[2]/a[2]
${locator.Questions.Subject} id= Subject
${locator.Questions.Question} id=Question
${locator.Questions.DocumentReference} id = DocumentReference
${locator.Questions.CategoryDropdown} //*[@id='_Category_dropdown']/div[2]/i
${locator.Questions.CategoryDocuments} //*[@id='_Category_dropdown']/ul/li[3]/a
${locator.Questions.PriorityDropdown} //*[@id='_Priority_dropdown']/div[2]/i
${locator.Questions.PriorityMedium} //*[@id='_Priority_dropdown']/ul/li[2]/a
${locator.Questions.ApproveQuestion} id=question-Approved
${locator.Questions.Confirm} id=confirm-edit-yes
${locator.Answers.PageTitle} id=pageTitle
${locator.Answers.Answer} id=Answer
${locator.Answers.Publish} id=question-Published
