from models import Points, get_or_create_points
from flask import request
from flask_restful import Resource
from common import auth, AuthException, distance_ll, did_user_vote
import logging

class Get_user(Resource):
    def get(self):
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        logging.info(claims)

        p = get_or_create_points(claims["sub"])

        res = {
            "user_points": p.count
        }

        return {"result": res}, 200
