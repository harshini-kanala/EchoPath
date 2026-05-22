import qrcode


def generate_qr(location_name):
    img = qrcode.make(location_name)
    img.save(f"static/qr_codes/{location_name}.png")