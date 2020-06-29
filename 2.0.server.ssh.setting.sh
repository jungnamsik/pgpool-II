# as postgres
#@=====[postgres ssh 설정]

ssh-keygen -t rsa
ssh-copy-id postgres@pg01
ssh-copy-id postgres@pg02
ssh-copy-id postgres@pg03
# ---------------------------------
# ssh-copy-id postgres@pg01.localnet
# ssh-copy-id postgres@pg02.localnet
# ssh-copy-id postgres@pg03.localnet
