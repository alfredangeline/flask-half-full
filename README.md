# flask-half-full

To run this app, hook a UART that is constantly streaming data up and:

    git clone https://github.com/ece544-spring2020/flask-half-full.git
    cd flask-half-full
    virtualenv flasky
    source flasky/bin/activate
    pip3 install -r reqs.txt

Start the application:  

    python3 app.py
  
See http://localhost:5000 and watch your serial data stream.  

Note: I had to install libatlas-base-dev to get numpy to work.
