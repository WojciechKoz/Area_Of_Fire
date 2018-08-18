var net = require('net');
var msgpack = require('msgpack');

const TIMEOUT_KICK = 60000; // 60 s

const MSGS_SEND = {
	NEW_PLAYER: 0,
	PLAYER_MOVE: 1,
};

const MSGS_RECEIVE = {
	SET_NICKNAME: 0,
	PLAYER_MOVE: 1,
}

var _lastClientId = 1;
function newClientId() {
	return _lastClientId++;
}

var allClients = [];

// after 15s of no data a socket is considered disconnected.
function resetTimeout(socket) {
	socket.disconnectTimeout.refresh();
}

// Pack a message and send it to socket
function messageToSocket(socket, message) {
	if(socket == null) {
		console.warn(`Tried to send ${message} to an undefined socket`)
	}
	socket.write(msgpack.pack(message));
}

// send all existing players' nicknames to a newly connected player
function sendAllPlayersNicknames(socket) {
	var message = [];
	for (var clientIdx in allClients) {
		var client = allClients[clientIdx];
		if(client.nickname != null) {
			message.push(MSGS_SEND.NEW_PLAYER);
			message.push([client.clientId, client.nickname]);
		}
	}
	messageToSocket(socket, message);
}

function sendToAllExcept(clientId, message) {
	allClients.forEach(client => {
		if(client.clientId != clientId) {
			messageToSocket(client.socket, message);
		}
	})
}

// All message types possible to receive from the client
var handleMessage = []
handleMessage[MSGS_RECEIVE.SET_NICKNAME] = function(arg) {
	arg = "" + arg;

	console.log(`Nickname = ${arg}`)
	this.nickname = arg;
	sendToAllExcept(this.clientId, [MSGS_SEND.NEW_PLAYER, [this.clientId, arg]])
}
handleMessage[MSGS_RECEIVE.PLAYER_MOVE] = function(arg) {
	// arg is [x:float, y:float, delta_x:float, delta_y:float]
	if(!Array.isArray(arg) || arg.length != 4) {
		console.warn(`Malformed PLAYER_MOVE from client ${this.clientId}`);
		return;
	}
	var message = [MSGS_SEND.PLAYER_MOVE, [this.clientId, arg[0], arg[1], arg[2], arg[3]]];
	console.log(message)
	sendToAllExcept(this.clientId, message);
}


var server = net.createServer(function(socket) {
	console.log('connected')

	socket.disconnectTimeout = setTimeout(function() {
		console.log(`Kicking ${socket} due to inactivity`);
		socket.end();
	}, TIMEOUT_KICK);

	sendAllPlayersNicknames(socket);
	//messageToSocket(socket, [MSGS_SEND.PLAYER_MOVE, [123, 1.5, 1.5, 1.5, 1.5]])

	var clientInfo = {
		clientId: newClientId(),
		nickname: null,
		socket
	}

	const allClientsIndex = allClients.length;
	allClients.push(clientInfo);

	socket.on('data', function(data) {
		resetTimeout(socket);

		var arr = msgpack.unpack(data);
		for(var i = 0, len = arr.length; i < len; i += 2) {
			var kind = arr[i];
			var arg = arr[i + 1];
			//console.log(`Received message type ${kind} with arg ${arg}`)
			if(!handleMessage[kind]) {
				console.warn(`Missing a handler for message ${kind}`)
				continue;
			}

			handleMessage[kind].call(clientInfo, arg);
		}
	})

	socket.on('end', function() {
		// TODO: tell other players this player is disconnected
		delete allClients[allClientsIndex];
	});

	socket.on('error', function(err) {
		console.log(err)
	})
});

server.listen(7543, '127.0.0.1');
