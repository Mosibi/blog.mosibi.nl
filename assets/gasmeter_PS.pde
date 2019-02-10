#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

int Ledpin = 13;
int Switchpin = 10;
int Sensorpin = 6;
int debug = 0;
int counter_one = 13805;
int counter_two = 20;
int counter = 0;
int usage = 0;

void setup() {
	Serial.begin(9600);
	pinMode(Ledpin, OUTPUT);
	pinMode(Switchpin, OUTPUT);
	pinMode(Sensorpin, INPUT);
        lcd.begin(16, 2);
        digitalWrite(Switchpin, HIGH);  // Set power on the Switchpin
}

void loop(){
        // set the cursor to column 0, line 1
        // (note: line 1 is the second row, since counting begins with 0):
        lcd.setCursor(0, 0);

	int switchstate = CheckSwitch();

	if ( switchstate == 1 ) {
                counter_two = (counter_two + 10);
                usage = (usage + 10);
	}

	if ( counter_two >= 1000 ) {
		counter_two = 0;
		counter_one++;
	}

        String counter = "";
        counter += counter_one;
        counter += ".";
        if (counter_two < 100) {
          counter += 0;
        }  
        counter += counter_two;

        Serial.print("Counter: ");
        Serial.print(counter);
        Serial.print("  Usage: ");
        Serial.println(usage);

        lcd.print("C: ");
        lcd.print(counter);
}

int CheckSwitch() {
	int retval = 0;
	int switchstate = digitalRead(Sensorpin);

	if (switchstate == HIGH) {
		digitalWrite(Ledpin, HIGH);  // Led on

		// Now let us check how long the switch is closed
		long switchclosed = CountStateDuration();
                
		if (debug) {
			Serial.print("DEBUG switch was closed (ms): ");
			Serial.println(switchclosed);

		}
		
		retval = 1;
	} else {
		digitalWrite(Ledpin, LOW);  // Led off
	}

	if (debug) {
		Serial.print("DEBUG switchstate: ");
		Serial.println(switchstate);
	}

	return retval;
}

int CountStateDuration() {
	long startmillis = millis();
	long millisclosed = 0;

	int switchstate = digitalRead(Sensorpin);

	while (switchstate == HIGH) {
		millisclosed = (millis() - startmillis);
                switchstate = digitalRead(Sensorpin);

		if (debug) {
			Serial.print("DEBUG switch now closed for (ms): ");
			Serial.println(millisclosed);

                        lcd.setCursor(0, 1);	
                        lcd.print("Closed: ");
                        lcd.print(millisclosed);

		}
	}

	return millisclosed;
}
