from __future__ import print_function
import boto3
import common
import os
import json

def time(event, handler):
    print(common.get_timestamp())

def check_queue(event, context):
    message = common.extract_body(event)
    print(common.parse_message(message))