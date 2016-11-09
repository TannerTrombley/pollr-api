from flask_restful import Resource
from flask import request
from common import auth, AuthException, distance_ll, did_user_vote
from models import Poll, Answer
from google.appengine.ext import ndb
from google.appengine.api import search
import logging
import random



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
        return {"result": result_poll.serialize(voted=did_user_vote(claims['sub'], result_poll.participants))}, 200

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
        #####
        # #TEMP
        # for i in range(len(result_poll.answers)):
        #     result_poll.answers[i].count = random.randint(result_poll.answers[i].count + 1, result_poll.answers[i].count + 151)
        # result_poll.put()
        #####

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

        if id is None:
            return {"error": "Did not provide a valid answer option"}, 401



        # the user can vote at this point
        result_poll.participants.append(claims['sub'])
        try:
            result_poll.answers[id].count += 1
        except IndexError as e:
            return {"error": "answer_id out of range"}, 401

        result_poll.put()

        return {"result": result_poll.serialize(voted=did_user_vote(claims['sub'], result_poll.participants))}, 201





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

        for i in range(len(newPoll.answers)):
            newPoll.answers[i].count = random.randint(newPoll.answers[i].count, newPoll.answers[i].count + 151)

        poll_key = newPoll.put()

        logging.info("Created the pool and put it in the datastore")

        #
        fields = [
            search.NumberField(name="radius", value=data['radius']),
            search.GeoField(name="location", value=search.GeoPoint(data['lat'], data['lon']))
        ]

        logging.info("Created the fields object")

        d = search.Document(doc_id=str(poll_key.id()), fields=fields)
        logging.info("Created the searc.document")
        try:
            add_result = search.Index(name="Polls").put(d)
            logging.info('added the document to the index')
        except search.Error:
            logging.error("error creating index of poll")
            return {"error": "Error creating index"}




        logging.info("poll id ")
        logging.info(poll_key.id())

        return {"result": newPoll.serialize(voted=did_user_vote(claims['sub'], newPoll.participants))}, 201

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
            result.append(i.serialize(voted=did_user_vote(claims['sub'], i.participants)))
        return {"result": result}, 200


class Location_polls(Resource):
    '''
    This function takes agruments in the URI parameters lat and lon. They should be double values representing degrees
    '''
    def get(self):
        claims = None
        try:
            claims = auth(request)
        except AuthException as e:
            return {"error": "Unauthorized"}, 401

        # Validate the lat lon
        # if request.args.get('lat') < -90.0 or request.args.get('lat') > 90.0 or request.args.get('lon') < -180.0 or request.args.get('lon') > 180.0:
        #     logging.error("invalid lat lon: {} {}".format(request.args.get('lat'), request.args.get('lon')))
        #     return {"error": "Invalid lat lon values"}

        #Set up the response array. This will contain and series of ints representing IDs in sorted order
        near = []

        # This is the distance in meters of the diameter of detroit -- our maximum radius to query for
        max_dist = 32200
        try:
            # Build the query object here
            query = "distance(location, geopoint({}, {})) < {}".format(request.args.get('lat'),
                                                                          request.args.get('lon'), max_dist)
            loc_expr = "distance(location, geopoint({}, {}))".format(request.args.get('lat'), request.args.get('lon'))
            sortexpr = search.SortExpression(expression=loc_expr, direction=search.SortExpression.ASCENDING, default_value=max_dist+1)
            search_query = search.Query(query_string=query, options=search.QueryOptions(sort_options=search.SortOptions(expressions=[sortexpr])))

            # get the index and execute the query
            index = search.Index('Polls')
            search_results = index.search(search_query)
            for doc in search_results:
                # index.delete(doc.doc_id)

                if distance_ll(request.args.get('lat'), request.args.get('lon'), doc.fields[1].value.latitude, doc.fields[1].value.longitude) <= doc.fields[0].value:
                    near.append(int(doc.doc_id))

            # Get the actual polls based on the ids that we put in the search results
            polls_near = ndb.get_multi([ndb.Key(Poll, k) for k in near])

            # Proccess the results and convert to a json object and return
            result = []
            for i in polls_near:
                if not i:
                    continue
                result.append(i.serialize(voted=did_user_vote(claims['sub'], i.participants)))
            return {"result": result}, 200



        # If there is an error searching we will be bumped out here
        except search.Error as e:
            logging.error("Error tryin to search for polls")
            logging.error(e)
            return {"error": "Error while searching for polls"}, 400


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
            result.append(i.serialize(voted=did_user_vote(claims['sub'], i.participants)))
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

        return {"result": newPoll.serialize(voted=did_user_vote(claims['sub'], newPoll  .participants))}, 201