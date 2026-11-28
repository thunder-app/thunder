#!/usr/bin/env python3
"""Update Thunder's known Lemmy and PieFed instances.

Lemmy instances come from Lemmyverse, which includes large instances that block FediDB's crawler.
PieFed instances come from FediDB, since Lemmyverse has no PieFed user counts.
"""

import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
MIN_MONTHLY_USERS = 50
HEADERS = {"Accept": "application/json", "User-Agent": "Thunder (+https://github.com/thunder-app/thunder)"}

KNOWN_INSTANCES = ROOT / "lib/src/features/instance/data/constants/known_instances.dart"
ANDROID_MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
SAFARI_MANIFEST = ROOT / "ios/Open In Thunder/Resources/manifest.json"
SAFARI_CONTENT = ROOT / "ios/Open In Thunder/Resources/content.js"


def get_json(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=60) as response:
        return json.load(response)


def lemmy_instances():
    for instance in get_json("https://data.lemmyverse.net/data/instance.full.json"):
        if instance["usage"]["users"]["activeMonth"] > MIN_MONTHLY_USERS and not instance["isSuspicious"]:
            yield instance["baseurl"]


def piefed_instances():
    url = "https://api.fedidb.org/v1/servers?software=piefed&limit=40"
    
    while url:
        page = get_json(url)
        
        for server in page["data"]:
            if (server["stats"]["monthly_active_users"] or 0) > MIN_MONTHLY_USERS:
                yield server["domain"]
        url = page["links"]["next"]


PLATFORMS = {"lemmy": lemmy_instances, "piefed": piefed_instances}


def fetch(platform):
    domains = sorted({domain.lower() for domain in PLATFORMS[platform]()})
    
    if not domains:
        raise SystemExit(f"Found no {platform} instances.")
    
    return domains


def replace_between(path, start, end, lines):
    """Replace the lines between the start and end marker lines of a file."""
    contents = path.read_text(encoding="utf-8")
    pattern = re.compile(rf"(^[^\n]*{re.escape(start)}[^\n]*\n)(.*?)(^[^\n]*{re.escape(end)})", re.MULTILINE | re.DOTALL)    
    updated, count = pattern.subn(lambda match: match[1] + "".join(f"{line}\n" for line in lines) + match[3], contents)
    
    if count != 1:
        raise SystemExit(f"Could not find the instance list in {path}")
    
    path.write_text(updated, encoding="utf-8")


def main():
    # A domain listed for both platforms keeps its first platform.
    instances = {}

    for platform in PLATFORMS:
        for domain in fetch(platform):
            instances.setdefault(domain, platform)
    
    domains = sorted(instances)

    entries = "".join(f"  '{domain}': ThreadiversePlatform.{platform},\n" for domain, platform in instances.items())
    
    KNOWN_INSTANCES.write_text(
        "import 'package:thunder/src/core/domain/domain.dart';\n\n"
        f"const Map<String, ThreadiversePlatform> knownInstances = {{\n{entries}}};\n",
        encoding="utf-8",
    )

    replace_between(
        ANDROID_MANIFEST,
        "#AUTO_GEN_INSTANCE_LIST_DO_NOT_TOUCH#",
        "#INSTANCE_LIST_END#",
        [f'              <data android:host="{domain}" />' for domain in domains],
    )

    manifest = json.loads(SAFARI_MANIFEST.read_text(encoding="utf-8"))
    manifest["content_scripts"][0]["matches"] = [f"*://{domain}/*" for domain in domains]
    SAFARI_MANIFEST.write_text(json.dumps(manifest, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")

    quoted = [f'    "{domain}"' for domain in domains]
    replace_between(SAFARI_CONTENT, "let instances = [", "];", [",\n".join(quoted)])

    print(f"Updated {len(domains)} instances.")


if __name__ == "__main__":
    main()
