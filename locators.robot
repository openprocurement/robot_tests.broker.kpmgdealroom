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
${locator.exchangeAdmin.nav.Publish}                        xpath=//*[contains(@href,"/Exchange/Admin/Publish")]
${locator.exchangeAdmin.publish.publishButton}              id=publish-exchange-submit
${locator.exchangeAdmin.publish.confirmButton}              id=publishExchange-dialog-yes
${locator.exchangeAdmin.publish.publishedID}                id=providerAuctionId

# cancel exchange
${locator.exchangeAdmin.nav.Cancel}  id=leftNavLink_Cancel_Exchange
${locator.exchangeAdmin.cancel.reason}  id=Reason
${locator.exchangeAdmin.cancel.date}  id=CancellationDate
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
${locator.createExchange.ClientSelector.Prozorro}           //a[text()='Prozorro Seller Entity']
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
${locator.createExchange.MinimumStepValue}                  xpath=//input[contains(@id,"inimumStepValue")]

${locator.createExchange.dgfID}                             id=dgfId
${locator.createExchange.dgfDecisionID}                     name=ExchangeDetails.DgfDecisionId
${locator.createExchange.dgfDecisionDate}                   id=DgfDecisionDateInput
${locator.createExchange.dgfDecisionDateField}              DgfDecisionDateInput
${locator.createExchange.description}                       name=ExchangeDetails.Description
${locator.createExchange.tenderAttempts}                    name=_ExchangeDetails.TenderAttempts   

${locator.createExchange.SubmitButton}                      id=create-exchange-submit

# edit exchange
${locator.editExchange.title}  name=Exchange.Title
${locator.editExchange.dgfId}  name=ExchangeDetails.DgfId
${locator.editExchange.dgfDecisionID}  name=ExchangeDetails.DgfDecisionId
${locator.editExchange.dgfDecisionDate}  id=DgfDecisionDateInput
${locator.editExchange.description}  id=description
${locator.editExchange.tenderAttempts}  name=ExchangeDetails.TenderAttempts
${locator.editExchange.SubmitButton}  //*[@value="Save"]


