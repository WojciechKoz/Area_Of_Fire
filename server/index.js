// vim: sw=7 ts=7 noet

var net = require('net');
var msgpack = require('msgpack');

const TIMEOUT_KICK = 60000; // 60 s

const MSGS_SEND = {
	NEW_PLAYER: 0,
	PLAYER_MOVE: 1,
	SHOT: 2,
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

// after TIMEOUT_KICK ms of no data a socket is considered disconnected.
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
handleMessage[MSGS_RECEIVE.SET_NICKNAME] = function(clientInfo, arg) {
	arg = "" + arg;

	console.log(`Nickname = ${arg}`)
	clientInfo.nickname = arg;
	sendToAllExcept(clientInfo.clientId, [MSGS_SEND.NEW_PLAYER, [clientInfo.clientId, arg]])
}
handleMessage[MSGS_RECEIVE.PLAYER_MOVE] = function(clientInfo, arg) {
	// arg is [x:float, y:float, flags:short]
	if(!Array.isArray(arg) || arg.length != 3) {
		console.warn(`Malformed PLAYER_MOVE from client ${clientInfo.clientId}`);
		return;
	}
	var message = [MSGS_SEND.PLAYER_MOVE, [clientInfo.clientId, arg[0], arg[1], arg[2]]];
	console.log(message)
	sendToAllExcept(clientInfo.clientId, message);
}
handleMessage[MSGS_RECEIVE.SHOT] = function(arg) {
	console.log(`Received shot! ${arg}`);
	/// ....
}


var server = net.createServer(function(socket) {
	console.log('connected')

	socket.setNoDelay(true);

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

	allClients[clientInfo.clientId] = clientInfo;

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

			handleMessage[kind](clientInfo, arg);
		}
	})

	socket.on('end', function() {
		// TODO: tell other players this player is disconnected
		delete allClients[clientInfo.clientId];
	});

	socket.on('error', function(err) {
		console.log(err)
	})
});

server.listen(7543, '0.0.0.0');
