from flask_restful import Resource

class Test_route(Resource):
    def get(self):
        return {'Status': 'Works!', "Messge": "This code is running on Google's scalable infrastructure. Pretty Neato!"}
    def put(self):
        return {'message': "This is the put route"}
