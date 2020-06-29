
#@=====[ pgpool start pg01, pg02, pg03]
sudo systemctl start pgpool

ssh postgres@pg02.localnet "sudo systemctl start pgpool"
ssh postgres@pg03.localnet "sudo systemctl start pgpool"

#@=====[log check : sudo journalctl --unit pgpool -f]
#sudo journalctl --unit pgpool -f




