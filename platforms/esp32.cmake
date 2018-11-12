set(ARDUINO_FCPU "240000000L")
set(ARDUINO_PORT "/dev/ttyUSB0")

set(PKG_PATH "$ENV{HOME}/Arduino/hardware/espressif/esp32")


set(GCC_PATH "${PKG_PATH}/tools/xtensa-esp32-elf/bin/")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_ASM_COMPILER "${GCC_PATH}/xtensa-esp32-elf-gcc")
set(CMAKE_C_COMPILER "${GCC_PATH}/xtensa-esp32-elf-gcc")
set(CMAKE_CXX_COMPILER "${GCC_PATH}/xtensa-esp32-elf-g++")
set(CMAKE_AR "${GCC_PATH}/xtensa-esp32-elf-ar")

set(C_WARNING_FLAGS "                     \
  -Wall -Wextra -Werror=all              \
  -Wpointer-arith                         \
  ")
set(CXX_WARNING_FLAGS "                   \
  -Wall -Wextra                           \
  -Wpointer-arith                         \
  ")

set(ARDUINO_FLAGS "                       \
  -DESP_PLATFORM                          \
  -DMBEDTLS_CONFIG_FILE=\"mbedtls/esp_config.h\" \
  -DHAVE_CONFIG_H                         \
  -DARDUINO=10805                         \
  -DARDUINO_ARCH_ESP32                    \
  -DARDUINO_FEATHER_ESP32                 \
  -DARDUINO_BOARD=\"FEATHER_ESP32\"       \
  -DESP32                                 \
  -DCORE_DEBUG_LEVEL=0                    \
  -DF_CPU=${ARDUINO_FCPU}                 \
  ")

# Compilation flags
set(CMAKE_C_FLAGS "                       \
  ${ARDUINO_FLAGS}                        \
  ${C_WARNING_FLAGS}                      \
  -g3 -Os -std=gnu99                      \
  -nostdlib                               \
  -mlongcalls -mtext-section-literals     \
  -fstack-protector -ffunction-sections   \
  -fdata-sections -fstrict-volatile-bitfields \
  -MMD                                    \
  ")

set(CMAKE_CXX_FLAGS "                     \
  ${ARDUINO_FLAGS}                        \
  ${CXX_WARNING_FLAGS}                    \
  -g3 -Os -std=gnu++11                    \
  -nostdlib                               \
  -mlongcalls -mtext-section-literals     \
  -fstack-protector -ffunction-sections   \
  -fdata-sections -fstrict-volatile-bitfields \
  -MMD                                    \
  ")

# add include directories
set(SDK_PATH "${PKG_PATH}/tools/sdk")
include_directories(
  ${PKG_PATH}/cores/esp32
  ${PKG_PATH}/variants/feather_esp32
  ${SDK_PATH}/include/config
  ${SDK_PATH}/include/bluedroid
  ${SDK_PATH}/include/app_trace
  ${SDK_PATH}/include/app_update
  ${SDK_PATH}/include/bootloader_support
  ${SDK_PATH}/include/bt
  ${SDK_PATH}/include/driver
  ${SDK_PATH}/include/esp32
  ${SDK_PATH}/include/esp_adc_cal
  ${SDK_PATH}/include/ethernet
  ${SDK_PATH}/include/fatfs
  ${SDK_PATH}/include/freertos
  ${SDK_PATH}/include/heap
  ${SDK_PATH}/include/jsmn
  ${SDK_PATH}/include/log
  ${SDK_PATH}/include/mdns
  ${SDK_PATH}/include/mbedtls
  ${SDK_PATH}/include/mbedtls_port
  ${SDK_PATH}/include/newlib
  ${SDK_PATH}/include/nvs_flash
  ${SDK_PATH}/include/spi_flash
  ${SDK_PATH}/include/sdmmc
  ${SDK_PATH}/include/spiffs
  ${SDK_PATH}/include/tcpip_adapter
  ${SDK_PATH}/include/ulp
  ${SDK_PATH}/include/vfs
  ${SDK_PATH}/include/wear_leveling
  ${SDK_PATH}/include/xtensa-debug-module
  ${SDK_PATH}/include/console
  ${SDK_PATH}/include/soc
  ${SDK_PATH}/include/coap
  ${SDK_PATH}/include/wpa_supplicant
  ${SDK_PATH}/include/expat
  ${SDK_PATH}/include/json
  ${SDK_PATH}/include/nghttp
  ${SDK_PATH}/include/lwip
)

# add arduino sources
set(ARDUINO_CORE_DIR "${PKG_PATH}/cores/esp32/")
file(GLOB_RECURSE ARDUINO_CORE_FILES
  "${ARDUINO_CORE_DIR}/*.S"
  "${ARDUINO_CORE_DIR}/*.c"
  "${ARDUINO_CORE_DIR}/*.cpp"
)
target_sources(${CMAKE_PROJECT_NAME} PUBLIC ${ARDUINO_CORE_FILES})
# turn off warnings for core
set_source_files_properties(${ARDUINO_CORE_FILES} PROPERTIES COMPILE_FLAGS -w)


