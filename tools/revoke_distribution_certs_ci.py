#!/usr/bin/env python3
"""Revoga certs Distribution via API Apple (Codemagic)."""
import os
import sys
import time

import jwt
import requests

TYPES = {"IOS_DISTRIBUTION", "DISTRIBUTION"}
BASE = "https://api.appstoreconnect.apple.com/v1"


def main() -> int:
    issuer = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "").strip()
    key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "").strip()
    private_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "").strip()
    if not issuer or not key_id or not private_key:
        print("ERRO: faltam APP_STORE_CONNECT_* no ambiente.", flush=True)
        return 1

    now = int(time.time())
    token = jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": key_id},
    )
    headers = {"Authorization": f"Bearer {token}"}

    deleted = 0
    url = f"{BASE}/certificates?limit=200"
    while url:
        r = requests.get(url, headers=headers, timeout=60)
        if r.status_code >= 400:
            print(f"LIST {r.status_code}: {r.text[:400]}", flush=True)
            return 1
        body = r.json()
        for item in body.get("data", []):
            ctype = item.get("attributes", {}).get("certificateType", "")
            cid = item.get("id")
            if ctype in TYPES and cid:
                print(f"DELETE {ctype} {cid}", flush=True)
                dr = requests.delete(f"{BASE}/certificates/{cid}", headers=headers, timeout=60)
                if dr.status_code in (200, 204, 404):
                    deleted += 1
                else:
                    print(f"  falhou {dr.status_code}: {dr.text[:300]}", flush=True)
        url = body.get("links", {}).get("next")

    print(f"Revogados via API: {deleted}", flush=True)
    return 0 if deleted > 0 else 1


if __name__ == "__main__":
    sys.exit(main())
