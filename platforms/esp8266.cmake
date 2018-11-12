set(ARDUINO_FCPU "80000000L")
set(ARDUINO_PORT "/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0")
set(LDSCRIPT "eagle.flash.1m512.ld")

set(PKG_PATH "$ENV{HOME}/.arduino15/packages/esp8266")

set(GCC_PATH "${PKG_PATH}/tools/xtensa-lx106-elf-gcc/1.20.0-26-gb404fb9-2/bin/")
set(SDK_PATH "${PKG_PATH}/hardware/esp8266/2.3.0/tools/sdk")


enable_language(ASM)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_ASM_COMPILER "${GCC_PATH}/xtensa-lx106-elf-gcc")
set(CMAKE_C_COMPILER "${GCC_PATH}/xtensa-lx106-elf-gcc")
set(CMAKE_CXX_COMPILER "${GCC_PATH}/xtensa-lx106-elf-g++")
set(CMAKE_AR "${GCC_PATH}/xtensa-lx106-elf-ar")

set(C_WARNING_FLAGS "                     \
  -Wall -Wextra                           \
  -Wpointer-arith                         \
  -Wno-implicit-function-declaration      \
  ")
set(CXX_WARNING_FLAGS "                   \
  -Wall -Wextra                           \
  ")

set(ARDUINO_FLAGS "                       \
  -DARDUINO=10805                         \
  -DARDUINO_ARCH_ESP8266                  \
  -DARDUINO_ESP8266_ESP01                 \
  -DESP8266                               \
  -DARDUINO_BOARD=\\\"ESP8266_ESP01\\\"   \
  -DF_CPU=${ARDUINO_FCPU}                 \
  -DLWIP_OPEN_SRC                         \
  -D__ets__                               \
  -DICACHE_FLASH                          \
  -U__STRICT_ANSI__                       \
  ")

# Compilation flags
set(CMAKE_ASM_FLAGS "                     \
  ${ARDUINO_FLAGS}                        \
  -g -x assembler-with-cpp                \
  -mlongcalls -MMD                        \
  ")

set(CMAKE_C_FLAGS "                       \
  ${ARDUINO_FLAGS}                        \
  ${C_WARNING_FLAGS}                      \
  -g -Os -std=gnu99                       \
  -Wl,-EL -nostdlib                       \
  -mlongcalls -mtext-section-literals     \
  -fno-inline-functions -fdata-sections   \
  -ffunction-sections -falign-functions=4 \
  -MMD                                    \
  ")

set(CMAKE_CXX_FLAGS "                     \
  ${ARDUINO_FLAGS}                        \
  ${CXX_WARNING_FLAGS}                    \
  -g -Os -std=c++11                       \
  -mlongcalls -mtext-section-literals     \
  -fno-exceptions -fno-rtti -fdata-sections \
  -ffunction-sections -falign-functions=4 \
  -MMD                                    \
  ")

set(CMAKE_EXE_LINKER_FLAGS "              \
  ${CMAKE_EXE_LINKER_FLAGS}               \
  -L${SDK_PATH}/ld                        \
  -T ${LDSCRIPT}                          \
  -nostdlib                               \
  -Wl,--no-check-sections                 \
  -Wl,-static                             \
  -Wl,--gc-sections                       \
  -u call_user_start                      \
  -u _printf_float                        \
  -u _scanf_float                         \
  -Wl,-wrap,system_restart_local          \
  -Wl,-wrap,register_chipv6_phy           \
  ")

# add include directories
include_directories(
  ${PKG_PATH}/hardware/esp8266/2.3.0/tools/sdk/include
  ${PKG_PATH}/hardware/esp8266/2.3.0/tools/sdk/lwip/include
  ${PKG_PATH}/hardware/esp8266/2.3.0/cores/esp8266
  ${PKG_PATH}/hardware/esp8266/2.3.0/variants/generic
)

# add arduino sources
set(ARDUINO_CORE_DIR "${PKG_PATH}/hardware/esp8266/2.3.0/cores/esp8266/")
file(GLOB_RECURSE ARDUINO_CORE_FILES
  "${ARDUINO_CORE_DIR}/*.S"
  "${ARDUINO_CORE_DIR}/*.c"
  "${ARDUINO_CORE_DIR}/*.cpp"
)
target_sources(${CMAKE_PROJECT_NAME} PUBLIC ${ARDUINO_CORE_FILES})
# turn off warnings for core
set_source_files_properties(${ARDUINO_CORE_FILES} PROPERTIES COMPILE_FLAGS -w)

