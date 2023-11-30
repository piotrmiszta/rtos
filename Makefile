# Makefile template from
#	https://github.com/cpq/bare-metal-programming-guide/blob/main/steps/step-0-minimal/Makefile

INC_DIR = -Iinclude/
INCLUDES = $(INC_DIR)
INCLUDES += $(INC_DIR)kernel/
INCLUDES += $(INC_DIR)lib/

CFLAGS  ?=  -W -Wall -Wextra --pedantic -Wundef -Wshadow -Wdouble-promotion \
            -Wformat-truncation -fno-common -Wconversion \
            -g3 -ffunction-sections -fdata-sections -I. $(INCLUDES) \
            -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 $(EXTRA_CFLAGS)

TESTFLAGS = -W -Wall -Wextra --pedantic -Werror $(INCLUDES)

LDFLAGS ?= -TFLASH.ld --specs nano.specs -lc -lgcc -Wl,--gc-sections -Wl,-Map=$@.map
SOURCES += src/*.c
SOURCES += startup/startup.s
SOURCES += src/kernel/*.c
SOURCES += src/lib/cm7/*.c
SOURCES += src/lib/stm32h755/*.c

TEST_SOURCES += test/*.c

ifeq ($(OS),Windows_NT)
  RM = cmd /C del /Q /F
else
  RM = rm -f
endif

all: test

test: test_build test_run
test_build: $(SOURCES) $(TEST_SOURCES)
	gcc $(TEST_SOURCES) $(TESTFLAGS) -o build/test.exe

test_run:
	build/test.exe

build: clean build/firmware.bin

build/firmware.elf: $(SOURCES)
	arm-none-eabi-gcc $(SOURCES) $(CFLAGS) $(LDFLAGS) -o $@

build/firmware.bin: build/firmware.elf
	arm-none-eabi-objcopy -O binary $< $@

flash: build/firmware.bin
	st-flash --reset write $< 0x8000000

clean:
	$(RM) build\firmware*.* build\test.exe
