from flask_restful import Resource
from flask import request
from common import auth, AuthException
from models import Poll, Answer
# from google.appengine.ext import ndb
# from google.appengine.api import search
import logging



class Specific_Poll(Resource):

    def get(self, poll_id):
        '''
        this method just gets the poll based on the supplied and then returns JSON representation
        :param poll_id:
        :return:
        '''
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        if not poll_id:
            return {"error": "Invalid poll id"}, 401

        print("poll id: ")
        print(type(poll_id))
        result_poll = Poll.get_by_id(int(poll_id))
        if not result_poll:
            return {"error": "Poll does not exist"}, 401
        return {"result": result_poll.serialize()}, 200

    def post(self, poll_id):
        '''
        The post method here is how polls are going to be voted on.
        First the poll is retrieved from the datastore, the correct answer count is incremented and the user is added to the participants
        If the user has already voted return an error.
        :param poll_id:
        :return:
        '''
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401
        if not poll_id:
            return {"error": "Invalid poll id"}, 401

        result_poll = Poll.get_by_id(int(poll_id))
        if not result_poll:
            return {"error": "Poll does not exist"}, 401

        data = request.get_json()

        # if not data['answer_id'] and data['answer_id']
        #     return {"error": "answer_id must be the index to the answer to vote in"}, 401

        # Check if the uer can vote
        if claims['sub'] is result_poll.created_by:
            return {"error": "Creator cannot vote in their own poll"}, 401

        if claims['sub'] in result_poll.participants:
            return {"error": "User already voted in the poll"}, 401

        #get the id of the poll to vote on
        id = None
        for i in range(len(result_poll.answers)):
            if result_poll.answers[i].answer_text == data['answer_id']:
                id = i
                break

        # the user can vote at this point
        result_poll.participants.append(claims['sub'])
        try:
            result_poll.answers[id].count += 1
        except IndexError as e:
            return {"error": "answer_id out of range"}, 401

        result_poll.put()

        return {"result": result_poll.serialize()}, 201





class Post_poll(Resource):
    def post(self):
        '''
        form data

        question: <string>
        location: <object -> lat, lon>
        answers: <list -> string>
        radius <int> -> meters?
        :return:
        '''
        logging.info("Going to try to create a new poll")
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            logging.error("Unable to authenticate")
            return {"error": "Unauthorized"}, 401

        logging.info(request.get_json())
        data = request.get_json()

        a = [Answer(answer_text=ans) for ans in data['answers']]
        newPoll = Poll(
            created_by=claims["sub"],
            question=data['question'],
            answers=a,
            # location=ndb.GeoPt(request.form['location'].lat,request.form['location'].lon),
            lat = data['lat'],
            lon=data['lon'],
            radius=data['radius']
        )
        #
        # fields = [
        #     search.TextField(name="poll_id", value=newPoll.key.id()),
        #     search.GeoField(name="location", value=search.GeoPoint(request.form['lat'], request.form['lon']))
        # ]
        #
        # d = search.Document(fields=fields)
        # try:
        #     add_result = search.Index(name="Poll").put(d)
        # except search.Error:
        #     logging.error("error creating index of poll")
        #     return {"error": "Error creating index"}


        poll_key = newPoll.put()

        logging.info("poll id ")
        logging.info(poll_key.id())

        return {"result": newPoll.serialize()}, 201

class User_polls(Resource):
    '''
    This function will return all of the polls that the current authorized user created
    '''
    def get(self):
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        q = Poll.query(Poll.created_by == claims['sub'])
        res = q.fetch()
        if not res:
            return {"error": "no polls"}, 401

        result = []
        for i in res:
            result.append(i.serialize())
        return {"result": result}, 200


class Location_polls(Resource):

    def get(self):
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        logging.info(claims)

        # query goes here

        # result = []
        # for i in res:
        #     result.append(i.serialize())
        # return {"result": result}, 200

class Demo_polls(Resource):
    '''
    the demo resource has a get method that will return a list of all of the demo polls
    and a post method that allows creation of the new demo polls
    '''

    def get(self):
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        q = Poll.query(Poll.created_by == 'demo')
        res = q.fetch()
        if not res:
            return {"error": "no polls"}, 401

        result = []
        for i in res:
            result.append(i.serialize())
        return {"result": result}, 200

    def post(self):
        '''
        Route that allows for the creation of the demo polls
        :return:
        '''
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            logging.error("Unable to authenticate")
            return {"error": "Unauthorized"}, 401

        data = request.get_json()

        a = [Answer(answer_text=ans) for ans in data['answers']]
        newPoll = Poll(
            created_by='demo',
            question=data['question'],
            answers=a,
            # location=ndb.GeoPt(request.form['location'].lat,request.form['location'].lon),
            lat=data['lat'],
            lon=data['lon'],
            radius=data['radius']
        )

        # preset the poll answer counts
        i = 0
        for c in data['answer_counts']:
            newPoll.answers[i].count = c
            i += 1

        newPoll.put()

        return {"result": newPoll.serialize()}, 201