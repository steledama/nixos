"""Paddle small CPU: images in, UTF-8 text out; optional structured results."""

import argparse
import contextlib
import importlib.metadata
import json
from pathlib import Path
import sys
import time


def main():
    parser = argparse.ArgumentParser(prog="ocr-cpu", description=__doc__)
    parser.add_argument("images", nargs="+", type=Path)
    parser.add_argument(
        "--json", type=Path, help="Salva testo, coordinate e tempi in JSON"
    )
    parser.add_argument("--threads", type=int, default=4)
    parser.add_argument(
        "--detection-model", required=True, type=Path, help=argparse.SUPPRESS
    )
    parser.add_argument(
        "--recognition-model", required=True, type=Path, help=argparse.SUPPRESS
    )
    args = parser.parse_args()
    if args.threads < 1:
        parser.error("--threads deve essere positivo")
    for path in args.images:
        if not path.is_file():
            parser.error(f"immagine non trovata: {path}")
    from PIL import Image

    for path in args.images:
        try:
            with Image.open(path) as image:
                if getattr(image, "n_frames", 1) != 1:
                    parser.error(f"immagine multipagina non ammessa: {path}")
                image.verify()
        except (OSError, ValueError) as error:
            parser.error(f"immagine non valida: {path}: {error}")
    started = time.perf_counter()
    pages = []
    # Native libraries and PaddleX print diagnostics: stdout is only the OCR text.
    with contextlib.redirect_stdout(sys.stderr):
        from paddleocr import PaddleOCR

        ocr = PaddleOCR(
            text_detection_model_name="PP-OCRv6_small_det",
            text_recognition_model_name="PP-OCRv6_small_rec",
            text_detection_model_dir=str(args.detection_model),
            text_recognition_model_dir=str(args.recognition_model),
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
            use_textline_orientation=False,
            device="cpu",
            cpu_threads=args.threads,
            enable_mkldnn=False,
        )
        load_s = time.perf_counter() - started
        for path in args.images:
            page_start = time.perf_counter()
            result = list(ocr.predict(str(path)))[0]
            pages.append(
                {
                    "input": str(path),
                    "seconds": time.perf_counter() - page_start,
                    "texts": list(result["rec_texts"]),
                    "scores": [float(v) for v in result["rec_scores"]],
                    "polygons": [v.tolist() for v in result["rec_polys"]],
                }
            )
    if args.json:
        args.json.write_text(
            json.dumps(
                {
                    "engine": "PP-OCRv6_small",
                    "device": "cpu",
                    "threads": args.threads,
                    "versions": {
                        n: importlib.metadata.version(n)
                        for n in ("paddleocr", "paddlex", "paddlepaddle")
                    },
                    "load_seconds": load_s,
                    "total_seconds": time.perf_counter() - started,
                    "pages": pages,
                },
                ensure_ascii=False,
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
    sys.stdout.write("\n\n".join("\n".join(page["texts"]) for page in pages) + "\n")


if __name__ == "__main__":
    main()
