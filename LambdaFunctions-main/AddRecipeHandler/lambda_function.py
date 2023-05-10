import json
import boto3
import firebase_admin
from firebase_admin import auth
from firebase_admin import credentials

# Adding a test comment

def lambda_handler(event, context):

    print(event)
    if (firebase_admin._apps.__len__() == 0):
        cred = credentials.Certificate('serviceAccount.json')
        default_app = firebase_admin.initialize_app(cred)

    dynamodb = boto3.client('dynamodb',region_name='us-east-1')
    speak_output = 'Failed'
    
    eventA = json.loads(event['body'])#.encode('utf-8'))
    
    print(eventA)

    try:
        if (eventA['Token'] != 'nologon'):
            claim = auth.verify_id_token(eventA['Token'])
            code = 500
            if (eventA['AccountID'] != claim['user_id']):
                code = 403
                return {
                'statusCode': code,
                'body': "UserID doesn't match the token."
                }

            newItem = {'Recipe Name':{},'Directions':{},'Ingredient List':{},'TotalTime':{},'CookTime':{},'PrepTime':{},'ActiveTime':{},'Public':{},'AccountID':{},'UID':{}, 'Type':{}, 'Characteristics':{}, 'Description':{}, 'Summary':{}, 'VideoLink':{}, 'Links':{}, 'PairsWith':{}, 'ImageUrl':{}, 'Source':{}, 'Nutrition':{}, 'Equipment':{}, 'Servings':{}}
            try:
                newItem['Recipe Name']['S'] = eventA['Recipe Name']
                newItem['Public']['BOOL'] = eventA['Public']
                newItem['AccountID']['S'] = eventA['AccountID']
                newItem['UID']['S'] = eventA['UID']
                
                directions = eventA['Directions']
                newDirections = []
                for x in directions:
                    newDirections.append({'S':x})
                newItem['Directions']['L'] = newDirections
                
                ingredients = eventA['Ingredient List']
                newIngredients = []
                for x in ingredients:
                    newIngredients.append({'L':[{'S':x[0]},{'N':str(x[1])},{'S':x[2]}]})
                newItem['Ingredient List']['L']= newIngredients
                
                newItem['TotalTime']['N'] = str(eventA['TotalTime'])
                newItem['ActiveTime']['N'] = str(eventA['ActiveTime'])
                newItem['CookTime']['N'] = str(eventA['CookTime'])
                newItem['PrepTime']['N'] = str(eventA['PrepTime'])
                newItem['Type']['S'] = str(eventA['Type'])
                newItem['Description']['S'] = str(eventA['Description'])
                newItem['Summary']['S'] = str(eventA['Summary'])
                newItem['VideoLink']['S'] = str(eventA['VideoLink'])
                newItem['ImageUrl']['S'] = str(eventA['ImageUrl'])
                newItem['Source']['S'] = str(eventA['Source'])
                newItem['Nutrition']['S'] = str(eventA['Nutrition'])
                newItem['Equipment']['S'] = str(eventA['Equipment'])
                newItem['Servings']['N'] = str(eventA['Servings'])
                
                characteristics = eventA['Characteristics']
                newCharacteristics = []
                for x in characteristics:
                    newCharacteristics.append({'S':x})
                newItem['Characteristics']['L']= newCharacteristics

                links = eventA['Links']
                newLinks = []
                for x in links:
                    newLinks.append({'S':x})
                newItem['Links']['L']= newLinks

                pairs = eventA['PairsWith']
                newPairs = []
                for x in pairs:
                    newPairs.append({'S':x})
                newItem['PairsWith']['L']= newPairs
                
                dynamodb.put_item(TableName='Recipes', Item=newItem)
                speak_output = 'Success'
                code = 200
            except Exception as e:
                speak_output = str(e)
                print(e)
            return {
                'statusCode': code,
                'body': json.dumps(speak_output)
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
