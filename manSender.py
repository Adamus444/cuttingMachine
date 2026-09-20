import serial
import threading

ser = serial.Serial("/dev/ttyUSB0", 115200, timeout=0.1)

def reader():
    while True:
        line = ser.readline()
        if line:
            print(line.decode(errors="replace"), end="")

threading.Thread(target=reader, daemon=True).start()

while True:
    try:
        cmd = input("> ")
        ser.write((cmd + "\n").encode())
    except KeyboardInterrupt:
        break
