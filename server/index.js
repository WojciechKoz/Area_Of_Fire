// vim: sw=7 ts=7 noet

var net = require('net');
var msgpack = require('msgpack');

var math = require('./math.js');

// fix exiting in Docker
process.on('SIGINT', function() {
    process.exit();
});

const PLAYER_RADIUS = 15;

const TIMEOUT_KICK = 60000; // 60 s

const MSGS_SEND = {
	NEW_PLAYER: 0,
	PLAYER_MOVE: 1,
	SHOT: 2,
	SET_HP: 3
};

const MSGS_RECEIVE = {
	SET_NICKNAME: 0,
	PLAYER_MOVE: 1,
	SHOT_WEAPON: 2,
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
function sendGameStateToNewPlayer(socket) {
	var message = [];
	for (var clientIdx in allClients) {
		var client = allClients[clientIdx];
		if(client.nickname != null) {
			message.push(MSGS_SEND.NEW_PLAYER);
			message.push([client.clientId, client.nickname]);
			message.push(MSGS_SEND.SET_HP);
			message.push([client.clientId, client.hp]);
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

function weaponDamage(weaponId) {
	const weaponDamages = [
		1,
		1,
		2,
		3,
		10,
		1,
		2,
		5,
		1,
		3,
		1,
		1
	];

	return weaponDamages[weaponId] || 1;
}

function decreaseHp({ hit, shooter }) {
	var damage = weaponDamage(shooter.weapon);
	console.log(`Decreased hp of ${hit.clientId} from ${hit.hp} to ${hit.hp - damage}`);
	hit.hp -= damage;
	sendToAllExcept(hit.clientId, [MSGS_SEND.SET_HP, [hit.clientId, hit.hp, shooter.clientId]])
	messageToSocket(hit.socket, [MSGS_SEND.SET_HP, [-1, hit.hp, shooter.clientId]]);
}

function handleShot(shootingClient, bulletEnd) {
	allClients.forEach(otherPlayer => {
		if(otherPlayer.clientId == shootingClient.clientId)
			return; // skip the shooter

		console.log(shootingClient.x, shootingClient.y, bulletEnd.x, bulletEnd.y, otherPlayer.x, otherPlayer.y, PLAYER_RADIUS);
		if(math.line_intersection_with_circle(
			shootingClient.x, shootingClient.y,
			bulletEnd.x, bulletEnd.y,
			otherPlayer.x, otherPlayer.y, PLAYER_RADIUS)) {

			decreaseHp({ hit: otherPlayer, shooter: shootingClient });
		}
	});
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
	// arg is [x:float, y:float, flags:short, weapon:int]
	if(!Array.isArray(arg) || arg.length != 4) {
		console.warn(`Malformed PLAYER_MOVE from client ${clientInfo.clientId}`);
		return;
	}

	var [x, y, flags, weapon] = arg;

	clientInfo.x = x;
	clientInfo.y = y;
	clientInfo.flags = flags;
	clientInfo.weapon = weapon;

	var message = [MSGS_SEND.PLAYER_MOVE, [clientInfo.clientId, x, y, flags, weapon]];
	console.log(message)
	sendToAllExcept(clientInfo.clientId, message);
}
handleMessage[MSGS_RECEIVE.SHOT_WEAPON] = function(clientInfo, arg) {
	// arg is [ x, y, x, y, ... ]
	console.log(`Received shot! ${arg}`);
	if(!Array.isArray(arg) || arg.filter(num => typeof num !== 'number').length > 0) {
		console.warn(`SHOT from ${clientInfo.clientId}: argument is not a number array: ${arg}`);
		return;
	}

	sendToAllExcept(clientInfo.clientId, [MSGS_SEND.SHOT, [ clientInfo.clientId ].concat(arg)]);

	for(var i = 0, len = arg.length; i < len; i += 2) {
		handleShot(clientInfo, new math.Point(arg[i], arg[i + 1]));
	}
}


var server = net.createServer(function(socket) {
	console.log('connected')

	socket.setNoDelay(true);

	socket.disconnectTimeout = setTimeout(function() {
		console.log(`Kicking ${socket} due to inactivity`);
		socket.end();
	}, TIMEOUT_KICK);

	sendGameStateToNewPlayer(socket);
	//messageToSocket(socket, [MSGS_SEND.PLAYER_MOVE, [123, 1.5, 1.5, 1.5, 1.5]])

	var clientInfo = {
		clientId: newClientId(),
		nickname: null,
		x: 0,
		y: 0,
		flags: 0,
		weapon: 0,
		hp: 5,
		socket,
	}

	allClients[clientInfo.clientId] = clientInfo;

	var msgpackStream = new msgpack.Stream(socket);
	msgpackStream.addListener('msg', function(arr) {
		resetTimeout(socket);

		if(!Array.isArray(arr)) {
			console.warn('Got a message that is not an array');
			return;
		}

		for(var i = 0, len = arr.length; i < len; i += 2) {
			var kind = arr[i];
			var arg = arr[i + 1];
			//console.log(`Received message type ${kind} with arg ${arg}`)
			if(!handleMessage[kind]) {
				console.warn(`Missing a handler for message type ${kind}`)
				continue;
			}

			handleMessage[kind](clientInfo, arg);
		}
	});

	socket.on('end', function() {
		// TODO: tell other players this player is disconnected
		delete allClients[clientInfo.clientId];
	});

	socket.on('error', function(err) {
		console.log(err)
	})
});

server.listen(7543, '0.0.0.0', function() {
	console.log('Listening');
});
