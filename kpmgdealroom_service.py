# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import time
import os

from datetime import datetime
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn


# asset units name translation dictionary
unitNameDictionary = {
    u'pair' : u'пара',
    u'litre': u'літр',
    u'set': u'набір',
    u'number of packs': u'пачок',
    u'metre': u'метри',
    u'lot': u'лот',
    u'service': u'послуга',
    u'metre cubed': u'метри кубічні',
    u'box': u'ящик',
    u'trip': u'рейс',
    u'tonne': u'тони',
    u'metre squared': u'метри квадратні',
    u'kilometre': u'кілометри',
    u'piece': u'штуки',
    u'month': u'місяць',
    u'ream': u'пачка',
    u'pack': u'упаковка',
    u'hectare': u'гектар',
    u'kilogram': u'кілограми',
    u'block': u'блок'
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


def convert_number_to_currency_str(number):
    return '%.2f' % number


def convert_to_int(value):
    return int(value)


def convert_unit_name(name):
    return_value = name
    if unitNameDictionary.has_key(name):
        return_value = unitNameDictionary[name]
    return return_value


def extract_unit_name(value):
    temp = value.split('\n')    # this is 100% temporary and needs refactoring following HTML page optimization
    return_value = temp[1].replace(' ', '').replace(')', '').split('(')[0]
    return return_value


def post_process_field(field_name, value):
    if (field_name == 'tenderAttempts') or ('quantity' in field_name):
        return_value = convert_to_int(value)
    elif (field_name == 'value.amount') or (field_name == 'minimalStep.amount'):
        return_value = float(value.replace(' ', '').replace(',','.' ))
    elif (field_name == 'dgfDecisionDate'):
        return_value = convert_date_to_dash_format(value)
    elif ('unit.name' in field_name):
        return_value = convert_unit_name(extract_unit_name(value))
    elif(field_name =='value.valueAddedTaxIncluded'):
        return_value = (str(value).lower() == 'true')
    else:
        return_value = value
    return return_value


def get_upload_file_path(filename):
    workingFolder = os.path.join(os.getcwd(), 'src/robot_tests.broker.kpmgdealroom/')
    filename.replace('/','')
    return os.path.join(workingFolder, filename)
