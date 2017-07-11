*** Settings ***
Resource    kpmgdealroom.robot

*** Variables ***
# login page
${locator.login.EmailField}                 id=Email
${locator.login.PasswordField}              id=Password
${locator.login.LoginButton}                id=login-submit

# toolbar
${locator.toolbar.CreateExchangeButton}     //li[@id='top-nav-create-exchange']/a/div/span
${locator.toolbar.LogoutButton}             id=toolbar-logout

# create exchange
${locator.createExchange.ClientSelector}    id=_ClientId_dropdown
${locator.createExchange.ClientSelectorProzorro}     //*[@id='_ClientId_dropdown']//a[contains(text(),'Prozorro')]
${locator.createExchange.Name}              id=Name
${locator.createExchange.SellerName}        id=sellerDisplayName
${locator.createExchange.SponsorEmail}      id=SponsorEmail
${locator.createExchange.AdminEmails}       id=PrincipalAdministratorEmails
${locator.createExchange.TypeSelector}      id=_TypeId_dropdown
${locator.createExchange.TypeSelectorProzorro}   //div[@id='_TypeId_dropdown']//a[contains(text(),'Prozorro')]
${locator.createExchange.StartDate}         id=AuctionStartDate
${locator.createExchange.DgfCategorySelector}   id=_ProzorroCategoryId_dropdown
${locator.createExchange.DgfCategorySelectorDgfFinancialAssets}   //div[@id='_ProzorroCategoryId_dropdown']//a[contains(text(),'dgfFinancialAssets')]
${locator.createExchange.GuaranteeAmount}   id=guaranteeAmount
${locator.createExchange.StartPrice}        id=startingPrice
${locator.createExchange.SubmitButton}      id=create-exchange-submit

