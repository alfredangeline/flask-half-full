from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from random import random
from time import sleep
from threading import Thread, Event
import serial
import io
import random
from flask import Response
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
import numpy as np
import matplotlib.pyplot as plt

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True

socketio = SocketIO(app, async_mode='gevent', logger=False, engineio_logger=False)

thread_stop_event = Event()
port = '/dev/ttyS0'
baud = 230400 
ser = serial.Serial(port, baud, timeout=0)

@app.route('/plot.png')
def plot_png():
    fig = create_figure()
    output = io.BytesIO()
    FigureCanvas(fig).print_png(output)
    return Response(output.getvalue(), mimetype='image/png')

def create_figure():
    np.random.seed(0)

    dt = 0.01  # sampling interval
    Fs = 1 / dt  # sampling frequency
    t = np.arange(0, 10, dt)

    # generate noise:
    nse = np.random.randn(len(t))
    r = np.exp(-t / 0.05)
    cnse = np.convolve(nse, r) * dt
    cnse = cnse[:len(t)]

    s = 0.1 * np.sin(4 * np.pi * t) + cnse  # the signal

    fig, axes = plt.subplots(nrows=3, ncols=2, figsize=(7, 7))

    # plot time signal:
    axes[0, 0].set_title("Signal")
    axes[0, 0].plot(t, s, color='C0')
    axes[0, 0].set_xlabel("Time")
    axes[0, 0].set_ylabel("Amplitude")

    # plot different spectrum types:
    axes[1, 0].set_title("Magnitude Spectrum")
    axes[1, 0].magnitude_spectrum(s, Fs=Fs, color='C1')

    axes[1, 1].set_title("Log. Magnitude Spectrum")
    axes[1, 1].magnitude_spectrum(s, Fs=Fs, scale='dB', color='C1')

    axes[2, 0].set_title("Phase Spectrum ")
    axes[2, 0].phase_spectrum(s, Fs=Fs, color='C2')

    axes[2, 1].set_title("Angle Spectrum")
    axes[2, 1].angle_spectrum(s, Fs=Fs, color='C2')

    axes[0, 1].remove()  # don't display empty ax

    fig.tight_layout()
    return fig

def pollSerial():
    print("Reading serial data")
    while not thread_stop_event.isSet():
        data = ser.readline().decode()
        socketio.emit('newdata', {'data': data}, namespace='/test')
        socketio.sleep(.001)


@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect', namespace='/test')
def test_connect():
    print('Client connected')
    t = Thread(target=pollSerial)
    t.start()

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')


if __name__ == '__main__':
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)
