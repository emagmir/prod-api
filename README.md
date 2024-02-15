FASTAPI used for who knows what

This branch is as of now incomplete, will return to it later

CI part is done, CD not quite

This deployment needs ECS using EC2 instances as provider. from within the instances, it is working, not so much from outside aws

These instances need to have the private docker credentials provisioned as per below instrunctions:

https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth-container-instances.html

No other method of pulling private docker images i found working

You need also to create an AmazonDucumentDB cluster

That cluster will provide the login credentials, for ex, that need to be added to the mongo connection files:
--> mongodb://pythonadmin:pythonadmin@fast-api-docudb.cluster-ckrpn1rvr9wq.us-east-1.docdb.amazonaws.com:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false

(cluster has been deleted, credentials are no longer valid)

Some security groups need to be created, to allow traffic between containers and docu db cluster