*** Settings ***
Resource    kpmgdealroom.robot

*** Variables ***
# login page
${locator.login.EmailField}                                 id=Email
${locator.login.PasswordField}                              id=Password
${locator.login.LoginButton}                                id=login-submit

# main toolbar
${locator.toolbar.ExchangesButton}                          //*[@id='top-nav-exchange-dashboard']/a/div[2]
${locator.toolbar.CreateExchangeButton}                     //*[@id='top-nav-create-exchange']/a/div/span
${locator.toolbar.LogoutButton}                             id=toolbar-logout

# exchange toolbar
${locator.exchangeToolbar.Details}                          id=li-exchange-toolbar-assets
${locator.exchangeToolbar.DataRoom}                         id=li-exchange-toolbar-data-room
${locator.exchangeToolbar.FAQ}                              id=li-exchange-toolbar-data-faq
${locator.exchangeToolbar.Bids}                             id=li-exchange-toolbar-data-bids	
${locator.exchangeToolbar.Admin}                            id=li-exchange-toolbar-admin

# publish exchange
${locator.exchangeAdmin.nav.Publish}                        id=leftNavLink_Publish_Exchange
${locator.exchangeAdmin.publish.publishButton}              id=publish-exchange-submit
${locator.exchangeAdmin.publish.confirmButton}              id=publishExchange-dialog-yes
${locator.exchangeAdmin.publish.publishedID}                id=providerAuctionId

# team management
${locator.Admin.Admin}                                      id=li-exchange-toolbar-admin
${locator.AddTeam.AddEditTeams}                           xpath=//ul[@id='sidebar']/li[2]/a
${locator.AddTeam.AddNewteam}                               id=AddExchangeTeam
${locator.AddTeam.Name}                                     id=Name
${locator.AddTeam.Save}                                     //*[@id='SaveNewExchangeTeam']/span

# user management
${locator.Addusers.Addusers}            xpath=//ul[@id='sidebar']/li[3]/a
${locator.Addusers.Email}               id=Emails
${locator.Addusers.AssignTeamDropdown}  //*[@id='_SelectedTeamId_dropdown']/div[2]
${locator.Addusers.AssignTeamBuyer}     link=Buyer team
${locator.Addusers.Add}                 id=add-users-submit

# adding users to bids
${locator.Bids.Bids}                    id=li-exchange-toolbar-bids
${locator.Bids.Buyer1Eligible}          //div[@class='form-group']/table/tbody/tr[1]/td[2]/label/span
${locator.Bids.Buyer1Qualified}         //div[@class='form-group']/table/tbody/tr[1]/td[3]/label/span
${locator.Bids.Buyer2Eligible}          //div[@class='form-group']/table/tbody/tr[2]/td[2]/label/span
${locator.Bids.Buyer2Qualified}         //div[@class='form-group']/table/tbody/tr[2]/td[3]/label/span
${locator.Bids.Save}                    css=.btn.btn-default.btn-primary

# create exchange
${locator.createExchange.ClientSelector}                    //div[@id='_ClientId_dropdown']/div[2]
${locator.createExchange.ClientSelector.Prozorro}           //a[contains(text(),'Prozorro Entity')]
${locator.createExchange.Name}                              id=Name
${locator.createExchange.SellerName}                        id=sellerDisplayName
${locator.createExchange.SponsorEmail}                      id=SponsorEmail
${locator.createExchange.AdminEmails}                       id=PrincipalAdministratorEmails
${locator.createExchange.TypeSelector}                      //div[@id='_TypeId_dropdown']/div[2]
${locator.createExchange.TypeSelector.Prozorro}             link=Prozorro
${locator.createExchange.StartDate}                         id=AuctionStartDateInput
${locator.createExchange.StartDateField}                    AuctionStartDate
${locator.createExchange.DgfCategorySelector}               //div[@id='_ExchangeDetails.ProzorroCategory_dropdown']/div[2]/i
${locator.createExchange.DgfCategorySelector.dgfFinancialAssets}     //a[contains(text(),'dgfFinancialAssets')]
${locator.createExchange.DgfCategorySelector.dgfOtherAssets}         //a[contains(text(), 'dgfOtherAssets')]
${locator.createExchange.GuaranteeAmount}                   id=guaranteeAmount
${locator.createExchange.StartPrice}                        id=startingPrice
${locator.createExchange.MinimumStepValue}                  id=minimumStepValue

${locator.createExchange.dgfID}                             id=dgfId
${locator.createExchange.dgfDecisionID}                     name=ExchangeDetails.DgfDecisionId
${locator.createExchange.dgfDecisionDate}                   id=DgfDecisionDateInput
${locator.createExchange.dgfDecisionDateField}              DgfDecisionDate
${locator.createExchange.description}                       name=ExchangeDetails.Description
${locator.createExchange.tenderAttempts}                    name=ExchangeDetails.TenderAttempts   

