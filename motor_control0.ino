/*
 * Links:
 * ** ClearCore Documentation: https://teknic-inc.github.io/ClearCore-library/
 * ** ClearCore Manual: https://www.teknic.com/files/downloads/clearcore_user_manual.pdf
 * ** ClearPath Manual (DC Power): https://www.teknic.com/files/downloads/clearpath_user_manual.pdf
 * ** ClearPath Manual (AC Power): https://www.teknic.com/files/downloads/ac_clearpath-mc-sd_manual.pdf
 *
 * 
 * Copyright (c) 2020 Teknic Inc. This work is free to use, copy and distribute under the terms of
 * the standard MIT permissive software license which can be found at https://opensource.org/licenses/MIT
 */
 
// LIBRARIES
#include "ClearCore.h"
#include "math.h"
#include <Bounce2.h>

// DEFINE SERIAL
  // Select the baud rate to match the target serial device
#define baudRate 9600
  // Specify which serial to use: ConnectorUsb, ConnectorCOM0, or ConnectorCOM1.
#define SerialPort ConnectorUsb

// DEFINE MOTOR
  // Specifies which motor to move.
#define motor ConnectorM0
  // Define the velocity and acceleration limits to be used for each move
int32_t velocityLimit = 5000; // pulses per sec
int32_t accelerationLimit = 50000; // pulses per sec^2

// DEFINE FUNCTIONS
bool MoveAbsolutePosition(int32_t position);
bool MoveAtVelocity(int32_t velocity);
//void stateMessage(char message);
//void stateUpdate(int

// DEFINE SWITCHES
#define LIMIT_PIN0 A11
#define LIMIT_PIN1 A12
#define STATE_PIN A10

// Bounce OBJECTs, one for each switch
Bounce limitSwitch0 = Bounce();
Bounce limitSwitch1 = Bounce();
Bounce stateSwitch = Bounce();

// DEFINE LOGIC
int state = 0;
int sendFlag = 0;

//boolean flags set to true when limit is reached
bool home0 = false;
bool home1 = false;

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

// MOTOR SETUP
    // Sets the input clocking rate. This normal rate is ideal for ClearPath
    // step and direction applications.
    MotorMgr.MotorInputClocking(MotorManager::CLOCK_RATE_NORMAL);
    // Sets all motor connectors into step and direction mode.
    MotorMgr.MotorModeSet(MotorManager::MOTOR_ALL,
                          Connector::CPM_MODE_STEP_AND_DIR);
    // Set the motor's HLFB mode to bipolar PWM
    motor.HlfbMode(MotorDriver::HLFB_MODE_HAS_BIPOLAR_PWM);
    // Set the HFLB carrier frequency to 482 Hz
    motor.HlfbCarrier(MotorDriver::HLFB_CARRIER_482_HZ);
    // Sets the maximum velocity for each move
    motor.VelMax(velocityLimit);
    // Set the maximum acceleration for each move
    motor.AccelMax(accelerationLimit);
    // Enables the motor; homing will begin automatically if enabled
    motor.EnableRequest(true);
    SerialPort.SendLine("Motor Enabled");
    // Waits for HLFB to assert (waits for homing to complete if applicable)
    SerialPort.SendLine("Waiting for HLFB...");
    while (motor.HlfbState() != MotorDriver::HLFB_ASSERTED) {
        continue;
    }
    SerialPort.SendLine("Motor Ready");

