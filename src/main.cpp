#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h>

#include <fauxmoESP.h>

#include <IRremoteESP8266.h>
#include <IRsend.h>

const bool IR_LED_INVERTED = true;
const int IR_LED_PIN = 1; // GPIO1 is TX

IRsend irsend(IR_LED_PIN, IR_LED_INVERTED);
fauxmoESP fauxmo;
enum command_t {IDLE, PWR_ON, PWR_OFF, STEREO_ON, STEREO_OFF} cmd;

void setup()
{
  WiFi.hostname("AlexIR");

  WiFiManager wifiManager;
  wifiManager.autoConnect("AlexIR");

  irsend.begin();

  cmd = IDLE;

  // Fauxmo 3.0
  fauxmo.enable(true);
  fauxmo.addDevice("Beamer");
  fauxmo.addDevice("3D");
  fauxmo.onSetState(
    [](unsigned char device_id, const char * device_name, bool state)
    {
      if(String(device_name) == String("Beamer"))
      {
        if(state == true)
        {
          cmd = PWR_ON;
        }
        else
        {
          cmd = PWR_OFF;
        }
      }
      else if(String(device_name) == String("3D"))
      {
        if(state == true)
        {
          cmd = STEREO_ON;
        }
        else
        {
          cmd = STEREO_OFF;
        }
      }
    }
  );
}

void loop()
{
  fauxmo.handle();

  switch(cmd)
  {
    case PWR_ON:
      irsend.sendNEC(0x4CB340BF);
      break;
    case PWR_OFF:
      {
        uint16_t raw_data[69] = {9000,250, 450,3650, 1000,100, 750,1450, 650,450, 650,450, 650,1550, 650,1600, 600,500, 700,400, 600,1600, 600,500, 600,1600, 600,1600, 600,500, 600,500, 650,1550, 650,1550, 650,450, 650,1600, 600,1600, 600,1600, 600,500, 600,1600, 600,500, 700,400, 600,1600, 600,500, 650,450, 650,450, 650,1550, 650,450, 750,1500, 600,1600, 600};
        irsend.sendRaw(raw_data, 69, 38000);
        delay(1000);
        irsend.sendRaw(raw_data, 69, 38000);
      }
      break;
    case STEREO_ON:
      irsend.sendNEC(0x4CB3916E);
      delay(1000);
      irsend.sendNEC(0x4CB328D7);
      delay(1000);
      irsend.sendNEC(0x4CB3F00F);
      break;
    case STEREO_OFF:
      irsend.sendNEC(0x4CB3916E);
      delay(1000);
      irsend.sendNEC(0x4CB38877);
      delay(1000);
      irsend.sendNEC(0x4CB3F00F);
      break;
    }
    cmd = IDLE;
}