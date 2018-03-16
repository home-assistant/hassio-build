"""Automatic deploy Home-Assistant container."""
import argparse
import logging
import subprocess
import shlex
import time

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

    for row in release_data:
        tag = row['tag_name']
        if tag == until:
            break
        yield tag


def run_build(builder, architectures, machines, version):
    """Run Build."""
    generic = ("docker run --rm --privileged -v ~/.docker:/root/.docker "
               "-v /var/run/docker.sock:/var/run/docker.sock "
               "homeassistant/{}-builder "
               "-r https://github.com/home-assistant/hassio-build "
               "-t homeassistant/generic --docker-hub homeassistant "
               "--{} --homeassistant {}").format(
                   builder, " --".join(architectures), version)

    machine = ("docker run --rm --privileged -v ~/.docker:/root/.docker "
               "-v /var/run/docker.sock:/var/run/docker.sock "
               "homeassistant/{}-builder "
               "-r https://github.com/home-assistant/hassio-build "
               "-t homeassistant/machine --docker-hub homeassistant "
               "--homeassistant-machine {}={}").format(
                   builder, version, machines)

    logging.info("Start generic build of %s", version)
    run_generic = subprocess.run(
        shlex.split(generic), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    run_generic.check_returncode()

    logging.info("Start generic machine of %s", version)
    run_machine = subprocess.run(
        shlex.split(machine), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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

    try:
        logging.info("Start Build System")
        main()
    except Exception:  # pylint: disable=W0703
        logging.exception("Fatal Error on Build System")
    else:
        logging.info("Stop Build System")
