# This docker file has next features:
# 1. send_email

FROM ubuntu:latest
MAINTAINER morgan.wu "eHVlNzc3aHVhQGdtYWlsLmNvbQo="

USER root
WORKDIR /root/

ENV LANG C.UTF-8

RUN apt-get update 
RUN apt-get install -y mutt ca-certificates

ENV GMAIL_USER ""
ENV GMAIL_FULLNAME "MailBot"
ENV GMAIL_PASS ""

RUN mkdir /data
VOLUME ["/data"]
ENV EMAIL_SUBJ "Email Subject"
ENV EMIAL_FILE_CONTENT "content.html"

# split by comma
ENV EMAIL_TO_LIST "goodpaper77@gmail.com"
ENV EMAIL_CC_LIST "goodpaper77@gmail.com"

ADD muttrc /root/.muttrc

ENTRYPOINT ["bash", "-c"]
CMD ["mutt -s \"${EMAIL_SUBJ}\" -c \"${EMAIL_CC_LIST}\" \"${EMAIL_TO_LIST}\" < /data/${EMIAL_FILE_CONTENT}"]

# mutt -s 'sub' xue777hua@gmail.com -c amymeng5277@gmail.com,xue777hua@gmail.com < content

# send the email
# cat server_status.txt | mutt -s "VM is down, please help to boot up" user1@company.com,user2@company.com -c myself@company.com -c myManager@company.com



