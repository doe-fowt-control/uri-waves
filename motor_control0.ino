/*
 * Title: MovePositionAbsolute
 *
 * Objective:
 *    This example demonstrates control of a ClearPath motor in Step and
 *    Direction mode.
 *
 * Description:
 *    This example enables a ClearPath then commands a series of repeating
 *    absolute position moves to the motor.
 *
 * Requirements:
 * 1. A ClearPath motor must be connected to Connector M-0.
 * 2. The connected ClearPath motor must be configured through the MSP software
 *    for Step and Direction mode (In MSP select Mode>>Step and Direction).
 * 3. The ClearPath motor must be set to use the HLFB mode "ASG-Position
 *    w/Measured Torque" with a PWM carrier frequency of 482 Hz through the MSP
 *    software (select Advanced>>High Level Feedback [Mode]... then choose
 *    "ASG-Position w/Measured Torque" from the dropdown, make sure that 482 Hz
 *    is selected in the "PWM Carrier Frequency" dropdown, and hit the OK
 *    button).
 * 4. Set the Input Format in MSP for "Step + Direction".
 *
 * ** Note: Homing is optional, and not required in this operational mode or in
 *    this example. This example makes positive absolute position moves,
 *    assuming any homing move occurs in the negative direction.
 *
 * ** Note: Set the Input Resolution in MSP the same as your motor's Positioning
 *    Resolution spec if you'd like the pulses sent by ClearCore to command a
 *    move of the same number of Encoder Counts, a 1:1 ratio.
 *
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


// DEFINE MOTOR
  // Specifies which motor to move.
#define motor ConnectorM0
  // Select the baud rate to match the target serial device
#define baudRate 9600
  // Specify which serial to use: ConnectorUsb, ConnectorCOM0, or ConnectorCOM1.
#define SerialPort ConnectorUsb
  // Define the velocity and acceleration limits to be used for each move
int32_t velocityLimit = 5000; // pulses per sec
int32_t accelerationLimit = 50000; // pulses per sec^2
  // Helper function
bool MoveAbsolutePosition(int32_t position);

// DEFINE SWITCHES
#define BOUNCE_PIN0 A11
#define BOUNCE_PIN1 A12
#define BOUNCE_PIN_STATE A10

  // INSTANTIATE two Bounce OBJECT, one for each switch
Bounce bounce0 = Bounce();
Bounce bounce1 = Bounce();
Bounce bounceState = Bounce();

  // SET A VARIABLE TO STORE THE SWITCH STATE
int switchState0 = HIGH;
int switchState1 = HIGH;

// DEFINE LOGIC
int state = 0;

void setup() {


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
bounce0.attach( BOUNCE_PIN0 ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP
bounce1.attach( BOUNCE_PIN1 ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP
bounceState.attach( BOUNCE_PIN_STATE ,  INPUT_PULLUP ); // USE INTERNAL PULL-UP

// DEBOUNCE INTERVAL IN MILLISECONDS
bounce0.interval(10); // interval in ms
bounce1.interval(10); // interval in ms
bounceState.interval(10);
}

void loop() {


  
// not running
  if ( state == 0 ) {
    SerialPort.SendLine("In startup state");
    bounceState.update();
    if ( bounceState.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 1;
        SerialPort.SendLine("Entering homing state");
      }
    }
  }


  if ( state == 1 ) {
    SerialPort.SendLine("In homing state");
    
    // homing
    bounceState.update();
    if ( bounceState.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 2;
        SerialPort.SendLine("Entering passive state");
      }
    }
  }

  if ( state == 2 ) {
    SerialPort.SendLine("In passive state");

    //MoveAbsolutePosition(0);
   // MoveAtVelocity(0);
    
    bounceState.update();
    if ( bounceState.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 3;
        SerialPort.SendLine("Entering motion state");
      }
    }
    
  }

  if ( state == 3 ) {
    SerialPort.SendLine("In motion state");

// motion
    int currentTime = millis();
    float currentTimeSec = currentTime * .001;
    float desiredPos = 400 * sin(currentTimeSec);
    motor.Move(desiredPos, MotorDriver::MOVE_TARGET_ABSOLUTE);
    
    
    bounceState.update();
    if ( bounceState.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 2;
        SerialPort.SendLine("Entering passive state");
      }
    }

    bounce0.update();
    if ( bounce0.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 8;
        SerialPort.SendLine("Limit Switch Triggered!!");      
      }
    }

    bounce1.update();
    if ( bounce1.changed() ) {
      int debouncedInput = bounceState.read();
      if ( debouncedInput == LOW ) {
        state = 8;
        SerialPort.SendLine("Limit Switch Triggered!!");      
      }
    }
  }  

  if ( state == 8 ) {
    ConnectorM0.EnableRequest(false);
    SerialPort.SendLine("Motor disabled");   
  }

  

    /*
     *     // check switch 0
    bounce0.update();
    if ( bounce0.changed() ) {
      MoveSinusoid(400);
      runState = !runState;
      SerialPort.SendLine("Limit Switch Triggered!!");
    }

    // check switch 1
    bounce1.update();
    if ( bounce1.changed() ) {
      MoveSinusoid(400);
      runState = !runState;
      SerialPort.SendLine("Limit Switch Triggered!!");
    }
     * 
     * 
     */
    
