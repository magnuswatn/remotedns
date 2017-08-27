"""
A little REST server that looks up DNS query from a request, and responds with the answer as JSON.

Must be placed behind a reverse proxy with authentication.
"""
import json

import ipaddress
import dns.resolver
import dns.exception

from flask import Flask
from flask import request
from flask import Response

TIMEOUT = 5

app = Flask(__name__)

def lookup(record_type, name, nameserver):
    """Looks up the requested record"""
    resolver = dns.resolver.Resolver()
    resolver.lifetime = TIMEOUT
    if nameserver:
        nameserver_ip = resolve_nameserver(nameserver)
        resolver.nameservers = [nameserver_ip]
    response = resolver.query(name, record_type, raise_on_no_answer=False)
    answers = []
    for data in response:
        answers += [data.to_text()]
    return answers


def resolve_nameserver(nameserver):
    """Resolve the IP of the nameserver, if it's an FQDN"""
    try:
        ipaddress.ip_address(nameserver)
    except ValueError:
        return dns.resolver.query(nameserver)[0].to_text()
    else:
        return nameserver

@app.route("/dns/<record_type>/<record>", methods=['GET'])
def dns_service(record_type, record):
    """Accepts requests from clients and returns the result of the lookup"""
    try:
        answer = lookup(record_type, record, request.args.get('server'))
    except dns.exception.DNSException as error:
        resp = Response(json.dumps({"error":error.msg}), status=500, mimetype="application/json")
    else:
        resp = Response(json.dumps({"answer":answer}), status=200, mimetype="application/json")
    return resp

if __name__ == "__main__":
    app.run(host='0.0.0.0')
