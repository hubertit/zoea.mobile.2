#!/usr/bin/env python3
"""
Export + normalize Etike tour data from a MariaDB/phpMyAdmin SQL dump into clean JSON/CSV.

Goals:
- Do NOT touch Zoea DB. This is an offline extractor.
- Output a consistent, clean dataset focused on:
  - package details
  - prices converted to RWF in 5,000 steps
  - who sells it (tour operator)

Usage:
  python3 backend/scripts/etike/export_etike_tours.py \
    --input /Users/macbookpro/Desktop/etike.sql \
    --usd-to-rwf 1300 \
    --rounding ceil \
    --out-dir /Users/macbookpro/projects/flutter/zoea2/backend/scripts/etike/out
"""

from __future__ import annotations

import argparse
import csv
import html
import json
import math
import os
import re
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Dict, Iterable, List, Optional, Tuple


INSERT_RE = re.compile(r"^INSERT INTO `(?P<table>[^`]+)`\s+\([^)]+\)\s+VALUES\s*$")


def _unescape_mysql_string(s: str) -> str:
    # phpMyAdmin dumps typically escape with backslashes.
    # Keep this conservative; we only need good-enough for text fields.
    return (
        s.replace("\\\\", "\\")
        .replace("\\'", "'")
        .replace('\\"', '"')
        .replace("\\r", "\r")
        .replace("\\n", "\n")
        .replace("\\t", "\t")
    )


def _strip_html_keep_text(s: str) -> str:
    # Convert entities (&amp;, etc.) first, then strip tags.
    s = html.unescape(s)
    # Replace <br> and <p>/<li> with newlines to keep readability.
    s = re.sub(r"(?i)<\s*br\s*/?\s*>", "\n", s)
    s = re.sub(r"(?i)<\s*/?\s*(p|div|li|ul|ol|strong|em|span)\b[^>]*>", "", s)
    # Strip any other remaining tags.
    s = re.sub(r"<[^>]+>", "", s)
    # Collapse whitespace.
    s = re.sub(r"[ \t]+", " ", s)
    s = re.sub(r"\n{3,}", "\n\n", s)
    return s.strip()


def _parse_decimal(v: Any) -> Optional[Decimal]:
    if v is None:
        return None
    if isinstance(v, Decimal):
        return v
    if isinstance(v, (int, float)):
        return Decimal(str(v))
    if isinstance(v, str):
        v = v.strip()
        if v == "":
            return None
        try:
            return Decimal(v)
        except InvalidOperation:
            return None
    return None


def _round_to_step(value: Decimal, step: int, rounding: str) -> int:
    """
    Convert Decimal -> integer multiple of `step`.
    rounding: "ceil" | "nearest" | "floor"
    """
    if value is None:
        return 0
    x = float(value)
    if step <= 0:
        return int(round(x))
    q = x / step
    if rounding == "floor":
        return int(math.floor(q) * step)
    if rounding == "nearest":
        return int(round(q) * step)
    # default: ceil
    return int(math.ceil(q) * step)


