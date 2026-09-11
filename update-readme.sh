#!/bin/sh

set -eu
cd "$(dirname "$0")"

# Use the same image list as the build. Credentials stay in the environment and
# HTTP request bodies, rather than appearing in command-line arguments or logs.
exec python3 - <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def request(method, path, payload=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(payload).encode() if payload is not None else None
    req = Request(f"https://hub.docker.com/v2/{path}", data=data,
                  headers=headers, method=method)
    try:
        with urlopen(req, timeout=60) as response:
            return json.load(response)
    except HTTPError as error:
        sys.exit(f"Docker Hub {method} {path}: HTTP {error.code}")
    except URLError:
        sys.exit(f"Docker Hub {method} {path}: connection failed")


username = os.environ.get("DOCKERHUB_USERNAME")
password = os.environ.get("DOCKERHUB_PASSWORD")
if not username or not password:
    sys.exit("Set DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD (Docker Hub token)")
images = subprocess.check_output(["./build.sh", "list"], text=True).split()
if not images:
    sys.exit("No images found in the build manifest")
description = Path("README.md").read_text()
if len(description.encode()) > 25000:
    sys.exit("README.md exceeds Docker Hub's 25,000-byte limit")
token = request("POST", "auth/token", {
    "identifier": username, "secret": password,
})["access_token"]
for image in images:
    path = f"repositories/whatwedo/{image}/"
    request("PATCH", path, {"full_description": description}, token)
    if request("GET", path, token=token)["full_description"] != description:
        sys.exit(f"Docker Hub README verification failed for whatwedo/{image}")
    print(f"Updated and verified README for whatwedo/{image}", flush=True)
PY
