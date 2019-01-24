"""Automatic deploy Home-Assistant container."""
from distutils.version import StrictVersion
import argparse
import logging
import subprocess
import time
import sys

import requests

RELEASE_URL = \
    'https://api.github.com/repos/home-assistant/home-assistant/releases'


def parse_args():
    """Parse program arguments."""
    parser = argparse.ArgumentParser(
        description="Automat deploying of Home-Assistant containers."
    )
    parser.add_argument(
        "--builder-arch", dest='builder', required=True,
        help="Builder arch to use for builds")
    parser.add_argument(
        "--latest-build", dest='version', required=True,
        help="Version of latest build")
    parser.add_argument(
        "--arch", action='append', dest='architectures', required=True,
        help="Run build for this architecture")
    parser.add_argument(
        "--machines", dest='machines', required=True,
        help="Run machine build for this")

    return parser.parse_args()


def get_releases(until=None):
    """Read releases into list."""
    try:
        release_data = requests.get(RELEASE_URL).json()
    except requests.exceptions.RequestException:
        logging.exception("Can't read releases")
        release_data = []

    release_list = [row['tag_name'] for row in release_data]
    release_list.sort(key=StrictVersion, reverse=True)

    build_list = []
    for tag in release_list:
        if tag == until:
            break
        build_list.insert(0, tag)

    for tag in build_list:
        yield tag


def run_build(builder, architectures, machines, version):
    """Run Build."""
    generic = ("docker run --rm --privileged -v ~/.docker:/root/.docker "
               "-v /var/run/docker.sock:/var/run/docker.sock "
               "homeassistant/{}-builder "
               "-r https://github.com/home-assistant/hassio-homeassistant "
               "-t generic --docker-hub homeassistant "
               "--{} --homeassistant {}").format(
                   builder, " --".join(architectures), version)

    machine = ("docker run --rm --privileged -v ~/.docker:/root/.docker "
               "-v /var/run/docker.sock:/var/run/docker.sock "
               "homeassistant/{}-builder "
               "-r https://github.com/home-assistant/hassio-homeassistant "
               "-t machine --docker-hub homeassistant "
               "--homeassistant-machine {}={}").format(
                   builder, version, machines)

    logging.info("Start generic build of %s", version)
    run_generic = subprocess.run(generic, shell=True, stdout=sys.stdout, stderr=sys.stderr)
    run_generic.check_returncode()

    logging.info("Start generic machine of %s", version)
    run_machine = subprocess.run(machine, shell=True, stdout=sys.stdout, stderr=sys.stderr)
    run_machine.check_returncode()


def main():
    """Run automatic build system."""
    args = parse_args()

    latest_build = args.version
    while True:
        for release in get_releases(latest_build):
            run_build(args.builder, args.architectures, args.machines, release)
            latest_build = release
            logging.info("Build of release %s done", release)

        # Wait 10 min before
        time.sleep(600)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    while True:
        try:
            logging.info("Start Build System")
            main()
        except Exception:  # pylint: disable=W0703
            logging.exception("Fatal Error on Build System")
            time.sleep(600)

    logging.info("Stop Build System")