${locator.createExchange.SubmitButton}                      id=create-exchange-submit

# add item / asset
${locator.assetDetails.items[0].description}                    xpath=(//input[@name='Assets[0].Description'])[2]
${locator.assetDetails.items[0].quantity}                       xpath=(//input[@name='Assets[0].Quantity'])[2]
${locator.assetDetails.items[0].classification.scheme}          xpath=(//input[@name='Assets[0].Classification.Scheme'])[2]
${locator.assetDetails.items[0].classification.description}     xpath=(//input[@name='Assets[0].Classification.Description'])[2]
${locator.assetDetails.items[0].classification.code}            xpath=(//input[@name='Assets[0].ClassificationCode'])[2]
${locator.assetDetails.items[0].address1}                       xpath=(//input[@name='Assets[0].Address.AddressLineOne'])[2]
${locator.assetDetails.items[0].address2}                       xpath=(//input[@name='Assets[0].Address.AddressLineTwo'])[2]
${locator.assetDetails.items[0].city}                           xpath=(//input[@name='Assets[0].Address.City'])[2]
${locator.assetDetails.items[0].country}                        xpath=(//input[@name='Assets[0].Address.Country'])[2]
${locator.assetDetails.items[0].region}                         xpath=(//input[@name='Assets[0].Address.Region'])[2]
${locator.assetDetails.items[0].postcode}                       xpath=(//input[@name='Assets[0].Address.PostCode'])[2]

${locator.assetDetails.items[1].description}                    name=Assets[1].Description
${locator.assetDetails.items[1].quantity}                       name=Assets[1].Quantity
${locator.assetDetails.items[1].classification.scheme}          name=Assets[1].Classification.Scheme
${locator.assetDetails.items[1].classification.description}     name=Assets[1].Classification.Description
${locator.assetDetails.items[1].classification.code}            name=Assets[1].ClassificationCode
${locator.assetDetails.items[1].address1}                       name=Assets[1].Address.AddressLineOne
${locator.assetDetails.items[1].address2}                       name=Assets[1].Address.AddressLineTwo
${locator.assetDetails.items[1].city}                           name=Assets[1].Address.City
${locator.assetDetails.items[1].country}                        name=Assets[1].Address.Country
${locator.assetDetails.items[1].region}                         name=Assets[1].Address.Region
${locator.assetDetails.items[1].postcode}                       name=Assets[1].Address.PostCode

${locator.assetDetails.items[2].description}                    name=Assets[2].Description
${locator.assetDetails.items[2].quantity}                       name=Assets[2].Quantity
${locator.assetDetails.items[2].classification.scheme}          name=Assets[2].Classification.Scheme
${locator.assetDetails.items[2].classification.description}     name=Assets[2].Classification.Description
${locator.assetDetails.items[2].classification.code}            name=Assets[2].ClassificationCode
${locator.assetDetails.items[2].address1}                       name=Assets[2].Address.AddressLineOne
${locator.assetDetails.items[2].address2}                       name=Assets[2].Address.AddressLineTwo
${locator.assetDetails.items[2].city}                           name=Assets[2].Address.City
${locator.assetDetails.items[2].country}                        name=Assets[2].Address.Country
${locator.assetDetails.items[2].region}                         name=Assets[2].Address.Region
${locator.assetDetails.items[2].postcode}                       name=Assets[2].Address.PostCode

# edit assets
${locator.addAsset.item[0].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[2]
${locator.addAsset.item[1].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[3]
${locator.addAsset.item[2].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[4]

${locator.addAsset.SaveButton}                              css=.btn.btn-default.btn-primary
${locator.addAsset.AddButton}                               id=add-asset


# view exchange information
${locator.viewExchange.title}                               id=Exchange_Title
${locator.viewExchange.description}                             id=description
${locator.viewExchange.procurementMethodType}               
${locator.viewExchange.dgfID}                               id=dgfId
${locator.viewExchange.dgfDecisionID}                       id=dgfDecisionId
${locator.viewExchange.dgfDecisionDate}                     id=DgfDecisionDate
${locator.viewExchange.tenderAttempts}                      id=tenderAttempts
${locator.viewExchange.eligibilityCriteria}
${locator.viewExchange.value.amount}                        id=startingPrice
${locator.viewExchange.minimalStep.amount}                  id=ExchangeDetails_MinimumStepValue
${locator.viewExchange.value.currency}                      
${locator.viewExchange.value.valueAddedTaxIncluded}
${locator.viewExchange.tenderId}
${locator.viewExchange.procuringEntity.name}
${locator.viewExchange.auctionPeriod.startDate}             xpath=//div[@class='form-group']/div[3]/div[1]/div[1]/input[1]
${locator.viewExchange.auctionPeriod.endDate}               xpath=//div[@class='form-group']/div[3]/div[1]/div[1]/input[2]
${locator.viewExchange.tenderPeriod.startDate}              xpath=//div[@class='form-group']/div[2]/div[1]/div[1]/input[1]
${locator.viewExchange.tenderPeriod.endDate}                xpath=//div[@class='form-group']/div[2]/div[1]/div[1]/input[2]
${locator.viewExchange.enquiryPeriod.startDate}             xpath=//div[@class='form-group']/div[1]/div[1]/div[1]/input[1]
${locator.viewExchange.enquiryPeriod.endDate}               xpath=//div[@class='form-group']/div[1]/div[1]/div[1]/input[2]
${locator.viewExchange.status}

${locator.viewExchange.items[0].description}

# search exchange list
#${locator.exchangeList.FilterByTypeButton}  //th[@id='exchangeDashboardTypeCol']/a/span
${locator.exchangeList.FilterByIdButton}    //th[@id='exchangeDashboardAuctionIdCol']/a/span
${locator.exchangeList.FilterTextField}     //input[@type='text']
${locator.exchangeList.FilterSubmitButton}  //button[@type='submit']
${locator.exchangeList.FilteredFirstRow}    //*[@id='exchangeDashboardTable']/table/tbody/tr/td[1]/a
${locator.exchangeList.FilteredSecondRow}   //*[@id='exchangeDashboardTable']/table/tbody/tr[2]/td/a

# questions and answers
${locator.Questions.DraftQuestionButton}    css=a.btn.btn-primary
${locator.Questions.Subject}                id=Subject
${locator.Questions.Question}               id=Question
${locator.Questions.SubmitQuestionButton}   //button[@type='submit']
${locator.Questions.ApproveQuestion}        id=question-Approved
${locator.Questions.Confirm}                id=confirm-edit-yes

${locator.Answers.PageTitle}                id=pageTitle
${locator.Answers.Answer}                   id=Answer
${locator.Answers.Publish}                  id=question-Published


# bidding
${locator.Bidding.UploadFilesButton}        //button[@type='submit']
${locator.Bidding.EligibilityFile}          id=BidDocuments_EligibilityDocument
${locator.Bidding.QualificationFile}        id=BidDocuments_QualificationDocument
${locator.Bidding.InitialBiddingLink}       //td/a
${locator.Bidding.BiddingAmount}            id=ExternalExchangeBid_Amount
${locator.Bidding.SubmitBidButton}          id=submit-bid-submitbtn
${locator.Bidding.ConfirmBidPassword}       id=Password
${locator.Bidding.ConfirmBidButton}         id=submit-bid-dialog-yes
${locator.Bidding.CancelBidButton}          id=submit-bid-cancelbtn
${locator.Bidding.CancelBidYesButton}       id=cancel-bid-dialog-yes

# file operations
${locator.Dataroom.DataRoom}                id=li-exchange-toolbar-data-room
${locator.Dataroom.Upload}                  id=dataroom-upload
${locator.Dataroom.T&CYes}                  id=exchangerules-dialog-yes
${locator.Dataroom.UploadSelect}            id=dataroom-upload
${locator.Dataroom.SelectFiles}             id=files
${locator.Dataroom.UploadFileButton}        //*[@id='dataroom-upload-modal-form']/div/div/div/button[2]
${locator.Dataroom.CloseButton}             id=dataroom-upload-btn-close







# Edwin - The below locators are from UISCE's driver.  To eventually delete...
${locator.edit.description}                 id = auction-description
${locator.items[0].quantity}                id=item-quantity-1
${locator.items[0].description}             id = item-description-1
${locator.items[0].unit.code}               id = item-unit_code1
${locator.items[0].unit.name}               id = item-unit_name-1
${locator.items[0].deliveryAddress.postalCode}    id=item-postalCode1
${locator.items[0].deliveryAddress.region}  id=item-region1
${locator.items[0].deliveryAddress.locality}    id=item-locality1
${locator.items[0].deliveryAddress.streetAddress}    id=item-streetAddress1
${locator.items[0].classification.scheme}   id=tw_item_0_classification_scheme
${locator.items[0].classification.id}       id = item-classification_id1
${locator.items[0].classification.description}    id = item-classification_description1
${locator.items[0].additionalClassifications[0].scheme}    id=tw_item_0_additionalClassifications_description
${locator.items[0].additionalClassifications[0].id}    id=tew_item_0_additionalClassifications_id
${locator.items[0].additionalClassifications[0].description}    id=tw_item_0_additionalClassifications_description
${locator.items[1].description}             id = item-description-2
${locator.items[1].classification.id}       id = item-classification_id2
${locator.items[1].classification.description}    id = item-classification_description2
${locator.items[1].classification.scheme}   id=tw_item_1_classification_scheme
${locator.items[1].unit.code}               id = item-unit_code2
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