set(CMAKE_EXE_LINKER_FLAGS "              \
  ${CMAKE_EXE_LINKER_FLAGS}               \
  -nostdlib                               \
  -L${SDK_PATH}/ld                        \
  -T esp32_out.ld                         \
  -T esp32.common.ld                      \
  -T esp32.rom.ld                         \
  -T esp32.peripherals.ld                 \
  -T esp32.rom.spiram_incompatible_fns.ld \
  -u ld_include_panic_highint_hdl         \
  -u call_user_start_cpu0                 \
  -Wl,--gc-sections                       \
  -Wl,-static                             \
  -Wl,--undefined=uxTopUsedPriority       \
  -u __cxa_guard_dummy                    \
  -u __cxx_fatal_exception                \
  ")

# add libraries
find_library(APP_TRACE_LIB app_trace HINTS ${SDK_PATH}/lib)
find_library(CXX_LIB cxx HINTS ${SDK_PATH}/lib)
find_library(JSMN_LIB jsmn HINTS ${SDK_PATH}/lib)
find_library(NVS_FLASH_LIB nvs_flash HINTS ${SDK_PATH}/lib)
find_library(TCPIP_ADAPTER_LIB tcpip_adapter HINTS ${SDK_PATH}/lib)
find_library(APP_UPDATE_LIB app_update HINTS ${SDK_PATH}/lib)
find_library(DRIVER_LIB driver HINTS ${SDK_PATH}/lib)
find_library(JSON_LIB json HINTS ${SDK_PATH}/lib)
find_library(OPENSSL_LIB openssl HINTS ${SDK_PATH}/lib)
find_library(ULP_LIB ulp HINTS ${SDK_PATH}/lib)
find_library(BOOTLOADER_SUPPORT_LIB bootloader_support HINTS ${SDK_PATH}/lib)
find_library(ESP32_LIB esp32 HINTS ${SDK_PATH}/lib)
find_library(LOG_LIB log HINTS ${SDK_PATH}/lib)
find_library(PHY_LIB phy HINTS ${SDK_PATH}/lib)
find_library(VFS_LIB vfs HINTS ${SDK_PATH}/lib)
find_library(BT_LIB bt HINTS ${SDK_PATH}/lib)
find_library(ESP_ADC_CAL_LIB esp_adc_cal HINTS ${SDK_PATH}/lib)
find_library(LWIP_LIB lwip HINTS ${SDK_PATH}/lib)
find_library(PP_LIB pp HINTS ${SDK_PATH}/lib)
find_library(WEAR_LEVELLING_LIB wear_levelling HINTS ${SDK_PATH}/lib)
find_library(BTDM_APP_LIB btdm_app HINTS ${SDK_PATH}/lib)
find_library(ESPNOW_LIB espnow HINTS ${SDK_PATH}/lib)
find_library(M_LIB m HINTS ${SDK_PATH}/lib)
find_library(PTHREAD_LIB pthread HINTS ${SDK_PATH}/lib)
find_library(WPA2_LIB wpa2 HINTS ${SDK_PATH}/lib)
find_library(C_LIB c HINTS ${SDK_PATH}/lib)
find_library(ETHERNET_LIB ethernet HINTS ${SDK_PATH}/lib)
find_library(MBEDTLS_LIB mbedtls HINTS ${SDK_PATH}/lib)
find_library(RTC_LIB rtc HINTS ${SDK_PATH}/lib)
find_library(WPA_LIB wpa HINTS ${SDK_PATH}/lib)
find_library(C_NANO_LIB c_nano HINTS ${SDK_PATH}/lib)
find_library(EXPAT_LIB expat HINTS ${SDK_PATH}/lib)
find_library(MDNS_LIB mdns HINTS ${SDK_PATH}/lib)
find_library(SDMMC_LIB sdmmc HINTS ${SDK_PATH}/lib)
find_library(WPA_SUPPLICANT_LIB wpa_supplicant HINTS ${SDK_PATH}/lib)
find_library(COAP_LIB coap HINTS ${SDK_PATH}/lib)
find_library(FATFS_LIB fatfs HINTS ${SDK_PATH}/lib)
find_library(MICRO-ECC_LIB micro-ecc HINTS ${SDK_PATH}/lib)
find_library(SMARTCONFIG_LIB smartconfig HINTS ${SDK_PATH}/lib)
find_library(WPS_LIB wps HINTS ${SDK_PATH}/lib)
find_library(COEXIST_LIB coexist HINTS ${SDK_PATH}/lib)
find_library(FREERTOS_LIB freertos HINTS ${SDK_PATH}/lib)
find_library(NET80211_LIB net80211 HINTS ${SDK_PATH}/lib)
find_library(SOC_LIB soc HINTS ${SDK_PATH}/lib)
find_library(XTENSA-DEBUG-MODULE_LIB xtensa-debug-module HINTS ${SDK_PATH}/lib)
find_library(CONSOLE_LIB console HINTS ${SDK_PATH}/lib)
find_library(HAL_LIB hal HINTS ${SDK_PATH}/lib)
find_library(NEWLIB_LIB newlib HINTS ${SDK_PATH}/lib)
find_library(SPIFFS_LIB spiffs HINTS ${SDK_PATH}/lib)
find_library(CORE_LIB core HINTS ${SDK_PATH}/lib)
find_library(HEAP_LIB heap HINTS ${SDK_PATH}/lib)
find_library(NGHTTP_LIB nghttp HINTS ${SDK_PATH}/lib)
find_library(SPI_FLASH_LIB spi_flash HINTS ${SDK_PATH}/lib)


