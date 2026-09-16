//! Browser-side RHP4 check: opens a WebTransport session to a host's QUIC
//! address, scans its settings with the RHP4 Settings RPC, closes the session
//! and reports the outcome in the same shape as a troubleshootd RHP4 result.

use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

use chrono::Utc;
use js_sys::Uint8Array;
use serde::Serialize;
use sia_core::rhp4::HostSettings;
use sia_core::rhp4::protocol::RPCSettings;
use sia_core::signing::PublicKey;
use tokio::io::{AsyncRead, ReadBuf};
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_time::{Duration, Instant};

/// The WebTransport URL path hosts serve RHP4 on.
const RHP4_PATH: &str = "/sia/rhp/v4";
const PROTOCOL: &str = "webtransport";

#[wasm_bindgen]
extern "C" {
    type ReadableStreamReadResult;

    #[wasm_bindgen(method, getter, js_name = "done")]
    fn is_done(this: &ReadableStreamReadResult) -> bool;

    #[wasm_bindgen(method, getter)]
    fn value(this: &ReadableStreamReadResult) -> JsValue;
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct NetAddress {
    protocol: &'static str,
    address: String,
}

/// Mirrors the troubleshootd RHP4 result so the client can render it alongside
/// the server-side results. Durations are nanoseconds, like Go's time.Duration.
#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct ScanResult {
    net_address: NetAddress,
    connected: bool,
    dial_time: u64,
    handshake: bool,
    handshake_time: u64,
    scanned: bool,
    scan_time: u64,
    settings: Option<HostSettings>,
    errors: Vec<String>,
    warnings: Vec<String>,
}

struct Deadline(Instant);

struct Connection {
    transport: web_sys::WebTransport,
}

struct Stream {
    reader: web_sys::ReadableStreamDefaultReader,
    writer: web_sys::WritableStreamDefaultWriter,
    pending_read: Option<JsFuture>,
    buf: Vec<u8>,
}

impl ScanResult {
    fn new(address: &str) -> Self {
        Self {
            net_address: NetAddress {
                protocol: PROTOCOL,
                address: address.to_string(),
            },
            connected: false,
            dial_time: 0,
            handshake: false,
            handshake_time: 0,
            scanned: false,
            scan_time: 0,
            settings: None,
            errors: Vec::new(),
            warnings: Vec::new(),
        }
    }
}

impl Deadline {
    fn after(timeout: Duration) -> Self {
        Self(Instant::now() + timeout)
    }

    /// Runs `fut` until it completes or the deadline passes.
    async fn run<T>(
        &self,
        what: &str,
        fut: impl Future<Output = Result<T, String>>,
    ) -> Result<T, String> {
        let remaining = self.0.saturating_duration_since(Instant::now());
        tokio::select! {
            result = fut => result,
            _ = sleep(remaining) => Err(format!("timed out while {what}")),
        }
    }
}

impl Connection {
    /// Creates the session and starts the handshake. The returned future
    /// resolves when the session closes; subscribing to it up front keeps a
    /// failed handshake from surfacing as an unhandled promise rejection.
    fn open(url: &str) -> Result<(Self, JsFuture<web_sys::WebTransportCloseInfo>), String> {
        let options = web_sys::WebTransportOptions::new();
        let transport = web_sys::WebTransport::new_with_options(url, &options).map_err(|e| {
            format!(
                "failed to create WebTransport session: {}",
                js_err_message(&e)
            )
        })?;
        let closed = JsFuture::from(transport.closed());
        Ok((Self { transport }, closed))
    }

    async fn ready(&self) -> Result<(), String> {
        JsFuture::from(self.transport.ready())
            .await
            .map(|_| ())
            .map_err(|e| js_err_message(&e))
    }

    async fn open_stream(&self) -> Result<Stream, String> {
        let bidi: web_sys::WebTransportBidirectionalStream =
            JsFuture::from(self.transport.create_bidirectional_stream())
                .await
                .map_err(|e| format!("failed to open stream: {}", js_err_message(&e)))?
                .unchecked_into();
        let reader = bidi
            .readable()
            .get_reader()
            .unchecked_into::<web_sys::ReadableStreamDefaultReader>();
        let writer = bidi
            .writable()
            .get_writer()
            .map_err(|e| format!("failed to get stream writer: {}", js_err_message(&e)))?;
        Ok(Stream {
            reader,
            writer,
            pending_read: None,
            buf: Vec::new(),
        })
    }

    fn close(&self) {
        self.transport.close();
    }
}

impl Drop for Connection {
    fn drop(&mut self) {
        self.close();
    }
}

impl Stream {
    /// Writes the whole buffer in a single JS call.
    async fn write_all(&self, data: &[u8]) -> Result<(), String> {
        let chunk = Uint8Array::new_with_length(data.len() as u32);
        chunk.copy_from(data);
        JsFuture::from(self.writer.write_with_chunk(&chunk))
            .await
            .map(|_| ())
            .map_err(|e| js_err_message(&e))
    }
}

