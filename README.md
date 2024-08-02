Simple Dockerfile to produce image of a simple web server that calls url given in query string and returns the response.

Target url is passed as query string in the request to the server in format `http://server:8080?targetX=other_server`, where X is number from 0 to 9 - used is target with lowest number.

Parameter `protocolX` can be used to specify protocol of the target server, `http` is default.

All query params other than used `targetX` (and `protocolX`) are passed to the target server.

Calling of url `http://frontend:8080?target1=backend:8080&target2=database:8080` will call `http://backend:8080?target2=database:8080`.

