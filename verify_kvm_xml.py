#!/usr/bin/env python3
"""Reject any libvirt capability or VM XML that does not explicitly use KVM."""
import argparse
import sys
import xml.etree.ElementTree as ET


def is_kvm_xml(kind: str, root: ET.Element) -> bool:
    if kind == "capabilities":
        return root.tag == "capabilities" and bool(root.findall(".//guest/arch/domain[@type='kvm']"))
    if kind == "domcapabilities":
        return root.tag == "domainCapabilities" and root.findtext("domain") == "kvm"
    if kind == "domain":
        return root.tag == "domain" and root.get("type") == "kvm"
    raise ValueError("unknown XML type")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("kind", choices=("capabilities", "domcapabilities", "domain"))
    parser.add_argument("file", nargs="?", default="-")
    args = parser.parse_args()
    try:
        root = ET.parse(sys.stdin if args.file == "-" else args.file).getroot()
    except (ET.ParseError, OSError) as exc:
        print(f"KVM_CHECK_FAILED: invalid XML: {exc}", file=sys.stderr)
        return 1
    if not is_kvm_xml(args.kind, root):
        print(f"KVM_CHECK_FAILED: {args.kind} lacks explicit KVM support", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
