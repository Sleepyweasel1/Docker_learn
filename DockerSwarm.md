# Docker Swarm
## Start the Swarm
'''
docker swarm init
'''
- initiate a docker swarm, node command is used on becomes the manager node
'''
docker swarm join --token SWMTKN-1-02fzfbg0nxz7v8uktv4hix9gqq81fqnb23nb4tg5isqqqqb448-5t051dq5r30i7drupk5zlcusx 192.168.20.1:2377
'''
- command to join a worker to the swarm
- this command is displayed after the init command to assist with joining worker nodes
'''
docker node ls
'''
- will list the nodes and their sate in the swarm