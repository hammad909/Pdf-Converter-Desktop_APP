import os
from pathlib import Path

APP_NAME = "PdfConverterFiLes"

BASE_DIR = Path(os.getenv("LOCALAPPDATA")) / APP_NAME
UPLOAD_DIR = BASE_DIR / "uploads"
CONVERTED_DIR = BASE_DIR / "converted"

UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
CONVERTED_DIR.mkdir(parents=True, exist_ok=True)