target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PUBLIC
  -Wl,--start-group
  gcc
  ${APP_TRACE_LIB}
  ${CXX_LIB}
  ${JSMN_LIB}
  ${NVS_FLASH_LIB}
  ${TCPIP_ADAPTER_LIB}
  ${APP_UPDATE_LIB}
  ${DRIVER_LIB}
  ${JSON_LIB}
  ${OPENSSL_LIB}
  ${ULP_LIB}
  ${BOOTLOADER_SUPPORT_LIB}
  ${ESP32_LIB}
  ${LOG_LIB}
  ${PHY_LIB}
  ${VFS_LIB}
  ${BT_LIB}
  ${ESP_ADC_CAL_LIB}
  ${LWIP_LIB}
  ${PP_LIB}
  ${WEAR_LEVELLING_LIB}
  ${BTDM_APP_LIB}
  ${ESPNOW_LIB}
  ${M_LIB}
  ${PTHREAD_LIB}
  ${WPA2_LIB}
  ${C_LIB}
  ${ETHERNET_LIB}
  ${MBEDTLS_LIB}
  ${RTC_LIB}
  ${WPA_LIB}
  ${C_NANO_LIB}
  ${EXPAT_LIB}
  ${MDNS_LIB}
  ${SDMMC_LIB}
  ${WPA_SUPPLICANT_LIB}
  ${COAP_LIB}
  ${FATFS_LIB}
  ${MICRO-ECC_LIB}
  ${SMARTCONFIG_LIB}
  ${WPS_LIB}
  ${COEXIST_LIB}
  ${FREERTOS_LIB}
  ${NET80211_LIB}
  ${SOC_LIB}
  ${XTENSA-DEBUG-MODULE_LIB}
  ${CONSOLE_LIB}
  ${HAL_LIB}
  ${NEWLIB_LIB}
  ${SPIFFS_LIB}
  ${CORE_LIB}
  ${HEAP_LIB}
  ${NGHTTP_LIB}
  ${SPI_FLASH_LIB}
  stdc++
  -Wl,--end-group
  )


# Add user libraries
foreach(LIB ${LIBS})
  set(LIB_PATH "${PKG_PATH}/libraries/${LIB}/src")
  file(GLOB_RECURSE LIB_FILES
    "${LIB_PATH}/*.cpp"
    )
  set_source_files_properties(${LIB_FILES} PROPERTIES COMPILE_FLAGS -w)
  target_sources(${CMAKE_PROJECT_NAME} PUBLIC ${LIB_FILES})
  include_directories(${LIB_PATH})
endforeach()


set(CMAKE_EXECUTABLE_SUFFIX ".elf")

find_program(
  ESPTOOL "esptool.py"
  HINTS "${PKG_PATH}/tools"
  )
find_program(
  ESPPART "gen_esp32part.py"
  HINTS "${PKG_PATH}/tools"
  )
find_program(
  SIZE "xtensa-esp32-elf-size"
  HINTS "${GCC_PATH}"
  )

set(FLASH_MODE "dio")
set(FLASH_FREQ "40")
set(FLASH_CHIPSIZE "1M")


if(ESPPART AND SIZE)
	# Make firmware and print size
	add_custom_target(hex)
	add_dependencies(hex ${CMAKE_PROJECT_NAME})
	add_custom_command(
    TARGET hex
    POST_BUILD
		COMMAND
      ${ESPPART}
      "${PKG_PATH}/tools/partitions/default.csv"
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.partitions.bin
    COMMAND ${SIZE} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf
    COMMAND
      ${ESPTOOL}
      --chip esp32
      elf2image
      --flash_mode dio
      --flash_freq 80m
      --flash_size 4MB
      --output ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
      ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf
  )
endif()

set(PORT $ENV{ARDUINO_PORT})
if (NOT PORT)
	set(PORT ${ARDUINO_PORT})
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
      --chip esp32
      --port ${PORT}
      --baud 921600
      --before default_reset
      --after hard_reset write_flash
      -z
      --flash_mode dio
      --flash_freq 80m
      --flash_size detect
      0xE000 ${PKG_PATH}/tools/partitions/boot_app0.bin
      0x1000 ${PKG_PATH}/tools/sdk/bin/bootloader_dio_80m.bin
      0x10000 ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
      0x8000  ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}.partitions.bin
  )
endif()