# add libraries
find_library(STDC++_LIB       stdc++      HINTS ${SDK_PATH}/lib)
find_library(MAIN_LIB         main        HINTS ${SDK_PATH}/lib)
find_library(AIRKISS_LIB      airkiss     HINTS ${SDK_PATH}/lib)
find_library(AXTLS_LIB        axtls       HINTS ${SDK_PATH}/lib)
find_library(CRYPTO_LIB       crypto      HINTS ${SDK_PATH}/lib)
find_library(ESPNOW_LIB       espnow      HINTS ${SDK_PATH}/lib)
find_library(HAL_LIB          hal         HINTS ${SDK_PATH}/lib)
find_library(LWIP_GCC_LIB     lwip_gcc    HINTS ${SDK_PATH}/lib)
find_library(MESH_LIB         mesh        HINTS ${SDK_PATH}/lib)
find_library(NET80211_LIB     net80211    HINTS ${SDK_PATH}/lib)
find_library(PHY_LIB          phy         HINTS ${SDK_PATH}/lib)
find_library(PP_LIB           pp          HINTS ${SDK_PATH}/lib)
find_library(SMARTCONFIG_LIB  smartconfig HINTS ${SDK_PATH}/lib)
find_library(WPA_LIB          wpa         HINTS ${SDK_PATH}/lib)
find_library(WPA2_LIB         wpa2        HINTS ${SDK_PATH}/lib)
find_library(WPS_LIB          wps         HINTS ${SDK_PATH}/lib)

target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PUBLIC
  -Wl,--start-group
  ${HAL_LIB}
  ${PHY_LIB}
  ${PP_LIB}
  ${NET80211_LIB}
  ${MAIN_LIB}
  ${LWIP_GCC_LIB}
  ${WPA_LIB}
  ${CRYPTO_LIB}
  ${WPS_LIB}
  ${AXTLS_LIB}
  ${ESPNOW_LIB}
  ${SMARTCONFIG_LIB}
  ${AIRKISS_LIB}
  ${MESH_LIB}
  ${WPA2_LIB}
  ${STDC++_LIB}
  m
  c
  gcc
  -Wl,--end-group
  )


# Add sdk libraries
foreach(LIB ${LIBS})
  set(LIB_PATH "${PKG_PATH}/hardware/esp8266/2.3.0/libraries/${LIB}")
  file(GLOB_RECURSE LIB_FILES
    "${LIB_PATH}/*.cpp"
    "${LIB_PATH}/src/*.cpp"
    )
  set_source_files_properties(${LIB_FILES} PROPERTIES COMPILE_FLAGS "-w")
  target_sources(${CMAKE_PROJECT_NAME} PUBLIC ${LIB_FILES})
  file(GLOB_RECURSE LIB_HEADERS
    "${LIB_PATH}/*.h"
    "${LIB_PATH}/src/*.h"
    )
  set_source_files_properties(${LIB_HEADERS} PROPERTIES COMPILE_FLAGS "-w")
  include_directories(${LIB_PATH})
  include_directories("${LIB_PATH}/src")
endforeach()


set(CMAKE_EXECUTABLE_SUFFIX ".elf")

set(PORT $ENV{ARDUINO_PORT})
if (NOT PORT)
	set(PORT ${ARDUINO_PORT})
endif()

find_program(
  ESPTOOL "esptool"
  HINTS "${PKG_PATH}/tools/esptool/0.4.9"
  )
find_program(
  OBJCOPY "xtensa-lx106-elf-objcopy"
  HINTS "${GCC_PATH}"
  )
find_program(
  SIZE "xtensa-lx106-elf-size"
  HINTS "${GCC_PATH}"
  )

set(BOOTLOADER_ELF "${PKG_PATH}/hardware/esp8266/2.3.0/bootloaders/eboot/eboot.elf")
set(FLASH_MODE "dio")
set(FLASH_FREQ "40m")
set(FLASH_CHIPSIZE "1M")


if(ESPTOOL AND SIZE)
	# Make firmware and print size
	add_custom_target(hex)
	add_dependencies(hex ${CMAKE_PROJECT_NAME})
	add_custom_command(
    TARGET hex 
    POST_BUILD
		COMMAND
      ${ESPTOOL}
      -v
      -eo ${BOOTLOADER_ELF}
      -bo ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
      -bm ${FLASH_MODE}
      -bf ${FLASH_FREQ}
      -bz ${FLASH_CHIPSIZE}
      -bs .text
      -bp 4096
      -ec
      -eo ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf
      -bs .irom0.text
      -bs .text
      -bs .data
      -bs .rodata
      -bc
      -ec
    COMMAND ${SIZE} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf
  )
endif()

if(ESPTOOL)
  # Upload hex to arduino
	add_custom_target(upload)
	add_dependencies(upload hex)
	add_custom_command(
    TARGET upload
    POST_BUILD
		COMMAND
      ${ESPTOOL}
      -v
      -cd ck
#       -cb 115200
      -cb 921600
      -cp ${PORT}
      -cf ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
#       -cr
	)
endif()