impl AsyncRead for Stream {
    fn poll_read(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>,
        buf: &mut ReadBuf<'_>,
    ) -> Poll<std::io::Result<()>> {
        let this = self.get_mut();

        if !this.buf.is_empty() {
            let n = this.buf.len().min(buf.remaining());
            buf.put_slice(&this.buf[..n]);
            this.buf.drain(..n);
            return Poll::Ready(Ok(()));
        }

        let future = this
            .pending_read
            .get_or_insert_with(|| JsFuture::from(this.reader.read()));
        let result = std::task::ready!(Pin::new(future).poll(cx))
            .map_err(|e| std::io::Error::other(js_err_message(&e)))?;
        this.pending_read = None;

        let chunk: ReadableStreamReadResult = result.unchecked_into();
        if chunk.is_done() {
            return Poll::Ready(Ok(()));
        }

        let data = Uint8Array::new(&chunk.value()).to_vec();
        let n = data.len().min(buf.remaining());
        buf.put_slice(&data[..n]);
        this.buf.extend_from_slice(&data[n..]);
        Poll::Ready(Ok(()))
    }
}

fn js_err_message(e: &JsValue) -> String {
    if let Some(err) = e.dyn_ref::<js_sys::Error>() {
        let message: String = err.message().into();
        if !message.is_empty() {
            return message;
        }
    }
    e.as_string().unwrap_or_else(|| format!("{e:?}"))
}

fn webtransport_supported() -> bool {
    js_sys::Reflect::get(&js_sys::global(), &"WebTransport".into())
        .map(|v| !v.is_undefined())
        .unwrap_or(false)
}

async fn sleep(duration: Duration) {
    let promise = js_sys::Promise::new(&mut |resolve, _| {
        let set_timeout: js_sys::Function =
            js_sys::Reflect::get(&js_sys::global(), &"setTimeout".into())
                .expect("setTimeout is defined")
                .into();
        let _ = set_timeout.call2(
            &JsValue::NULL,
            &resolve,
            &JsValue::from_f64(duration.as_millis() as f64),
        );
    });
    let _ = JsFuture::from(promise).await;
}

async fn scan_settings(conn: &Connection) -> Result<HostSettings, String> {
    let mut stream = conn.open_stream().await?;
    let mut request = Vec::new();
    let rpc = RPCSettings::send_request(&mut request)
        .await
        .map_err(|e| format!("failed to encode request: {e}"))?;
    stream
        .write_all(&request)
        .await
        .map_err(|e| format!("failed to write request: {e}"))?;
    let response = rpc
        .complete(&mut stream)
        .await
        .map_err(|e| format!("failed to read response: {e}"))?;
    Ok(response.settings)
}

fn check_settings(settings: &HostSettings, host_key: &PublicKey, result: &mut ScanResult) {
    let prices = &settings.prices;
    if prices.valid_until <= Utc::now() {
        result.errors.push(format!(
            "host prices expired at {}",
            prices.valid_until.to_rfc3339()
        ));
    }
    if prices.tip_height == 0 {
        result
            .errors
            .push("host reports a tip height of 0, it may not be synced".to_string());
    }
    if !host_key.verify(prices.sig_hash().as_ref(), &prices.signature) {
        result.errors.push(
            "host prices signature is invalid, the host may not be using the expected key"
                .to_string(),
        );
    }
}

async fn scan(address: &str, host_key: &str, timeout: Duration) -> ScanResult {
    let mut result = ScanResult::new(address);

    let host_key: PublicKey = match host_key.parse() {
        Ok(key) => key,
        Err(e) => {
            result
                .errors
                .push(format!("invalid host public key {host_key:?}: {e:?}"));
            return result;
        }
    };
    if !webtransport_supported() {
        result
            .errors
            .push("this browser does not support WebTransport".to_string());
        return result;
    }

    let deadline = Deadline::after(timeout);
    let url = format!("https://{address}{RHP4_PATH}");
    let (conn, closed) = match Connection::open(&url) {
        Ok(v) => v,
        Err(e) => {
            result.errors.push(e);
            return result;
        }
    };

    let start = Instant::now();
    if let Err(e) = deadline.run("connecting", conn.ready()).await {
        let e = e.trim_end_matches('.');
        result.errors.push(format!(
            "failed to connect to {url}: {e}. The host may be offline, UDP may be blocked, or the browser may not trust the host's TLS certificate"
        ));
        return result;
    }
    result.dial_time = start.elapsed().as_nanos() as u64;
    result.connected = true;
    // The TLS handshake completes as part of establishing the session.
    result.handshake = true;

    let start = Instant::now();
    match deadline
        .run("scanning settings", scan_settings(&conn))
        .await
    {
        Ok(settings) => {
            result.scan_time = start.elapsed().as_nanos() as u64;
            result.scanned = true;
            check_settings(&settings, &host_key, &mut result);
            result.settings = Some(settings);
        }
        Err(e) => result.errors.push(format!("failed to scan settings: {e}")),
    }

    conn.close();
    let closed = async { closed.await.map(|_| ()).map_err(|e| js_err_message(&e)) };
    if let Err(e) = deadline.run("closing the session", closed).await {
        result
            .errors
            .push(format!("session did not close cleanly: {e}"));
    }
    result
}

/// Scans `address` over WebTransport with an overall deadline of `timeout_ms`
/// and returns the result as JSON shaped like a troubleshootd RHP4 result.
#[wasm_bindgen(js_name = scanHost)]
pub async fn scan_host(address: String, host_key: String, timeout_ms: u32) -> String {
    let result = scan(
        &address,
        &host_key,
        Duration::from_millis(timeout_ms.into()),
    )
    .await;
    serde_json::to_string(&result).expect("scan result serializes")
}
