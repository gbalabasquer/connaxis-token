type = 
name = $(type)

all:; dapp build
clean:; dapp clean
test:; dapp test
deploy:; dapp deploy $(type) $(args) --name=$(name)
