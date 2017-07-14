# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import time

from datetime import datetime
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

def is_checked(locator): 
    driver = get_webdriver() 
    return driver.find_element_by_id(locator).is_selected() 

def convert_ISO_DMY(isodate):
    return dateutil.parser.parse(isodate).strftime("%d/%m/%Y")

def convert_date(isodate):
    return datetime.strptime(isodate, '%d/%m/%Y').date().isoformat()

def convert_date_to_iso(v_date, v_time):
    full_value = v_date+" "+v_time
    date_obj = datetime.strptime(full_value, "%d/%m/%Y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%dT%H:%M:%S.%f%z")

def convert_number_to_str(number):
    return str(number)

def convert_string_to_fake_email(username):
    return username + "@robottest.com"

def cleanup_string(text):
    return text.replace("[", "").replace("]", "").replace("/", "-").replace(".", "")

def inc(value):
    return int(value) + 1