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


def main():
    request = {
        "Records": [
            {
                "cf": {
                    "config": {
                        "distributionDomainName": "d111111abcdef8.cloudfront.net",
                        "distributionId": "EDFDVBD6EXAMPLE",
                        "eventType": "viewer-request",
                        "requestId": "4TyzHTaYWb1GX1qTfsHhEqV6HUDd_BzoBZnwfnvQc_1oF26ClkoUSEQ=="
                    },
                    "request": {
                        "clientIp": "203.0.113.178",
                        "headers": {
                            "host": [
                                {
                                    "key": "Host",
                                    "value": "ipfs.dev.filedgr.com"
                                }
                            ],
                            "user-agent": [
                                {
                                    "key": "User-Agent",
                                    "value": "curl/7.66.0"
                                }
                            ],
                            "accept": [
                                {
                                    "key": "accept",
                                    "value": "*/*"
                                }
                            ]
                        },
                        "method": "GET",
                        "querystring": "#x-ipfs-companion-no-redirect",
                        "uri": "/ipfs/bafybeifx7yeb55armcsxwwitkymga5xf53dxiarykms3ygqic223w5sk3m/home"
                    }
                }
            }
        ]
    }
    lambda_handler(request, None)
    # https://ipfs.dev.filedgr.com/ipfs/bafybeifx7yeb55armcsxwwitkymga5xf53dxiarykms3ygqic223w5sk3m#x-ipfs-companion-no-redirect


if __name__ == "__main__":
    main()
