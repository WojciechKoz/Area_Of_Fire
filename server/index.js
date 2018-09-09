// vim: sw=7 ts=7 noet

var net = require('net');
var msgpack = require('msgpack');

var math = require('./math.js');

// fix exiting in Docker
process.on('SIGINT', function() {
    process.exit();
});

const PLAYER_RADIUS = 15;

const TIMEOUT_KICK = 20000; // 20 s

const TICK_INTERVAL = 1000/50; // how frequest send messages to clients

const MSGS_SEND = {
	NEW_PLAYER: 0,
	PLAYER_MOVE: 1,
	SHOT: 2,
	SET_HP: 3,
	PLAYER_DISCONNECT: 4,
	CHAT: 5,
	SET_TEAM: 6,
	STATS: 7,
};

const MSGS_RECEIVE = {
	SET_NICKNAME: 0,
	PLAYER_MOVE: 1,
	SHOT_WEAPON: 2,
	CHAT: 3,
	SET_TEAM: 4,
	RESPAWN: 5,
}

var _lastClientId = 1;
function newClientId() {
	return _lastClientId++;
}

var allClients = [];


function setupTimeout(client) {
	client.socket.disconnectTimeout = setTimeout(function() {
		console.log(`Kicking client ${client.clientId} due to inactivity`);
		getRidOf(client);
	}, TIMEOUT_KICK);
}

// after TIMEOUT_KICK ms of no data a socket is considered disconnected.
function resetTimeout(client) {
	if(client.socket.disconnectTimeout.refresh) { // Node >= 10
		client.socket.disconnectTimeout.refresh();
	} else {
		setupTimeout(client);
	}
}

function sendQueuedMessagesToClient(client) {
	if(client.queuedMessages && client.queuedMessages.length == 0) {
		return;
	}

	if(client == null || client.socket == null) {
		console.warn(`Tried to send messages to an undefined/disconnected client ${client.clientId}`)
		return;
	}

	client.socket.write(msgpack.pack(client.queuedMessages));

	client.queuedMessages = [];
}

function tick() {
	allClients.forEach(client => {
		sendQueuedMessagesToClient(client);
	});
}

// Queue a message to send it to client
function messageToClient(client, topic, message) {
	if(client == null || client.socket == null || client.alreadyDisconnected) {
		console.warn(`Tried to queue message [${topic}, ${message}] for an undefined/disconnected client ${client.clientId}`)
		return;
	}
	client.queuedMessages.push(topic, message)
	//socket.write(msgpack.pack(message));
}

// send all existing players' nicknames to a newly connected player
function sendGameStateToNewPlayer(newClient) {
	allClients.forEach(client => {
		if(client.nickname == null)
			return;

		messageToClient(newClient, MSGS_SEND.NEW_PLAYER, [client.clientId, client.nickname]);

		messageToClient(newClient, MSGS_SEND.SET_HP, [client.clientId, client.hp]);

		messageToClient(newClient, MSGS_SEND.PLAYER_MOVE, [client.clientId, client.x, client.y, client.flags, client.weapon]);

		if(client.team != null)
			messageToClient(newClient, MSGS_SEND.SET_TEAM, [client.clientId, client.team]);
	});
}

