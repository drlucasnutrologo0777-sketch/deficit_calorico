#!/usr/bin/env python3
"""Cria Bundle ID na Apple (App Store Connect API). Rode uma vez no PC."""
import json
import sys
import time
from pathlib import Path

try:
    import jwt
    import requests
except ImportError:
    print("Instalando dependencias...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "PyJWT", "cryptography", "requests", "-q"])
    import jwt
    import requests

BUNDLE_ID = "com.mycompany.deficitcalorico"
APP_NAME = "Deficit Calorico"
DOWNLOADS = Path.home() / "Downloads"

def find_p8():
    keys = sorted(DOWNLOADS.glob("AuthKey_*.p8"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not keys:
        raise SystemExit(f"ERRO: Nenhum AuthKey_*.p8 em {DOWNLOADS}")
    p8 = keys[0]
    key_id = p8.stem.replace("AuthKey_", "")
    return p8, key_id

def make_token(issuer_id: str, key_id: str, private_key: str) -> str:
    now = int(time.time())
    payload = {"iss": issuer_id, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})

def api(method: str, url: str, token: str, **kwargs):
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    r = requests.request(method, url, headers=headers, timeout=60, **kwargs)
    if r.status_code >= 400:
        print(f"API {r.status_code}: {r.text[:800]}")
        r.raise_for_status()
    return r.json() if r.text else {}

def main():
    print("=" * 50)
    print("  CONFIGURAR APPLE - Deficit Calorico")
    print("=" * 50)
    p8_path, key_id = find_p8()
    print(f"Chave: {p8_path.name}  (Key ID: {key_id})")
    issuer = input(
        "\nCole o Issuer ID (App Store Connect > Usuarios > Integracoes > API > topo da pagina):\n> "
    ).strip()
    if not issuer or len(issuer) < 10:
        raise SystemExit("Issuer ID invalido. Copie da pagina da Apple.")
    private_key = p8_path.read_text(encoding="utf-8")
    token = make_token(issuer, key_id, private_key)
    base = "https://api.appstoreconnect.apple.com/v1"

    # Bundle ID existe?
    data = api(
        "GET",
        f"{base}/bundleIds",
        token,
        params={"filter[identifier]": BUNDLE_ID, "limit": 1},
    )
    items = data.get("data", [])
    if items:
        bid = items[0]["id"]
        print(f"OK: Bundle ID ja existe: {BUNDLE_ID}")
    else:
        print(f"Criando Bundle ID {BUNDLE_ID}...")
        created = api(
            "POST",
            f"{base}/bundleIds",
            token,
            json={
                "data": {
                    "type": "bundleIds",
                    "attributes": {
                        "identifier": BUNDLE_ID,
                        "name": APP_NAME,
                        "platform": "IOS",
                    },
                }
            },
        )
        bid = created["data"]["id"]
        print(f"OK: Bundle ID criado (id interno {bid})")

    # Sign in with Apple
    caps = api("GET", f"{base}/bundleIds/{bid}/bundleIdCapabilities", token)
    has_apple = any(
        c.get("attributes", {}).get("capabilityType") == "SIGN_IN_WITH_APPLE"
        for c in caps.get("data", [])
    )
    if has_apple:
        print("OK: Sign in with Apple ja ativo")
    else:
        print("Ativando Sign in with Apple...")
        api(
            "POST",
            f"{base}/bundleIdCapabilities",
            token,
            json={
                "data": {
                    "type": "bundleIdCapabilities",
                    "attributes": {"capabilityType": "SIGN_IN_WITH_APPLE"},
                    "relationships": {
                        "bundleId": {"data": {"type": "bundleIds", "id": bid}}
                    },
                }
            },
        )
        print("OK: Sign in with Apple ativado")

    print("\n" + "=" * 50)
    print("PRONTO na Apple. Agora no Codemagic:")
    print("1) Team settings > Integrations > Developer Portal")
    print(f"   Nome: DeficitApple | Key ID: {key_id} | arquivo: {p8_path.name}")
    print("2) Start new build > >>> USAR ESTE - iOS App Store <<<")
    print("=" * 50)
    input("\nEnter para fechar...")

if __name__ == "__main__":
    main()
