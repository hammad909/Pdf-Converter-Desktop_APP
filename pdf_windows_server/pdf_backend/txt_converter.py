from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path
import shutil
import uuid
import pdfplumber
from paths import UPLOAD_DIR, CONVERTED_DIR

router = APIRouter()

TXT_DIR = CONVERTED_DIR


def group_words_into_lines(words, y_tolerance=3):
    lines = []
    for word in sorted(words, key=lambda x: x['top']):
        for line in lines:
            if abs(line[0]['top'] - word['top']) < y_tolerance:
                line.append(word)
                break
        else:
            lines.append([word])
    return lines

def extract_text_from_pdf(pdf_path: str) -> str:
    full_text = ""
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages):
            full_text += f"\n--- Page {i + 1} ---\n"
            words = page.extract_words()
            lines = group_words_into_lines(words)
            for line in lines:
                line_text = " ".join(word["text"] for word in line)
                full_text += line_text + "\n"
    return full_text

@router.post("/upload/txt/")
async def upload_and_convert_to_txt(file: UploadFile = File(...)):
    if file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")

    file_id = str(uuid.uuid4())
    original_filename = Path(file.filename).stem
    pdf_path = UPLOAD_DIR / f"{file_id}.pdf"
    txt_path = TXT_DIR / f"{original_filename}.txt"

    with pdf_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        text = extract_text_from_pdf(str(pdf_path))
        with txt_path.open("w", encoding="utf-8") as f:
            f.write(text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"TXT conversion failed: {e}")

    return {
        "message": "PDF converted to TXT successfully",
        "file": txt_path.name,
        "download_url": f"/download/{txt_path.name}"
    }

