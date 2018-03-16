"""Automatic deploy Home-Assistant container."""
import argparse
import logging
from pathlib import Path
import subprocess
import time

import requests


DATA_STORE = Path('build.db')
RELEASE_URL = \
    'https://api.github.com/repos/home-assistant/home-assistant/releases'


def parse_args():
    """Parse program arguments."""
    parser = argparse.ArgumentParser(
        description="Automat deploying of Home-Assistant containers."
    )
    parser.add_argument(
        "--latest-build", dest='version', required=True,
        help="Version of latest build")
    parser.add_argument(
        "--arch", action='append', dest='architectures', required=True,
        help="Run build for this architecture")

    return parser.parse_args()


def get_releases(until=None):
    """Read releases into list."""
    release_data = requests.get(RELEASE_URL).json()

    for row in release_data:
        tag = row['tag_name']
        if tag == until:
            break
        yield tag


def run_build(architectures, version):
    """Run Build."""
    command = f"docker run --rm --privileged -v ~/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock homeassistant/{ARCH}-builder -r https://github.com/home-assistant/hassio-build -t homeassistant/generic --docker-hub homeassistant --{architectures.join(' --')} --homeassistant {version}"


def main():
    """Run automatic build system."""
    args = parse_args()

    latest_build = args.version
    while True:
        for release in get_releases(latest_build):
            run_build(args.architectures, release):
            latest_build = release

        # Wait 10 min before
        time.sleep(600)


if __name__ == '__main__':
    try:
        logging.info("Start Build System")
        main()
    except Exception:  # pylint: disable=W0703
        logging.exception("Fatal Error on Build System")
    else:
        logging.info("Stop Build System")
