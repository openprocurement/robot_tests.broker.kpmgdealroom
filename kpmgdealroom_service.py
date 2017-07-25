# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import time

from datetime import datetime
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn

def get_webdriver():
    se2lib = BuiltIn().get_library_instance('Selenium2Library')
    return se2lib._current_browser()

def get_tender_dates(initial_tender_data, key):
    data_period = initial_tender_data.data.auctionPeriod
    start_dt = dateutil.parser.parse(data_period['startDate'])
    data = {
        'StartDate': start_dt.strftime("%d/%m/%Y"),
        'StartTime': start_dt.strftime("%H:%M"),
    }
    return data.get(key, '')


def adapt_tender_data(tender_data):
    tender_data['data']['procuringEntity']['name'] = u"Prozorro Test"
    tender_data['data']['title'] = tender_data['data']['title'].replace("[", "").replace("]", "")
    tender_data['data']['title_en'] = tender_data['data']['title_en'].replace("[", "").replace("]", "").replace("TESTING", "")
    tender_data['data']['title_ru'] = tender_data['data']['title_ru'].replace("[", "").replace("]", "")
    tender_data['data']['dgfDecisionID'] = tender_data['data']['dgfDecisionID'].replace("/", "-")
    tender_data['data']['description'] = tender_data['data']['description_en'].replace(".","")
    tender_data['data']['minimalStep']['amount'] = 10000000

    # todo - remove on completion of KDR-1237
    tender_data['data']['title'] = tender_data['data']['title_en'][:21] + " _kdrtest"
    return tender_data

def is_checked(locator): 
    driver = get_webdriver() 
    return driver.find_element_by_id(locator).is_selected() 

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

def convert_number_to_str(number):
    return str(number)

def convert_number_to_currency_str(number):
    return "%.2f" % number

def convert_string_to_fake_email(username):
    return username + "@robottest.com"

#def cleanup_string(text):
#    return text.replace("[", "").replace("]", "").replace("/", "-").replace(".", "")

#def cleanup_name_string(text):
#    return text.replace("[TESTING]", "")[:21] + " _kdrtest"

def inc(value):
    return int(value) + 1


def get_upload_file_path(filename):
    workingFolder = os.path.join(os.getcwd(), 'src/robot_tests.broker.kpmgdealroom/')
    filename.replace('/','')
    return os.path.join(workingFolder, filename)


# ----- temporary code from here onwards -----
def set_field(locator, value):
    driver = get_webdriver()
    print ("The value is : " + value)
    stringValue = value.replace("-", "/")
    driver.find_element_by_id(locator).clear()
    driver.find_element_by_id(locator).send_keys(stringValue)
