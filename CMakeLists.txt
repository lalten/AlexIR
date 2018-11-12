project(alexir)
cmake_minimum_required(VERSION 3.3.1)

# Create Target with user sources
add_executable(${CMAKE_PROJECT_NAME}
  src/arduino_main.cpp
	)

include_directories(
  include
  )

# Add SDK libraries
set(LIBS
  ESP8266WiFi
  ESP8266HTTPUpdateServer
  ESP8266WebServer
  ESP8266mDNS
  Hash
  ArduinoOTA
  )

# List user libraries checked out in ./lib
set(USER_LIBS
  ESPAsyncTCP
  fauxmoesp
  IRremoteESP8266
  arduinoWebSockets
)

# ------------------------------------------------------------------------------

# Add user libraries
foreach(LIB ${USER_LIBS})
  set(LIB_PATH "${CMAKE_SOURCE_DIR}/lib/${LIB}/src")
  file(GLOB_RECURSE LIB_FILES
    "${LIB_PATH}/*.cpp"
    "${LIB_PATH}/*.c"
    )
  set_source_files_properties(${LIB_FILES} PROPERTIES COMPILE_FLAGS -w)
  target_sources(${CMAKE_PROJECT_NAME} PUBLIC ${LIB_FILES})
  include_directories(${LIB_PATH})
endforeach()

# Toolchain
include(${CMAKE_SOURCE_DIR}/platforms/esp8266.cmake)