# add item / asset
${locator.addAsset.items[0].description}                    xpath=(//textarea[@name='Assets[0].Description'])[2]
${locator.addAsset.items[0].quantity}                       xpath=(//input[@name='Assets[0].Quantity'])[2]
${locator.addAsset.items[0].classification.scheme}          xpath=(//input[@name='Assets[0].Classification.Scheme'])[2]
${locator.addAsset.items[0].classification.description}     xpath=(//input[@name='Assets[0].Classification.Description'])[2]
${locator.addAsset.items[0].classification.code}            xpath=(//input[@name='Assets[0].ClassificationCode'])[2]
${locator.addAsset.items[0].address1}                       xpath=(//input[@name='Assets[0].Address.AddressLineOne'])[2]
${locator.addAsset.items[0].address2}                       xpath=(//input[@name='Assets[0].Address.AddressLineTwo'])[2]
${locator.addAsset.items[0].city}                           xpath=(//input[@name='Assets[0].Address.City'])[2]
${locator.addAsset.items[0].country}                        xpath=(//input[@name='Assets[0].Address.Country'])[2]
${locator.addAsset.items[0].region}                         xpath=(//input[@name='Assets[0].Address.Region'])[2]
${locator.addAsset.items[0].postcode}                       xpath=(//input[@name='Assets[0].Address.PostCode'])[2]

${locator.addAsset.items[1].description}                    name=Assets[1].Description
${locator.addAsset.items[1].quantity}                       name=Assets[1].Quantity
${locator.addAsset.items[1].classification.scheme}          name=Assets[1].Classification.Scheme
${locator.addAsset.items[1].classification.description}     name=Assets[1].Classification.Description
${locator.addAsset.items[1].classification.code}            name=Assets[1].ClassificationCode
${locator.addAsset.items[1].address1}                       name=Assets[1].Address.AddressLineOne
${locator.addAsset.items[1].address2}                       name=Assets[1].Address.AddressLineTwo
${locator.addAsset.items[1].city}                           name=Assets[1].Address.City
${locator.addAsset.items[1].country}                        name=Assets[1].Address.Country
${locator.addAsset.items[1].region}                         name=Assets[1].Address.Region
${locator.addAsset.items[1].postcode}                       name=Assets[1].Address.PostCode

${locator.addAsset.items[2].description}                    name=Assets[2].Description
${locator.addAsset.items[2].quantity}                       name=Assets[2].Quantity
${locator.addAsset.items[2].classification.scheme}          name=Assets[2].Classification.Scheme
${locator.addAsset.items[2].classification.description}     name=Assets[2].Classification.Description
${locator.addAsset.items[2].classification.code}            name=Assets[2].ClassificationCode
${locator.addAsset.items[2].address1}                       name=Assets[2].Address.AddressLineOne
${locator.addAsset.items[2].address2}                       name=Assets[2].Address.AddressLineTwo
${locator.addAsset.items[2].city}                           name=Assets[2].Address.City
${locator.addAsset.items[2].country}                        name=Assets[2].Address.Country
${locator.addAsset.items[2].region}                         name=Assets[2].Address.Region
${locator.addAsset.items[2].postcode}                       name=Assets[2].Address.PostCode

${locator.addAsset.SaveButton}                              css=.btn.btn-default.btn-primary
${locator.addAsset.AddButton}                               id=add-asset

# view exchange information
${locator.viewExchange.title}
${locator.viewExchange.description}
${locator.viewExchange.procurementMethodType}
${locator.viewExchange.dgfID}
${locator.viewExchange.dgfDecisionID}
${locator.viewExchange.dgfDecisionDate}
${locator.viewExchange.tenderAttempts}
${locator.viewExchange.eligibilityCriteria}
${locator.viewExchange.value.amount}
${locator.viewExchange.minimalStep.amount}
${locator.viewExchange.value.currency}
${locator.viewExchange.value.valueAddedTaxIncluded}
${locator.viewExchange.tenderId}
${locator.viewExchange.procuringEntity.name}
${locator.viewExchange.auctionPeriod.startDate}
${locator.viewExchange.auctionPeriod.endDate}
${locator.viewExchange.tenderPeriod.startDate}
${locator.viewExchange.tenderPeriod.endDate}
${locator.viewExchange.enquiryPeriod.startDate}
${locator.viewExchange.enquiryPeriod.endDate}
${locator.viewExchange.status}

# search exchange list
${locator.exchangeList.FilterByIdButton}    //th[@id='exchangeDashboardIdCol']/a/span
${locator.exchangeList.FilterTextField}     //input[@type='text']
${locator.exchangeList.FilterSubmitButton}  //button[@type='submit']
${locator.exchangeList.FilteredResult}      //tr[1]/td/a

# questions and answers
${locator.Questions.Q&A}                //*[@id='li-exchange-toolbar-qanda']	
${locator.Questions.DraftQuestions}     //*[@id='questionsPartial']/div/div[1]/div[2]/a[2]
${locator.Questions.Subject}            id=Subject
${locator.Questions.Question}           id=Question
${locator.Questions.DocumentReference}  id = DocumentReference
${locator.Questions.CategoryDropdown}   //*[@id='_Category_dropdown']/div[2]/i
${locator.Questions.CategoryDocuments}  //*[@id='_Category_dropdown']/ul/li[3]/a
${locator.Questions.PriorityDropdown}   //*[@id='_Priority_dropdown']/div[2]/i
${locator.Questions.PriorityMedium}     //*[@id='_Priority_dropdown']/ul/li[2]/a
${locator.Questions.ApproveQuestion}    id=question-Approved
${locator.Questions.Confirm}            id=confirm-edit-yes
${locator.Answers.PageTitle}            id=pageTitle
${locator.Answers.Answer}               id=Answer
${locator.Answers.Publish}              id=question-Published

# file operations
${locator.Dataroom.DataRoom}            id=li-exchange-toolbar-data-room
${locator.Dataroom.Upload}              id=dataroom-upload
${locator.Dataroom.T&CYes}              id=exchangerules-dialog-yes
${locator.Dataroom.UploadSelect}        id=dataroom-upload
${locator.Dataroom.SelectFiles}         id=files
${locator.Dataroom.UploadFile}          //*[@id='dataroom-upload-modal-form']/div/div/div/button[2]
${locator.Dataroom.CloseButton}         id=dataroom-upload-btn-close


# Edwin - The below locators are from UISCE's driver.  To eventually delete...
${locator.edit.description}    id = auction-description
${locator.items[0].quantity}    id=item-quantity-1
${locator.items[0].description}    id = item-description-1
${locator.items[0].unit.code}    id = item-unit_code1
${locator.items[0].unit.name}    id = item-unit_name-1
${locator.items[0].deliveryAddress.postalCode}    id=item-postalCode1
${locator.items[0].deliveryAddress.region}    id=item-region1
${locator.items[0].deliveryAddress.locality}    id=item-locality1
${locator.items[0].deliveryAddress.streetAddress}    id=item-streetAddress1
${locator.items[0].classification.scheme}    id=tw_item_0_classification_scheme
${locator.items[0].classification.id}    id = item-classification_id1
${locator.items[0].classification.description}    id = item-classification_description1
${locator.items[0].additionalClassifications[0].scheme}    id=tw_item_0_additionalClassifications_description
${locator.items[0].additionalClassifications[0].id}    id=tew_item_0_additionalClassifications_id
${locator.items[0].additionalClassifications[0].description}    id=tw_item_0_additionalClassifications_description
${locator.items[1].description}    id = item-description-2
${locator.items[1].classification.id}    id = item-classification_id2
${locator.items[1].classification.description}    id = item-classification_description2
${locator.items[1].classification.scheme}    id=tw_item_1_classification_scheme
${locator.items[1].unit.code}    id = item-unit_code2
${locator.items[1].unit.name}    id=item-unit_name-2
${locator.items[1].quantity}    id=tew_item_1_quantity
${locator.items[2].description}    id = item-description-3
${locator.items[2].classification.id}    id = item-classification_id3
${locator.items[2].classification.description}    id = item-classification_description3
${locator.items[2].classification.scheme}    id=tw_item_2_classification_scheme
${locator.items[2].unit.code}    id = item-unit_code3
${locator.items[2].unit.name}    id = item-unit_name-3
${locator.items[2].quantity}    id=tew_item_2_quantity
${locator.questions[0].title}    id = question-title1
${locator.questions[0].description}    id=question-description1
${locator.questions[0].date}    id = question-date1
${locator.questions[0].answer}    id = question-answer1
${locator.cancellations[0].status}    id = status
${locator.cancellations[0].reason}    id = messages-notes
${locator.contracts.status}    css=.contract_status