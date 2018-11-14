package IssueTracker::Controller::BaseController ; 
use strict ; use warnings ; 

use Mojo::Base 'Mojolicious::Controller';
use Data::Printer ; 


our $module_trace    = 0 ; 
our $appConfig       = {};
our $objLogger       = {} ;
our $rdbms_type      = 'postgres' ; 

use IssueTracker::App::Mdl::Model ; 
use IssueTracker::App::Db::In::RdrDbsFactory ; 
use IssueTracker::App::Cnvr::CnrHsr2ToHsr2 ; 


sub doReloadProjectDbMetaData {

   my $self                = shift ;
   my $db                  = shift ;

   $appConfig		 		   = $self->app->get('AppConfig');
   my $objRdrDbsFactory    = {} ; 
   my $objRdrDb            = {} ; 
   my $msr2                = {} ; 
   my $ret                 = 1 ; 
   my $msg                 = "fatal error while reloading project database meta data " ; 
   my $objModel            = {} ; 

   $objModel               = 'IssueTracker::App::Mdl::Model'->new ( \$appConfig ) ;
   $objModel->set('postgres_db_name' , $db ) ; 
    
   $objRdrDbsFactory       = 'IssueTracker::App::Db::In::RdrDbsFactory'->new( \$appConfig, \$objModel );
   $objRdrDb               = $objRdrDbsFactory->doInstantiate( $rdbms_type );
   ($ret, $msg , $msr2 )   = $objRdrDb->doLoadProjDbMetaData( $db ) ; 

   $appConfig->{ "$db" . '.meta' } = $msr2 ; # chk: it-181101180808

   return ( $ret , $msg , $msr2 ) ; 
}


sub isAuthorized {

   my $self                = shift ;
   my $db                  = shift ;
   $appConfig		 		   = $self->app->get('AppConfig');

   my $htpasswd_file = $appConfig->{ 'ProductInstanceDir'} . '/cnf/sec/passwd/' . $db . '.htpasswd' ;

   return 1 unless -f $htpasswd_file ;  # open by default !!! ( temporary till v0.5.1 )
   return 1 if $self->basic_auth(
      $db => {
         'path' => $htpasswd_file
      }
   );

   return 0  ;

}

# 
# call-by : $self->SUPER::doRenderJson($http_code,$msg,$http_method,$met,$cnt,$dat);
#
sub doRenderJson {

   my $self          = shift ; 
   my $http_code     = shift ; 
   my $msg           = shift ; 
   my $http_method   = shift || 'GET' ; 
   my $met           = shift ; 
   my $cnt           = shift ; 
   my $dat           = shift ; 
   my $req           = "$http_method " . $self->req->url->to_abs ; 

   $self->res->headers->content_type('application/json; charset=utf-8');
   $self->res->code($http_code);
   $self->render( 'json' =>  { 
        'ret'   => $http_code
      , 'msg'   => $msg
      , 'req'   => $req
      , 'met'   => $met
      , 'cnt'   => $cnt
      , 'dat'   => $dat
   });
}

1;

__END__
