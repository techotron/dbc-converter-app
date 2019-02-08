import datetime
import time
import json


def get_timestamp():
    timestamp = datetime.datetime.today()
    return (timestamp)

def parse_message(message):
    json_message = json.loads(message.replace("'", '"'))
    for record in json_message["Records"]:
        s3record = record["s3"]
        message_timestamp = record["eventTime"]
        message_bucket = s3record["bucket"]["name"]
        message_key = s3record["object"]["key"]
        message_size = s3record["object"]["size"]

        return message_timestamp

def extract_body(event):
    for record in event['Records']:
        return record["body"]