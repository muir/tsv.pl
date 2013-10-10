
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
	'PM'	=> {
		tsv	=> '$(INST_LIBDIR)/TSV/Utility.pm',
	},
	'EXE_FILES'     => ['tsv'],
);