def _split_tuples(values_blob: str) -> List[str]:
    """
    Split "(...),(...),(...)" into ["(...)", "(...)"] without breaking on commas in strings.
    """
    tuples: List[str] = []
    i = 0
    n = len(values_blob)
    in_str = False
    esc = False
    depth = 0
    start = None
    while i < n:
        ch = values_blob[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == "'":
                in_str = False
        else:
            if ch == "'":
                in_str = True
            elif ch == "(":
                if depth == 0:
                    start = i
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0 and start is not None:
                    tuples.append(values_blob[start : i + 1])
                    start = None
        i += 1
    return tuples


def _split_fields(tuple_blob: str) -> List[str]:
    """
    Split "(a,b,'c,d',NULL)" (including parentheses) into raw field strings.
    """
    assert tuple_blob[0] == "(" and tuple_blob[-1] == ")"
    inner = tuple_blob[1:-1]
    fields: List[str] = []
    buf: List[str] = []
    in_str = False
    esc = False
    for ch in inner:
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == "'":
                in_str = False
        else:
            if ch == "'":
                in_str = True
                buf.append(ch)
            elif ch == ",":
                fields.append("".join(buf).strip())
                buf = []
            else:
                buf.append(ch)
    if buf:
        fields.append("".join(buf).strip())
    return fields


def _coerce_value(raw: str) -> Any:
    if raw.upper() == "NULL":
        return None
    if raw.startswith("'") and raw.endswith("'"):
        return _unescape_mysql_string(raw[1:-1])
    # numeric?
    try:
        if "." in raw:
            return Decimal(raw)
        return int(raw)
    except Exception:
        return raw


def iter_inserts(sql_path: str, target_tables: Iterable[str]) -> Dict[str, List[List[Any]]]:
    """
    Returns dict: table -> list of parsed rows (as arrays in column order as in dump).
    """
    target = set(target_tables)
    out: Dict[str, List[List[Any]]] = {t: [] for t in target}
    with open(sql_path, "r", encoding="utf-8", errors="replace") as f:
        current_table: Optional[str] = None
        collecting: List[str] = []

        for line in f:
            line = line.rstrip("\n")
            m = INSERT_RE.match(line)
            if m:
                tbl = m.group("table")
                if tbl in target:
                    current_table = tbl
                    collecting = []
                else:
                    current_table = None
                continue

            if current_table is None:
                continue

            collecting.append(line)
            if line.endswith(";"):
                blob = "\n".join(collecting)
                # Remove trailing semicolon.
                if blob.endswith(";"):
                    blob = blob[:-1]
                tuples = _split_tuples(blob)
                for t in tuples:
                    fields_raw = _split_fields(t)
                    out[current_table].append([_coerce_value(x) for x in fields_raw])
                current_table = None
                collecting = []

    return out


@dataclass
class Operator:
    legacy_id: int
    name: str
    phone: Optional[str]
    email: Optional[str]
    bio: Optional[str]
    profile_pic: Optional[str]
    status: Optional[str]
    code: Optional[str]


@dataclass
class Package:
    legacy_id: int
    slug: str
    name: str
    description_raw: Optional[str]
    base_price_usd: Optional[Decimal]
    cover_image: Optional[str]
    seller_legacy_id: int
    status: Optional[str]


@dataclass
class Option:
    legacy_id: int
    package_legacy_id: int
    name: str
    description: Optional[str]
    price_usd: Optional[Decimal]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default="/Users/macbookpro/Desktop/etike.sql")
    ap.add_argument("--usd-to-rwf", type=float, default=1300.0, help="FX rate used for normalization.")
    ap.add_argument("--step", type=int, default=5000, help="RWF rounding step.")
    ap.add_argument("--rounding", choices=["ceil", "nearest", "floor"], default="ceil")
    ap.add_argument("--out-dir", default=os.path.join(os.getcwd(), "backend/scripts/etike/out"))
    args = ap.parse_args()

    tables = iter_inserts(
        args.input,
        target_tables=[
            "users",
            "tour_packages",
            "tour_package_options",
            "tour_package_categories",
            "tour_package_category_relations",
        ],
    )

    # Parse operators from `users` rows:
    # columns: user_id, name, phone, email, password, profile_pic, bio, token, role, status, registration_date, code
    operators: Dict[int, Operator] = {}
    for row in tables["users"]:
        if len(row) < 12:
            continue
        role = row[8]
        if role != "tour_operator":
            continue
        legacy_id = int(row[0])
        operators[legacy_id] = Operator(
            legacy_id=legacy_id,
            name=str(row[1] or "").strip(),
            phone=(str(row[2]).strip() if row[2] is not None else None),
            email=(str(row[3]).strip() if row[3] is not None else None),
            bio=(str(row[6]).strip() if row[6] is not None else None),
            profile_pic=(str(row[5]).strip() if row[5] is not None else None),
            status=(str(row[9]).strip() if row[9] is not None else None),
            code=(str(row[11]).strip() if row[11] is not None else None),
        )

    # Parse packages:
    # columns: id, code, name, description, base_price, cover_image, seller_id, status, created_by, updated_by, created_at, updated_at
    packages: Dict[int, Package] = {}
    for row in tables["tour_packages"]:
        if len(row) < 12:
            continue
        legacy_id = int(row[0])
        packages[legacy_id] = Package(
            legacy_id=legacy_id,
            slug=str(row[1] or "").strip(),
            name=str(row[2] or "").strip(),
            description_raw=(str(row[3]) if row[3] is not None else None),
            base_price_usd=_parse_decimal(row[4]),
            cover_image=(str(row[5]).strip() if row[5] is not None else None),
            seller_legacy_id=int(row[6]),
            status=(str(row[7]).strip() if row[7] is not None else None),
        )

    # Parse options:
    # columns: id, package_id, name, description, price, created_at, updated_at
    options_by_package: Dict[int, List[Option]] = {}
    for row in tables["tour_package_options"]:
        if len(row) < 7:
            continue
        opt = Option(
            legacy_id=int(row[0]),
            package_legacy_id=int(row[1]),
            name=str(row[2] or "").strip(),
            description=(str(row[3]).strip() if row[3] is not None else None),
            price_usd=_parse_decimal(row[4]),
        )
        options_by_package.setdefault(opt.package_legacy_id, []).append(opt)

    # Categories + relations
    # categories columns: id, code, name, description, cover_image, status, created_by, updated_by, created_at, updated_at
    categories: Dict[int, Dict[str, Any]] = {}
    for row in tables["tour_package_categories"]:
        if len(row) < 10:
            continue
        cid = int(row[0])
        categories[cid] = {
            "legacy_id": cid,
            "slug": str(row[1] or "").strip(),
            "name": str(row[2] or "").strip(),
            "description": (str(row[3]).strip() if row[3] is not None else None),
            "cover_image": (str(row[4]).strip() if row[4] is not None else None),
            "status": (str(row[5]).strip() if row[5] is not None else None),
        }

    # relations columns: id, package_id, category_id, created_at
    package_categories: Dict[int, List[int]] = {}
    for row in tables["tour_package_category_relations"]:
        if len(row) < 4:
            continue
        pkg_id = int(row[1])
        cat_id = int(row[2])
        package_categories.setdefault(pkg_id, []).append(cat_id)

    fx = Decimal(str(args.usd_to_rwf))

    out_rows: List[Dict[str, Any]] = []
    for pkg in sorted(packages.values(), key=lambda p: p.legacy_id):
        seller = operators.get(pkg.seller_legacy_id)
        opts = options_by_package.get(pkg.legacy_id, [])
        cat_ids = package_categories.get(pkg.legacy_id, [])
        cats = [categories[c] for c in cat_ids if c in categories]

        # Price points: prefer options if present; else base_price.
        usd_points: List[Decimal] = []
        for o in opts:
            if o.price_usd is not None:
                usd_points.append(o.price_usd)
        if not usd_points and pkg.base_price_usd is not None:
            usd_points = [pkg.base_price_usd]

        rwf_points = sorted(
            {
                _round_to_step((p * fx), args.step, args.rounding)
                for p in usd_points
                if p is not None
            }
        )

        min_rwf = rwf_points[0] if rwf_points else 0
        max_rwf = rwf_points[-1] if rwf_points else 0

        desc_raw = pkg.description_raw or ""
        desc_clean = _strip_html_keep_text(desc_raw) if desc_raw else ""

        out_rows.append(
            {
                "package_legacy_id": pkg.legacy_id,
                "slug": pkg.slug,
                "name": pkg.name,
                "status": pkg.status,
                "seller_legacy_id": pkg.seller_legacy_id,
                "seller_name": (seller.name if seller else None),
                "seller_email": (seller.email if seller else None),
                "seller_phone": (seller.phone if seller else None),
                "seller_profile_pic": (seller.profile_pic if seller else None),
                "seller_bio": (seller.bio if seller else None),
                "categories": [{"slug": c["slug"], "name": c["name"]} for c in cats],
                "cover_image": pkg.cover_image,
                "base_price_usd": (str(pkg.base_price_usd) if pkg.base_price_usd is not None else None),
                "currency": "RWF",
                "fx_rate_usd_to_rwf": float(args.usd_to_rwf),
                "rounding_step_rwf": args.step,
                "rounding_mode": args.rounding,
                "price_points_rwf": rwf_points,
                "min_price_rwf": min_rwf,
                "max_price_rwf": max_rwf,
                "description_clean": desc_clean,
                "description_raw": desc_raw,
                "options": [
                    {
                        "name": o.name,
                        "description": o.description,
                        "price_usd": (str(o.price_usd) if o.price_usd is not None else None),
                        "price_rwf": (
                            _round_to_step((o.price_usd * fx), args.step, args.rounding)
                            if o.price_usd is not None
                            else None
                        ),
                    }
                    for o in sorted(opts, key=lambda x: x.legacy_id)
                ],
            }
        )

    os.makedirs(args.out_dir, exist_ok=True)

    json_path = os.path.join(args.out_dir, "etike_tours_normalized.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(out_rows, f, ensure_ascii=False, indent=2)

    csv_path = os.path.join(args.out_dir, "etike_tours_normalized.csv")
    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "package_legacy_id",
                "slug",
                "name",
                "status",
                "seller_legacy_id",
                "seller_name",
                "seller_email",
                "seller_phone",
                "category_primary",
                "min_price_rwf",
                "max_price_rwf",
                "price_points_rwf",
                "cover_image",
            ],
        )
        w.writeheader()
        for r in out_rows:
            cats = r.get("categories") or []
            primary = cats[0]["name"] if cats else ""
            w.writerow(
                {
                    "package_legacy_id": r["package_legacy_id"],
                    "slug": r["slug"],
                    "name": r["name"],
                    "status": r["status"],
                    "seller_legacy_id": r["seller_legacy_id"],
                    "seller_name": r["seller_name"],
                    "seller_email": r["seller_email"],
                    "seller_phone": r["seller_phone"],
                    "category_primary": primary,
                    "min_price_rwf": r["min_price_rwf"],
                    "max_price_rwf": r["max_price_rwf"],
                    "price_points_rwf": ";".join(str(x) for x in r["price_points_rwf"]),
                    "cover_image": r["cover_image"],
                }
            )

    print("✅ Export complete")
    print(f"- Operators (tour_operator role): {len(operators)}")
    print(f"- Packages: {len(packages)}")
    print(f"- Packages with options: {sum(1 for p in packages if options_by_package.get(p))}")
    print(f"- Output JSON: {json_path}")
    print(f"- Output CSV : {csv_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


