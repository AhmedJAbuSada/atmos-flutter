#!/usr/bin/env python3
"""Prints what is on the emulator's screen, from `uiautomator dump`: one line per element with
its resource id, text and content description (Flutter puts its semantics labels there). Used when the journey fails, so the
CI annotation says what the app was showing instead of only "not visible".

usage: describe-screen.py <window_dump.xml>
"""
import sys
import xml.etree.ElementTree as ET


def main() -> None:
    try:
        root = ET.parse(sys.argv[1]).getroot()
    except (OSError, ET.ParseError) as error:
        print(f"(no screen dump: {error})")
        return
    for node in root.iter("node"):
        parts = [
            node.get("resource-id", ""),
            node.get("text", ""),
            node.get("content-desc", ""),
        ]
        if any(parts):
            print(" | ".join(part for part in parts if part))


if __name__ == "__main__":
    main()
