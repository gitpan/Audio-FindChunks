#!/usr/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Audio-FindChunks.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 16 };
use Audio::FindChunks;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $pi2 = 2*atan2(0, -1);
sub write_sine ($$$$$) {
  my ($fh, $samples, $freq, $ampl, $phase) = @_;
  while ($samples--) {
    my $v = sin($phase) * $ampl;
    $phase += $freq * $pi2;
    my $short = pack 'v', unpack 'S', pack 's', $v;
    print $fh $short x 2;
  }
}

sub write_header {
  my @b = qw(
      52 49 46 46  44 D7 A6 01  57 41 56 45  66 6D 74 20
      10 00 00 00  01 00 02 00  44 AC 00 00  10 B1 02 00
      04 00 10 00  64 61 74 61   ); # 20 D7 A6 01
  my $str = join '', map {pack 'H2', $_} @b;
  my ($fh, $len) = (shift, shift);
  print $fh substr($str, 0, 4), pack('V', $len + length($str) + 4), substr($str, 8);
  print $fh pack 'V', $len;			# length
}

my @chunks = ([5,30], [20, 1e4], [0.9, 30], [0.3, 1e4], [0.9, 30], [0.3, 1e4], [0.9, 30], [10.9, 1e4], [0.9, 30], [0.3, 1e4], [0.9, 30], [24.9, 1e4], [3, 30]);	# [len, ampl]
#my @chunks = ([1,30], [2, 1e4], [0.9, 30], [0.3, 1e4], [0.9, 30], [2.9, 1e4], [1, 30]);	# [len, ampl]
my $tot = 0;
map $tot += $_->[0], @chunks;

unless (-f 'tmp.rms') {
  open OUT, '>tmp.wav' or die;
  binmode OUT;
  write_header(\*OUT, 2 * 2 * 44100 * $tot);
  for my $c (@chunks) {
    write_sine(\*OUT, 44100 * $c->[0], 2000/44100, $c->[1], 0);
  }
  close OUT or die;
}
ok(1,1, 'create a wave or RMS');

my $h = Audio::FindChunks->new(	stem_strip_extension => 1,
				min_silence_sec => 1.5,		# default 2
				cache_rms => 1,
				filename => 'tmp.wav');
ok(1,1, 'create an object');
$h->get('rms_data');
ok(1,1, 'fetch RMS data');
my $t = $h->get('threshold');
ok($t < 1100,1, 'threshold <');
ok($t > 900,1, 'threshold >');

$h->get('maybe_signal');
ok(1,1, 'signal and noise separation');

my $b = $h->get('b');
ok(1,1, 'blocks');

sub str { join ' ', map "[@$_]", @{$h->get( shift )} }

my @ques = map "b$_", 0..4, '';
my @ans = split /\n/, <<EOT;
[0 0 47] [1 47 206] [0 253 3] [1 256 9] [0 265 3] [1 268 9] [0 277 3] [1 280 115] [0 395 3] [1 398 9] [0 407 3] [1 410 255] [0 665 27]
[-1 0 47] [2 47 206] [0 253 3] [1 256 9] [0 265 3] [1 268 9] [0 277 3] [2 280 115] [0 395 3] [1 398 9] [0 407 3] [2 410 255] [-1 665 27]
[-1 0 47] [2 47 206] [0 253 27] [2 280 115] [0 395 15] [2 410 255] [-1 665 27]
[-1 0 47] [2 47 206] [-1 253 27] [2 280 115] [-1 395 15] [2 410 255] [-1 665 27]
[-1 0 47] [2 47 206] [-1 253 27] [2 280 115] [-1 395 15] [2 410 255] [-1 665 27]
[-1 0 44] [2 44 214] [-1 258 19] [2 277 393] [-1 670 22]
EOT

for my $q (0..$#ques) {
  ok (str($ques[$q]), $ans[$q], "field $ques[$q]");
}

open OUT, '>blocks.tmp' or warn;
my $old = select OUT;

$h->output_blocks();
ok(1, 1, 'output_blocks()');

$h->output_levels();
ok(1, 1, 'output_levels()');

select $old;
close OUT or warn;

-f 'tmp.wav' and (unlink 'tmp.wav' or warn "unlink: $!");
