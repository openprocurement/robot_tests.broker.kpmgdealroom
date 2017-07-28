# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import time

from datetime import datetime
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn

def get_tender_dates(initial_tender_data, key):
    data_period = initial_tender_data.data.auctionPeriod
    start_dt = dateutil.parser.parse(data_period['startDate'])
    data = {
        'StartDate': start_dt.strftime("%d/%m/%Y"),
        'StartTime': start_dt.strftime("%H:%M"),
    }
    return data.get(key, '')


def adapt_tender_data(tender_data):
    tender_data['data']['procuringEntity']['name'] = u"Prozorro Entity"
    #tender_data['data']['title'] = tender_data['data']['title'].replace("[", "").replace("]", "")
    #tender_data['data']['title_en'] = tender_data['data']['title_en'].replace("[", "").replace("]", "").replace("TESTING", "")
    #tender_data['data']['title_ru'] = tender_data['data']['title_ru'].replace("[", "").replace("]", "")
    #tender_data['data']['dgfDecisionID'] = tender_data['data']['dgfDecisionID'].replace("/", "-")
    #tender_data['data']['description'] = tender_data['data']['description'].replace(".","")

    # todo - remove on completion of KDR-1237
    #tender_data['data']['title'] = tender_data['data']['title_en'][:21] + " _kdrtest"
    tender_data['data']['title'] = tender_data['data']['title'][:21] + " _kdrtest"
    return tender_data

def convert_ISO_DMY(isodate):
    return dateutil.parser.parse(isodate).strftime("%d/%m/%Y")

def convert_date(isodate):
    return datetime.strptime(isodate, '%d-%m-%Y').date().isoformat()

def convert_date_to_slash_format(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d/%m/%Y %H:%M:%S")
    return date_string

def convert_date_to_iso(v_date, v_time):
    full_value = v_date+" "+v_time
    date_obj = datetime.strptime(full_value, "%d/%m/%Y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y/%m/%dT%H:%M:%S.%f%z")

def convert_number_to_currency_str(number):
    return "%.2f" % number


def get_upload_file_path(filename):
    workingFolder = os.path.join(os.getcwd(), 'src/robot_tests.broker.kpmgdealroom/')
    filename.replace('/','')
    return os.path.join(workingFolder, filename)
