from fastapi import APIRouter, UploadFile, File, HTTPException
from pathlib import Path
import uuid
import pdfplumber
import io
from PIL import Image
import base64
from paths import UPLOAD_DIR, CONVERTED_DIR 

router = APIRouter()


HTML_DIR = CONVERTED_DIR 

def group_words_into_lines(words):
    lines = []
    current_line = []
    prev_y = None
    for word in words:
        y = round(word["top"], 1)
        if prev_y is not None and abs(y - prev_y) > 2:
            lines.append(current_line)
            current_line = []
        current_line.append(word)
        prev_y = y
    if current_line:
        lines.append(current_line)
    return lines

def encode_image_to_base64(pil_img):
    img_byte_arr = io.BytesIO()
    pil_img.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    return base64.b64encode(img_byte_arr.read()).decode('utf-8')

@router.post("/upload/html/")
async def convert_pdf_to_html(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    file_id = str(uuid.uuid4())
    pdf_path = UPLOAD_DIR / f"{file_id}.pdf"
    html_path = HTML_DIR / f"{file_id}.html"

    with open(pdf_path, "wb") as f:
        f.write(await file.read())

    html_content = ["<html><head><meta charset='UTF-8'><title>PDF to HTML</title></head><body style='font-family:sans-serif;'>"]

    try:
        with pdfplumber.open(str(pdf_path)) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                html_content.append(f"<div style='page-break-after: always;'><h2>Page {page_num}</h2>")

                # Text extraction
                words = page.extract_words(extra_attrs=["fontname", "size"])
                lines = group_words_into_lines(words) if words else []
                for line in lines:
                    line_html = "<p style='margin: 0;'>"
                    for word in line:
                        font_size = float(word.get("size", 12))
                        fontname = word.get("fontname", "").lower()
                        bold = "bold" in fontname
                        italic = "italic" in fontname or "oblique" in fontname
                        styles = [
                            f"font-size:{font_size}px",
                            "font-weight:bold" if bold else "font-weight:normal",
                            "font-style:italic" if italic else "font-style:normal",
                        ]
                        span = f"<span style='{'; '.join(styles)}'>{word['text']}</span>"
                        line_html += span + " "
                    line_html += "</p>"
                    html_content.append(line_html)

                # Image extraction
                for img in page.images:
                    try:
                        x0, top_img, x1, bottom = img["x0"], img["top"], img["x1"], img["bottom"]
                        bbox = (x0, top_img, x1, bottom)
                        image_proxy = page.crop(bbox).to_image(resolution=150)
                        pil_img = image_proxy.image  # Direct PIL.Image
                        base64_str = encode_image_to_base64(pil_img)
                        html_content.append(
                            f"<img src='data:image/png;base64,{base64_str}' style='max-width:100%; margin: 10px 0;'/>"
                        )
                    except Exception as e:
                        print("Image extract failed:", e)

                html_content.append("</div>")

        html_content.append("</body></html>")
        with open(html_path, "w", encoding="utf-8") as f:
            f.write("\n".join(html_content))

        return {
            "message": "PDF converted to HTML successfully",
            "file": html_path.name,
            "download_url": f"/download/{html_path.name}"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"HTML conversion failed: {e}")


