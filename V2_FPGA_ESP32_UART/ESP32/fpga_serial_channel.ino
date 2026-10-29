
#include <Arduino.h>
#include <string.h>
#include <stdio.h>

#define FPGA_RX_PIN 4
#define FPGA_TX_PIN 5

char line[160];
int indexPos = 0;

int ch[4], peak[4], topChannel;
char alertMask[5];

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

void setup() {
    Serial.begin(115200);
    Serial1.begin(9600, SERIAL_8N1, FPGA_RX_PIN, FPGA_TX_PIN);
    Serial.println("FPGA parser ready!");
}

void loop() {
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
            } else {
                Serial.print("Parse failed: ");
                Serial.println(line);
            }

            indexPos = 0;
        } else if (indexPos < (int)sizeof(line) - 1) {
            line[indexPos++] = c;
        } else {
            // Discard an overlong line and start fresh.
            indexPos = 0;
        }
    }
}
