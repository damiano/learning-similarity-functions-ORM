#!/usr/bin/perl
use strict;



my %topicDetectionRelSys=();
my %topicDetectionRelGold=();
my %entityDocs=();
my %entityDocsSys=();
my $avgF=0;
my $avgR=0;
my $avgS=0;
my $samplesEntities=0;


open (FICHIN,$ARGV[0]) or die("not found $ARGV[0]");
my $line=<FICHIN>;
while (my $line=<FICHIN>){
  if ($line=~/\n/){
    chop ($line);
  }
  $line=~s/\"//g;
  if ($line=~/\w/){
    	(my $entity,my $id,my $topicDetection)=split(/\t/,$line);
	 $topicDetectionRelGold{$entity}{$id}=$topicDetection;
	 $entityDocs{$entity}.="|$id"; 
  }	
}
close (FICHIN);

open (FICHIN,$ARGV[1]) or die("not found $ARGV[1]");
$line=<FICHIN>;
while (my $line=<FICHIN>){
  if ($line=~/\n/){
    chop ($line);
  }
  $line=~s/\"//g;
  if ($line=~/\w/){
    (my $entity,my $id,my $topicDetection)=split(/\t/,$line);
    $topicDetectionRelSys{$entity}{$id}=$topicDetection;
  }	
}
close (FICHIN);


print "system\tentity\tReliability\tSensitivity\tF measure\n";
 
foreach my $entity (keys %entityDocs){
  my $samplesS=0;
  my $samplesR=0;
  my $R=0;
  my $S=0;
  foreach my $doc1 (split(/\|/,$entityDocs{$entity})){
    if ($doc1 ne ""){
      my $Rd=0;
      my $sampRd=0;
      my $Sd=0;
      my $sampSd=0;
      foreach my $doc2 (split(/\|/,$entityDocs{$entity})){
	if ($doc2 ne ""){
	  if ($topicDetectionRelGold{$entity}{$doc1}eq $topicDetectionRelGold{$entity}{$doc2}){
	    $sampSd++;
	    if ((exists $topicDetectionRelSys{$entity}{$doc1})&&
		(exists $topicDetectionRelSys{$entity}{$doc2})&&	
		($topicDetectionRelSys{$entity}{$doc1} eq $topicDetectionRelSys{$entity}{$doc2})){
	      $Sd++;
	    }
	  }
	}
      }
      foreach my $doc2 (split(/\|/,$entityDocs{$entity})){
	if ($doc2 ne ""){
	  if ((exists $topicDetectionRelSys{$entity}{$doc1})&&
	      (exists $topicDetectionRelSys{$entity}{$doc2})&&	
	      ($topicDetectionRelSys{$entity}{$doc1} eq $topicDetectionRelSys{$entity}{$doc2})){
	    $sampRd++;
	    if ($topicDetectionRelGold{$entity}{$doc1} eq $topicDetectionRelGold{$entity}{$doc2}){
	      $Rd++;
	    }
	  }
	}
      }
      $samplesS++;
      if ($sampSd>0){
	$S+=$Sd/$sampSd;
      }else{
	$S+=1;
      }
      $samplesR++;
      if ($sampRd>0){
	$R+=$Rd/$sampRd;
      }else{
	$R++;
      }
    }
  }
  $R=$R/$samplesR;
  $S=$S/$samplesS;
  my $F=0;
  if (($R>0)&&($S>0)){
    $F=2/(1/$R+1/$S);
  }
  print "$ARGV[1]\t$entity\t$R\t$S\t$F\n"; 
  $samplesEntities++;
  $avgF+=$F;
  $avgR+=$R;
  $avgS+=$S;
}
print "$ARGV[1]\taverage\t".($avgR/$samplesEntities)."\t".($avgS/$samplesEntities)."\t".($avgF/$samplesEntities)."\n";
