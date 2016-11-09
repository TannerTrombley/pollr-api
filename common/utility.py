

def did_user_vote(user_id, participants):
    '''

    :param user_id: the user id of the person you are checking
    :param participants: a list of people who have voted on the poll
    :return:
    True if the user voted, False otherwise
    '''
    return user_id in participants