# add item / asset
${index}
${locator.assetDetails.items.title}                          xpath=(//input[@name='Assets[${index}].Title'])[last()]
${locator.assetDetails.items.description}                    xpath=(//input[@name='Assets[${index}].Description'])[last()]
${locator.assetDetails.items.quantity}                       xpath=(//input[@name='Assets[${index}].Quantity'])[last()]
${locator.assetDetails.items.classification.scheme}          xpath=(//input[@name='Assets[${index}].Classification.Scheme'])[last()]
${locator.assetDetails.items.classification.description}     xpath=(//input[@name='Assets[${index}].Classification.Description'])[last()]
${locator.assetDetails.items.classification.code}            xpath=(//input[@name='Assets[${index}].ClassificationCode'])[last()]
${locator.assetDetails.items.address1}                       xpath=(//input[@name='Assets[${index}].Address.AddressLineOne'])[last()]
${locator.assetDetails.items.address2}                       xpath=(//input[@name='Assets[${index}].Address.AddressLineTwo'])[last()]
${locator.assetDetails.items.city}                           xpath=(//input[@name='Assets[${index}].Address.City'])[last()]
${locator.assetDetails.items.country}                        xpath=(//input[@name='Assets[${index}].Address.Country'])[last()]
${locator.assetDetails.items.region}                         xpath=(//input[@name='Assets[${index}].Address.Region'])[last()]
${locator.assetDetails.items.postcode}                       xpath=(//input[@name='Assets[${index}].Address.PostCode'])[last()]
${locator.assetDetails.items.unit.code}                      xpath=(//input[@name='Assets[${index}].Unit'])[last()]


# edit assets
${locator.addAsset.item[0].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[2]
${locator.addAsset.item[1].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[3]
${locator.addAsset.item[2].delete}                          xpath=(//div[@id='at-asset-container-0']/a)[4]

${locator.addAsset.SaveButton}                              css=.btn.btn-default.btn-primary
${locator.addAsset.AddButton}                               id=add-asset

# view exchange information
${locator.viewExchange.description}  id=description
${locator.viewExchange.title}  id=ExternalExchange_Title
${locator.viewExchange.status}  //*[@for="ExchangeDetails_Status"]/following-sibling::input
${locator.viewExchange.auctionID}  id=ExchangeDetails_AuctionCode

${locator.viewExchange.dgfID}  id=dgfId
${locator.viewExchange.dgfDecisionID}  id=dgfDecisionId
${locator.viewExchange.dgfDecisionDate}  id=ExchangeDetails_DgfDecisionDate
${locator.viewExchange.tenderAttempts}  id=tenderAttempts

${locator.viewExchange.value.amount}  id=startingPrice
${locator.viewExchange.legalName}
${locator.viewExchange.procurementMethodType}  xpath=//*[@for="ExchangeDetails_ProzorroCategory"]/following-sibling::input
${locator.viewExchange.minimalStep.amount}  xpath=//input[contains(@id,"inimumStepValue")]

${locator.viewExchange.eligibilityCriteria}  xpath=//div[2]/div/div/div/div/div[2]/div[1]/div[7]/label[2]
${locator.viewExchange.value.currency}  xpath=//*[text()="Currency"]/following-sibling::label
${locator.viewExchange.value.valueAddedTaxIncluded}  id=vatIncluded

${locator.viewExchange.procuringEntity.name}  xpath=//div[2]/div/div/div/div/div[2]/div[2]

# auction dates on bids page
${locator.viewExchange.auctionPeriod.startDate}  id=auctionPeriodStart

${award_index}
${locator.viewExchange.award.status}  xpath=//*[text()="Award Bidders"]/following-sibling::table/tbody/tr[${award_index}]/td[5]

# auction dates on bids page
${locator.viewExchange.auctionPeriod.startDate}  id=auctioPeriodStart
${locator.viewExchange.auctionPeriod.endDate}  id=auctionPeriodEnd
${locator.viewExchange.tenderPeriod.startDate}  id=tenderPeriodStart
${locator.viewExchange.tenderPeriod.endDate}  id=tenderPeriodEnd
${locator.viewExchange.enquiryPeriod.startDate}  id=enquiryPeriodStart
${locator.viewExchange.enquiryPeriod.endDate}  id=enquiryPeriodEnd

# assets info
${item_id}
${locator.viewExchange.item.description}  xpath=//*[contains(@value,"${item_id}")]
${locator.viewExchange.item.quantity}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"Quantity")]
${locator.viewExchange.item.classification.scheme}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"Classification_Scheme")]
${locator.viewExchange.item.classification.id}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"ClassificationCode")]
${locator.viewExchange.item.classification.description}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"Classification_Description")]
${locator.viewExchange.item.unit.name}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"Unit")]/..
${locator.viewExchange.item.unit.code}  xpath=//*[contains(@value,"${item_id}")]/ancestor::*[contains(@id,"asset-container")]/descendant::*[contains(@id,"Unit")]

# cancellation info
${locator.viewExchange.cancellations.status}  xpath=//*[text()="Auction Status"]/following-sibling::input
${locator.viewExchange.cancellations.reason}  xpath=//*[@data-test-id="cancellation-reason"]

# search exchange list
#${locator.exchangeList.FilterByTypeButton}  //th[@id='exchangeDashboardTypeCol']/a/span
${locator.exchangeList.FilterByIdButton}  //*[contains(@class,"k-state-active")]/descendant::*[contains(@id,"IdCol")]/a[contains(@class,"k-grid-filter")]
${locator.exchangeList.FilterTextField}  //form[contains(@style,"display: block")]/descendant::input[@type='text']
${locator.exchangeList.FilterSubmitButton}  //form[contains(@style,"display: block")]/descendant::button[@type='submit']
${locator.exchangeList.FilteredFirstRow}  //*[@id='exchangeDashboardTable']/table/tbody/tr/td[1]/a
${locator.exchangeList.FilteredSecondRow}  //*[@id='exchangeDashboardTable']/table/tbody/tr[2]/td/a
${locator.exchangeList.MyExchangesTab}  //li/span[2]
${locator.exchangeList.ProzorroExchangesTab}  //li[2]/span[2]
${locator.exchangeList.ProzorroFilteredFirstRow}  //div[@id='prozorroExchangesTable']/table/tbody/tr/td[2]/a


# questions and answers
${question_id}
${locator.Questions.DraftQuestionButton}    css=a.btn.btn-primary
${locator.Questions.expandButton}           xpath=//*[contains(text(), "${question_id}")]/../../i[contains(@class, 'fa-plus-square')]
${locator.Questions.title}                  xpath=//*[contains(text(),"${question_id}")]
${locator.Questions.description}            xpath=//*[contains(text(),"${question_id}")]/../../../../descendant::*[contains(text(), "Question detail")]/following-sibling::p
${locator.Questions.answer}                 xpath=//*[contains(text(), "${question_id}")]/../../../..//*[contains(@class, 'faq-q-answer')]
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
${locator.Bidding.FinancialFile}            id=BidDocuments.FinancialLicenseDocument
${locator.Bidding.InitialBiddingLink}       xpath=//*[contains(@href,"Bids/Submit/")]
${locator.Bidding.BiddingAmount}            id=ExternalExchangeBid_Amount
${locator.Bidding.SubmitBidButton}          id=submit-bid-submitbtn
${locator.Bidding.ConfirmBidPassword}       id=Password
${locator.Bidding.ConfirmBidButton}         id=submit-bid-dialog-yes
${locator.Bidding.CancelBidButton}          id=submit-bid-cancelbtn
${locator.Bidding.CancelBidYesButton}       id=cancel-bid-dialog-yes

# file operations
${locator.Dataroom.DataRoom}                id=li-exchange-toolbar-data-room
${locator.Dataroom.UploadIcon}              id=dataroom-upload
#${locator.Dataroom.Upload}                  id=dataroom-upload
${locator.Dataroom.RulesDialogYes}          id=exchangerules-dialog-yes
${locator.Dataroom.UploadSelect}            id=dataroom-upload
${locator.Dataroom.SelectFiles}             id=files
${locator.Dataroom.UploadFileButton}        //*[@id='dataroom-upload-modal-form']/div/div/div/button[2]
${locator.Dataroom.CloseButton}             id=dataroom-upload-btn-close