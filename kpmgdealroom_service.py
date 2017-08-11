# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import time
import os

from datetime import datetime
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from pytz import timezone 

# asset units name translation dictionary
unitNameDictionary = {
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


def get_chromedriver_version():
    return os.popen('chromedriver --version').read()


def get_tender_dates(initial_tender_data, key):
    data_period = initial_tender_data.data.auctionPeriod
    start_dt = dateutil.parser.parse(data_period['startDate'])
    data = {
        'StartDate': start_dt.strftime('%d/%m/%Y'),
        'StartTime': start_dt.strftime('%H:%M'),
    }
    return data.get(key, '')


def convert_date_to_dp_format(date):
    date_obj = dateutil.parser.parse(date)
    return date_obj.strftime('%d/%m/%Y %H:%M:%S')


def adapt_tender_data(tender_data):
    tender_data['data']['procuringEntity']['name'] = u'Prozorro Seller Entity'
    return tender_data


def convert_ISO_DMY(isodate):
    return dateutil.parser.parse(isodate).strftime('%d/%m/%Y')


def convert_date(isodate):
    return datetime.strptime(isodate, '%d-%m-%Y').date().isoformat()


def convert_date_to_dash_format(date):
    return datetime.strptime(date, '%d/%m/%Y').strftime('%Y-%m-%d')


def convert_date_to_slash_format(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime('%d/%m/%Y %H:%M:%S')
    return date_string


def convert_date_to_iso(v_date, v_time):
    full_value = v_date+' '+v_time
    date_obj = datetime.strptime(full_value, '%d/%m/%Y %H:%M')
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime('%Y/%m/%dT%H:%M:%S.%f%z')


def custom_convert_time(date):    
    date = datetime.strptime(date, "%d/%m/%Y %H:%M")
    return timezone('Europe/Kiev').localize(date).strftime('%Y-%m-%dT%H:%M:30.%f%z')


def convert_number_to_currency_str(number):
    return '%.2f' % number


def convert_to_int(value):
    return int(value)


def convert_unit_name(name):
    return unitNameDictionary.get(name, name)


def extract_unit_name(value):
    temp = value.split('\n')    # this is temporary.  Refactor after HTML page optimization
    return temp[1].replace(' ', '').replace(')', '').split('(')[0]


def extract_procuring_entity_name(value):
    temp = value.split('\n')
    return temp[1].strip()


def post_process_field(field_name, value):
    if field_name == 'tenderAttempts' or 'quantity' in field_name:
        return_value = convert_to_int(value)
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
    elif 'date' in field_name:
        return_value = custom_convert_time(value)
    else:
        return_value = value
    return return_value


def get_upload_file_path(filename):
    working_folder = os.path.join(os.getcwd(), 'src/robot_tests.broker.kpmgdealroom/')
    filename.replace('/', '')
    return os.path.join(working_folder, filename)
