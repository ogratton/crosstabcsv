# Perl version of Postgresql's \crosstabview command for CSVs. Uses the same h,v,c names as the wiki https://wiki.postgresql.org/wiki/Crosstabview
# Takes a 3 or 4 column table, e.g.:
#
#  v  | h  |  c  | hsort 
# ----+----+-----+-------
#  v0 | h4 | qux |     4
#  v1 | h0 | baz |     1
#  v1 | h2 | foo |     3
#  v2 | h1 | bar |     2
#
# and pivots it thus:
#
#  v  | h0  | h1  | h2  | h4  
# ----+-----+-----+-----+-----
#  v0 |     |     |     | qux
#  v1 | baz |     | foo | 
#  v2 |     | bar |     | 
#
# If the 4th column is not present, the headers will appear in the order they were given.

crosstabcsv() {
    perl -e '
        use strict;
        use warnings;

        # By making use of the module "Text::ParseWords" we can abstract all the complexity of handling all the edge cases of CSV data, like quoted fields, escaped quotes, etc.
        # Source: https://www.oreilly.com/library/view/perl-cookbook/1565922433/ch01s16.html
        use Text::ParseWords;
        # use Term::ANSIColor qw(:constants);

        # TODO add cmdline args for these
        my $IN_SEP=",";
        my $OUT_SEP=",";

        my $v_name;
        my %value_hash;
        my %hsort_h;
        my %hsort_v;

        # Read input file and construct data structure
        while (my $line = <>) {
            chomp $line;
            next if $line eq "";

            my ($v_val, $h_val, $c_val, $hsort) = quotewords($IN_SEP, 0, $line);

            if ($. == 1) {
                $v_name = $v_val;
                next;
            }

            # hsort is an optional column. default to the row number.
            $hsort = $hsort || $.;

            $value_hash{$v_val}{$h_val} = $c_val;
            $hsort_h{$h_val} = $hsort unless (exists $hsort_h{$h_val} and $hsort_h{$h_val} < $hsort);
            $hsort_v{$v_val} = $hsort unless (exists $hsort_v{$v_val} and $hsort_v{$v_val} < $hsort);
        }

        # Sort both fields by hsort value
        my @h_vals = sort { $hsort_h{$a} <=> $hsort_h{$b} } keys %hsort_h;
        my @v_vals = sort { $hsort_v{$a} <=> $hsort_v{$b} } keys %hsort_v;

        # Print output table header
        # print BOLD, UNDERLINE, "$v_name$OUT_SEP\|$OUT_SEP" . join($OUT_SEP, @h_vals) . "\n", RESET;
        print "$v_name$OUT_SEP" . join($OUT_SEP, @h_vals) . "\n";

        # Print output table rows
        for my $v_val (@v_vals) {
            my @row_values = ("") x @h_vals;

            for my $h_val (keys %{ $value_hash{$v_val} }) {
                # Insert c_val in the right place, according to h_vals
                my $c_val = $value_hash{$v_val}{$h_val};
                my $index = 0;
                $index++ until $h_vals[$index] eq $h_val;
                $row_values[$index] = $c_val;
            }

            # Print row with values
            # print BOLD, "$v_val", RESET, "$OUT_SEP\|$OUT_SEP" . join($OUT_SEP, @row_values) . "\n";
            print "$v_val$OUT_SEP" . join($OUT_SEP, @row_values) . "\n";
        }
    '
}
