CWD=$(shell pwd)

build:
	docker build -t morgan:mail -f mail.dockerfile.md .
run:
	docker run --name morgan_mail -d morgan:mail sleep 1000000
test_send:
	echo "test<br/> content<hr/>From Morgan" > content.html
	[[ -z $$EMAIL_USER ]] && read -p "Enter email user: " EMAIL_USER ; \
[[ -z $$EMAIL_PASS ]] && read -p "Enter email pass: " EMAIL_PASS ; \
[[ -z $$EMAIL_SUBJ ]] && EMAIL_SUBJ="Test Sub" ; \
[[ -z $$EMAIL_TO_LIST ]] && EMAIL_TO_LIST="xue777hua@gmail.com" ; \
docker run --rm --name morgan_mutt \
		-e GMAIL_USER="$$EMAIL_USER" \
		-e GMAIL_PASS="$$EMAIL_PASS" \
		-e EMAIL_SUBJ="$$EMAIL_SUBJ" \
		-e EMAIL_TO_LIST="$$EMAIL_TO_LIST" \
		-v $(CWD):/data \
		morgan:mail 
exec:
	docker exec -it morgan_mail bash
rm:
	docker rm -vf morgan_mail
rmi:
	docker rmi morgan:mail
clean:
	docker rm -vf morgan_mail
	docker rmi morgan:mail

