# Goal for studying:

1. setup auto scaling group
   1. setup scale up and scale down
2. setup EFS
3. auto snapshot
4. setup RDS
5. cloudwatch alarm + sns notification
6. networking between subnet
7. setup NAT network (private, public network)
8. Production + DR
    1. setup servers in 2 vpc
    2. in each vpc, There are 3 subnet backend, frontend and RDS.
    3. one jump host in one vpc
    4. backend web only can access with specific ip + frontend
    4. frontend web can be access publicly
    4. web, ssh access between backend and backend web (cross vpc)
    4. web, ssh access between bacnend and frontend web (same vpc)
    1. load balancer on frontend servers
9. cross vpc (vpc peering)
