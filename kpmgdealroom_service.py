# -*- coding: utf-8 -*-

# This script is provided by KPMG to ProZorro for the purpose of carrying out automated tests on
# the KPMG Deal Room testing system, in accordance with the rules of compliance for participating
# in the ProZorro.Sale process, as set out by the Ministry of Economic Development and Trade of
# Ukraine, Transparency International Ukraine, the Deposit Guarantee Fund and the National Bank of
# Ukraine - https://prozorro.sale/en/aim. For more information on the transparent public testing
# procedures please visit here https://github.com/openprocurement/

import dateutil.parser
import urllib
from datetime import datetime
from pytz import timezone
from dateutil.tz import tzlocal

tzlocal = tzlocal()

# asset units name translation dictionary
UNITS_NAME_DICT = {
    'pair': u'пара',
    'litre': u'літр',
    'set': u'набір',
    'number of packs': u'пачок',
    'metre': u'метри',
    'lot': u'лот',
    'service': u'послуга',
    'metre cubed': u'метри кубічні',
    'box': u'ящик',
    'trip': u'рейс',
    'tonne': u'тони',
    'metre squared': u'метри квадратні',
    'kilometre': u'кілометри',
    'piece': u'штуки',
    'month': u'місяць',
    'ream': u'пачка',
    'pack': u'упаковка',
    'hectare': u'гектар',
    'kilogram': u'кілограми',
    'block': u'блок'
}

AUCTION_STATE_DICT = {
    'Tendering': 'active.tendering',
    'Auction': 'active.auction',
    'Qualification': 'active.qualification',
    'Awarded': 'active.awarded',
    'Unsuccessful': 'unsuccessful',
    'Completed': 'complete',
    'Cancelled': 'cancelled'
}

PROCUREMENT_TYPE = {
    'Other Assets': 'dgfOtherAssets',
    'Financial Assets': 'dgfFinancialAssets',
    'Dutch Auction': 'dgfInsider'
}

AWARD_STATE_DICT = {
    'Verification': 'pending.verification',
    'Waiting': 'pending.waiting',
    'Payment': 'pending.payment',
    'Unsuccessful': 'unsuccessful',
    'Cancelled': 'cancelled',
    'Active': 'active'
}

def convert_date_to_dp_format(value, fieldname):
    if "dgfDecisionDate" in fieldname:
        value = dateutil.parser.parse(value).strftime('%d/%m/%Y')
    elif "Date" in fieldname:
        value = dateutil.parser.parse(value).strftime('%d/%m/%Y %H:%M:%S')
    return value


def adapt_tender_data(tender_data, role):
    if role == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u'Prozorro Seller Entity'
        for i in range(len(tender_data['data']['items'])):
            unit_name = list(UNITS_NAME_DICT.keys())[list(UNITS_NAME_DICT.values()).index(tender_data['data']['items'][i]['unit']['name'])]
            tender_data['data']['items'][i]['unit']['name'] = unit_name
    return tender_data


def convert_date_to_dash_format(date):
    return datetime.strptime(date, '%d/%m/%Y').strftime('%Y-%m-%d')


def convert_time_to_local(date):
    date_obj = datetime.strptime(date, "%d/%m/%Y %H:%M").replace(tzinfo=tzlocal)
    return date_obj.astimezone(timezone('Europe/Kiev')).strftime('%Y-%m-%dT%H:%M:30.%f%z')


def convert_number_to_currency_str(number):
    return '%.2f' % number


def convert_unit_name(name):
    return UNITS_NAME_DICT.get(name, name)


def convert_auction_status(status):
    return AUCTION_STATE_DICT.get(status, status)

def convert_award_status(status):
    return AWARD_STATE_DICT.get(status, status)

def convert_procurement_type(proc_type):
    return PROCUREMENT_TYPE.get(proc_type, proc_type)


def extract_unit_name(value):
    return value.split('\n')[-1]


def extract_procuring_entity_name(value):
    temp = value.split('\n')
    return temp[1].strip()


def post_process_field(field_name, value):
    if field_name == 'tenderAttempts':
        return_value = int(value.split(" ")[0])
    elif field_name == 'procurementMethodType':
        return_value = convert_procurement_type(value)
    elif 'quantity' in field_name:
        return_value = int(value)
    elif field_name == 'value.amount' or field_name == 'minimalStep.amount':
        return_value = float(value.replace(' ', '').replace(',', '.'))
    elif field_name == 'dgfDecisionDate':
        return_value = convert_date_to_dash_format(value)
    elif 'unit.name' in field_name:
        return_value = convert_unit_name(extract_unit_name(value))
    elif field_name == 'value.valueAddedTaxIncluded':
        return_value = (str(value).lower() == 'true')
    elif field_name == 'procuringEntity.name':
        return_value = extract_procuring_entity_name(value)
    elif 'Date' in field_name:
        return_value = convert_time_to_local(value)
    elif field_name == 'status':
        return_value = convert_auction_status(value)
    elif 'cancellations' in field_name and 'status'in field_name and value == 'Cancelled':
        return_value = 'active'
    elif 'awards' in field_name and 'status'in field_name:
        return_value = convert_award_status(value)
    else:
        return_value = value
    return return_value


def kpmg_download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))
