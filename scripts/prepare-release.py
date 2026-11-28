#!/usr/bin/env python3
"""Update Thunder's release version or validate it for CI."""

import argparse
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
APP_CONFIG = ROOT / "lib/src/core/config/app_config.dart"
PUBSPEC_VERSION = re.compile(r"""^version:[ \t]*(\S+)""", re.MULTILINE)
APP_VERSION = re.compile(r"^const String currentVersion = '([^']+)';$", re.MULTILINE)
VERSION = re.compile(r"(?P<ios>[0-9]+\.[0-9]+\.[0-9]+)(?P<suffix>-[0-9A-Za-z.-]+)?(?:\+(?P<build>[1-9][0-9]*))?")


def read_version(pattern, contents, path):
    match = pattern.search(contents)
    
    if match is None:
        raise ValueError(f"Could not find the version in {path}")
    return match


def parse_version(version):
    match = VERSION.fullmatch(version)
    
    if match is None:
        raise ValueError(f"Invalid release version {version!r}. Use a version such as 0.9.0-6+101.")
    tag = version.split("+", 1)[0]
    
    return tag, match["ios"], int(match["build"] or 1), bool(match["suffix"])


def highest_tagged_build(tags):
    """Return the highest build number in pubspec.yaml across the release tags."""
    highest = 0
    
    for tag in tags:
        if not VERSION.fullmatch(tag):
            continue
        result = subprocess.run(["git", "show", f"{tag}:pubspec.yaml"], cwd=ROOT, capture_output=True, text=True)
        match = PUBSPEC_VERSION.search(result.stdout)
        previous = VERSION.fullmatch(match[1].strip("'\"")) if match else None
        
        if previous and previous["build"]:
            highest = max(highest, int(previous["build"]))
    
    return highest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("version", nargs="?", help="New version, including its build number")
    mode.add_argument("--check", action="store_true", help="Validate the checked-out version without editing files")
    parser.add_argument("--notes", action="store_true", help="Validate the release notes when checking")
    parser.add_argument("--ref", help="Validate a publishing ref and its release notes when checking")
    parser.add_argument("--play-version-code", type=int, help="Highest version code already uploaded to Play Store")
    args = parser.parse_args()

    try:
        pubspec = PUBSPEC.read_text(encoding="utf-8")
        app_config = APP_CONFIG.read_text(encoding="utf-8")
        pubspec_version = read_version(PUBSPEC_VERSION, pubspec, PUBSPEC)
        app_version = read_version(APP_VERSION, app_config, APP_CONFIG)

        if args.check:
            version = pubspec_version[1].strip("'\"")
            if version != app_version[1]:
                raise ValueError(f"pubspec.yaml has {version}, but app_config.dart has {app_version[1]}")
        else:
            version = args.version

        tag, ios_version, build_number, prerelease = parse_version(version)
        notes_file = Path("release-notes") / f"{tag}.txt"

        if args.ref and args.ref != f"refs/tags/{tag}":
            raise ValueError(f"Publish from the {tag} tag (got {args.ref}).")

        if args.notes or args.ref:
            if not (ROOT / notes_file).is_file():
                raise ValueError(f"Write the release notes in {notes_file}.")
            notes = (ROOT / notes_file).read_text(encoding="utf-8").strip()
            if not 1 <= len(notes) <= 500:
                raise ValueError(f"{notes_file} must contain 1-500 characters for Google Play.")

        if not args.check:
            if "+" not in version:
                raise ValueError("Include an explicit build number, such as +102.")
            tags = subprocess.check_output(["git", "tag", "--list"], cwd=ROOT, text=True).splitlines()
            
            if tag in tags:
                raise ValueError(f"Tag {tag} already exists. Choose a new release tag.")
            highest = max(highest_tagged_build(tags), args.play_version_code or 0)
            
            if build_number <= highest:
                raise ValueError(f"Build number {build_number} must exceed {highest}.")

            for path, contents, match in (
                (PUBSPEC, pubspec, pubspec_version),
                (APP_CONFIG, app_config, app_version),
            ):
                start, end = match.span(1)
                path.write_text(contents[:start] + version + contents[end:], encoding="utf-8")
            (ROOT / notes_file.parent).mkdir(exist_ok=True)
            (ROOT / notes_file).touch()

        metadata = (
            f"version={tag}\nios_version={ios_version}\nbuild_number={build_number}\n"
            f"prerelease={str(prerelease).lower()}\nnotes_file={notes_file}\n"
        )

        print(metadata, end="")
        
        if args.check and os.environ.get("GITHUB_OUTPUT"):
            with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
                output.write(metadata)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