function sendToAllExcept(clientId, topic, message) {
	allClients.forEach(client => {
		if(client.clientId != clientId) {
			messageToClient(client, topic, message);
		}
	})
}
function sendToAll(topic, message) {
	allClients.forEach(client => {
		messageToClient(client, topic, message);
	});
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

function sendStats(client) {
	var stats = allClients
		.filter(el => el != null)
		.map(c => [
			(client.clientId == c.clientId) ? -1 : c.clientId,
			c.stats.kills,
			c.stats.deaths])

	// Sort in descending order
	stats.sort((a, b) => {
		var a_kills = a[1];
		var a_deaths = a[2];
		var a_score = a_kills - a_deaths;

		var b_kills = b[1];
		var b_deaths = b[2];
		var b_score = b_kills - b_deaths;

		return b_score - a_score;
	})

	console.log(`Sending stats to ${client.clientId}: ${JSON.stringify(stats)}`)
	messageToClient(client, MSGS_SEND.STATS, stats);
}

function sendStatsToAll() {
	allClients.forEach(client => sendStats(client));
}

function playerDied({died, shooter}) {
	console.log(`Player ${died.clientId} has died`)
	died.stats.deaths += 1;
	shooter.stats.kills += 1;

	sendStatsToAll();
}

function decreaseHp({ hit, shooter }) {
	var damage = weaponDamage(shooter.weapon);
	console.log(`Decreased hp of ${hit.clientId} from ${hit.hp} to ${hit.hp - damage}`);
	hit.hp -= damage;

	allClients.forEach(client => {
		var hitId = (client.clientId == hit.clientId) ? -1 : hit.clientId;
		var shooterId = (client.clientId == shooter.clientId) ? -1 : shooter.clientId;

		messageToClient(client, MSGS_SEND.SET_HP, [hitId, hit.hp, shooterId]);
	});

	if(hit.hp <= 0) {
		playerDied({ died: hit, shooter: shooter });
  }
}

function handleShot(shootingClient, bulletEnd) {
	allClients.forEach(otherPlayer => {
		if(otherPlayer.clientId == shootingClient.clientId)
			return; // skip the shooter

		if(otherPlayer.hp <= 0)
			return;

		//console.log(shootingClient.x, shootingClient.y, bulletEnd.x, bulletEnd.y, otherPlayer.x, otherPlayer.y, PLAYER_RADIUS);
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
handleMessage[MSGS_RECEIVE.SET_NICKNAME] = function(client, arg) {
	arg = "" + arg;

	console.log(`Nickname = ${arg}`)
	client.nickname = arg;
	sendToAllExcept(client.clientId, MSGS_SEND.NEW_PLAYER, [client.clientId, arg])
}
handleMessage[MSGS_RECEIVE.PLAYER_MOVE] = function(client, arg) {
	// arg is [x:float, y:float, flags:short, weapon:int]
	if(!Array.isArray(arg) || arg.length != 4) {
		console.warn(`Malformed PLAYER_MOVE from client ${client.clientId}`);
		return;
	}

	var [x, y, flags, weapon] = arg;

	client.x = x;
	client.y = y;
	client.flags = flags;
	client.weapon = weapon;

	sendToAllExcept(client.clientId, MSGS_SEND.PLAYER_MOVE, [client.clientId, x, y, flags, weapon]);
}
handleMessage[MSGS_RECEIVE.SHOT_WEAPON] = function(client, arg) {
	// arg is [ x, y, x, y, ... ]
	console.log(`Received shot! ${arg}`);
	if(!Array.isArray(arg) || arg.filter(num => typeof num !== 'number').length > 0) {
		console.warn(`SHOT from ${client.clientId}: argument is not a number array: ${arg}`);
		return;
	}

	sendToAllExcept(client.clientId, MSGS_SEND.SHOT, [ client.clientId ].concat(arg));

	for(var i = 0, len = arg.length; i < len; i += 2) {
		handleShot(client, new math.Point(arg[i], arg[i + 1]));
	}
}
handleMessage[MSGS_RECEIVE.CHAT] = function(client, arg) {
	arg = "" + arg;

	console.log(`Chat from ${client.clientId} (${client.nickname}): ${arg}`);

	if(arg.length > 500) {
		console.warn(`Received chat message of length ${arg.length}.\n` +
			`\tSince the client does not send messages longer than 200 characters, this is highly suspicious. Not relaying.`);
		return;
	}

	sendToAll(MSGS_SEND.CHAT, [`${client.nickname}: ${arg}`]);
}
handleMessage[MSGS_RECEIVE.SET_TEAM] = function(client, arg) {
	arg = arg | 0;

	client.team = arg;

	console.log(`Changing team of ${client.clientId} to ${arg} (${(arg == 0) ? 'blue' : (arg == 1) ? 'red' : 'not valid team id'})`);
	sendToAllExcept(client.clientId, MSGS_SEND.SET_TEAM, [client.clientId, arg]);
}
handleMessage[MSGS_RECEIVE.RESPAWN] = function(client, arg) {
	console.log(`Respawning ${client.clientId}`);

	client.hp = 5;

	sendToAllExcept(client.clientId, MSGS_SEND.SET_HP, [client.clientId, client.hp]);
	messageToClient(client, MSGS_SEND.SET_HP, [-1, client.hp]);
}


function getRidOf(client) {
	if(client.alreadyDisconnected == true)
		return;

	console.log(`Getting rid of ${client.clientId}`);

	client.alreadyDisconnected = true;

	sendQueuedMessagesToClient(client);

	client.socket.end();
	delete allClients[client.clientId];
	if(client.socket && client.socket.disconnectTimeout)
		clearTimeout(client.socket.disconnectTimeout);

	sendToAllExcept(client.clientId, MSGS_SEND.PLAYER_DISCONNECT, [client.clientId]);

	sendStatsToAll();
}

var server = net.createServer(function(socket) {
	console.log('connected')

	socket.setNoDelay(true);

	setupTimeout(clientInfo);

	var clientInfo = {
		clientId: newClientId(),
		nickname: null,
		x: 0,
		y: 0,
		flags: 0,
		weapon: 0,
		hp: 5,
		alreadyDisconnected: false,
		queuedMessages: [],
		team: null,
		socket,
		stats: {
			kills: 0,
			deaths: 0,
		},
	}

	sendGameStateToNewPlayer(clientInfo);

	allClients[clientInfo.clientId] = clientInfo;

	sendStatsToAll();

	var msgpackStream = new msgpack.Stream(socket);
	msgpackStream.addListener('msg', function(arr) {
		resetTimeout(clientInfo);

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
		console.log(`Received an 'end' event on client ${clientInfo.clientId}, will get rid of if needed`)
		getRidOf(clientInfo);
	});
	socket.on('close', function() {
		console.log(`Received a 'close' event on client ${clientInfo.clientId}, will get rid of if needed`)
		getRidOf(clientInfo);
	});

	socket.on('error', function(err) {
		console.log(`Received an error on socket for client ${clientInfo.clientId}, getting rid if needed:`, err)
		getRidOf(clientInfo);
	})
});

server.listen(7543, '0.0.0.0', function() {
	setInterval(tick, 1000/50);
	console.log('Listening');
});
