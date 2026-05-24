"""Captura telas REAIS do build web Flutter — 1290x2796 (iOS 6.9")."""
from __future__ import annotations

import http.server
import shutil
import socketserver
import subprocess
import sys
import threading
import time
from pathlib import Path

OUT = Path.home() / "Desktop" / "AppStoreScreenshots"
WEB_ROOT = Path(__file__).resolve().parents[1] / "build" / "web"
PORT = 8793
W, H = 1290, 2796

SCREENS = {
    "login.png": "/paginaInicial",
    "pagina_inicial.png": "/paginaDoPaciente",
    "tmb.png": "/tmb",
    "alimento.png": "/pagRegistrarAlimentos",
    "treino.png": "/listaDeTreino",
}


class SpaHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def do_GET(self):
        rel = self.path.split("?", 1)[0]
        target = WEB_ROOT / rel.lstrip("/")
        if rel != "/" and (not target.exists() or target.is_dir()):
            self.path = "/index.html"
        return super().do_GET()


def export_logo_from_assets(dest: Path) -> None:
    from PIL import Image

    assets = Path(__file__).resolve().parents[1] / "assets" / "images"
    src = assets / "LOGO767.jpeg"
    if not src.exists():
        src = assets / "app_launcher_icon.jpeg"
    img = Image.open(src).convert("RGBA")
    canvas = Image.new("RGB", (W, H), (11, 11, 12))
    max_side = min(W, H) - 400
    img.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    x = (W - img.width) // 2
    y = (H - img.height) // 2 - 80
    if img.mode == "RGBA":
        canvas.paste(img, (x, y), img)
    else:
        canvas.paste(img, (x, y))
    canvas.save(dest, "PNG", optimize=True)
    print(f"OK logo (asset) {dest}")


def wait_flutter(page) -> None:
    page.wait_for_timeout(8000)
    try:
        page.wait_for_selector("flt-glass-pane, canvas, input, textarea", timeout=45000)
    except Exception:
        pass
    page.wait_for_timeout(3000)


def main():
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "playwright", "-q"])
        subprocess.check_call([sys.executable, "-m", "playwright", "install", "chromium"])
        from playwright.sync_api import sync_playwright

    if not WEB_ROOT.exists():
        print("ERRO: Rode antes: flutter build web --release")
        sys.exit(1)

    OUT.mkdir(parents=True, exist_ok=True)
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), SpaHandler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    time.sleep(2)

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            context = browser.new_context(
                viewport={"width": W, "height": H},
                device_scale_factor=1,
                is_mobile=True,
                has_touch=True,
            )
            page = context.new_page()
            base = f"http://127.0.0.1:{PORT}"

            for filename, route in SCREENS.items():
                page.goto(base + route, wait_until="load", timeout=120000)
                wait_flutter(page)
                path = OUT / filename
                page.screenshot(path=str(path), full_page=False)
                print(f"OK {path}")

            page.goto(base + "/paginaInicial", wait_until="load", timeout=120000)
            wait_flutter(page)
            logo_path = OUT / "logo.png"
            page.screenshot(
                path=str(logo_path),
                clip={"x": 0, "y": 0, "width": W, "height": 900},
            )
            print(f"OK {logo_path}")

            browser.close()
    finally:
        httpd.shutdown()

    export_logo_from_assets(OUT / "logo.png")
    desk = Path.home() / "Desktop"
    for f in OUT.glob("*.png"):
        if f.name in {*SCREENS.keys(), "logo.png"}:
            shutil.copy2(f, desk / f.name)
    print(f"Copiado para {desk}")


if __name__ == "__main__":
    main()
