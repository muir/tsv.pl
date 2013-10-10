
use ExtUtils::MakeMaker;

WriteMakefile( 
	'VERSION_FROM' => 'tsv',
	'NAME' => 'tsv',
	'ABSTRACT' => 'tsv file manipulation utility',
	'AUTHOR'   => 'David Muir Sharnoff <muir@idiom.org>',
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	'PREREQ_PM'	=> {
		'Getopt::Long'	=> 0,
		'Pod::Usage'	=> 0,
		'List::Util'	=> 0,
	},
	'BUILD_REQUIRES' => {
		'File::Slurp'	=> 0,
		'File::Temp'	=> 0,
		'FindBin'	=> 0,
	},
	'PM'	=> {
		tsv	=> '$(INST_LIBDIR)/TSV/Utility.pm',
	},
	'EXE_FILES'     => ['tsv'],
	'META_MERGE'     => {
		resources  => {
			repository => 'http://github.com/muir/tsv.pl',
		},
	},
);

package MY;

sub postamble {
    <<"END_OF_POSTAMBLE";

pm_to_blib: README

README: tsv
\tpod2text tsv >README

END_OF_POSTAMBLE
}