/*
// running
  if ( runState == 1 ) {
    // check switch 0
    bounce0.update();
    if ( bounce0.changed() ) {
      MoveAtVelocity(0);
      runState = !runState;
      SerialPort.SendLine("Limit Switch Triggered!!");
    }
    
    bounce1.update();
    if ( bounce1.changed() ) {
      MoveAtVelocity(0);
      runState = !runState;
      SerialPort.SendLine("Limit Switch Triggered!!");
    }

    

  
  }

    SerialPort.Send("position:");
    SerialPort.Send(desiredPos);
    SerialPort.Send(",");
    SerialPort.Send("velocity:");
    SerialPort.SendLine(desiredVel);
    
    float desiredVel = 800 * cos(currentTimeSec);
    
*/


    
// ON POWER UP FIND LIMIT SWITCHES
// INITIATE SLOW MOVE IN ONE DIRECTION UNTIL SWITCH IS PRESSED
// MOVE BACKWARDS A KNOWN AMOUNT TO AVOID PRESSING THE BUTTON FOREVER
// STOP MOVING
// FIND CURRENT POSITION 0
// MOVE IN OTHER DIRECTION UNTIL THE OTHER SWITCH IS PRESSED
// MOVE BACK, STOP MOVING, FIND CURRENT POSITION 1
// FIND AVERAGE OF TWO POSITIONS
// MOVE THERE
// CALL THAT POSITION ZERO
// MOVE ON TO MAIN MOTION


/*    
  if (hasRun == false)
    {
       //hasRun = true;
       //MoveAbsolutePosition(0);
    }
*/
  delay(5);
}

// DUMPSTER
/*
 * 
    float angle_rad = currentTime / 1000;
    uint32_t desiredPos = -800 * sin(millis() / 1000);
    MoveAbsolutePosition(desiredPos);

    SerialPort.Send("angle: ");
    SerialPort.SendLine(angle_rad);
    SerialPort.Send("desired position: ");
    SerialPort.SendLine(desiredPos);
    


    uint32_t desiredPos = -800 * sin(millis() / 1000);
    SerialPort.Send("position: ");
    SerialPort.SendLine(desiredPos);    
    
    SerialPort.Send("millis: ");
    SerialPort.Send(currentTime);
    SerialPort.SendLine();    

    SerialPort.Send("time: ");
    SerialPort.SendLine(currentTimeSec, 3);
// including velocity does not do great things
          // motor.MoveVelocity(desiredVel);
 * 
 */


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
//--------------------------------------------------------------------------
