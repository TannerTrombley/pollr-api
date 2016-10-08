from flask_restful import Resource
from flask import request
from common import verify_auth_token

class Test_route(Resource):

    def get(self):
        claims = verify_auth_token(request)
        res = {}
        if not claims:
            return {"error": "Unauthorized"}, 401

        return claims, 200

    def put(self):
        return {'message': "This is the put route"}

