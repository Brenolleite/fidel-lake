import json
from urllib.request import Request, urlopen
from random import randrange, uniform

def request_url(url, post_data):
    req = Request(url)
    req.add_header('content-type', 'application/json')
    req.add_header('Fidel-Key', 'sk_test_50ea90b6-2a3b-4a56-814d-1bc592ba4d63')
    return json.loads(urlopen(req, data = bytes(json.dumps(post_data), encoding="utf-8")).read())
    
def generate_random_amount(n_range):
    # letting zero as an error for data pipeline treatment
    return round(uniform(0, n_range), 2);


def lambda_handler(event, context):
    
    data = {
        "amount": generate_random_amount(20),
        "cardId": "4f1970c2-4096-4a50-8490-006c55ea5b1b",
        "locationId": "f5c70ab1-a944-4367-9e4d-ea2ad5030fb2"
    }
    
    json_transaction = request_url('https://api.fidel.uk/v1/transactions/test', data);
    
    return {
        'statusCode': 200,
        'body': json_transaction
    }
