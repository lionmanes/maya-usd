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

        # Extract the version number
        print re.search(r'^AL_USDMaya-(\d+\.\d+\.\d+)$', package_info.release_tag).group(0)
        title_content = "v{}".format(re.search(r'^AL_USDMaya-(\d+\.\d+\.\d+)$',
                                               package_info.release_tag).group(1))
        title_date = self._release.get_release_date()

        title = u'## {} ({})\n'.format(title_content, title_date.strftime('%Y-%m-%d'))

        return title

class AL_USDMayaChangeLog(ChangeLog):

    def __init__(self, initial_version):
        """
        Prepend releases changelog starting from 'initial_version'

        :param initial_version: generate changelog starting from this version
        """
        super(AL_USDMayaChangeLog, self).__init__(repository='AL_USDMaya',
                                                  package='AL_USDMaya',
                                                  root='',
                                                  owner='rnd')

        self._initial_version = initial_version

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

        with open(path, 'w') as ostream:
            for release in package.iter_releases(branch=branch):
                if release.release_tag < self._initial_version:
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
    parser.add_argument('-i', '--initial_version', required=False, default='AL_USDMaya-0.23.3',
                        type=str, help='version from which the changelog is generated')
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

    maya_changelog = AL_USDMayaChangeLog(opts.initial_version)
    maya_changelog.write(opts.output)


if __name__ == '__main__':
    sys.exit(main())
