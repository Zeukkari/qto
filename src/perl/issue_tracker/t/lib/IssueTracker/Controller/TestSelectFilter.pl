use strict ; use warnings ; 
use Test::More;
use Test::Mojo;
use Data::Printer ; 
use FindBin;

BEGIN { unshift @INC, "$FindBin::Bin/../../../../../issue_tracker/lib" }

my $t = Test::Mojo->new('IssueTracker');
$t->get_ok('/')->status_is(200) ; 

my $appConfig = $t->app->get('AppConfig') ; 

# if the product instance id dev -> dev_issue_tracker
# if the product instance id tst -> tst_issue_tracker
my $db_name= $appConfig->{ 'postgres_db_name' } ; 
my @tables = ( 'daily_issues' , 'weekly_issues' , 'monthly_issues' , 'yearly_issues' ) ; 
my $ua  = $t->ua ; 
my $res = {} ; #a tmp result json string
my $hsr2 = {} ; # the tmp hash ref of hash refs
my $tm = '' ; 

$res = $ua->get('/' . $db_name . '/Select-tables')->result->json ; 
$hsr2 = $res->{ 'dat' } ; 

# foreach table in the app db in test call db/select/table
for my $table ( @tables ) {
	
	my $url_params = '' ; # 

	# test a filter by Select of integers	
	$url_params = '?fltr-by=prio&fltr-val=1,2,3' ; 
	$t->get_ok('/' . $db_name . '/select/' . $table . $url_params )
		->status_is(200) 
		->header_is('Accept-Charset' => 'UTF-8')
		->header_is('Accept-Language' => 'fi, en')
	;

	print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
	$hsr2 = $res->{'dat'} ; 

	foreach my $key ( sort keys %$hsr2 ) {
		my $row = $hsr2->{$key } ; 
		$tm = "only prio smaller or equal than 3 are selected for $table: " . substr ( $row->{'name'} , 0, 30 ) . ' ...' ; 	
		ok ( $row->{'prio'} <= 3, $tm ) ; 
		$tm = "only prio greater or equal to 1  are selected for $table: " . substr ( $row->{'name'} , 0, 30 ) . ' ...' ; 	
		ok ( $row->{'prio'} >= 1, $tm ) ; 
	}
   

	print "test a string filter \n" ; 
	$url_params = '?fltr-by=status&fltr-val=02-todo' ; 
	print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
	$hsr2 = $res->{'dat'} ; 

   # feature-guid: 1f89454a-1801-423d-9784-9477973d05fc
	foreach my $key ( sort keys %$hsr2 ) {
		my $row = $hsr2->{$key } ; 
		$tm = "all the retrieved statuses should be 02-todo for the table: $table: " . substr ( $row->{'name'} , 0, 30 ) . ' ...' ;
		ok ( $row->{'status'} eq '02-todo', $tm ) ; 
	}

   # feature-guid: c71d93de-f178-485a-844f-fe8d226628a4
	print 'test a response with invalid syntax - provide fltr-by only' . "\n" ; 
	$url_params = '?fltr-by=status' ; 
	print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
	ok ( $res->{'msg'} 
		eq 'mall-formed url params for filtering - valid syntax is ?fltr-by=<<attribute>>&fltr-val=<<filter-value>>' ) ; 
	ok ( $res->{'ret'} == 400 ) ; 	

   # feature-guid: c71d93de-f178-485a-844f-fe8d226628a4
   print 'test a response with invalid syntax - provide fltr-val only ' . "\n" ; 
	$url_params = '?fltr-val=wrong' ; 
	print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
	ok ( $res->{'msg'} 
		eq 'mall-formed url params for filtering - valid syntax is ?fltr-by=<<attribute>>&fltr-val=<<filter-value>>' ) ; 
	ok ( $res->{'ret'} == 400 ) ; 	

   # feature-guid: d6561095-c965-4658-a5dc-0350093e75ab
   print "\n start test a response with valid syntax, but use unexisting columns \n" ; 
   $url_params = '?fltr-by=non_existing_column&fltr-val=foo-bar' ; 
   print "running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
   ok ( $res->{'msg'} eq "the non_existing_column column does not exist" ) ; 
   ok ( $res->{'ret'} == 400 ) ; 	
   print "stop  test a response with valid syntax, but use unexisting columns \n" ; 
   
   # feature-guid: 95cdac3a-4a41-4c5b-9ba8-6f8134b0edc9
   print "\n start test a response with only a single column pick" ; 
   $url_params = "?pick=name" ; 
   print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
   ok ( $res->{'ret'} == 200 ) ; 	
   print "stop  test a response with only a single column pick" ; 
  
   # feature-guid: 95cdac3a-4a41-4c5b-9ba8-6f8134b0edc9 
   print "\n start test a response with a Select column pick" ; 
   $url_params = "?pick=name,update_time" ; 
   print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
   ok ( $res->{'ret'} == 200 ) ; 	
   print "stop  test a response with a Select column pick" ; 
  
   # feature-guid: fd3e2d4e-99a1-4cd8-8ebe-bb47f9de9caf
   print "\n start test a response with an inexisting column pick" ; 
   $url_params = "?pick=non_existing_column" ; 
   print "\n running url: /$db_name" . '/select/' . $table . $url_params . "\n" ; 	
   $res = $ua->get('/' . $db_name . '/select/' . $table . $url_params )->result->json ; 
   ok ( $res->{'msg'} eq "the non_existing_column column does not exist" ) ; 
   ok ( $res->{'ret'} == 400 ) ; 	
   print "\n start test a response with an inexisting column pick" ; 
} 
#eof foreach table


# fetch all the tables 
done_testing();