#!/usr/bin/python

import sys, getopt
import airflow
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser

def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"u:e:p:",["username=","emailaddress=","password="])
    except getopt.GetoptError:
        print 'adduser.py -u <username> -e <emailaddress> -p <password>'
        sys.exit(2)
    print 'OPTIONS :', opts
    for opt, arg in opts:
        if opt in ("-u", "--username"):
            username = arg
        elif opt in ("-e", "--emailaddress"):
            emailaddress = arg
        elif opt in ("-p", "--password"):
            password = arg
    print 'Output username is ', username
    print 'Output emailaddress is ', emailaddress
    print 'Output password is ', password
    user = PasswordUser(models.User())
    user.username = username
    user.email = emailaddress
    user.password = password
    session = settings.Session()
    session.add(user)
    session.commit()
    session.close()
    exit()

if __name__ == "__main__":
    main(sys.argv[1:])
