from flask_restful import Resource
from flask import request
from common import verify_auth_token
from models import Poll
from google.appengine.ext import ndb
import logging

class Test_route(Resource):

    def get(self):
        # claims = verify_auth_token(request)
        # res = {}
        # if not claims:
        #     return {"error": "Unauthorized"}, 401

        # get all of the users poll
        logging.info("In the get route")
        print("hello")
        query = Poll.query(Poll.created_by == "Tanner")
        res = query.fetch()
        # logging.info("the query: ", res)
        print(type(res))
        result = []
        for i in res:
            result.append(i.serialize())
        return {"result": result}

    def put(self):
        # claims = verify_auth_token(request)
        # res = {}
        # if not claims:
        #     return {"error": "Unauthorized"}, 401
        logging.info("In the put route")

        newPoll = Poll(
            created_by="Tanner",
            question="Is this working?",
            answers=["yes", "no"],
            location=ndb.GeoPt(42.2808,83.7430),
            radius=10
        )

        newPoll.put()
        return {"Result": "Successful put"}
