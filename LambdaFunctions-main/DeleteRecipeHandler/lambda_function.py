import json
import boto3
from boto3.dynamodb.conditions import Key
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
            
            response = table.query(KeyConditionExpression=Key('UID').eq(eventA['UID']))
            data = response['Items']

            if len(data) == 0:
                return {
                    'statusCode': 404,
                    'body': 'Item not found'
                }
            if  data[0]['AccountID'] != claim['user_id']:
                return {
                    'statusCode': 404,
                    'body': 'Item not owned by user'
                }
            response = table.delete_item(Key={
                'UID': eventA['UID']
            })
            return {
                'statusCode': 200,
                'body': json.dumps(response)
            }
        else:
            return {
                'statusCode': 401,
                'body': 'Client is not logged in.'
            }
    except Exception as ex:
        template = "An exception of type {0} occurred. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)
        return {
            'statusCode': 401,
            'body': 'Token is expired'
        }