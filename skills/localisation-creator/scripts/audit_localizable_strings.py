#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ENTRY_RE = re.compile(r'^"((?:\\.|[^"\\])*)"\s*=\s*"((?:\\.|[^"\\])*)"\s*;\s*$')
PLACEHOLDER_RE = re.compile(r"%(?:\d+\$)?[@dfius]")
EXPECTED_LOCALES = ("en", "uk", "es", "fr", "pt-BR")
REQUIRED_TRANSLATION_LOCALES = ("uk", "es", "fr", "pt-BR")


def parse_strings_file(path: Path) -> tuple[dict[str, str], list[str]]:
    entries: dict[str, str] = {}
    errors: list[str] = []

    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw_line.strip()
        if not line or line.startswith("//"):
            continue

        match = ENTRY_RE.match(line)
        if not match:
            errors.append(f"{path}:{line_number}: could not parse line")
            continue

        key, value = match.groups()
        entries[key] = value

    return entries, errors


def find_project_root(start: Path) -> Path:
    for candidate in (start, *start.parents):
        if (candidate / "bjjtracker").is_dir():
            return candidate
    raise FileNotFoundError("Could not find project root containing 'bjjtracker/'")


def placeholders(text: str) -> list[str]:
    return PLACEHOLDER_RE.findall(text)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Audit Localizable.strings coverage and placeholder consistency.",
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=None,
        help="Override the repo root. Defaults to auto-detection from the current path.",
    )
    parser.add_argument(
        "--strict-en",
        action="store_true",
        help="Fail if English keys are missing instead of treating them as informational.",
    )
    args = parser.parse_args()

    try:
        project_root = args.project_root.resolve() if args.project_root else find_project_root(Path.cwd().resolve())
    except FileNotFoundError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    locale_dir = project_root / "bjjtracker"
    locale_paths = {locale: locale_dir / f"{locale}.lproj" / "Localizable.strings" for locale in EXPECTED_LOCALES}

    missing_files = [str(path) for path in locale_paths.values() if not path.exists()]
    if missing_files:
        print("Missing localisation files:")
        for path in missing_files:
            print(f"  - {path}")
        return 1

    parsed: dict[str, dict[str, str]] = {}
    parse_errors: list[str] = []
    for locale, path in locale_paths.items():
        entries, errors = parse_strings_file(path)
        parsed[locale] = entries
        parse_errors.extend(errors)

    if parse_errors:
        print("Parse errors:")
        for error in parse_errors:
            print(f"  - {error}")
        return 1

    all_keys = sorted(set().union(*(entries.keys() for entries in parsed.values())))

    missing_by_locale: dict[str, list[str]] = {locale: [] for locale in EXPECTED_LOCALES}
    placeholder_issues: list[str] = []

    for key in all_keys:
        key_placeholders = placeholders(key)
        for locale, entries in parsed.items():
            value = entries.get(key)
            if value is None:
                missing_by_locale[locale].append(key)
                continue

            value_placeholders = placeholders(value)
            if value_placeholders != key_placeholders:
                placeholder_issues.append(
                    f"{locale}: key '{key}' has placeholders {key_placeholders}, value has {value_placeholders}"
                )

    issues_found = False

    for locale, missing_keys in missing_by_locale.items():
        if not missing_keys:
            continue
        is_required_locale = locale in REQUIRED_TRANSLATION_LOCALES or (locale == "en" and args.strict_en)
        issues_found = issues_found or is_required_locale
        heading = "Missing keys" if is_required_locale else "Informational: missing keys"
        print(f"{heading} in {locale} ({len(missing_keys)}):")
        for key in missing_keys:
            print(f"  - {key}")

    if placeholder_issues:
        issues_found = True
        print("Placeholder mismatches:")
        for issue in placeholder_issues:
            print(f"  - {issue}")

    if issues_found:
        return 1

    print("Localizable.strings audit passed.")
    print(f"Checked locales: {', '.join(EXPECTED_LOCALES)}")
    print(f"Checked keys: {len(all_keys)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
