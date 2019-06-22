#!/home/larry/nom/install/bin/perl6

use MONKEY-SEE-NO-EVAL;

my $CJK = %*ENV<HOME> ~ '/cjk';
#chdir $CJK or die "Can't cd to $CJK: $!\n";

my $debug = 0;
my $keeptrying = 0;
my $likeliness = 0;
my $verbose = 0;
my $expand = 0;
my $eXpand = 0;

while @*ARGS and ~@*ARGS[0] ~~ /^'-'/ {
    given @*ARGS.shift {
	when '-h' | '--help' {
	    print
'Usage:
    rad -[dhklrvxX] [args]

    Switches:
	-d	Debug
	-h	This help message
	-k	Keep trying if necessary by truncating final arg
	-l	Look for likely lookalikes
	-r	Match only radicals
	-v	Verbose (show precomputed subradical list)
	-x	Expand subradicals
	-X	Expand subradicals including lookalikes

';
	    exit;
	}
	when '-d'        { $debug = 1; }
	when '-k'        { $keeptrying = 1; }
	when '-l'        { $likeliness = 1; }
	when '-r'        { push(@*ARGS, "radical"); }
	when '-v'        { $verbose = 1; }
	when /'-x'(\d*)/ { $expand = 0 + $0; }
	when /'-X'(\d*)/ { $expand = 0 + $0; $eXpand = 1; }
	default          { last }
    }
}

my %alias;
#my $ALIAS = open "cjkrads/alias" or die "Can't open cjkrads/alias: $!\n";
#for $ALIAS.lines {
#    my ($key,$val,$hex,$char,$where) = .words;
#    %alias{$key} = $val;
#    %alias{$char} = $val;
#    %alias{$hex} = $val;
#}
#close $ALIAS;

my @OUT;

if not @*ARGS {
    while $*IN.get -> $_ {
	my @words = .words;
	@OUT = [] xx 99;
	look(@words);
	for @OUT.reverse -> @out {
	    next unless @out;
	    say '';
	    .say for @out.reverse;
	}
	say '-' x 80;
    }
}
else {
    @OUT = [] xx 99;
    look(@*ARGS);
    for @OUT.reverse -> @out {
	next unless @out;
	say '';
	.say for @out.reverse;
    }
}

my %plusline;
my %xseen;

