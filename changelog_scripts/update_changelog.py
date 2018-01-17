import argparse
import logging
import re
import sys

from AL.github.changelog.formatter import TopicsFormatter
from AL.github.changelog.release import GitHubRepository, ReleaseNotFound, PackageNotFound
from AL.github.changelog.changelog import ChangeLog

logger = logging.getLogger(__name__)


class AL_USDMayaChangeLogFormatter(TopicsFormatter):

    def __init__(self, release):
        super(AL_USDMayaChangeLogFormatter, self).__init__(release, public=True)

    def _format_title(self):
        """
        :rtype: unicode
        """

        package_info = self._release.release_package_info

        # Extract the version number (internal version might use 4 digits)
        title_content = "v{}".format(re.search(r'^AL_USDMaya-(\d+\.\d+\.\d+)(\.\d)?$',
                                               package_info.release_tag).group(1))
        title_date = self._release.get_release_date()

        title = u'## {} ({})\n\n'.format(title_content, title_date.strftime('%Y-%m-%d'))

        return title


class AL_USDMayaChangeLog(ChangeLog):

    def __init__(self):
        """
        Prepend releases changelog to the changelog file
        """
        super(AL_USDMayaChangeLog, self).__init__(repository='AL_USDMaya',
                                                  package='AL_USDMaya',
                                                  root='',
                                                  owner='rnd')

    def write(self, path, branch=None):
        """
        :param path: the path to write the change log to
        :param formatter_name: name of the formatter to use
        """
        if not path:
            raise ValueError('No path was provided to write a change log to')

        try:
            package = self._get_package()
        except PackageNotFound:
            msg = 'Unable to find package {} in repository {}'
            logger.error(msg.format(self._pkg_name, self._repo_name))

            return

        logger.info('Updating Change Log: {}'.format(path))
        with open(path, 'r') as istream:
            previous = istream.read()
            # Get the latest changelog version
            r = re.compile(r'^#+\s+v(\d+\.\d+\.\d)+.*')
            initial_version = ''
            for l in previous.splitlines():
                m = r.match(l)
                if m:
                    initial_version = 'AL_USDMaya-{}'.format(m.groups()[0])
                    logger.debug('Updating changelog from version {}'.format(initial_version))
                    break
            if not initial_version:
                logger.error('Unable to extract the latest changelog version')
                sys.exit(1)

        with open(path, 'w') as ostream:
            for release in package.iter_releases(branch=branch):
                if release.release_tag <= initial_version:
                    logger.debug('Skipping version {}'.format(release.release_tag))
                    continue
                    
                logger.info('Writing Entry for {}'.format(release.release_tag))

                formatter = AL_USDMayaChangeLogFormatter(release)
                ostream.write(formatter.format())
            ostream.write(previous)

        logger.info('Wrote Change Log: {}'.format(path))


def main():
    parser = argparse.ArgumentParser(description='Update AL_USDMaya changelog')
    parser.add_argument('-o', '--output', required=True,
                        type=str, help='output path for the generated change log')
    parser.add_argument('-v', '--verbose', required=False,
                        action='store_true')
    opts = parser.parse_args()

    log_level = logging.INFO
    if opts.verbose:
        log_level = logging.DEBUG

    logger.setLevel(log_level)
    ch = logging.StreamHandler()
    ch.setLevel(log_level)
    logger.addHandler(ch)

    maya_changelog = AL_USDMayaChangeLog()
    maya_changelog.write(opts.output)


if __name__ == '__main__':
    sys.exit(main())
