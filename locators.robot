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

# cancel exchange
${locator.exchangeAdmin.nav.Cancel}  id=leftNavLink_Cancel_Exchange
${locator.exchangeAdmin.cancel.reason}  id=Reason
${locator.exchangeAdmin.cancel.date}  id=CancellationDateHidden
${locator.exchangeAdmin.cancel.file}  id=cancellation-file-upload
${locator.exchangeAdmin.cancel.submitButton}  id=close-cancel-exchange-submit
${locator.exchangeAdmin.cancel.confirmButton}  id=closeCancelExchange-dialog-yes

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
${locator.createExchange.TypeSelector.Prozorro}             //*[@id="_TypeId_dropdown"]/descendant::*[@data-value="3"]/..
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
${locator.createExchange.dgfDecisionDateField}              DgfDecisionDateInput
${locator.createExchange.description}                       name=ExchangeDetails.Description
${locator.createExchange.tenderAttempts}                    name=ExchangeDetails.TenderAttempts   

${locator.createExchange.SubmitButton}                      id=create-exchange-submit

# edit exchange
${locator.editExchange.title}  name=Exchange.Title
${locator.editExchange.dgfId}  name=ExchangeDetails.DgfId
${locator.editExchange.dgfDecisionID}  name=ExchangeDetails.DgfDecisionId
${locator.editExchange.description}  id=description
${locator.editExchange.tenderAttempts}  name=ExchangeDetails.TenderAttempts
${locator.editExchange.SubmitButton}  //*[@value="Save"]


# add item / asset
${locator.assetDetails.items[0].title}                          xpath=(//input[@name='Assets[0].Title'])[2]
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

${locator.assetDetails.items[1].title}                          name=Assets[1].Title
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

${locator.assetDetails.items[2].title}                          name=Assets[2].Title
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
${locator.viewExchange.description}  id=description
${locator.viewExchange.title}  id=ExternalExchange_Title
${locator.viewExchange.status}  id=ExchangeDetails_Status
${locator.viewExchange.auctionID}  id=ExchangeDetails_AuctionCode

${locator.viewExchange.dgfID}  id=dgfId
${locator.viewExchange.dgfDecisionID}  id=dgfDecisionId
${locator.viewExchange.dgfDecisionDate}  id=ExchangeDetails_DgfDecisionDate
${locator.viewExchange.tenderAttempts}  id=tenderAttempts

${locator.viewExchange.value.amount}  id=startingPrice
${locator.viewExchange.legalName}
${locator.viewExchange.procurementMethodType}               xpath=//*[@for="ExchangeDetails_ProzorroCategory"]/following-sibling::input
${locator.viewExchange.minimalStep.amount}                  id=ExchangeDetails_MinimumStepValue


${locator.viewExchange.eligibilityCriteria}                 xpath= //div[2]/div/div/div/div/div[2]/div/div[3]/label[2]


#${locator.viewExchange.value.currency}                      
#${locator.viewExchange.value.valueAddedTaxIncluded}

${locator.viewExchange.procuringEntity.name}  
${locator.viewExchange.auctionPeriod.startDate}  id=ExchangeDetails_AuctionStartDate

#${locator.viewExchange.auctionPeriod.endDate}               xpath=//div[@class='form-group']/div[3]/div[1]/div[1]/input[2]
#${locator.viewExchange.tenderPeriod.startDate}              xpath=//div[@class='form-group']/div[2]/div[1]/div[1]/input[1]
#${locator.viewExchange.tenderPeriod.endDate}                xpath=//div[@class='form-group']/div[2]/div[1]/div[1]/input[2]
#${locator.viewExchange.enquiryPeriod.startDate}             xpath=//div[@class='form-group']/div[1]/div[1]/div[1]/input[1]
#${locator.viewExchange.enquiryPeriod.endDate}               xpath=//div[@class='form-group']/div[1]/div[1]/div[1]/input[2]

${locator.viewExchange.items[0].description}

# search exchange list
#${locator.exchangeList.FilterByTypeButton}  //th[@id='exchangeDashboardTypeCol']/a/span
${locator.exchangeList.Prozorro.FilterByIdButton}  //th[@id='prozorroDashboardIdCol']/a/span
${locator.exchangeList.FilterByIdButton}  //th[@id='exchangeDashboardAuctionIdCol']/a/span
${locator.exchangeList.FilterTextField}  //input[@type='text']
${locator.exchangeList.FilterSubmitButton}  //button[@type='submit']
${locator.exchangeList.FilteredFirstRow}  //*[@id='exchangeDashboardTable']/table/tbody/tr/td[1]/a
${locator.exchangeList.FilteredSecondRow}  //*[@id='exchangeDashboardTable']/table/tbody/tr[2]/td/a
${locator.exchangeList.MyExchangesTab}  //li/span[2]
${locator.exchangeList.ProzorroExchangesTab}  //li[2]/span[2]
${locator.exchangeList.ProzorroFilteredFirstRow}  //div[@id='prozorroExchangesTable']/table/tbody/tr/td[2]/a


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
${locator.Dataroom.RulesDialogYes}          id=exchangerules-dialog-yes
${locator.Dataroom.UploadSelect}            id=dataroom-upload
${locator.Dataroom.SelectFiles}             id=files
${locator.Dataroom.UploadFileButton}        //*[@id='dataroom-upload-modal-form']/div/div/div/button[2]
${locator.Dataroom.CloseButton}             id=dataroom-upload-btn-close