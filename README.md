
# JSONWebTokens.cfc - A ColdFusion Gateway For JSON Web Tokens

by [Ben Nadel][1] (on [Google+][2])

This is a small ColdFusion module to facilitate the encoding and decoding of JSON Web 
Tokens, or JWT. In order to start working with JSON Web Tokens, you can either use the
.encode() and .decode() methods provided by the core gateway:

```cfc
var jwt = new lib.JsonWebTokens();

var jwtToken = jwt.encode( somePayload, "HS256", "secretKey" );
var payload = jwt.decode( jwtToken, "HS256", "secretKey" );
```

Or, if you intend to use the same encoding and decoding methods over and over again in
a particular application, it can be more efficient to instantiate and cache a JSON Web 
Token client:

```cfc
var client = new lib.JsonWebTokens().createClient( "HS256", "secretKey" );

var jwtToken = client.encode( somePayload );
var payload = client.decode( jwtToken );
```

By doing this, you can pass around your JWT implementation without having to pass around
your secret key or your signing algorithm. 

## Security

At this time, the ColdFusion JSON Web Token library supports both Hmac and RSA based 
signing:

* HS256 _( uses HmacSHA256 as the underlying Java algorithm)_.
* HS384 _( uses HmacSHA384 as the underlying Java algorithm)_.
* HS512 _( uses HmacSHA512 as the underlying Java algorithm)_.
* RS256 _( uses SHA256withRSA as the underlying Java algorithm)_.
* RS384 _( uses SHA384withRSA as the underlying Java algorithm)_.
* RS512 _( uses SHA512withRSA as the underlying Java algorithm)_.

However, since the round-trip RSA encryption algorithm requires both a public
key (for verification) and a private key (for signing), the private key is required when
using RSA-based methods or creating an RSA-based client:

```cfc
// Create an Hmac-based client.
var client = new lib.JsonWebTokens().createClient( "HS256", "secret" );

// Create an RSA-based client.
var client = new lib.JsonWebTokens().createClient( "RS256", "publicKey", "privateKey" );

// Or, just use the .encode() and .decode() methods directly:
var jwt = new lib.JsonWebTokens();

// Encode a payload:
jwt.encode( somePayload, "HS256", "secretKey" );
jwt.encode( somePayload, "RS256", "publicKey", "privateKey" );

// Decode a payload:
jwt.decode( jwtToken, "HS256", "secretKey" );
jwt.decode( jwtToken, "RS256", "publicKey", "privateKey" );
```

When using the RSA encryption algorithm, the public and private keys are assumed to be
provided in plain-text PEM format.

_**NOTE**: PEM (Privacy Enhanced Mail) format is a Base64 encoded DER certificate commonly 
used on servers._

The JSON Web Token library prevent anonymous / pre-verified tokens, and for security 
purposes, never uses the algorithm presented in the header. All decoding / verifying is
required to use the internal signer with a specific algorithm so as to prevent abuse.


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
