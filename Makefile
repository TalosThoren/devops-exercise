MONGODB_CONTAINER := devopsexercise_mongodb_1

default: populate-mongo

check: populate-mongo
	-/bin/bash ./curl-check.sh

populate-mongo: up
	-docker exec -t ${MONGODB_CONTAINER} /bin/bash /test/data/populate-mongo.sh

up:
	-docker-compose up -d

clean:
	-docker-compose down

.PHONY: up clean populate-mongo check
