import json
import boto3
from boto3.dynamodb.conditions import Attr
import firebase_admin
from firebase_admin import auth
from firebase_admin import credentials
def lambda_handler(event, context):

    if (firebase_admin._apps.__len__() == 0):
        cred = credentials.Certificate('serviceAccount.json')
        default_app = firebase_admin.initialize_app(cred)

    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    
    table = dynamodb.Table('Recipes')

    eventA = json.loads(event['body'])
    
    try:
        if (eventA['Token'] != 'nologon'):
            claim = auth.verify_id_token(eventA['Token'])
            response = table.scan(FilterExpression=Attr('AccountID').eq(claim['user_id']) | Attr('Public').eq(True)) # FilterExpression=Attr('AccountID').eq(eventB['AccountID']) & Attr('Public').eq(true)
            data = response['Items']
        else:
            response = table.scan(FilterExpression=Attr('Public').eq(True)) # FilterExpression=Attr('AccountID').eq(eventB['AccountID']) & Attr('Public').eq(true)
            data = response['Items']

        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            data.extend(response['Items'])
        
        return {
        'statusCode': 200,
        'body': data
        }
    except Exception as ex:
        template = "An exception of type {0} occurred. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)
        return {
            'statusCode': 401,
            'body': message
        }
