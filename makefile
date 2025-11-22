# Variables
CFLAGS = -Wall -Wextra
LDFLAGS = -lhidapi-hidraw -lpthread
SRC = $(wildcard src/*.c)
OUT = fan_speed_control

build:
	@gcc $(SRC) -o $(OUT) $(CFLAGS) $(LDFLAGS)
	@echo "Build complete."
	@echo "Build finished. You can run './$(OUT)' to test."