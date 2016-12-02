var SUCCESS = 0;

var sequenceNumber = 0;
var db = {};
function onConfirmation(args) {
    //TODO: do some error checking
    db[args.sequenceNumber](args.sequenceNumber, args.success);
}
function onValue(args) {
    if (args.success == SUCCESS) {
        db[args.sequenceNumber](args.sequenceNumber, args.success, args.value);
    } else {
        //TODO: do some error checking
        db[args.sequenceNumber](args.sequenceNumber, args.success);
    }
}
function SetKey(filename, key, value, callback) {
    if (Game.IsInToolsMode()) {
        $.Msg("[ModDotaLib - LocalStorage] WARNING: Running LocalStorage in tools mode. Using alternate location to prevent read-only storage for end users");
    }
    GameEvents.SendEventClientSide("moddota_localstorage_set", {
        "filename" : "scripts/" +(Game.IsInToolsMode() ? "tools/" : "") + filename + ".kv",
        "key" : key,
        "value" : value,
        "sequenceNumber" : ++sequenceNumber,
        "pid" : 255 //This tells Lua later to just redirect it back to us.
    });
    db[sequenceNumber] = callback;
    return sequenceNumber; 
}
function GetKey(filename, key, callback) {
    if (Game.IsInToolsMode()) {
        $.Msg("[ModDotaLib - LocalStorage] WARNING: Running LocalStorage in tools mode. Using alternate location to prevent read-only storage for end users");
    }
    GameEvents.SendEventClientSide("moddota_localstorage_get", {
        "filename" : "scripts/" +(Game.IsInToolsMode() ? "tools/" : "") + filename + ".kv",
        "key" : key,
        "sequenceNumber" : ++sequenceNumber,
        "pid" : 255 //This tells Lua later to just redirect it back to us.
    });
    db[sequenceNumber] = callback;
    return sequenceNumber;
}

(function() {
    $.Msg("[ModDotaLib - LocalStorage] Loaded.");
    GameEvents.Subscribe("moddota_localstorage_ack", onConfirmation);
    GameEvents.Subscribe("moddota_localstorage_value", onValue);
    GameEvents.SetKey = SetKey;
    GameEvents.GetKey = GetKey;
})();