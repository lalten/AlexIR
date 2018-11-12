#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPUpdateServer.h>
#include <ESP8266mDNS.h>

#include <WebSocketsServer.h>
#include <fauxmoESP.h>
#include <IRremoteESP8266.h>
#include <IRsend.h>

#include "wifi_pass.h"

const bool IR_LED_INVERTED = true;
const int IR_LED_PIN = 1; // GPIO1 is TX

const char MDNS_NAME[] = "alexir";
const uint16_t WEBSOCKET_PORT = 81;

fauxmoESP fauxmo;
IRsend irsend(IR_LED_PIN, IR_LED_INVERTED);
WebSocketsServer webSocket = WebSocketsServer(WEBSOCKET_PORT);
ESP8266WebServer httpServer(80);
ESP8266HTTPUpdateServer httpUpdater;

void switch_on()
{
  irsend.sendNEC(0x4CB340BF);
}

void switch_off()
{
  uint16_t raw_data[69] = {9000,250, 450,3650, 1000,100, 750,1450, 650,450, 650,450, 650,1550, 650,1600, 600,500, 700,400, 600,1600, 600,500, 600,1600, 600,1600, 600,500, 600,500, 650,1550, 650,1550, 650,450, 650,1600, 600,1600, 600,1600, 600,500, 600,1600, 600,500, 700,400, 600,1600, 600,500, 650,450, 650,450, 650,1550, 650,450, 750,1500, 600,1600, 600};
  irsend.sendRaw(raw_data, 69, 38000);
  delay(1000);
  irsend.sendRaw(raw_data, 69, 38000);
}

void switch_3d_on()
{
  irsend.sendNEC(0x4CB3916E);
  delay(1000);
  irsend.sendNEC(0x4CB328D7);
  delay(1000);
  irsend.sendNEC(0x4CB3F00F);
}

void switch_3d_off()
{
  irsend.sendNEC(0x4CB3916E);
  delay(1000);
  irsend.sendNEC(0x4CB38877);
  delay(1000);
  irsend.sendNEC(0x4CB3F00F);
}

void webSocketEvent (uint8_t client_num, WStype_t type, uint8_t *payload, size_t length)
{
  switch(type) {
    case WStype_DISCONNECTED:
//       USE_SERIAL.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED:
    {
      webSocket.sendTXT(client_num, "Connected to Alexir");
      char buf[200]={0};
      sprintf(buf, "[WIFI] STATION Mode, SSID: %s, IP address: %s, MAC: %s", WiFi.SSID().c_str(), WiFi.localIP().toString().c_str(), WiFi.macAddress().c_str());
      webSocket.sendTXT(client_num, buf);
    }
    break;
    case WStype_TEXT:
    {
      char buf[256] = {0};
      sprintf(buf, "Unknown command \"%s\"", payload);
      webSocket.sendTXT(client_num, buf);
    }
    break;
    case WStype_BIN:
      break;
  }
}

void setup() {
  // Set IR LED as output
//   Serial.begin(115200);
  irsend.begin();
  
  // Wifi
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) yield();
  WiFi.setAutoReconnect(true);
  
  MDNS.begin(MDNS_NAME);
  
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  webSocket.broadcastTXT("Alexir WebSocket ready");
  
  
  httpUpdater.setup(&httpServer);
  MDNS.addService("http", "tcp", 80);
  
  
  // Start HTTP Server
  httpServer.begin();
  webSocket.broadcastTXT("HTTP server started");
  
  
  // Fauxmo v2.0
  fauxmo.addDevice("Beamer");
  fauxmo.addDevice("3D");
  fauxmo.onMessage(
    [](unsigned char device_id, const char * device_name, bool state)
    {
      char buf[200]={0};
      sprintf(buf, "[MAIN] Device #%d (%s) state: %s", device_id, device_name, state ? "ON" : "OFF");
      webSocket.broadcastTXT(buf);
      if(String(device_name) == String("Beamer"))
      {
        if(state == true)
        {
          switch_on();
        }
        else
        {
          switch_off();
        }
      }
      else if(String(device_name) == String("3D"))
      {
        if(state == true)
        {
          switch_3d_on();
        }
        else
        {
          switch_3d_off();
        }
      }
    }
  );
}

void loop() {
  fauxmo.handle();
  webSocket.loop();
  httpServer.handleClient();
}
