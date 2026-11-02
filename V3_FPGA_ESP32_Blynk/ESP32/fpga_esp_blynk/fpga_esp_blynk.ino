#define BLYNK_TEMPLATE_ID   "TMPL3c8MgQJyr"
#define BLYNK_TEMPLATE_NAME "FPGA Event Monitor"
#define BLYNK_AUTH_TOKEN    "a6iaWGD6gstzLY3-1j_QkSi5IoLQdeOw"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <string.h>
#include <stdio.h>

#define FPGA_RX_PIN 4
#define FPGA_TX_PIN 5


char ssid[] = "Redmi 12 5G";
char pass[] = "rounakvyas7";

BlynkTimer timer;

char line[160];
int indexPos = 0;

int ch[4] = {0};
int peak[4] = {0};
int topChannel = 0;
char alertMask[5] = "0000";

bool parseMessage(char *msg) {
  int matched = sscanf(
    msg,
    "CH1:%d PK1:%d CH2:%d PK2:%d "
    "CH3:%d PK3:%d CH4:%d PK4:%d "
    "TOP:%d ALERT:%4s",
    &ch[0], &peak[0],
    &ch[1], &peak[1],
    &ch[2], &peak[2],
    &ch[3], &peak[3],
    &topChannel, alertMask
  );

  return matched == 10 && strlen(alertMask) == 4;
}

void sendToBlynk() {
  for (int i = 0; i < 4; i++) {
    Blynk.virtualWrite(V0 + i, ch[i]);
    Blynk.virtualWrite(V4 + i, peak[i]);
  }

  Blynk.virtualWrite(V8, topChannel);

  // Convert alert mask, e.g. "1001", into integer 9.
  int alertValue = 0;
  for (int i = 0; i < 4; i++) {
    alertValue = (alertValue << 1) |
                 (alertMask[i] == '1' ? 1 : 0);
  }

  Blynk.virtualWrite(V9, alertValue);
}

void setup() {
  Serial.begin(115200);
  Serial1.begin(9600, SERIAL_8N1, FPGA_RX_PIN, FPGA_TX_PIN);

  Serial.println("Connecting to Blynk...");
  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  Serial.println("Blynk connected!");

  // Send the latest parsed data to Blynk every second.
  timer.setInterval(1000L, sendToBlynk);
}

void loop() {
  Blynk.run();
  timer.run();

  while (Serial1.available()) {
    char c = Serial1.read();

    if (c == '\r') continue;

    if (c == '\n') {
      line[indexPos] = '\0';

      if (parseMessage(line)) {
        Serial.println("\n--- FPGA DATA ---");

        for (int i = 0; i < 4; i++) {
          Serial.printf(
            "CH%d: Count=%d, Peak=%d, Alert=%s\n",
            i + 1, ch[i], peak[i],
            alertMask[i] == '1' ? "ON" : "OFF"
          );
        }

        Serial.printf("Top channel: %d\n", topChannel);
        Serial.printf("Alert mask: %s\n", alertMask);
      } else {
        Serial.print("Parse failed: ");
        Serial.println(line);
      }

      indexPos = 0;
    } else if (indexPos < (int)sizeof(line) - 1) {
      line[indexPos++] = c;
    } else {
      // Discard malformed/overlong messages.
      indexPos = 0;
    }
  }
}