// SWITCHES SETUP
  limitSwitch0.attach( LIMIT_PIN0 ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP
  limitSwitch1.attach( LIMIT_PIN1 ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP
  stateSwitch.attach( STATE_PIN ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP
  
  // DEBOUNCE INTERVAL IN MILLISECONDS
  limitSwitch0.interval(10); // interval in ms
  limitSwitch1.interval(10); // interval in ms
  stateSwitch.interval(10);
}

void loop() {


  
// STARTUP
  if ( state == 0 ) {
    stateMessage("STARTUP");
    // go to new state when switch is pressed
    stateUpdate(1);
  }

// HOMING
  if ( state == 1 ) {
    stateMessage("HOMING");
  
    int home_found = 0;
    int relative_position = 4000; // the size of the first move
    int move_distance = 10; // the number of steps to move for every count


    // both start as true
    if ( !home0 && !home1 ) {
      //SerialPort.SendLine("Both False"); 

      // move in a direction, slowly
      MoveAtVelocity(800);         

      limitSwitch0.update();
      if ( limitSwitch0.changed() ) {
        int input = limitSwitch0.read();
        if ( input == HIGH ) {
          motor.MoveStopAbrupt();
          SerialPort.SendLine("Limit found");
          delay(1000);
          home0 = true;
          
        }
      }
      
      limitSwitch1.update();
      if ( limitSwitch1.changed() ) {
        int input = limitSwitch1.read();
        if ( input == HIGH ) {
          motor.MoveStopAbrupt();
          SerialPort.SendLine("Limit found");
          delay(1000);
          home1 = true;
        }
      }            

    
    }

    // only one should be false after initial press
    if ( (home0 && !home1) || (!home0 && home1) ) {
        // SerialPort.SendLine("One False");
        // move the opposite direction
        motor.Move(-relative_position);
        delay(500);

        while ( home_found == 0 ) {
          
          limitSwitch0.update();
          if ( limitSwitch0.changed() ) {
            int input = limitSwitch0.read();
            if ( input == HIGH ) {
              motor.MoveStopAbrupt();
              SerialPort.SendLine("Limit found");
              delay(1000);
              home0 = true;
              home_found = 1;
            }
          }
          
          limitSwitch1.update();
          if ( limitSwitch1.changed() ) {
            int input = limitSwitch1.read();
            if ( input == HIGH ) {
              motor.MoveStopAbrupt();
              SerialPort.SendLine("Limit found");
              delay(1000);
              home1 = true;
              home_found = 1;
            }
          }
                      
          motor.Move(-move_distance);
          delay(25);
          relative_position = relative_position + move_distance;
          //SerialPort.SendLine(relative_position);

        }
    }

    if ( home0 && home1 ) {
      int relative_home = round(0.5 * relative_position);
      motor.Move(relative_home);
      delay(5000);
      
      //motor.EnableRequest(false);
      //delay(2000);
     // motor.EnableRequest(true);
     // motor.ClearAlerts();
      motor.PositionRefSet(0);
      delay(1000);
      state = 2;
      sendFlag = 0;
    }      

          /*
          // check the status of the switches
          limitSwitch0.update();
          limitSwitch1.update();
      
          // if either has changed
          if ( limitSwitch0.changed() || limitSwitch1.changed() ) {
            
            // check to see if either is pressed (HIGH)
            int input0 = limitSwitch0.read();
            int input1 = limitSwitch1.read();
            if ( input0 == HIGH || input1 == HIGH ) {
              // stop moving
              motor.MoveStopAbrupt();
              SerialPort.SendLine("Limit found!");
              delay(1000);
*/

        // check to see if the stateSwitch is pressed at any point before the limit is found
        stateUpdate(2);
  }
   

// PASSIVE
  if ( state == 2 ) {
    stateMessage("PASSIVE");   

    MoveAtVelocity(0);
    
    // move on if switch is pressed
    stateUpdate(3);
    
  }

  
// MOVING
  if ( state == 3 ) {
    stateMessage("MOVING");    

    if (motor.StatusReg().bit.AlertsPresent) {
        Serial.println("Motor status: 'In Alert'. Move Canceled.");
    }    

    float currentTimeSec = millis() * 0.001;
    float freqHz = 0.4;
    float freqRad = 6.2832 * freqHz;
    int A = 400;
    float desiredPos = A * sin(freqRad * currentTimeSec);
    float desiredVel = A * freqRad * cos(freqRad * currentTimeSec);

    /*
    int currentTime = millis();
    float currentTimeSec = currentTime * .001 * 6.2832 * .4; // convert ms to s then multiply by 2*pi and divide by period
    float desiredPos = 400 * cos(currentTimeSec);
    */

    motor.Move(desiredPos, StepGenerator::MOVE_TARGET_ABSOLUTE); 
    //motor.MoveVelocity(desiredVel);
    //SerialPort.SendLine(desiredPos);
    
    // go back to state 2 if state switch is pressed
    stateUpdate( 2 );

    // disable if limit switch is triggered
    limitDisable( limitSwitch0 );
    limitDisable( limitSwitch1 );

  }  

// DISABLED
  if ( state == 8 ) {
    motor.EnableRequest(false);

    if ( sendFlag == 0 ) {
      SerialPort.SendLine("Motor disabled");
      sendFlag = 1;
    }     

    // motor.ClearAlerts();
    
  }
}






void stateMessage( const char* message ) {
    if ( sendFlag == 0 ) {
      SerialPort.SendLine(message);
      sendFlag = 1;
    }
}

void stateUpdate( int newState ) {
    stateSwitch.update();
    if ( stateSwitch.changed() ) {
      int debouncedInput = stateSwitch.read();
      if ( debouncedInput == HIGH ) {
        state = newState;
        sendFlag = 0;
      }
    }
}

bool homingFlag( Bounce &theSwitch ) {
  theSwitch.update();
  if ( theSwitch.changed() ) {
    int input = theSwitch.read();
    if ( input == HIGH ) {
      motor.MoveStopAbrupt();
      SerialPort.SendLine("Limit found");
      delay(1000);
      return true;
    }
  }
}

void limitDisable( Bounce &theSwitch ) {
    theSwitch.update();
    if ( theSwitch.changed() ) {
      SerialPort.SendLine("switch registered");
      int debouncedInput = theSwitch.read();
      if ( debouncedInput == HIGH ) {
        SerialPort.SendLine("Limit Switch Triggered!!");
        state = 8;
        sendFlag = 0;      
      }
    }  
}


bool MoveSinusoid(int magnitude) {
    int currentTime = millis();
    float currentTimeSec = currentTime * .001;
    float desiredPos = magnitude * sin(currentTimeSec);
      
    motor.Move(desiredPos, MotorDriver::MOVE_TARGET_ABSOLUTE);
}

 
bool MoveAtVelocity(int velocity) {
    // Check if an alert is currently preventing motion
    if (motor.StatusReg().bit.AlertsPresent) {
        Serial.println("Motor status: 'In Alert'. Move Canceled.");
        return false;
    }

    //Serial.print("Moving at velocity: ");
    //Serial.println(velocity);

    // Command the velocity move
    motor.MoveVelocity(velocity);

    // Waits for the step command to ramp up/down to the commanded velocity. 
    // This time will depend on your Acceleration Limit.
    //Serial.println("Ramping to speed...");
    while (!motor.StatusReg().bit.AtTargetVelocity) {
        continue;
    }

    //Serial.println("At Speed");
    return true; 
}

/*------------------------------------------------------------------------------
 * MoveAbsolutePosition
 *
 *    Command step pulses to move the motor's current position to the absolute
 *    position specified by "position"
 *    Prints the move status to the USB serial port
 *    Returns when HLFB asserts (indicating the motor has reached the commanded
 *    position)
 *
 * Parameters:
 *    int position  - The absolute position, in step pulses, to move to
 *
 * Returns: True/False depending on whether the move was successfully triggered.
 */
bool MoveAbsolutePosition(int32_t position) {
    // Check if an alert is currently preventing motion
    if (motor.StatusReg().bit.AlertsPresent) {
        SerialPort.SendLine("Motor status: 'In Alert'. Move Canceled.");
        return false;
    }
    SerialPort.Send("Moving to absolute position: ");
    SerialPort.SendLine(position);
    // Command the move of absolute distance
    motor.Move(position, MotorDriver::MOVE_TARGET_ABSOLUTE);
    // Waits for HLFB to assert (signaling the move has successfully completed)
    SerialPort.SendLine("Moving.. Waiting for HLFB");
    while (!motor.StepsComplete() || motor.HlfbState() != MotorDriver::HLFB_ASSERTED) {
        continue;
    }
    SerialPort.SendLine("Move Done");
    return true;
}

bool MoveDistance(int distance) {
    // Check if an alert is currently preventing motion
    if (motor.StatusReg().bit.AlertsPresent) {
        Serial.println("Motor status: 'In Alert'. Move Canceled.");
        return false;
    }

    Serial.print("Moving distance: ");
    Serial.println(distance);

    // Command the move of incremental distance
    motor.Move(distance);

    // Waits for HLFB to assert (signaling the move has successfully completed)
    Serial.println("Moving.. Waiting for HLFB");
    while (!motor.StepsComplete() || motor.HlfbState() != MotorDriver::HLFB_ASSERTED) {
        continue;
    }

    Serial.println("Move Done");
    return true;
}
//--------------------------------------------------------------------------
