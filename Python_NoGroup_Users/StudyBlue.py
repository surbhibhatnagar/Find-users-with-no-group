#!/usr/bin/python
import os.path


def getUsersWithNoGroup(usrs, usrgrp, outputpath):
    """
    Write users with no groups to a file present at outputpath in linear time
    :param usrs: Dict[uid]=(uid,name,gid)
    :param usrgrp: Dict[(uid,gid)]=(uid,name,gid)
    :param outputpath: File pathname of output file
    :return:
    """
    file = open(outputpath, 'w')
    # For every user with uid and gid verify if there is a matching entry in
    # usrgrp dict
    for key, value in usrs.items():
        # Case3.1 user has multiple groups
        gid = value[2]
        if "," in gid:
            list_gid = gid.split(",")
            isFoundinOneGroupAtLeast = False
            for gid in list_gid:
                if (key, gid) in usrgrp:
                    isFoundinOneGroupAtLeast = True
                    break
            if not isFoundinOneGroupAtLeast:
                file.write(str(value) + '\n')
        # Case3.1 user belongs to single group
        else:
            if (key, gid) not in usrgrp:
                file.write(str(value) + '\n')
    file.close()


def createUsrDict(userfilepath, usrs):
    """
    Create dictionary of users from file at userfilepath
    :param userfilepath: File pathname of input file
    :param usrs: Dict[uid]=(uid,name,gid)
    :return:
    """
    if os.path.exists(userfilepath):
        file = open(userfilepath, 'r')
    else:
        return
    while True:
        line = file.readline()
        line = line.replace('\n', ' ')
        line = line.strip()
        if not line:
            break
        uid, name, gid = line.split(":")
        # Store the values into a user dict using tuple
        usrs[(uid)] = (uid, name, gid)
    file.close()


def createUsrGroupDict(groupfilepath, usrgrp):
    """
    Create dictionary of user-group mapped to (id,name,gid) from file at
    groupfilepath
    :param groupfilepath: File pathname of input file
    :param usrgrp: Dict[(uid,gid)]=(gid,name,uid)
    :return:
    """
    if os.path.exists(groupfilepath):
        file = open(groupfilepath, 'r')
    else:
        return
    while True:
        line = file.readline()
        line = line.replace('\n', ' ')
        line = line.strip()
        if not line:
            break
        gid, name, luid = line.split(":")
        # Store the values into a user group mapping in a dict using tuple
        luid = luid.split(",")
        for uid in luid:
            usrgrp[(uid, gid)] = (gid, name, luid)
    file.close()


def main():
    """
    Write users with no groups to a file called output.txt
    Case 1: users with no group id defined in users file
    Case 2: users with non existent group ids
    Case 3: Find groups that have mismatch values
    :return:
    """
    userfilepath = 'users.txt'
    groupfilepath = 'groups.txt'
    outputfilepath = 'output.txt'
    usrs = {}
    usrgrp = {}
    createUsrDict(userfilepath, usrs)
    createUsrGroupDict(groupfilepath, usrgrp)
    getUsersWithNoGroup(usrs, usrgrp, outputfilepath)


if __name__ == "__main__":
    main()
