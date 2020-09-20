// Node.js socket server script
const net = require('net');

// Data from network
const os = require('os');

// Move the mouse across the screen
var robot = require("robotjs");

const interfaces = os.networkInterfaces();


// Create a server object
const server = net.createServer((socket) => {
    console.log("\n\nCelular conectado!!!");

    // Handle data from client
    socket.setEncoding("utf8");
    let interval;
    socket.on("data", function (data) {
        let lastJson = data.toString().substring(data.toString().lastIndexOf("{"), data.toString().lastIndexOf("}")+1);
        data = JSON.parse(lastJson);

        if (data.distance && data.distance != "stop") {

            let mouse = robot.getMousePos();

            let resultX = calcX(data.distance, data.degree);
            let resultY = calcY(data.distance, data.degree);
            let xPos = mouse.x+1 + resultX;
            let yPos = mouse.y   + resultY;
            robot.moveMouse(xPos, yPos);

            clearInterval(interval);
            interval = setInterval(() => {
                xPos += resultX; 
                yPos += resultY;
                robot.moveMouse(xPos + resultX, yPos + resultY);
            }, 0);

        } else if (data.distance == "stop") {
            clearInterval(interval);
        }

        if(data.click){
            robot.mouseClick();
        }

        if(data.text){
            robot.keyTap(data.text);
        }
    });

    socket.on("disconnect", () => {
        console.info('Celular desconectado');
    });

    socket.on('end', function () {
        console.info('Celular desconectado');
    });

}).on('error', (err) => {
    console.error(err);
});







// Open server on port 3000
server.listen(3000, () => {

    console.info("Tudo funcionando!");

    var addresses = [];
    for (var k in interfaces) {
        for (var k2 in interfaces[k]) {
            var address = interfaces[k][k2];
            if (address.family === 'IPv4' && !address.internal) {
                addresses.push(address.address);
            }
        }
    }

    if (addresses.length == 0) {
        console.info("Parece que você não tem nenhum IP");
    }
    else if (addresses.length > 1) {
        console.info("Parece que você tem mais de um IP: ");
        console.info(addresses);
    } else {
        console.info("Seu ip é: " + ip);
    }

});

function calcY(distance, degree){
    return distance * Math.sin(degree * Math.PI / 180);
}
function calcX(distance, degree){
    return distance * Math.cos(degree * Math.PI / 180);
}
