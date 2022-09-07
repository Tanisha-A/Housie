
from crypt import methods
from pickle import NONE
from unittest import removeResult
from flask import Flask,request,jsonify
import json,random as rand
from generate_ticket import gen_ticket
from db_connect import connect_and_executeQuery as ceq
import psycopg2 as ps2

app = Flask(__name__)

# GET request to geneate a ticket
@app.route('/create_game',methods=['Post'])
def get_game_code():
    req =json.loads(request.data)
    username = req['username']
    try:        
        res=ceq(f"SELECT * FROM public.Games WHERE gameOwner = '{username}'")
        if len(res) > 0:
            return {'gameCode':res[0],'gameType':'in-progress','gameStatus':res[1]}
    except (Exception, ps2.DatabaseError):
        pass

    game_id = rand.randint(10000,99999)
    game_status = '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
    try:        
        res=ceq(f"INSERT INTO public.Games(gameid, gamestatus,gameowner)VALUES (%s,%s,%s) RETURNING gameid;",(game_id,game_status,username))
    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":"An error occured while initialising the game try again."})
    return {'gameCode':res[0],'gameType':'new-game','gameStatus':game_status}

@app.route('/join_game_with_code',methods=['Post'])
def join_game_with_code():
    req =json.loads(request.data)
    username = req['username']
    game_id =  req['game_id']
    try:
        res =ceq("SELECT username, gameid, userticket FROM public.usergames where username=%s and gameid=CAST(%s as varchar);",(username,game_id))
        if(not res):
            x = gen_ticket()
            ticket= x['layout']
            str_ticket=".".join([(",".join([str(x) for x in row])) for row in ticket])
            print(str_ticket)
            ceq(f"INSERT INTO public.usergames(username, gameid, userticket)VALUES (%s,%s,%s) RETURNING username,gameid;",(username,game_id,str_ticket))
            return jsonify({"status":"success","ticket":flatten(ticket)})
        else:
            ticket=[list(map(lambda x:int(x),row.split(","))) for row in res[2].split(".")]
            print(ticket)
            return jsonify({"status":"success","ticket":[x for sublist in ticket for x in sublist]})
    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":"An error occured while initialising the game try again."})


@app.route('/updateGameStatus',methods=['Post'])
def updateGameStatus():
    try:
        req =json.loads(request.data)
        gameCode =req["gameCode"]
        latest_number =req["number"]
        print("Latest number")
        print(latest_number)
        if not latest_number <=100 and latest_number >=1:
            raise Exception("Number cannot be less than 0 or more than 100")
        res= ceq(f"select * from Games where gameid={gameCode};")
        game_status =res[1]
        print(game_status)
        new_game_status = game_status[:latest_number-1] + "1" + game_status[latest_number:]
        print(new_game_status)
        ceq("UPDATE public.games SET gamestatus=%s WHERE gameid=%s returning gameid;",(new_game_status,gameCode))

    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":str(error)})

    return jsonify({"status":"Success","game_status":new_game_status})

@app.route('/getGameStatus',methods=['Post'])
def getGameStatus():
    try:
        req =json.loads(request.data)
        print(req)
        gameCode =req["gameCode"]
        res= ceq(f"select * from Games where gameid={gameCode};")
        game_status =res[1]

        print({"status":"Success","game_status":game_status})
    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":str(error)}),400

    return jsonify({"status":"Success","game_status":game_status})


@app.route('/register',methods=['Post'])
def register():
    req =json.loads(request.data)
    username = req['username']
    password = req['password']
    Confirmpassword=req['confirmPassword']

    try:
        if(password==Confirmpassword):
            res =ceq(f"INSERT INTO public.register VALUES (%s, %s) RETURNING username;",(username,password))
        else:
            raise Exception("An error occured while Registering,try again.")
    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":str(error)})

    return jsonify({"status":"Success","username":res[0]})


@app.route('/login',methods=['Post'])
def login():
    req =json.loads(request.data)
    username = req['username']
    print(username)
    password = req['password']
    try:
        res = ceq(f"SELECT * FROM register where username ='{username}';")
        actual_password=res[1]
        if password==actual_password:
            return jsonify({"allowLogin":True,"username":username})
        else:
            raise jsonify({"allowLogin":False,"username":username})
    except (Exception, ps2.DatabaseError) as error:
        return jsonify({"status":"Failure","errorSource":"Invalid username or password.","allowLogin":False})

@app.route('/registerWinner',methods=['Post'])
def registerWinner():
    req =json.loads(request.data)
    try:
        res = ceq(f"SELECT {req['objective']} FROM games where gameid ={req['gameID']};")
        print(f"SELECT {req['objective']} FROM games where gameid ={req['gameID']};")
        print(res[0])
        if(res[0]==None):
            print(f"UPDATE games set {req['objective']} = '{req['username']}' where gameid = {req['gameID']};")
            ceq(f"UPDATE games set {req['objective']} = '{req['username']}' where gameid = {req['gameID']} returning gameid;;")
            return jsonify( {"result":"success", "msg":f"Congratulations you secured the {req['objective']} objective.",'registered':True})
        elif(res[0]== req['username']):
            return jsonify({"status":"success","msg":"You have already secured this objective",'registered':True})
        else:
            return jsonify({"status":"success","msg":"A player has already secured this objective before you",'registered':False})
    except (Exception, ps2.DatabaseError) as error:
        print(error)
        return jsonify({"status":"Failure","errorSource":"Invalid request",'registered':False})

@app.route('/winnerList',methods=['POST'])
def declarewinner():
    req =json.loads(request.data)
    try:
        res = ceq(f"SELECT w_4c,w_r1,w_r2,w_r3,w_fh FROM games where gameid = {req['gameID']};")
        if(not res):
            raise Exception("Invalid gameID")
        print(f"SELECT w_4c,w_r1,w_r2,w_r3,w_fh FROM games where gameid = {req['gameID']};")
        return jsonify({"FourCorner":res[0],"FirstRow":res[1],"MiddleRow":res[2],"LastRow":res[3],"FullHousie":res[4]})
    except (Exception, ps2.DatabaseError) as error:
        print(error)
        return jsonify({"status":"Failure","errorSource":str(error)})
            



app.run(host='localhost', port=5005)


