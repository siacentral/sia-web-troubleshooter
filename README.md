# troubleshooter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building

The results page runs a browser-side WebTransport check backed by a Rust
crate in `wasm/`, compiled to WebAssembly with
[wasm-pack](https://github.com/drager/wasm-pack). Build it into `web/wasm`
before building or running the Flutter app:

```sh
cd wasm && wasm-pack build --release --target web --no-typescript --no-pack --out-dir ../web/wasm --out-name troubleshooter_wasm
flutter build web --release
```
