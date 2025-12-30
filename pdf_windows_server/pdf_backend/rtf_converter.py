from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
import fitz  # PyMuPDF
import os, uuid
from pathlib import Path
from PIL import Image
import io
from paths import UPLOAD_DIR, CONVERTED_DIR

router = APIRouter()

RTF_DIR = CONVERTED_DIR

@router.post("/upload/rtf/")
async def convert_pdf_to_rtf(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    file_id = str(uuid.uuid4())
    pdf_path = UPLOAD_DIR / f"{file_id}.pdf"
    rtf_path = RTF_DIR / f"{file_id}.rtf"

    with open(pdf_path, "wb") as f:
        f.write(await file.read())

    try:
        doc = fitz.open(str(pdf_path))

        rtf_lines = [
            "{\\rtf1\\ansi\\deff0\n",
            "{\\fonttbl{\\f0 Arial;}}\n",
            "\\viewkind4\\uc1\\pard\n"
        ]

        for page in doc:
            # --- Add text ---
            text_blocks = page.get_text("dict")["blocks"]
            for block in text_blocks:
                if "lines" in block:
                    for line in block["lines"]:
                        for span in line["spans"]:
                            text = (
                                span["text"]
                                .replace("\\", "\\\\")
                                .replace("{", "\\{")
                                .replace("}", "\\}")
                            )
                            size = int(span["size"])
                            font = span["font"].lower()
                            bold = "\\b " if "bold" in font else ""
                            italic = "\\i " if "italic" in font or "oblique" in font else ""
                            reset = "\\b0\\i0"
                            rtf_lines.append(f"{bold}{italic}\\fs{2*size} {text} {reset}\\par\n")

            # --- Add images ---
            for img_index, img in enumerate(page.get_images(full=True)):
                xref = img[0]
                try:
                    pix = fitz.Pixmap(doc, xref)
                    if pix.n > 4:  # CMYK etc.
                        pix = fitz.Pixmap(fitz.csRGB, pix)
                    image_bytes = pix.tobytes("png")
                    image_hex = convert_image_to_rtf_hex(image_bytes)
                    rtf_lines.append(image_hex + "\n\\par\n")
                    pix = None
                except Exception as e:
                    print(f"Skipping image xref={xref}: {e}")
                    continue

        rtf_lines.append("}")

        with open(rtf_path, "w", encoding="utf-8") as f:
            f.writelines(rtf_lines)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"RTF conversion failed: {e}")

    return {
        "message": "PDF converted to RTF with images",
        "file": rtf_path.name,
        "download_url": f"/download/{rtf_path.name}"
    }

def convert_image_to_rtf_hex(image_bytes: bytes) -> str:
    try:
        with Image.open(io.BytesIO(image_bytes)) as img:
            if img.mode not in ["RGB", "RGBA"]:
                img = img.convert("RGB")
            elif img.mode == "RGBA":
                img = img.convert("RGB")

            img.thumbnail((800, 800))  # Resize to reasonable dimensions
            output = io.BytesIO()
            img.save(output, format="BMP")

            # Remove 54-byte BMP header (14 file + 40 DIB header)
            bmp_data = output.getvalue()[54:]
            hex_string = ''.join(f"{b:02x}" for b in bmp_data)

            width_twips = img.width * 15
            height_twips = img.height * 15

            return (
                f"{{\\pict\\dibitmap0\\picw{img.width}\\pich{img.height}"
                f"\\picwgoal{width_twips}\\pichgoal{height_twips}\n"
                f"{hex_string}}}"
            )
    except Exception as e:
        raise ValueError(f"Failed to convert image to RTF hex: {e}")
