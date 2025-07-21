from flask import Flask
import RPi.GPIO as GPIO
import time
import threading
import subprocess
import signal
import os

#Setting up out GPIO pins
GPIO.setmode(GPIO.BCM)
GPIO.setup(17,GPIO.OUT)

#Setting up Flask
app = Flask(__name__)

#Insert whatever .mp3 or .wav you desire
fire = 'your_tunes.mp3'

#Globals to control the alarm
blinking = False
blinker thread = None
fire_player = None

#This function is what makes the LED's 'blink'
def blink_led():
  while blinking:
    GPIO.output(17, GPIO.HIGH)
    time.sleep(0.7)
    GPIO.output(17, GPIO.LOW)
    time.sleep(0.7)

#Dashboard Setup
@app.route("/")
def index():
  return "Alarm System is armed"

@app.route("/trigger")
def alarm_trigger():
  global blinking, blinker_thread, fire_player
  if not blinking:
    blinking = True
    blinker_thread = threading.Thread(target=blink_led)
    blinker_thread.start()
    fire_player = subprocess.Popen(["cvlc", "--play-and-exit", fire])
    return "Alarm Triggered!"
  return "Alarm already active"
  
#Resetting the alarm
@app.route("/reset")
def alarm_reset():
  global blinking, fire_player
  blinking = False
  GPIO.output(17, GPIO.LOW)

  #Stops the VLC player if still running
  if fire_player:
    try:
      os.kill(fire_player.pid, signal.SIGTERM)
      except:
        pass
      fire_player = None
    return "Alarm is reset"

#Helps us shutdownt the program PLEASE USE CTRL + C to end the code
if __name__ == "__main__":
  try:
    app.run(host="0.0.0.0", port=5000):
  except KeyboardInterrupt:
    print("Alarm System is shutting down")
    blinking = False
    GPIO.cleanup()
    
