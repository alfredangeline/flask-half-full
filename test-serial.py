from threading import Thread
from time import sleep
import serial

class SerialThread(Thread):
    def __init__(self):
        self.delay = .5
        port = '/dev/ttyUSB0'
        baud = 9600
        self.ser = serial.Serial(port, baud, timeout=0)
        super(SerialThread, self).__init__()

    def serialPoll(self):
        """
        Poll the serial port and print the data
        """
        print("Polling Serial")
        while True:
            data = self.ser.readline().decode()
            print(data)
            sleep(self.delay)

    def run(self):
        self.serialPoll()

def run():
    print("Simple thread example")
    t = SerialThread()
    t.start()
    print("Exit main thread")

if __name__ == "__main__":
    run()

