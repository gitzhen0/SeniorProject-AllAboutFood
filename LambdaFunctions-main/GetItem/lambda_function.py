import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from jose import jwt
def lambda_handler(event, context):
    
#     publicKey = """-----BEGIN PUBLIC KEY-----
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo
# 4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u
# +qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh
# kd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ
# 0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg
# cKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc
# mwIDAQAB
# -----END PUBLIC KEY-----"""

    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    
    table = dynamodb.Table('NewRecipeDataType')
    eventA = json.loads(event['body'])
    
    claim = jwt.get_unverified_claims(eventA['Token'])

    # eventB = jwt.decode(eventA['Token'], publicKey, algorithms=['RS256'], audience='ivfcr-43a7f')

    recipeID = eventA['UID']
    
    response = table.query(KeyConditionExpression=Key('UID').eq(recipeID))
    
    data = response['Items']
    
    if len(data) == 0:
        return {
            'statusCode': 404,
            'body': 'Item not found'
        }
    
    if  data[0]['AccountID'] != claim['user_id'] and not data[0]['Public']:
        return {
            'statusCode': 404,
            'body': 'Item not visible to user'
        }
    
    return {
        'statusCode': 200,
        'body': data
    }