sub look (*@args is copy){
    my $line;
    my $cjkrads;
    my $*likely = $likeliness;
    if $expand and @args[0] ~~ /^\+/ {
	if !%plusline {
	    my $ALL = open("$CJK/cjkrads/ALL");
	    for $ALL.lines {
		for .comb(/'+' <[a..zA..Z]> <[\-\w]>*/) -> $w {
		    %plusline{$w.substr(1)} = $_;
		}
	    }
	    close $ALL;
	}
	$line = %plusline{substr(@args[0],1)};
    }
    loop {
	my $vec = Buf.new(0xff xx 24575);  # up through plane 2
	if !$line and !$cjkrads {
	    my @newargs;
	    note "args @args[]" if $debug;
	    while my $arg = shift @args {
		note "processing $arg" if $debug;
		my $file = $arg;
		$file ~~ s/^ '+'//;
		$file ~~ s/^ \d+ '*'//;
		$file ~~ s/'!'+ $//;
		$file ~~ s/'.' \w+ $//;
		$file ~~ s/'~like' $//;
		next if $file eq "";
		my $alias = %alias{$file} // $file;
		if $alias ne $file and "cjkrads/vec/$alias".IO.f {
		    note "*** Mapping $file -> %alias{$file}\n";
		    $file = $alias;
		}
		if not "$CJK/cjkrads/vec/$file".IO.f {
		    note "retrying by splitting on -" if $debug;
		    my @n = split(/'-'/,$file);
		    if @n < 2 {
			push @newargs, $arg;
			next;
		    }
		    $arg = shift @n;
		    unshift(@args,@n);
		}
		note "found file" if $debug;
		push @newargs, $arg;
		note "Selecting $file\n" if $debug;
		my $BITS = open("$CJK/cjkrads/vec/$file", :bin) // die "Can't open $file: $!";
		my $bits = $BITS.read(100000);
		close $BITS;
		note "Size bits = ", $bits.elems if $debug;
		$vec ~&= $bits;
		note "Size vec = ", $bits.elems if $debug;
	    }
	    @args = @newargs;
	    my $filename = "./ALL";

	    $cjkrads = open "$CJK/cjkrads/$filename" or die "Can't open cjkrads/$filename: $!";
	}

	my @pats;
	my @negs;
	for @args -> $pat is copy {
	    if $pat ~~ /^'-'/ {
		$pat.substr(0,1) = '';
		my $tmp = transmogrify($pat);
		push @pats, $tmp;
		push @negs, 1;
	    }
	    else {
		my $tmp = transmogrify($pat);
		push @pats, $tmp;
		push @negs, 0;
	    }
	}
	note "PAT @pats[]\n" if $debug;
	note "NEG @negs[]\n" if $debug;
	note $vec.WHAT if $debug;
	my $got = 0;
	my @rx = @pats.map: -> $p { EVAL "/$p/" }
	my int $linenum = 0;
      LINE:
	while $line or $cjkrads {
	    if $line {
		$_ = $line;
		$line = "";
	    }
	    else {
		$_ = $cjkrads.get or last;
		++$linenum;
		next unless $vec[$linenum div 8] +& (1 +< ($linenum +& 7));
		for @rx Z @negs -> ($p, $n) {
		    my $matches = .match($p);
		    $matches = !$matches if $n;
		    next LINE unless $matches;
		}
	    }
	    $got++;
	    s/' [ ' <-[ \] \[ ]>* ' ]'// unless $verbose;
#	    print "LINE = $_\n";
	    my $strokes = +( m/' ' <( \d\d )> ' '/ // 0);
	    if $expand {
		.=subst(/^ (.*\t) /, -> $/ { $0 ~ "    " x $expand ~ substr(@args[0],1) ~ ':  '});
	    }
	    push(@OUT[$strokes], $_);
	    if defined $*expand {
		temp $*expand;
		$*expand++;
		my @words = .words;
		shift @words;
		shift @words;
		my %myxseen;
		for @words {
		    last if /^\[/;
		    next if /^\+/;
		    s/^\d+\*//;
		    s/\.<[a..z A..Z]>+$//;
		    next if s/'~like'$// and not $eXpand;
		    next if m/^'/'/;
		    next if $_ eq "radical";
		    next if $_ eq "sym";
		    next if $_ eq "vbar";
		    next if $_ eq "hbar";
		    next if .ord > 255;
		    next if /'='/;
		    next if %xseen{$_}++;
		    next if %myxseen{$_}++;
		    next unless /^ <[a..zA..Z]> <[\-a..zA..Z0..9]>* $/;
		    my $word = $_;
		    look("+$word");
		    %xseen{$word} = 0;
		}
	    }
	}
	last if $got;
	if !$*likely {
	    note "*** Trying for lookalikes of @args\n";
	    $*likely++;
	    $keeptrying++;
	    $cjkrads.seek(0);
	    next;
	}
	elsif @args > 1 and $keeptrying {
	    note "*** Ignoring ", pop(@args), "\n" ;
	    $*likely = 0;
	    close $cjkrads;
	    $cjkrads = Nil;
	    next;
	}
	else {
	    die "Nothing matches ", pop(@args), "\n" ;
	}
    }
    close $cjkrads;
}

sub transmogrify($_ is copy) {
    #print $_,"\n";

    my $officially = "";
    if s/'!'$// {
	$officially = '\t<[+]>?[\d\*]?'
    }

    my $def = "";
    if s/^'+'// {
	$def = "'+'";
    }

    my $like = "";
    if $*likely {
	$like = "'~like'?";
    }

    if %alias{$_} {
	my $word = %alias{$_};
	$_ = "$def$officially « $word $like » <![-~]>";
    }
    elsif /^ <[\- + A..Z a..z 0..9 _ . * ? ~ ]>* $/ {
	s:g/\?/\\S/;
	if $*likely {
	    s/(.*)\.(.*)/$0 $like .* $1*/ or $_ ~= $like;
	}
	s:g/\./\\./;
	s:g/\~/\\~/;
	s:g/\-/\\-/;
	s/^/«/ unless s/^\*//;
	s/$/»<![-~]>/ unless s/\*$//;
#	s:g/\*/<[\- + A..Z a..z 0..9 _ . ]>*/;
	$_ = "$def$officially$_";
    }
    elsif s/^ '/' (.*) '/'? $/$0/ {
	$_ = "$def$officially$_";
    }
    elsif .ord > 255 {
	$_ = "$def$_\t";
    }
    else {
	die "Don't understand $_\n";
    }
    note $_ if $debug;
    return $_;
}

