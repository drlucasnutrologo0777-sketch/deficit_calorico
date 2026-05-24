"""Gera screenshots App Store 1290x2796 — Déficit Calórico."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

W, H = 1290, 2796
OUT = Path.home() / "Desktop" / "AppStoreScreenshots"

BG = (11, 11, 12)
BG_TOP = (18, 18, 22)
CARD = (20, 20, 22)
CARD_BORDER = (42, 42, 46)
GOLD = (198, 169, 105)
GOLD_DIM = (120, 100, 62)
WHITE = (255, 255, 255)
MUTED = (161, 161, 166)
GREEN = (48, 209, 88)
RED_SOFT = (207, 102, 121)

PHONE_X = 95
PHONE_Y = 720
PHONE_W = 1100
PHONE_H = 1980
RADIUS = 48


def load_fonts():
    candidates = [
        ("title", 72, "C:/Windows/Fonts/segoeuib.ttf"),
        ("headline", 56, "C:/Windows/Fonts/segoeuib.ttf"),
        ("sub", 36, "C:/Windows/Fonts/segoeui.ttf"),
        ("body", 28, "C:/Windows/Fonts/segoeui.ttf"),
        ("small", 22, "C:/Windows/Fonts/segoeui.ttf"),
        ("tiny", 18, "C:/Windows/Fonts/segoeui.ttf"),
        ("large", 88, "C:/Windows/Fonts/segoeuib.ttf"),
        ("num", 64, "C:/Windows/Fonts/segoeuib.ttf"),
    ]
    fonts = {}
    for key, size, path in candidates:
        try:
            fonts[key] = ImageFont.truetype(path, size)
        except OSError:
            fonts[key] = ImageFont.load_default()
    return fonts


def gradient_bg(draw: ImageDraw.ImageDraw) -> None:
    for y in range(H):
        t = y / H
        r = int(BG_TOP[0] * (1 - t) + BG[0] * t)
        g = int(BG_TOP[1] * (1 - t) + BG[1] * t)
        b = int(BG_TOP[2] * (1 - t) + BG[2] * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b))


def draw_marketing(draw: ImageDraw.ImageDraw, fonts: dict, tagline: str, subtitle: str) -> None:
    draw.text((W // 2, 180), "DÉFICIT CALÓRICO", font=fonts["sub"], fill=MUTED, anchor="mm")
    draw.text((W // 2, 300), tagline, font=fonts["large"], fill=WHITE, anchor="mm")
    draw.text((W // 2, 420), subtitle, font=fonts["sub"], fill=GOLD, anchor="mm")
    draw.line([(200, 500), (W - 200, 500)], fill=GOLD_DIM, width=2)


def round_rect(draw, xy, radius, fill, outline=None):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=2 if outline else 0)


def phone_frame(img: Image.Image, draw: ImageDraw.ImageDraw) -> tuple[int, int, int, int]:
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    for i in range(12):
        sd.rounded_rectangle(
            [PHONE_X + i, PHONE_Y + i + 8, PHONE_X + PHONE_W + i, PHONE_Y + PHONE_H + i + 8],
            radius=RADIUS + 8,
            fill=(0, 0, 0, 18),
        )
    img.paste(shadow, (0, 0), shadow)
    round_rect(draw, [PHONE_X, PHONE_Y, PHONE_X + PHONE_W, PHONE_Y + PHONE_H], RADIUS, (8, 8, 10), GOLD_DIM)
    inner = [PHONE_X + 14, PHONE_Y + 14, PHONE_X + PHONE_W - 14, PHONE_Y + PHONE_H - 14]
    round_rect(draw, inner, RADIUS - 8, CARD)
    return inner


def status_bar(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    draw.text((x0 + 40, y0 + 36), "9:41", font=fonts["small"], fill=WHITE)
    draw.text((x1 - 40, y0 + 36), "●●● ▮", font=fonts["tiny"], fill=MUTED, anchor="rm")


def screen_login(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    status_bar(draw, inner, fonts)
    cy = y0 + 280
    draw.text((x0 + 60, cy), "DÉFICIT CALÓRICO", font=fonts["headline"], fill=WHITE)
    draw.text((x0 + 60, cy + 70), "Cutting Game", font=fonts["body"], fill=MUTED)
    cy += 200
    for label, hint in [("Digite o Email", "you@example.com"), ("Digite a senha", "••••••••")]:
        draw.text((x0 + 60, cy), label, font=fonts["small"], fill=MUTED)
        cy += 36
        round_rect(draw, [x0 + 60, cy, x1 - 60, cy + 72], 14, (26, 26, 30), CARD_BORDER)
        draw.text((x0 + 80, cy + 22), hint, font=fonts["body"], fill=(74, 74, 80))
        cy += 110
    round_rect(draw, [x0 + 60, cy + 40, x1 - 60, cy + 120], 14, GOLD)
    draw.text(((x0 + x1) // 2, cy + 80), "Iniciar", font=fonts["body"], fill=BG, anchor="mm")
    draw.text(((x0 + x1) // 2, cy + 180), "Ainda não tem conta?  CRIAR CONTA AGORA", font=fonts["tiny"], fill=MUTED, anchor="mm")


def screen_home(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    status_bar(draw, inner, fonts)
    draw.ellipse([x0 + 60, y0 + 120, x0 + 160, y0 + 220], fill=GOLD_DIM, outline=GOLD, width=2)
    draw.text((x0 + 190, y0 + 140), "Lucas Nutrologo", font=fonts["body"], fill=WHITE)
    draw.text((x0 + 190, y0 + 180), "TMB: 1.842 kcal", font=fonts["small"], fill=MUTED)
    card_y = y0 + 280
    round_rect(draw, [x0 + 50, card_y, x1 - 50, card_y + 520], 20, (24, 24, 28), GOLD_DIM)
    draw.text((x0 + 80, card_y + 40), "Resumo do dia", font=fonts["body"], fill=WHITE)
    rows = [
        ("Meta de déficit hoje", "300 kcal", WHITE),
        ("Gordura a queimar", "33 g", GOLD),
        ("Ingestão calórica", "1.240 kcal", WHITE),
        ("Gasto calórico", "2.180 kcal", WHITE),
        ("Falta para meta", "640 kcal", GREEN),
    ]
    ry = card_y + 100
    for label, val, col in rows:
        draw.text((x0 + 80, ry), label, font=fonts["tiny"], fill=MUTED)
        draw.text((x1 - 80, ry), val, font=fonts["body"], fill=col, anchor="rm")
        ry += 72
    draw.text((x0 + 80, card_y + 460), "Consumo: 1.240  |  Gasto: 2.180", font=fonts["tiny"], fill=MUTED)
    actions = ["Programar déficit", "Registro alimentar", "Registro de treino", "Gráfico evolutivo"]
    ay = card_y + 580
    for act in actions:
        round_rect(draw, [x0 + 50, ay, x1 - 50, ay + 88], 16, CARD, CARD_BORDER)
        draw.text((x0 + 80, ay + 28), act, font=fonts["body"], fill=WHITE)
        draw.text((x1 - 80, ay + 32), "›", font=fonts["headline"], fill=GOLD, anchor="rm")
        ay += 108


def screen_calculadora(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    status_bar(draw, inner, fonts)
    draw.text((x0 + 60, y0 + 120), "‹", font=fonts["headline"], fill=WHITE)
    draw.text(((x0 + x1) // 2, y0 + 130), "Definir Meta", font=fonts["body"], fill=WHITE, anchor="mm")
    cy = y0 + 280
    round_rect(draw, [x0 + 60, cy, x1 - 60, cy + 420], 24, CARD, GOLD_DIM)
    draw.text(((x0 + x1) // 2, cy + 80), "−", font=fonts["large"], fill=MUTED, anchor="mm")
    draw.text(((x0 + x1) // 2, cy + 200), "300", font=fonts["num"], fill=WHITE, anchor="mm")
    draw.text(((x0 + x1) // 2, cy + 280), "kcal", font=fonts["sub"], fill=MUTED, anchor="mm")
    draw.text(((x0 + x1) // 2, cy + 340), "+", font=fonts["large"], fill=MUTED, anchor="mm")
    draw.text(((x0 + x1) // 2, cy + 500), "300 kcal ≈ 33 g de gordura", font=fonts["small"], fill=GOLD, anchor="mm")
    round_rect(draw, [x0 + 60, y1 - 200, x1 - 60, y1 - 110], 14, GOLD)
    draw.text(((x0 + x1) // 2, y1 - 155), "Registrar Meta", font=fonts["body"], fill=BG, anchor="mm")


def screen_dieta(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    status_bar(draw, inner, fonts)
    draw.text((x0 + 60, y0 + 120), "Registro alimentar", font=fonts["headline"], fill=WHITE)
    draw.text((x0 + 60, y0 + 190), "Hoje", font=fonts["small"], fill=MUTED)
    foods = [
        ("Frango grelhado", "165 kcal", "P 31g"),
        ("Arroz integral", "112 kcal", "C 24g"),
        ("Ovos (2 un.)", "140 kcal", "P 12g"),
        ("Whey protein", "120 kcal", "P 24g"),
    ]
    fy = y0 + 280
    for name, kcal, macro in foods:
        round_rect(draw, [x0 + 50, fy, x1 - 50, fy + 120], 16, CARD, CARD_BORDER)
        draw.text((x0 + 80, fy + 28), name, font=fonts["body"], fill=WHITE)
        draw.text((x1 - 80, fy + 28), kcal, font=fonts["body"], fill=GOLD, anchor="rm")
        draw.text((x0 + 80, fy + 72), macro, font=fonts["tiny"], fill=MUTED)
        fy += 140
    round_rect(draw, [x0 + 50, fy + 40, x1 - 50, fy + 200], 20, (24, 24, 28))
    draw.text((x0 + 80, fy + 80), "Totais do dia", font=fonts["small"], fill=MUTED)
    draw.text((x0 + 80, fy + 120), "1.240 kcal", font=fonts["headline"], fill=WHITE)
    draw.text((x1 - 80, fy + 120), "C 98g  P 112g  G 38g", font=fonts["tiny"], fill=MUTED, anchor="rm")


def screen_perfil(draw, inner, fonts):
    x0, y0, x1, y1 = inner
    status_bar(draw, inner, fonts)
    draw.text((x0 + 60, y0 + 120), "Seu perfil", font=fonts["headline"], fill=WHITE)
    draw.ellipse([x0 + 60, y0 + 220, x0 + 200, y0 + 360], fill=GOLD_DIM, outline=GOLD, width=3)
    fields = [
        ("Nome", "Lucas Nutrologo"),
        ("Peso", "78 kg"),
        ("Altura", "180 cm"),
        ("Idade", "38 anos"),
        ("Nível", "Ativo (1.55)"),
    ]
    fy = y0 + 420
    for label, val in fields:
        draw.text((x0 + 60, fy), label, font=fonts["tiny"], fill=MUTED)
        round_rect(draw, [x0 + 60, fy + 32, x1 - 60, fy + 100], 12, (26, 26, 30), CARD_BORDER)
        draw.text((x0 + 80, fy + 52), val, font=fonts["body"], fill=WHITE)
        fy += 130
    chart_y = fy + 40
    round_rect(draw, [x0 + 50, chart_y, x1 - 50, chart_y + 360], 20, CARD)
    draw.text((x0 + 80, chart_y + 30), "Evolução — déficit diário", font=fonts["body"], fill=WHITE)
    bars = [120, 180, 90, 220, 160, 280, 200]
    bx = x0 + 100
    bw = 70
    max_h = 200
    for i, h in enumerate(bars):
        bh = int(h * max_h / 280)
        draw.rounded_rectangle(
            [bx + i * (bw + 24), chart_y + 320 - bh, bx + i * (bw + 24) + bw, chart_y + 320],
            radius=8,
            fill=GOLD if i == len(bars) - 1 else (60, 55, 45),
        )
    draw.text((x0 + 80, chart_y + 330), "Últimos 7 dias", font=fonts["tiny"], fill=MUTED)


def build(tagline: str, subtitle: str, screen_fn) -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    fonts = load_fonts()
    gradient_bg(draw)
    draw_marketing(draw, fonts, tagline, subtitle)
    phone_frame(img, draw)
    draw = ImageDraw.Draw(img)
    inner = [PHONE_X + 14, PHONE_Y + 14, PHONE_X + PHONE_W - 14, PHONE_Y + PHONE_H - 14]
    screen_fn(draw, inner, fonts)
    return img


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    specs = [
        ("login.png", "Login inteligente", "Acesso seguro em segundos", screen_login),
        ("home.png", "Controle sua dieta", "Tudo no painel do dia", screen_home),
        ("calculadora.png", "Cálculo automático", "Meta de déficit em kcal", screen_calculadora),
        ("dieta.png", "Resultados personalizados", "Macros e calorias claros", screen_dieta),
        ("perfil.png", "Evolução diária", "Acompanhe seu progresso", screen_perfil),
    ]
    for name, tag, sub, fn in specs:
        path = OUT / name
        img = build(tag, sub, fn)
        img.save(path, "PNG", optimize=True)
        print(f"OK {path} ({img.size[0]}x{img.size[1]})")


if __name__ == "__main__":
    main()
