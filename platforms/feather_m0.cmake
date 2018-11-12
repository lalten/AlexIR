set(ARDUINO_BOARD "SAMD_FEATHER_M0")
set(ARDUINO_VARIANTS "feather_m0")
set(ARDUINO_MCU "cortex-m0plus")
set(ARDUINO_FCPU "48000000L")
set(ARDUINO_UPLOAD_PROTOCOL "sam-ba")
set(ARDUINO_PORT "/dev/ttyACM0")

set(GCC_PATH "/home/laurenz/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1")
set(CMSIS_PATH "${CMAKE_SOURCE_DIR}/arduino/tools/CMSIS/4.5.0/CMSIS")
set(CMSIS_ATMEL_PATH "${CMAKE_SOURCE_DIR}/arduino/tools/CMSIS-Atmel/1.1.0/CMSIS/Device/ATMEL")


# enable assembler language
enable_language(ASM)

set(CMAKE_SYSTEM_NAME Generic)

set(CMAKE_ASM_COMPILER "${GCC_PATH}/bin/arm-none-eabi-gcc")
set(CMAKE_C_COMPILER "${GCC_PATH}/bin/arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "${GCC_PATH}/bin/arm-none-eabi-g++")
set(CMAKE_AR "${GCC_PATH}/bin/arm-none-eabi-ar")

set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

set(LDSCRIPT "${CMAKE_SOURCE_DIR}/arduino/variants/${ARDUINO_VARIANTS}/linker_scripts/gcc/flash_with_bootloader.ld")
set(LD_FLAGS "                            \
  -specs=nano.specs -specs=nosys.specs    \
  -L${CMSIS_PATH}/Lib/GCC/                \
  -larm_cortexM0l_math                    \
  -L${CMAKE_SOURCE_DIR}/arduino/variants/${ARDUINO_VARIANTS} \
  -lm                                     \
  -T ${LDSCRIPT}                          \
")

# C only fine tunning
set(TUNING_FLAGS "-Os -Wl,--gc-sections -ffunction-sections -fdata-sections -fno-tree-scev-cprop -flto -fno-fat-lto-objects")
set(WARNING_FLAGS "-Wall -Wextra")

set(ARDUINO_FLAGS "                       \
  -DARDUINO_ARCH_SAMD                     \
  -DARDUINO_SAMD_ZERO                     \
  -D__SAMD21G18A__                        \
  -DF_CPU=${ARDUINO_FCPU}                 \
  -DUSB_VID=0x239A                        \
  -DUSB_PID=0x800B                        \
  -DUSBCON                                \
  '-DUSB_MANUFACTURER=\"Adafruit\"'       \
  '-DUSB_PRODUCT=\"${USB_PRODUCT}\"'      \
  ")

# Compilation flags
set(CMAKE_ASM_FLAGS "-g -x assembler-with-cpp -MMD  ${ARDUINO_FLAGS} ${CMSIS_C_FLAGS}")
set(CMAKE_C_FLAGS "-mcpu=${ARDUINO_MCU} -mthumb -g -Os ${WARNING_FLAGS} -std=gnu11 -ffunction-sections -fdata-sections --param max-inline-insns-single=500 -MMD ${TUNING_FLAGS} ${ARDUINO_FLAGS} ${CMSIS_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-mcpu=${ARDUINO_MCU} -mthumb -g -Os ${WARNING_FLAGS} -std=gnu++11 -ffunction-sections -fdata-sections -fno-threadsafe-statics --param max-inline-insns-single=500 -fno-rtti -fno-exceptions -MMD ${TUNING_FLAGS} ${ARDUINO_FLAGS} ${CMSIS_C_FLAGS}")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LD_FLAGS}" )


file(GLOB CMSIS_INCLUDE_FILES
  "${CMSIS_PATH}/Include/*.h"
  "${CMSIS_ATMEL_PATH}/*.h"
)

set(ARDUINO_CORE_DIR "${CMAKE_SOURCE_DIR}/arduino/core")
file(GLOB_RECURSE ARDUINO_CORE_FILES
  "${ARDUINO_CORE_DIR}/*.h"
  "${ARDUINO_CORE_DIR}/*.S"
  "${ARDUINO_CORE_DIR}/*.c"
  "${ARDUINO_CORE_DIR}/*.cpp"
)

set(ARDUINO_PINS_DIR "${CMAKE_SOURCE_DIR}/arduino/variants/${ARDUINO_VARIANTS}")
file(GLOB ARDUINO_PINS_FILES
  "${ARDUINO_PINS_DIR}/*.cpp"
  "${ARDUINO_PINS_DIR}/*.c"
)

include_directories(
  ${CMSIS_PATH}/Include
  ${CMSIS_ATMEL_PATH}
  ${ARDUINO_PINS_DIR}
  ${ARDUINO_CORE_DIR}
)

set(ARDUINO_SOURCE_FILES
	${ARDUINO_PINS_FILES}
	${ARDUINO_CORE_FILES}
	${CMSIS_INCLUDE_FILES}
)

set(PORT $ENV{ARDUINO_PORT})
if (NOT PORT)
	set(PORT ${ARDUINO_PORT})
endif()

find_program(BOSSAC "bossac" HINTS "/home/laurenz/.arduino15/packages/arduino/tools/bossac/1.7.0/")
find_program(SIZE "arm-none-eabi-size" HINTS "/opt/arduino/arduino-1.8.5/hardware/tools/arm/bin/")
find_program(OBJCOPY "arm-none-eabi-objcopy" HINTS "/opt/arduino/arduino-1.8.5/hardware/tools/arm/bin/")

if(OBJCOPY AND SIZE)
	# Make firmware and print size
	add_custom_target(hex)
	add_custom_command(
    TARGET hex
    POST_BUILD
		COMMAND ${OBJCOPY} -O binary ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
		COMMAND ${OBJCOPY} -O ihex -R .eeprom ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.hex
    COMMAND ${SIZE} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}
  )
endif()

if(BOSSAC)
  # Upload hex to arduino
	add_custom_target(upload)
	add_dependencies(upload hex)
	add_custom_command(
    TARGET upload
    POST_BUILD
		COMMAND ${BOSSAC} -i --port=${PORT} -U true -e -w -v ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
	)
endif()
