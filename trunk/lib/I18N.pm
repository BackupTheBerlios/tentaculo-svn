package I18N;

use strict;

use POSIX;
use Locale::gettext;		# use a locale shown by 'locale -a'

my $language = "es";
my $locale = "es";

POSIX::setlocale(LC_MESSAGES, $locale);
Locale::gettext::textdomain("nc");

sub _ { gettext(@_) }

sub getLanguage { return $language; }

1;
