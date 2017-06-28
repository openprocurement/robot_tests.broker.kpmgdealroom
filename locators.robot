*** Settings ***
Resource    kpmgdealroom.robot

*** Variables ***
# login page
${locator.login.emailField}    id=Email
${locator.login.passwordField}    id=Password
${locator.login.loginButton}    id=login-submit

# toolbar
${locator.toolbar.createExchangeButton}  
${locator.toolbar.logoutButton} id=toolbar-logout

# create exchange
${locator.createExchange.clientSelector}
${locator.createExchange.name}
${locator.createExchange.sellerName}
${locator.createExchange.sponsorEmail}
${locator.createExchange.adminEmails}
${locator.createExchange.typeSelector}
${locator.createExchange.startDate}
${locator.createExchange.dgfCategorySelector}
${locator.createExchange.guaranteeAmount}
${locator.createExchange.startPrice}
${locator.createExchange.submitButton}

# add item / asset
${locator.addAsset.items[0].description}
${locator.addAsset.items[0].quantity}
${locator.addAsset.items[0].classification.scheme}
${locator.addAsset.items[0].classification.description}
${locator.addAsset.items[0].classification.code}
${locator.addAsset.items[0].deleteLink}

${locator.addAsset.items[1].description}
${locator.addAsset.items[1].quantity}
${locator.addAsset.items[1].classification.scheme}
${locator.addAsset.items[1].classification.description}
${locator.addAsset.items[1].classification.code}
${locator.addAsset.items[1].deleteLink}

${locator.addAsset.items[2].description}
${locator.addAsset.items[2].quantity}
${locator.addAsset.items[2].classification.scheme}
${locator.addAsset.items[2].classification.description}
${locator.addAsset.items[2].classification.code}
${locator.addAsset.items[2].deleteLink}

${locator.addAsset.saveButton}
${locator.addAsset.addButton}


# Edwin - The below locators are from UESC's driver.  To eventually delete...
${locator.edit.description}    id = auction-description
${locator.title}    id = auction-title
${locator.description}    id = auction-description
${locator.minimalStep.amount}    id = auction-minimalStep_amount
${locator.value.amount}    id = auction_value_amount
${locator.value.valueAddedTaxIncluded}    id=auction-valueAddedTaxIncluded
${locator.value.currency}    id=auction-minimalStep_currency
${locator.auctionPeriod.startDate}    id = auction-auctionPeriod_startDate
${locator.enquiryPeriod.startDate}    id = auction-enquiryPeriod_startDate
${locator.enquiryPeriod.endDate}    id = auction-enquiryPeriod_endDate
${locator.tenderPeriod.startDate}    id = auction-tenderPeriod_startDate
${locator.tenderPeriod.endDate}    id = auction-tenderPeriod_endDate
${locator.tenderId}    id = auction-auctionID
${locator.procuringEntity.name}    id = auction-procuringEntity_name
${locator.dgf}    id = auction-dgfID
${locator.dgfDecisionID}    id=auction-dgfDecisionID
${locator.dgfDecisionDate}    id=auction-dgfDecisionDate
${locator.eligibilityCriteria}    id=критерії оцінки
${locator.tenderAttempts}    id=auction-tenderAttempts
${locator.procurementMethodType}    id=auction-procurementMethodType
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