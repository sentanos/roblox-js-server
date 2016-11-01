# roblox-js-server

This is a primitive example server that uses my [roblox-js](https://github.com/sentanos/roblox-js) library, allowing users to execute site actions from in-game via HttpService.

## Instructions

Go to settings.json and set `username` and `password` to the username and password of the ROBLOX account you want to use. The `key` field is essentially a password for the site (to prevent strangers from accessing account functions). I recommend generating a random string or just smashing your keyboard since this will typically be accessed by another script that doesn't have to memorize said key.

## Video Tutorial

Coming soon.

## Documentation

### METHOD /example/{argument1: type}/{argument2: type}/[optional argument: type]?[optional_argument: type]&[optional_argument2: type]
```
Example usage
```

{argument3: type}

Description

Post data is under the header, in this example is starts with argument 3. This should be sent in json format or it will not be read correctly.
All functions respond with a json table containing the fields `error`, `message`, and `data`. The `error` field is always visible but may be null, the `message` field contains a human-readable message summarizing the pages action, and `data` contains response data from the API is applicable.

[response1: type, reponse2: type]

### POST /demote/{group: number}/{target: number}
```
/demote/18/2470023
{"key": "hunter2"}
```

{key: string}

Sets the role of the player to the adjacent lower-rank role.

[newRankName: string, newRank: number, newRoleSetId: number]

### POST /getPlayers/delete/{uid: string}
```
/getPlayers/delete/2f08e9796a
{"key": "hunter2"}
```

{key: string}

Deletes the getPlayers job with id `uid` from the filesystem if complete or the list if not. Note that if it is not complete it will still be running on the server though it cannot be accessed.

### POST /getPlayers/make/{group: number}/[rank: number]?[limit: number]&[online: boolean]
```
/getPlayers/make/147864?limit=1&online=false
{"key": "hunter2"}
```

{key: string}

Gets the players in group with group ID `group`. If `rank` is not specified it gets all players from all ranks, otherwise it gets all players from the role with that rank. If `online` is true only online users will be collected. If `limit` is enabled users will be returned in the same order they are visible in the group pages to the set number and forever if the number is -1. Note that this slows down the function considerably. The function returns a `uid` that can eventually be used to get the resulting player list (if the page just waited it could time out since this action can take a while). The file containing players is stored on the file system in the folder `players` and is not cleared by this script, therefore the result will be usable across restarts. See below for retrieving.

[uid: number]

### GET /getPlayers/retrieve/{uid: string}
```
/getPlayers/retrieve/2f08e9796a
```

Gets the result of the getPlayers job, returning `progress` in percent when not complete while `complete` denotes whether or not it is. The players are in json object `players`.

[progress: number,
complete: boolean,
players (object): {username (string): userId (number)}]

### POST /handleJoinRequest/{group: number}/{username: string}/{accept: boolean}
```
/handleJoinRequest/18/Froast/true
{"key": "hunter2"}
```

{key: string}

Searches for the join request of user with username `username` in the group with group ID `group` and accepts them if `accept` is true and denies them if it is false (note that for either case you still need the parameter in the url)

### POST /message/{recipient: number}
```
/message/2470023
{"subject": "Test", "body": "Test", "key": "hunter2"}
```

{subject: string,
body: string,
key: string}

Messages user with ID `recipient` with a message that has subject `subject` and body `body`.

### POST /promote/{group: number}/{target: number}
```
/promote/18/2470023
{"key": "hunter2"}
```

{key: string}

Sets the role of the player to the adjacent higher-rank role.

[newRankName: string, newRank: number, newRoleSetId: number]

### POST /setRank/{group: number}/{target: number}/{rank: number}
```
/setRank/18/2470023/2
{"key": "hunter2"}
```

{key: string}

Sets rank of player with user ID `target` to rank with rank number `rank` in group with group ID `group`. Responds with the role set ID of the user's updated rank, `newRoleSetId`.

[newRoleSetId: number]

### POST /shout/{group: number}
```
/shout/18
{"message": "Test", key": "hunter2"}
```


{message: string,
key: string}

Shouts in group with group ID `group` and the message `message`.
