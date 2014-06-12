# [Ezmlm](http://cr.yp.to/ezmlm.html) wrapper for Node.js

## Install

    npm i --save ezmlm

## Usage

```js
ezmlm = require("ezmlm");
```

The API looks as follows:

```js
ezmlm.COMMAND(COMMAND_OPTIONS [, CALLBACk]);
```
whereas `COMMAND` can be

- `make`
- `list`
- `sub`
- `unsub`

other ezmlm commands are not implemented yet.
Feel free to fork this repo and hack a new feature!

The `COMMAND_OPTIONS` object holds the basic and optional parameters.
The basic parameters for most commands are:

```js
var cfg = {
  name:   "mylist",  // required
  dir:    "./ezmlm", // default
};
```
The `CALLBACK` function takes two parameters, the error object and the result:

```js
var callback = function(err, result){
  if (err)
    return console.error("uuups...");
  // do s.th. with the result
}
```

If you omit the `CALLBACK`, you'll get the coresponding command string:

```js
ezmlm.list({name: "foo", type: "mod"}); // returns 'ezmlm-list ./ezmlm/foo mod'
```

### Examples

```js
var listname = "mylist"
ezmlm.make({
    name:     listname,               // required
    domain:   "example.org",          // required
    dir:      "./ezmlm",              // default
    qmail:    "./.qmail-" + listname, // default
    config:   "/etc/ezmlm/de",        // optional
    owner:    "foo@bar.tld",          // optional
    from:     "baz@bar.tld",          // optional
    switches: "AbDfglMrstu"           // optional
  },
  function(err){ /* ... */ }
);

ezmlm.list({
    name: "listname",
    type: "mod"
    // possible values: 'mod', 'allow'
    // if omitted the normal subscribers are read
  },
  function(err, res){
    if (err)
      return console.error("could not read subscribers: ", err.message);
    for (var i in res){
      console.log(res[i] + " is a moderator of the " + cfg.name + " list");
    }
  }
);

ezmlm.sub({
    name: "listname",
    type: 'allow',
    addresses: ["foo@example.org"]
  },
  function(err){ /* ... */ }
})

ezmlm.unsub({
    name: "listname",
    addresses: ["foo@example.org"]
  },
  function(err){ /* ... */ }
);
```
