
#@=====[ pgpool stop  pg03, pg02, pg01]

ssh postgres@pg03.localnet "sudo systemctl stop pgpool"
ssh postgres@pg02.localnet "sudo systemctl stop pgpool"

sudo systemctl stop pgpool



