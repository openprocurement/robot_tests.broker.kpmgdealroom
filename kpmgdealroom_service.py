# -*- coding: utf-8 -*-
import dateutil.parser
import urllib
import time
import os
from datetime import datetime
from pytz import timezone


# asset units name translation dictionary
UNITS_NAME_DICT = {
    'pair' : u'пара',
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
    'Tendering' : 'active.tendering',
    'Auction' : 'active.auction',
    'Qualification' : 'active.qualification',
    'Awarded':'active.awarded',
    'Unsuccessful' : 'unsuccessful',
    'Completed': 'complete',
    'Cancelled':'cancelled'
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
    return tender_data

def format_local_date(date):
    dst_active = time.daylight and time.localtime().tm_isdst > 0
    utc_offset = -(time.altzone if dst_active else time.timezone)
    hours = utc_offset // 3600
    minutes = (utc_offset % 3600) // 60
    fmt_date = date.replace("/", "-").replace(" ", "T") + ":00"
    return "{0:s}{1:+03d}:{2:02d}".format(fmt_date, hours, minutes)


def convert_date_to_dash_format(date):
    return datetime.strptime(date, '%d/%m/%Y').strftime('%Y-%m-%d')


def custom_convert_time(date):
    date = datetime.strptime(date, "%d/%m/%Y %H:%M")
    return timezone('Europe/Kiev').localize(date).strftime('%Y-%m-%dT%H:%M:30.%f%z')


def convert_number_to_currency_str(number):
    return '%.2f' % number


def convert_unit_name(name):
    return UNITS_NAME_DICT.get(name, name)


def convert_auction_status(status):
    return AUCTION_STATE_DICT.get(status, status)


def extract_unit_name(value):
    temp = value.split('\n')    # this is temporary.  Refactor after HTML page optimization
    return temp[1].replace(' ', '').replace(')', '').split('(')[0]


def extract_procuring_entity_name(value):
    temp = value.split('\n')
    return temp[1].strip()


def post_process_field(field_name, value):
    if field_name == 'tenderAttempts':
        return_value = int(value.split(" ")[0])
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
        return_value = extract_procuring_entity_name(value) #value.replace("Name:", "").strip()
    elif 'Date' in field_name:
        return_value = format_local_date(value)
    elif field_name == 'status':
        return_value = convert_auction_status(value)
    else:
        return_value = value
    return return_value


def kpmg_download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))


def get_upload_file_path(file_name):
    return os.path.join(os.getcwd(), 'src', 'robot_tests.broker.kpmgdealroom', file_name)