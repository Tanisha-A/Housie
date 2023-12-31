#!/usr/bin/python
import psycopg2 
from db_config import config

def connect_and_executeQuery(queryString,values=()):
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
		
        # create a cursor
        cur = conn.cursor()
        
	# execute a statement
        cur.execute(queryString,values)

        # display the PostgreSQL database server version
        result= cur.fetchone()
        conn.commit()
        
       
	# close the communication with the PostgreSQL
        cur.close()
        return result
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        raise error
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
