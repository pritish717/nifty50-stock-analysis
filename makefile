pipeline:
	docker-compose run --rm pipeline

project:
	docker-compose up -d --build prefect-server
	KAGGLE_USERNAME=$(KAGGLE_USERNAME) KAGGLE_KEY=$(KAGGLE_KEY) docker-compose up --build pipeline
	docker compose up -d --build --no-deps evidence

dashboard:
	open http://localhost:3000

prefect-server:
	open http://localhost:4200

down:
	docker-compose down

clean:
	docker-compose down -v
