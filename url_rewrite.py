def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    host = request["headers"]["host"][0]["value"]
    query = request["querystring"]
    uri = request["uri"]

    if host.startswith("ipfs") or host.startswith("ipns"):
        path = uri.split("/")
        cid = path[2]
        if len(path) > 3:
            request["uri"] = "/"
            request["uri"] += "/".join(path[3:])
        else:
            request["uri"] = "/"
        uri = request["uri"]

        return {
            'status': '302',
            'statusDescription': 'IPFS Subdomain Gateway rewrite',
            'headers': {
                'location': [
                    {
                        'key': 'Location',
                        'value': f"https://{cid}.{host}{uri}{query}"
                    }
                ]
            }
        }
    else:
        return request