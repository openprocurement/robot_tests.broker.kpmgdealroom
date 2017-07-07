# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib

from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn

def get_webdriver():
    se2lib = BuiltIn().get_library_instance('Selenium2Library')
    return se2lib._current_browser()


def convert_date(isodate):
    return datetime.strptime(isodate, '%d.%m.%Y').date().isoformat()

def convert_date_to_iso(v_date, v_time):
    full_value = v_date+" "+v_time
    date_obj = datetime.strptime(full_value, "%d.%m.%Y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%dT%H:%M:%S.%f%z")