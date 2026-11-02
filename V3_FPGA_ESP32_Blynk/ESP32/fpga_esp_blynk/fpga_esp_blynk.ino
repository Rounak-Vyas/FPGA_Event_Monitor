#define BLYNK_TEMPLATE_ID   "TMPL3c8MgQJyr"
#define BLYNK_TEMPLATE_NAME "FPGA Event Monitor"
#define BLYNK_AUTH_TOKEN    "a6iaWGD6gstzLY3-1j_QkSi5IoLQdeOw"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <stdio.h>
#include <string.h>

// Wi-Fi credentials
char ssid[] = "Redmi 12 5G";
char pass[] = "rounakvyas7";

#define FPGA_RX_PIN 4
#define FPGA_TX_PIN 5

BlynkTimer timer;

// UART receive buffer
char line[160];
int indexPos = 0;

// Parsed FPGA data
int ch[4] = {0};
int peak[4] = {0};
int topChannel = 0;
char alertMask[5] = "0000";

int total[4] = {0};

int t10Valid = 0;
int t10[4] = {0};

// --------------------------------------------------
// Parse FPGA UART message
// --------------------------------------------------

bool parseMessage(char *msg) {

  int matched = sscanf(
    msg,
    "CH1:%d PK1:%d CH2:%d PK2:%d "
    "CH3:%d PK3:%d CH4:%d PK4:%d "
    "TOP:%d ALERT:%4s "
    "TOT1:%d TOT2:%d TOT3:%d TOT4:%d "
    "T10V:%d T10:%d,%d,%d,%d",

    &ch[0], &peak[0],
    &ch[1], &peak[1],
    &ch[2], &peak[2],
    &ch[3], &peak[3],
    &topChannel, alertMask,
    &total[0], &total[1],
    &total[2], &total[3],
    &t10Valid,
    &t10[0], &t10[1],
    &t10[2], &t10[3]
  );

  return matched == 19 && strlen(alertMask) == 4;
}

// --------------------------------------------------
// Convert alert mask into integer
// Example: "1001" -> 9
// --------------------------------------------------

int getAlertValue() {

  int value = 0;

  for (int i = 0; i < 4; i++) {
    value = (value << 1) |
            (alertMask[i] == '1' ? 1 : 0);
  }

  return value;
}

// --------------------------------------------------
// Send regular FPGA data to Blynk
// --------------------------------------------------

void sendToBlynk() {

  if (!Blynk.connected()) {
    return;
  }

  for (int i = 0; i < 4; i++) {

    Blynk.virtualWrite(V0 + i, ch[i]);
    Blynk.virtualWrite(V4 + i, peak[i]);
    Blynk.virtualWrite(V10 + i, total[i]);
  }

  Blynk.virtualWrite(V8, topChannel);
  Blynk.virtualWrite(V9, getAlertValue());

  Serial.println("Regular data sent to Blynk");
}

// --------------------------------------------------
// Send completed 10-second data
// --------------------------------------------------

void send10SecondData() {

  Serial.println("\nSending 10-second data to Blynk:");

  for (int i = 0; i < 4; i++) {

    Serial.printf("V%d = %d\n", 14 + i, t10[i]);

    if (Blynk.connected()) {
      Blynk.virtualWrite(V14 + i, t10[i]);
    }
  }

  Serial.println("10-second transmission completed\n");
}

// --------------------------------------------------
// Print parsed FPGA data
// --------------------------------------------------

void printData() {

  Serial.println("\n--------- FPGA DATA ---------");

  for (int i = 0; i < 4; i++) {

    Serial.printf(
      "CH%d: Count=%d | Peak=%d | Total=%d | Alert=%s\n",
      i + 1,
      ch[i],
      peak[i],
      total[i],
      alertMask[i] == '1' ? "ON" : "OFF"
    );
  }

  Serial.printf("Top channel: %d\n", topChannel);
  Serial.printf("Alert mask: %s\n", alertMask);

  Serial.printf(
    "T10: %d, %d, %d, %d | Valid: %d\n",
    t10[0], t10[1], t10[2], t10[3], t10Valid
  );
}

// --------------------------------------------------
// Setup
// --------------------------------------------------

void setup() {

  Serial.begin(115200);

  Serial1.begin(
    9600,
    SERIAL_8N1,
    FPGA_RX_PIN,
    FPGA_TX_PIN
  );

  Serial.println("FPGA UART Receiver Ready");

  Serial.println("Connecting to Blynk...");

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);

  Serial.println("Blynk connected!");

  // Regular data transmission
  timer.setInterval(1000L, sendToBlynk);
}

// --------------------------------------------------
// Main loop
// --------------------------------------------------

void loop() {

  Blynk.run();
  timer.run();

  while (Serial1.available()) {

    char c = Serial1.read();

    if (c == '\r') {
      continue;
    }

    if (c == '\n') {

      line[indexPos] = '\0';

      if (parseMessage(line)) {

        printData();

        // Send fresh 10-second data only once
        if (t10Valid == 1) {
          send10SecondData();
        }

      } else {

        Serial.print("Parse failed: ");
        Serial.println(line);
      }

      indexPos = 0;

    } else if (indexPos < (int)sizeof(line) - 1) {

      line[indexPos++] = c;

    } else {

      // Discard malformed/overlong messages
      indexPos = 0;
    }
  }
}