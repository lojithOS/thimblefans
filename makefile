# Variables
LDFLAGS = -lhidapi-hidraw
SRC = $(wildcard src/*.c)
OUT = fan_speed_control

build:
	@gcc $(SRC) -o $(OUT) $(LDFLAGS)
	@echo "Build complete."