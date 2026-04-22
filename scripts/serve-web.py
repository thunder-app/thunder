#!/usr/bin/env python3

import argparse
import http.server
import os
import socket
import socketserver
from pathlib import Path


class CrossOriginRequestHandler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
    }

    def end_headers(self) -> None:
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Serve Flutter web output over the local network.")
    parser.add_argument("--host", default="0.0.0.0", help="Host/interface to bind to. Defaults to 0.0.0.0.")
    parser.add_argument("--port", type=int, default=8080, help="Port to serve on. Defaults to 8080.")
    parser.add_argument("--dir", default="build/web", help="Directory to serve. Defaults to build/web.")
    return parser.parse_args()


def local_ip() -> str:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(("8.8.8.8", 80))
        return sock.getsockname()[0]
    except OSError:
        return "localhost"
    finally:
        sock.close()


def main() -> None:
    args = parse_args()
    directory = Path(args.dir).resolve()

    if not directory.exists():
        raise SystemExit(f"Directory does not exist: {directory}")

    handler = lambda *handler_args, **handler_kwargs: CrossOriginRequestHandler(  # noqa: E731
        *handler_args,
        directory=os.fspath(directory),
        **handler_kwargs,
    )

    with socketserver.TCPServer((args.host, args.port), handler) as httpd:
        print(f"Serving {directory}")
        print(f"Local:   http://localhost:{args.port}")
        print(f"Network: http://{local_ip()}:{args.port}")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
