# 📼 VCR (`http`)

A package to store and replay requests using the `http` package.

## Getting Started

Create a client:

```dart
VcrClient client = VcrClient(cassettePath: 'cassette_path');
Response response = await client.get('https://api.github.com/users/keviinlouis/repos');
```

If the cassette file already exists when the `VcrClient` is created it will playback and match the requests to the stored requests.

If the cassette file did not already exist it will send and record the http requests.

To use a different cassette create another `VcrClient` instance.

## Replaying the recorded requests

Create a new `VcrClient` instance with the same `cassette_path`. If the cassette file already ex

### Using with custom Client

The recommended way to use VcrClint in combination with a custom Client is to wrap VcrClient with your custom Client. See the implementation of the http package's IOClient for an example on how this is done.


## Thanks to:

 * **[@keviinlouis](https://github.com/keviinlouis)** for creating the [`vcr`](https://github.com/keviinlouis/vcr) package for Dio requests.
 * The creators of the original Ruby VCR package which I use and love in my Ruby projects. 
