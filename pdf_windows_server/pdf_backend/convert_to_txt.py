from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import shutil
import uuid
from paths import UPLOAD_DIR, CONVERTED_DIR

router = APIRouter()


def convert_txt_to_pdf(txt_path: str, pdf_path: str):
    c = canvas.Canvas(pdf_path, pagesize=letter)
    width, height = letter
    margin = 40
    x = margin
    y = height - margin

    default_font = "Helvetica"
    default_font_size = 10
    line_height = 14
    paragraph_spacing = 18

    with open(txt_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

        for line in lines:
            line = line.rstrip()

            # Skip empty lines with spacing
            if line == "":
                y -= paragraph_spacing
                continue

            # Heading detection based on simple TXT convention
            # e.g., # Heading 1, ## Heading 2, ### Heading 3
            if line.startswith("### "):
                font_name = "Helvetica-Bold"
                font_size = 12
                text = line[4:].strip()
            elif line.startswith("## "):
                font_name = "Helvetica-Bold"
                font_size = 14
                text = line[3:].strip()
            elif line.startswith("# "):
                font_name = "Helvetica-Bold"
                font_size = 18
                text = line[2:].strip()
            else:
                font_name = default_font
                font_size = default_font_size
                text = line

            if y - line_height < margin:
                c.showPage()
                y = height - margin

            c.setFont(font_name, font_size)
            c.drawString(x, y, text)
            y -= line_height + (font_size - 10)  # Adjust line height for bigger fonts

    c.save()


@router.post("/upload/txt_to_pdf/")
async def upload_and_convert_to_pdf(file: UploadFile = File(...)):
    if file.content_type != "text/plain":
        raise HTTPException(status_code=400, detail="Only TXT files are allowed")

    file_id = str(uuid.uuid4())
    original_filename = Path(file.filename).stem
    txt_path = UPLOAD_DIR / f"{file_id}.txt"
    pdf_path = CONVERTED_DIR / f"{original_filename}.pdf"

    with txt_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        convert_txt_to_pdf(str(txt_path), str(pdf_path))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"PDF conversion failed: {e}")

    return {
        "message": "TXT converted to PDF successfully",
        "file": pdf_path.name,
        "download_url": f"/download/{pdf_path.name}"
    }
