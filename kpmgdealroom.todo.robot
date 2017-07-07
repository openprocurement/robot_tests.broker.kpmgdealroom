
# Upload document
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

# Go to the questions page
Перейти до сторінки запитань
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    kpmgdealroom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id = auction-view-btn
    Click Element    id = tab-2
    Wait Until Page Contains Element    id= create-question-btn


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



#------- get field data ---------


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