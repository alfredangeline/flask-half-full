from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from random import random
from time import sleep
from threading import Thread, Event
import serial

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True

socketio = SocketIO(app, async_mode=None, logger=True, engineio_logger=True)

thread = Thread()
thread_stop_event = Event()
port = '/dev/ttyS0'
baud = 230400 
ser = serial.Serial(port, baud, timeout=0)

def pollSerial():
    print("Reading serial data")
    while not thread_stop_event.isSet():
        data = ser.readline().decode()
        print(data)
        socketio.emit('newdata', {'data': data}, namespace='/test')
        socketio.sleep(.001)


@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect', namespace='/test')
def test_connect():
    global thread
    print('Client connected')

    if not thread.isAlive():
        print("Starting Thread")
        thread = socketio.start_background_task(pollSerial)

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')


if __name__ == '__main__':
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)
