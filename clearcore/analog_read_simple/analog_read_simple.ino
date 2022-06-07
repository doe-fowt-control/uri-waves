#include "ClearCore.h"

// DEFINE SERIAL
  // Select the baud rate to match the target serial device
#define baudRate 9600
  // Specify which serial to use: ConnectorUsb, ConnectorCOM0, or ConnectorCOM1.
#define SerialPort ConnectorUsb

// DEFINE ANALOG
#define adcResolution 12

void setup() {
// SERIAL SETUP
    // Sets up serial communication and waits up to 5 seconds for a port to open.
    // Serial communication is not required for this example to run.
    SerialPort.Mode(Connector::USB_CDC);
    SerialPort.Speed(baudRate);
    uint32_t timeout = 5000;
    uint32_t startTime = Milliseconds();
    SerialPort.PortOpen();
    while (!SerialPort && Milliseconds() - startTime < timeout) {
        continue;
    }

// SETUP ANALOG
    // Set the resolution of the ADC.
    analogReadResolution(adcResolution);

}

void loop() {

    int adcResult = analogRead(A9);
    // Convert the reading to a voltage.
    double inputVoltage = 10.0 * adcResult / ((1 << adcResolution) - 1);

    // Alternatively, you can use the following to get a measurement in
    // volts:
    // inputVoltage = analogRead(A12, MILLIVOLTS) / 1000.0;

    // Display the voltage reading to the USB serial port.
    Serial.print("Voltage: ");
    Serial.println(inputVoltage);
    //Serial.println("V.");
    delay(50);
}
