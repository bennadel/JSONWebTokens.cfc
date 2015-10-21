
# ColdFusion Gateway For JSON Web Tokens

by [Ben Nadel][1] (on [Google+][2])

This is a small ColdFusion module to facilitate the encoding and decoding of JSON Web 
Tokens, or JWT. In order to start working with JSON Web Tokens, you can either use the
.encode() and .decode() methods provided by the core gateway:

```cfc
var jwt = new lib.JsonWebTokens();

var jwtToken = jwt.encode( somePayload, "my-secret-key" );
var payload = jwt.decode( jwtToken, "my-secret-key" );
```

_NOTE: Each of the above methods takes an optional algorithm specification._

Or, if you intend to use the same encoding and decoding methods over and over again in
a particular application, it can be more efficient to instantiate and cache a JSON Web 
Token client:

```cfc
var client = new lib.JsonWebTokens().createClient( "my-secret-key" );

var jwtToken = client.encode( somePayload );
var payload = client.decode( jwtToken );
```

By doing this, you can pass around your JWT implementation without having to pass around
your secret key or your signing algorithm. 

## Security

At this time, this ColdFusion JSON Web Token library only supports HMac signing. It also
prevents anonymous / pre-verified tokens, forcing all encoding and decoding to use one of
the HMac algorithms (256, 384, 512).


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
