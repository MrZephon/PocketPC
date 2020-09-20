const io = require('socket.io')(3000);
const os = require( 'os' );

var interfaces = os.networkInterfaces();
var addresses = [];
for (var k in interfaces) {
    for (var k2 in interfaces[k]) {
        var address = interfaces[k][k2];
        if (address.family === 'IPv4' && !address.internal) {
            addresses.push(address.address);
        }
    }
}

console.log("Tudo funcionando!");

if(addresses.length == 0){
    console.log("Parece que você não tem nenhum IP");
}
else if(addresses.length > 1){
    console.log("Parece que você tem mais de um IP: ");
    console.log(addresses);
}else {
    console.log("Seu ip é: " + ip);
}

io.on("connection", function (client) {
    console.log('user connected');
});