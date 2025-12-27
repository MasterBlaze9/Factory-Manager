import base64
import json
import datetime
import decimal


def get_file_extension(file_name):
    last_dot_index = file_name.rfind('.')

    if last_dot_index != -1:
        extension = file_name[last_dot_index + 1:]
        return extension

    return ""


def convert_decimal(value):
    if isinstance(value, decimal.Decimal):
        return float(value)
    return value


def encode_parameter(parameter):
    return base64.b64encode(str(parameter))


def decode_parameter(parameter):
    return base64.b64decode(parameter)


def get_current_date():
    return datetime.datetime.now().strftime("%d-%m-%Y")


def get_current_time():
    return datetime.datetime.now().strftime("%H:%M:%S")


class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.date):
            return obj.strftime("%d-%m-%Y")
        if isinstance(obj, datetime.datetime):
            return obj.strftime("%d-%m-%Y %H:%M:%S")
        if isinstance(obj, decimal.Decimal):
            return str(obj)
