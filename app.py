from flask import Flask
from flask_restful import Api
import flask_cors
from resources import Test_route, Post_poll, Specific_Poll, User_polls, Location_polls, Demo_polls

app = Flask(__name__)
flask_cors.CORS(app)
api = Api(app)

#Add resources to the api
prefix = "/api/v1.0"
api.add_resource(Test_route, "/test")
api.add_resource(Post_poll, prefix + "/polls")
api.add_resource(Specific_Poll, prefix + "/polls/<poll_id>")
api.add_resource(User_polls, prefix + "/user/polls")
api.add_resource(Location_polls, prefix + "/location/polls")
api.add_resource(Demo_polls, prefix + "/demo")