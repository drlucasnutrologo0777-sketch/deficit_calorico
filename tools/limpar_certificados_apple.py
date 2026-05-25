#!/usr/bin/env python3
"""Apaga TODOS certificados Distribution na Apple. Rode ANTES do build Codemagic."""
import json
import sys
import time
from pathlib import Path

try:
    import jwt
    import requests
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "PyJWT", "cryptography", "requests", "-q"])
    import jwt
    import requests

DOWNLOADS = Path.home() / "Downloads"
BASE = "https://api.appstoreconnect.apple.com/v1"
TYPES_OK = {"IOS_DISTRIBUTION", "DISTRIBUTION"}


def find_p8():
    keys = sorted(DOWNLOADS.glob("AuthKey_*.p8"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not keys:
        raise SystemExit(f"Sem AuthKey_*.p8 em {DOWNLOADS}")
    p8 = keys[0]
    return p8, p8.stem.replace("AuthKey_", "")


def token(issuer: str, key_id: str, key: str) -> str:
    now = int(time.time())
    return jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        key,
        algorithm="ES256",
        headers={"kid": key_id},
    )


def main():
    print("=" * 50)
    print("  LIMPAR CERTIFICADOS DISTRIBUTION - Apple")
    print("=" * 50)
    p8_path, key_id = find_p8()
    print(f"Chave: {p8_path.name}")
    issuer = input("Cole Issuer ID (App Store Connect API): ").strip()
    if not issuer:
        raise SystemExit("Issuer ID obrigatorio.")
    t = token(issuer, key_id, p8_path.read_text(encoding="utf-8"))
    h = {"Authorization": f"Bearer {t}"}

    url = f"{BASE}/certificates?limit=200"
    deleted = 0
    while url:
        r = requests.get(url, headers=h, timeout=60)
        r.raise_for_status()
        body = r.json()
        for item in body.get("data", []):
            ctype = item.get("attributes", {}).get("certificateType", "")
            cid = item["id"]
            if ctype in TYPES_OK:
                print(f"Apagando {ctype} {cid}...")
                dr = requests.delete(f"{BASE}/certificates/{cid}", headers=h, timeout=60)
                if dr.status_code in (200, 204, 404):
                    deleted += 1
                else:
                    print(f"  aviso {dr.status_code}: {dr.text[:200]}")
        url = body.get("links", {}).get("next")

    print(f"\nApagados: {deleted}")
    print("\nAGUARDE 20-30 MINUTOS (pedido pendente da Apple some).")
    print("Depois: Codemagic > Start new build (log deve mostrar BUILD v4).")
    print("=" * 50)
    input("Enter...")


if __name__ == "__main__":
    main()
