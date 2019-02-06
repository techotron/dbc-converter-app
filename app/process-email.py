import boto3
import common
import os

def time(event, handler):
    print(common.get_timestamp())