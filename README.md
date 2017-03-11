remotedns
=====

This is a silly little thing that exposes DNS lookups over a REST API, so that you can do DNS querys from another "point of view". Can be useful with split DNS.


#### Server

A Python Flask app that can run in a Docker container on a remote computer. Must be placed behind a reverse proxy (Apache/nginx/Caddy) that does https and basic auth.

#### Client

A Powershell module that talkes to the server via https. To use it, you need to define the following variables in your Powershell profile: ResolveDnsNameFromRemote_Username, ResolveDnsNameFromRemote_Password and ResolveDnsNameFromRemote_URL.
