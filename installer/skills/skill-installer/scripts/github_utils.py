#!/usr/bin/env python3
"""Shared GitHub helpers for skill install scripts."""

from __future__ import annotations

import http.client
import os
import urllib.parse


ALLOWED_GITHUB_HOSTS = {"api.github.com", "github.com", "raw.githubusercontent.com"}


def github_request(url: str, user_agent: str) -> bytes:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "https" or parsed.hostname not in ALLOWED_GITHUB_HOSTS:
        raise ValueError(f"Unsupported GitHub URL: {url}")

    headers = {"User-Agent": user_agent}
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"token {token}"

    path = urllib.parse.urlunparse(("", "", parsed.path or "/", "", parsed.query, ""))
    connection = http.client.HTTPSConnection(parsed.hostname, timeout=30)  # nosemgrep: python.lang.security.audit.httpsconnection-detected.httpsconnection-detected
    try:
        connection.request("GET", path, headers=headers)
        response = connection.getresponse()
        body = response.read()
        if response.status >= 400:
            raise RuntimeError(f"GitHub request failed with HTTP {response.status}: {url}")
        return body
    finally:
        connection.close()


def github_api_contents_url(repo: str, path: str, ref: str) -> str:
    return f"https://api.github.com/repos/{repo}/contents/{path}?ref={ref}"
