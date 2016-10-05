# Razor-Server
(razor-server, razor, postgresql - CentOS7)


# Create Data directory on docker host
$mkdir -p /containerstore/razor

$docker run -ti -p 5432:5432 -p 8150:8150 --name razor-server -v /Containerstore/razor/:/var/lib/razor/repo-store <Imagename>
