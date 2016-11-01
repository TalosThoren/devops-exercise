default: up

up:
	-docker-compose up -d
	-docker exec -t devopsexercise_mongodb_1 /usr/bin/mongoimport --db auth --collection users /test/data/user.json
	-docker exec -t devopsexercise_mongodb_1 /usr/bin/mongoimport --db data --collection accounts /test/data/account.json

clean:
	-docker-compose down

.PHONY: up clean
