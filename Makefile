build:
	docker build -f ./Dockerfile -t mzyap_image .

run: build
	docker run --rm -it mzyap_image

clean:
	docker system prune -a -f 

info:
	docker system df -v