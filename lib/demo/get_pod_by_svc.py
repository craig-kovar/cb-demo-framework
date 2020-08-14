import subprocess
import sys
import time
import random
import os
import json
import argparse

def get_pod_by_svc(prefix, ns, svc):
    tmppod = "undefined"
    svcmap = "undefined"
    p = subprocess.Popen("kubectl get pods -n {}".format(ns), shell=True, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        spaces = line.split()
        if len(spaces) >= 2:
            if prefix in spaces[0].decode("ascii") and spaces[1].decode("ascii") == "1/1":
                tmppod = spaces[0].decode("ascii")
                break

    if tmppod != "undefined":
        p2 = subprocess.Popen(
            "kubectl exec -it {0} -n {1} -- curl --user \"Administrator:password\" --silent \"http://localhost:8091/pools/default/nodeServices\"".format(
                tmppod, ns), shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for line in p2.stdout.readlines():
            svcmap = line.decode("ascii")

    if svcmap != "undefined":
        parsedmap = json.loads(svcmap)
        for i in parsedmap["nodesExt"]:
            for j in i["services"]:
                if j == svc:
                    return i["hostname"]

    return "undefined"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-ns", "--namespace", help="Specify the namespace to use")
    parser.add_argument("-p", "--prefix", help="Specify the prefix to search for")
    parser.add_argument("-s", "--svc", help="Specify the service to search for")
    parser.add_argument("-sn", "--shortname", help="Indicate that the shortname should be returned", action="store_true") 
    args = parser.parse_args()

    svc = "undefined"
    if "kv" in args.svc.lower():
        svc = "kv"
    elif "index" in args.svc.lower():
        svc = "indexAdmin"
    elif "n1ql" in args.svc.lower():
        svc = "n1ql"
    elif "fts" in args.svc.lower():
        svc = "fts"
    elif "cbas" in args.svc.lower() or "analytics" in args.svc.lower():
        svc = "cbas"
    elif "eventing" in args.svc.lower():
        svc = "eventingAdminPort"

    name=get_pod_by_svc(args.prefix, args.namespace, svc)

    if args.shortname:
        name=name.split(".")[0]
    
    print(name)
    
