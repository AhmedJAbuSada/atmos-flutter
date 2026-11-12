#!/usr/bin/env python3
"""Turns a build log into GitHub Actions annotations, so a failure is readable on the run's
summary page without downloading logs.

usage: annotate-log.py <log file> <title>

Prints every distinct line containing "error:" (at most 20). If there is none, prints the
last 40 lines of the log in one annotation, because the reason is usually at the end.
"""
import sys


def escape(text: str) -> str:
    return text.replace("%", "%25").replace("\r", "").replace("\n", "%0A")


def main() -> None:
    path, title = sys.argv[1], sys.argv[2]
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    except FileNotFoundError:
        print(f"::error title={title}::{path} was not written; the step failed before it started.")
        return
    errors = list(dict.fromkeys(line.strip() for line in lines if "error:" in line))[:20]
    for line in errors:
        print(f"::error title={title}::{escape(line)}")
    if not errors:
        print(f"::error title={title} (last lines)::{escape(chr(10).join(lines[-40:]))}")


if __name__ == "__main__":
    main()
