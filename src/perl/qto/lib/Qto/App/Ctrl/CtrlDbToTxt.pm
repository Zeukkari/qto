package Qto::App::Ctrl::CtrlDbToTxt ; 

	use strict; use warnings;

	my $VERSION = '1.0.0';    

	require Exporter;
	our @ISA = qw(Exporter Qto::App::Utils::OO::SetGetable Qto::App::Utils::OO::AutoLoadable) ;
	our $AUTOLOAD =();
	use AutoLoader;
   use utf8 ;
   use Carp ;
   use Data::Printer ; 

   use parent 'Qto::App::Utils::OO::SetGetable' ;
   use parent 'Qto::App::Utils::OO::AutoLoadable' ;
   use Qto::App::Utils::Logger ; 
   use Qto::App::Db::In::RdrDbsFcry ; 
   use Qto::App::IO::Out::WtrTextFactory ; 
   use Qto::App::RAM::CnrHsr2ToTxt ; 
   use Qto::App::Mdl::Model ; 

	our $module_trace                = 1 ; 
	our $config						   = {} ; 
	our $objLogger						   = {} ; 
	our $objModel                    = {} ; 
	our $objFileHandler			      = {} ; 
   our $rdbms_type                  = 'postgre' ; 

=head1 SYNOPSIS
      my $objCtrlDbToTxt = 
         'Qto::App::Ctrl::CtrlDbToTxt'->new ( \$config ) ; 
      ( $ret , $msg ) = $objCtrlDbToTxt->doLoadIssuesFileToDb ( $issues_file ) ; 
=cut 

=head1 EXPORT

	A list of functions that can be exported.  You can delete this section
	if you don't export anything, such as for a purely object-oriented module.
=cut 

=head1 SUBROUTINES/METHODS

	# -----------------------------------------------------------------------------
	START SUBS 
=cut



   # 
	# -----------------------------------------------------------------------------
   # read the passed issue file , convert it to hash ref of hash refs 
   # and insert the hsr into a db
	# -----------------------------------------------------------------------------
   sub doReadAndWrite {

      my $self                = shift ; 

      my $ret                 = 1 ; 
      my $msg                 = 'unknown error while loading db issues to xls file' ; 
      my $str_issues          = q{} ; 
      my $hsr                 = {} ;   # this is the data hash ref of hash reffs 
      my $mhsr                = {} ;   # this is the meta hash describing the data hash ^^
      my $db                  = $objModel->get( 'env.postgres_db_name' );
      my @tables              = () ;   # which tables to read from
      my $tables              = $objModel->get( 'ctrl.tables' )  || 'daily_issues' ; 
	   push ( @tables , split(',',$tables ) ) ; 

      my $filter_by_attributes = $ENV{'filter_by_attributes'} || undef ; 


      for my $table ( @tables ) { 
         my $issues_file = ();  
         my $objRdrDbsFcry = 'Qto::App::Db::In::RdrDbsFcry'->new( \$config , \$objModel ) ; 
         my $objRdrDb 			= $objRdrDbsFcry->doSpawn ( "$rdbms_type" );

         ( $ret , $msg )  = 
            $objRdrDb->doSelectRows( $db , $table ) ; 
         return ( $ret , $msg ) unless $ret == 0 ; 

         my $objWtrTextFactory = 'Qto::App::IO::Out::WtrTextFactory'->new( \$config , $self ) ; 
         my $objWtrText 			= $objWtrTextFactory->doInit ( $table );
         
         my $objCnrHsr2ToTxt = 
            'Qto::App::RAM::CnrHsr2ToTxt'->new ( \$config ) ; 
         ( $ret , $msg )  = $objCnrHsr2ToTxt->doPrepareHashForPrinting( \$objModel ) ; 
         return ( $ret , $msg ) if $ret != 0 ;  
         
         ( $ret , $msg )  = $objCnrHsr2ToTxt->doConvertHashRefToStr( \$objModel ) ; 
         return ( $ret , $msg ) if $ret != 0 ;  

         ( $ret , $msg ) = $objWtrText->doPrintIssuesFile( \$objModel ) ; 
         return ( $ret , $msg ) if $ret != 0 ;  
      }
         return ( $ret , $msg ) ; 
   } 
	

=head1 WIP

	
=cut

=head1 SUBROUTINES/METHODS

	STOP  SUBS 
	# -----------------------------------------------------------------------------
=cut


=head2 new
	# -----------------------------------------------------------------------------
	# the constructor
=cut 

	# -----------------------------------------------------------------------------
	# the constructor 
	# -----------------------------------------------------------------------------
	sub new {

		my $class = shift;    # Class name is in the first parameter
		$config = ${ shift @_ } || { 'foo' => 'bar' ,} ; 
		$objModel   = ${ shift @_ } || croak 'objModel not passed !!!' ; 
		my $self = {};        # Anonymous hash reference holds instance attributes
		bless( $self, $class );    # Say: $self is a $class
      $self = $self->doInitialize( ) ; 
		return $self;
	}  
	#eof const


   #
	# --------------------------------------------------------
	# intializes this object 
	# --------------------------------------------------------
   sub doInitialize {
      my $self          = shift ; 

      %$self = (
           config => $config
       );

	   $objLogger 			= 'Qto::App::Utils::Logger'->new( \$config ) ;

      return $self ; 
	}	
	#eof sub doInitialize



1;

__END__

=head1 NAME

UrlSniper 

=head1 SYNOPSIS

use UrlSniper  ; 


=head1 DESCRIPTION
the main purpose is to initiate minimum needed environment for the operation 
of the whole application - man app cnfig hash 

=head2 EXPORT


=head1 SEE ALSO

perldoc perlvars

No mailing list for this module


=head1 AUTHOR

yordan.georgiev@gmail.com

=head1 



=cut 

