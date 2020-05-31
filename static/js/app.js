
$(document).ready(function(){
    //connect to the socket server.
    var socket = io.connect('http://' + document.domain + ':' + location.port + '/test');
    var data = [];

    //receive details from server
    socket.on('newdata', function(msg) {
        console.log("Received number" + msg.data);
        if (data.length >= 20){
            data.shift()
        }            
        data.push(msg.data);
        dataStr = '';
        for (var i = 0; i < data.length; i++){
            dataStr = dataStr + '<p>' + data[i].toString() + '</p>';
        }
        $('#log').html(dataStr);
    });

});