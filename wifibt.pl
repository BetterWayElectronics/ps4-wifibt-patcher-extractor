#!/usr/bin/perl 

use strict;
#use warnings; ########################################## <--- REMEMBER TO CHANGE THIS!
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Win32::Console::ANSI;
use Term::ANSIScreen qw/:color /;
use Term::ANSIScreen qw(cls);
use Time::HiRes;
use Fcntl qw(:flock :seek);
use String::HexConvert ':all';
use Win32::Console;
use File::Copy qw(copy);
use Regexp::Assemble;
use LWP 5.64;

##############################################################################################################################################
# __________        __    __                __      __               ___________.__                 __                       .__               
# \______   \ _____/  |__/  |_  ___________/  \    /  \_____  ___.__.\_   _____/|  |   ____   _____/  |________  ____   ____ |__| ____   ______
 # |    |  _// __ \   __\   __\/ __ \_  __ \   \/\/   /\__  \<   |  | |    __)_ |  | _/ __ \_/ ___\   __\_  __ \/  _ \ /    \|  |/ ___\ /  ___/
 # |    |   \  ___/|  |  |  | \  ___/|  | \/\        /  / __ \\___  | |        \|  |_\  ___/\  \___|  |  |  | \(  <_> )   |  \  \  \___ \___ \ 
 # |______  /\___  >__|  |__|  \___  >__|    \__/\  /  (____  / ____|/_______  /|____/\___  >\___  >__|  |__|   \____/|___|  /__|\___  >____  >
        # \/     \/                \/             \/        \/\/             \/           \/     \/                        \/        \/     \/ 

##############################################################################################################################################


my $CONSOLE=Win32::Console->new;
$CONSOLE->Title('BwE PS4 WiFi-BT Patcher');

my $version = "1.3.4"; ########################################## <--- REMEMBER TO CHANGE THIS!

my $clear_screen = cls(); 
my $osok = (colored ['bold green'], "OK");
my $osdanger = (colored ['bold red'], "DANGER");
my $oswarning = (colored ['bold yellow'], "WARNING");
my $osunlisted = (colored ['bold blue'], "UNLISTED");

my $BwE = (colored ['bold magenta'], qq{
===========================================================
|            __________          __________               |
|            \\______   \\ __  _  _\\_   ____/               |
|             |    |  _//  \\/ \\/  /|  __)_                |
|             |    |   \\\\        //       \\               |
|             |______  / \\__/\\__//______  /               |
|                 PS4\\/ WiFi-BT PATCHER \\/$version           |
|        		                                  |
===========================================================\n});
print $BwE;

print "\nChecking For Latest Version....\n";

my $url = 'https://www.betterwayelectronics.com.au/version_wifibt.txt'; 
my $browser = LWP::UserAgent->new;
my $response = $browser->get($url);
my $currentversion = $response->content;

if ($response->is_success) {
	#print "Current Version: ", $response->content;
	if ($response->content gt $version) {
	print $clear_screen;
	print $BwE;
	print "\n", (colored ['bold red'], "Alert: You Are Out Of Date, The Current Version Is: $currentversion\n");
		print "\n\nContinue With The Old Version? (y/n): "; 
		my $input = <STDIN>; chomp $input; 
		if ($input eq "n") { goto FAILURE } else { goto OKAY }
		}
} 

OKAY: #It is much easier to just do it this way than any other way :)

print $clear_screen;
print $BwE;

START:

############################################################################################################################################

my @files=(); 

while (<*.bin>) 
{
    push (@files, $_) if (-s eq "33554432");
}

my $input; my $file; my $original;

if ( @files == 0 ) {
	print "\n$oswarning: Nothing to patch. Aborting...\n"; 
	goto FAILURE;
} else {

if ( @files > 1 ) { 
	print "\nMultiple .bin files found within the directory:\n\n";
	foreach my $file (0..$#files) {
		print $file + 1 . " - ", "$files[$file]\n";
}

print "\nPlease make a selection: ";
my $input = <STDIN>; chomp $input; 
my $nums = scalar(@files);

if ($input > $nums) {
	print "\n\n$oswarning: Selection out of range. Aborting...\n\n"; 
	goto FAILURE;}
	
elsif ($input eq "0") {
	print "\n\n$oswarning: Selection out of range. Aborting...\n\n"; 
	goto FAILURE;}
	
elsif ($input eq "") {
	print "\n\n$oswarning: You didn't select anything. Aborting...\n\n"; 
	goto FAILURE;} else {
		$file = $files[$input-1]; 
		$original = $files[$input-1];}; 
	
} else { 
$file = $files[0]; 
$original = $file = $files[0];}
}

### Now that the file is selected....

open(my $bin, "<", $file) or die $!; binmode $bin;

my $md5sum = uc Digest::MD5->new->addfile($bin)->hexdigest; 
my $size= -s $bin;
if ($size ne "33554432") { print "\n\n$osdanger: $file is the wrong size ($size). Aborting...\n\n"; goto FAILURE} else {};

my %C002001_file_sizes;
my @C002001_files = <Patches/*.bin>;
foreach my $C002001_files (@C002001_files) {
   open( my $C0020001_bin, '<:raw', $C002001_files );
	$C002001_file_sizes{uc sprintf("%x",-s $C0020001_bin)} = $C002001_files ;
}

my %C002001_MD5_List;
my @C002001_MD5s = <Patches/*.bin>;
foreach my $C002001_MD5s (@C002001_MD5s) {
   open( my $C0020001_bin, '<:raw', $C002001_MD5s );
	$C002001_MD5_List{(uc Digest::MD5->new->addfile($C0020001_bin)->hexdigest)} = $C002001_MD5s ;
}

my %Reverse_MD5_List;
my @Reverse_MD5s = <Patches/*.bin>;
foreach my $Reverse_MD5s (@Reverse_MD5s) {
   open( my $C0020001_bin, '<:raw', $Reverse_MD5s );
	$Reverse_MD5_List{uc sprintf("%x",-s $C0020001_bin)} = (uc Digest::MD5->new->addfile($C0020001_bin)->hexdigest);
}

seek($bin, 0x0144024, 0); 
read($bin, my $C0020001_patch_size, 0x3); 
$C0020001_patch_size = uc ascii_to_hex($C0020001_patch_size);
$C0020001_patch_size = unpack "H*", reverse pack "H*", $C0020001_patch_size;
$C0020001_patch_size = hex($C0020001_patch_size); 
my $C0020001_patch_size_hex = uc sprintf("%x", $C0020001_patch_size);
my $Entropy_Suitability = 1;
my $C0020001_Size_Validation;

if ($C0020001_patch_size gt "460000") {
	$C0020001_Size_Validation = $osdanger;
	$Entropy_Suitability = 0;
}
	elsif ($C0020001_patch_size lt "410000") {
		$C0020001_Size_Validation = $osdanger;
		$Entropy_Suitability = 0;
		} else {
			$C0020001_Size_Validation = $osok;
		}

my $C0020001_Version;
seek($bin, 0x014421E, 0); 
read($bin, my $C0020001_Version_Detector, 0xD);
$C0020001_Version_Detector = uc ascii_to_hex($C0020001_Version_Detector); 

if ($C0020001_Version_Detector eq "746F727573325F66772E62696E") {
	$C0020001_Version = "Torus 2";
	} elsif ($C0020001_Version_Detector eq "9FE51CF09FE51CF09FE51CF09F") {
		$C0020001_Version = "Torus 1";
		} else {
			$C0020001_Version = "Unknown/Invalid Version $oswarning";
}

my $C0020001_Validation;
seek($bin, 0x144200, 0); 
read($bin, my $C0020001_MD5_Detector, $C0020001_patch_size);
my $C0020001_MD5 = uc md5_hex($C0020001_MD5_Detector);
my $C0020001_Validation_Rev_MD5 = $Reverse_MD5_List{$C0020001_patch_size_hex};

if (exists $C002001_MD5_List{$C0020001_MD5}) { 
	$C0020001_Validation = $osok; 
	} elsif (defined $C0020001_Validation_Rev_MD5) { #If the MD5 has a valid size = then its truely corrupt
			if (exists $C002001_MD5_List{$C0020001_Validation_Rev_MD5}) { 
				$C0020001_Validation = "$osdanger (Size/MD5 Mismatch)"; 
			}}
				else { 
				$C0020001_Validation = "$oswarning (Unlisted/Invalid)"; 
				}	
	
my $C0020001_Entropy_Validation;
my $C0020001_Entropy = 0; 

if ($Entropy_Suitability eq "0") {	
	$C0020001_Entropy = 0;
	$C0020001_Entropy_Validation = $osdanger;
} else {		
	seek($bin, 0x144200, 0); 
	read($bin, my $C0020001_Entropy_Range, $C0020001_patch_size);
	my %C0020001_Entropy_Count; my $C0020001_Entropy_Total = 0; 
	foreach my $char (split(//, $C0020001_Entropy_Range)) {$C0020001_Entropy_Count{$char}++; $C0020001_Entropy_Total++;}
	foreach my $char (keys %C0020001_Entropy_Count) {my $p = $C0020001_Entropy_Count{$char}/$C0020001_Entropy_Total; $C0020001_Entropy += $p * log($p);}
	$C0020001_Entropy = sprintf("%.2f", -$C0020001_Entropy/log(2));  
	
	if ($C0020001_Entropy > 6.97) {
		$C0020001_Entropy_Validation = $osok;
		} 
			else { 
			$C0020001_Entropy_Validation = $osdanger;
			}	
}

my $C0020001_Alternative_Validation_Result;
my @C0020001_Alternative_Validation; 
seek($bin, 0x144200, 0);
read($bin, my $C0020001_Alternative_Validation, $C0020001_patch_size);
while ($C0020001_Alternative_Validation =~ m/([^\xFF]\xFF{13,}[^\xFF])/g){
    my $C0020001_Alternative_Validation = $1;
    my $C0020001_Alternative_Validation_Offset = $-[0] + 0x144200;
	$C0020001_Alternative_Validation_Offset = uc sprintf("%x",$C0020001_Alternative_Validation_Offset);
	$C0020001_Alternative_Validation = uc ascii_to_hex($C0020001_Alternative_Validation); 
	my $C0020001_Alternative_Validation_Shortened = substr ($C0020001_Alternative_Validation, 0, 10);
	my $C0020001_Alternative_Validation_Length = uc sprintf("%x",length($C0020001_Alternative_Validation) / 2);
    push @C0020001_Alternative_Validation, "'$C0020001_Alternative_Validation_Shortened...' with length 0x$C0020001_Alternative_Validation_Length found at offset: 0x$C0020001_Alternative_Validation_Offset ";
	}
my $C0020001_Alternative_Validation_Count = grep {defined $_} @C0020001_Alternative_Validation;

if ($C0020001_Alternative_Validation_Count < 10) {
	if (grep {defined($_)} @C0020001_Alternative_Validation) {
		$C0020001_Alternative_Validation_Result = $osdanger;
		} 
		else {
			$C0020001_Alternative_Validation_Result = $osok;
			}
} else { 
		$C0020001_Alternative_Validation_Result = $osdanger;
}		

seek($bin, 0x1C8041,0);read($bin, my $whatisthesku, 0xE); $whatisthesku =~ tr/a-zA-Z0-9 -//dc; #Hahahaha! Easy!


my $whatistheversion;

seek($bin, 0x1C906A, 0); 
read($bin, my $FW_Version2, 0x2);
$FW_Version2 = uc ascii_to_hex($FW_Version2); 
if ($FW_Version2 eq "FFFF")
{
	seek($bin, 0x1CA606, 0); 
	read($bin, my $FW_Version1, 0x2);
	$FW_Version1 = uc ascii_to_hex($FW_Version1); 
	if ($FW_Version1 eq "FFFF")
	{
		$whatistheversion = "N/A";
	} 
	else
	{
		$FW_Version1 = unpack "H*", reverse pack "H*", $FW_Version1;
		$FW_Version1 = hex($FW_Version1); $FW_Version1 = uc sprintf("%x", $FW_Version1);
		$whatistheversion = substr($FW_Version1, 0, 1) . "." . substr($FW_Version1, 1);
	}
} 
else
{
	$FW_Version2 = unpack "H*", reverse pack "H*", $FW_Version2;
	$FW_Version2 = hex($FW_Version2); $FW_Version2 = uc sprintf("%x", $FW_Version2);
	$whatistheversion = substr($FW_Version2, 0, 1) . "." . substr($FW_Version2, 1);
}


################################################ SELECTIONNNS

print $clear_screen;
print $BwE;

print "\n1 - Validate & Patch";
print "\n2 - Validate & Extract\n";

print "\nPlease Make Your Selection: ";

$input = <STDIN>; chomp $input; 

if ($input eq "1") {
 
######################################################################## START THE PATCHING PROCESS NOW ######
 
if (exists $C002001_file_sizes{$C0020001_patch_size_hex}) {	
	my $patch = $C002001_file_sizes{$C0020001_patch_size_hex};
	
	#CREATE EMPTY FILE IN MEMORY AND FILL IT WITH THE LENGTH OF THE C0020001 - ESSENTIALLY ENSURING THAT THE FILE IS DELETED PRIOR TO WRITING.
	my $fillerdata_file	= "";
	open (my $fillerdata, '+<', \$fillerdata_file) or die $!; binmode($fillerdata);
	printf $fillerdata pack "H*", "00" x $C0020001_patch_size; 
	close $fillerdata;
	
	open (my $patchdata, '<', $patch) or die $!; binmode($patchdata);
	open (my $patchdata_2, '<', $patch) or die $!; binmode($patchdata_2); #IF I DONT DO THIS - THE PATCH IS INJECTED WRONG
	open ($fillerdata, '<', \$fillerdata_file) or die $!; binmode($fillerdata);
	open (my $patchdataMD5, '<', $patch) or die $!; binmode($patchdataMD5); #IF I DONT DO THIS - THE PATCH ISNT INJECTED - WEIRD AS FUCK!
	
	my $patchedmd5sum = uc Digest::MD5->new->addfile($patchdataMD5)->hexdigest;
	my $patchsize = -s $patch;
	my $patchsizehex = uc sprintf("%x", $patchsize);

	my $C0020001_Patch_Version;
	seek($patchdata_2, 0x1E, 0); 
	read($patchdata_2, my $C0020001_Patch_Version_Detector, 0xD);
	$C0020001_Patch_Version_Detector = uc ascii_to_hex($C0020001_Patch_Version_Detector); 
	
	if ($C0020001_Patch_Version_Detector eq "746F727573325F66772E62696E") {
		$C0020001_Patch_Version = "Torus 2";
		} elsif ($C0020001_Patch_Version_Detector eq "9FE51CF09FE51CF09FE51CF09F") {
			$C0020001_Patch_Version = "Torus 1";
			} else {
				$C0020001_Patch_Version = "Unknown/Invalid Version $oswarning";
		}
	
	print $clear_screen;
	print $BwE;

	print "\nFile: $file";
	print "\nSKU: $whatisthesku"; 
	print "\nVersion: $whatistheversion"; 
	print "\nMD5: $md5sum"; 
	print "\n\nC0020001 Version: $C0020001_Version";
	print "\nC0020001 Size: 0x$C0020001_patch_size_hex $C0020001_Size_Validation";
	print "\nC0020001 MD5: $C0020001_MD5";
	print "\n\nMD5 Based Validation: $C0020001_Validation";
	
	if ($C0020001_Entropy eq "0") {
		print "\nEntropy Validation: $C0020001_Entropy_Validation (Unable To Calculate)";
		} else {
			print "\nEntropy Validation: $C0020001_Entropy $C0020001_Entropy_Validation";
		}
	if ($C0020001_Alternative_Validation_Count > 10) {
		print "\nAlternative Validation: $C0020001_Alternative_Validation_Result (Too Many To Display!)\n";
		} else {
			print "\nAlternative Validation: $C0020001_Alternative_Validation_Result\n";
			print "$_ $osdanger\n" foreach @C0020001_Alternative_Validation; 
		}
		
	color 'black on green';
	print "\nDetected Correct Replacement Patch File (Original Will Be Erased)\n";
	color 'reset';
	print "\nPatch: $patch";
	print "\nPatch Version: $C0020001_Patch_Version";
	print "\nPatch Size: 0x$patchsizehex";
	print "\nPatch MD5: $patchedmd5sum";

	print "\n\nYou will be patching from: 0x144200";
	print "\n\nContinue? (y/n): "; 
	my $input = <STDIN>; chomp $input; 
	
	if ($input eq "n") { goto FAILURE } else { 
		#NOW YOU CAN COPY AND OPEN THE FILE
		(my $fileminusbin = $file) =~ s/\.[^.]+$//;
		my $patched = $fileminusbin."_patched.bin"; copy $file, $patched;
		open (my $patchbin, '+<',$patched) or die $!; binmode($patchbin);

		#DELETE PRIOR TO PATCHING
		my $area; use Fcntl 'SEEK_SET';
		read ($fillerdata, $area, $patchsize);
		sysseek $patchbin, hex(144200), SEEK_SET; syswrite ($patchbin, $area);
		close ($patched);
		
		#PATCH
		my $area2; use Fcntl 'SEEK_SET';
		sysread ($patchdata, $area2, $patchsize);
		sysseek $patchbin, hex(144200), SEEK_SET; syswrite ($patchbin, $area2);
		close ($patched);

		my $patchlength = uc sprintf("%x", 0x0144200 + $patchsize);
		
		color 'black on green';
		print "\nDump has been successfully patched as $fileminusbin\_patched.bin with $patch from 0x144200 to 0x$patchlength\n\n";
		color 'reset';

	}
} else { 

########################## IF THERE IS NOT A MATCHING PATCH FILE  - Why do it all over again? Well I don't remember! This isnt OOP yo! ##################################################################################

	print $clear_screen;
	print $BwE;
	
	my @patches=(); 

	while (<Patches/*.bin>) 
	{
		push (@patches, $_) if (-f "$_");
	}

	my $input; my $patch;

	if ( @patches == 0 ) {
		print "\n\n$oswarning: Nothing to patch with. Aborting...\n"; 
		goto FAILURE;
		} else {

		if ( @patches > 1 ) { 
			if ($Entropy_Suitability eq "0") {	
			print colored ['bold red'], "\nNo Compatible C0020001 Patch Found! Your Header (0x$C0020001_patch_size_hex) Is Also Corrupted! You May Never Know The Correct Size!\n";
			} else {
				print colored ['bold red'], "\nNo Compatible C0020001 Patch Found! You Need 0x$C0020001_patch_size_hex!\n";
			}
			print colored ['bold yellow'], "Continuing By Patching A Smaller/Larger/Wrong Version C0020001 Is EXPERIMENTAL!\n";
			print "\nSelect a .bin file to patch with:\n\n";
			foreach my $patch (0..$#patches) {
				print $patch + 1 . " - ", "$patches[$patch]\n";
			}

		print "\nPlease select patch for $file: ";
		my $input = <STDIN>; chomp $input; 
		my $nums = scalar(@patches);

		if ($input > $nums) {
			print "\n\n$oswarning: Selection out of range. Aborting...\n\n"; 
			goto FAILURE;}
			
		if ($input eq "0") {
			print "\n\n$oswarning: Selection out of range. Aborting...\n\n"; 
			goto FAILURE;}
			
		if ($input eq "") {
			print "\n\n$oswarning: You didn't select anything. Aborting...\n\n"; 
			goto FAILURE;} else {
				$patch = $patches[$input-1]; 
				}; 
			
		} else { 
			print "\n\n$oswarning: Auto-selecting...\n\n"; 
			$patch = $patches[0]; 
			}
			
		#CREATE EMPTY FILE IN MEMORY AND FILL IT WITH THE LENGTH OF THE C0020001 - ESSENTIALLY ENSURING THAT THE FILE IS DELETED PRIOR TO WRITING.
		my $fillerdata_file	= "";
		open (my $fillerdata, '+<', \$fillerdata_file) or die $!; binmode($fillerdata);
		printf $fillerdata pack "H*", "00" x $C0020001_patch_size; 
		close $fillerdata;
		
		#CREATE EMPTY FILE IN MEMORY AND FILL IT WITH THE NEW HEADER
		my $New_Header_File	= "";
		open (my $New_Header_Data, '+<', \$New_Header_File) or die $!; binmode($New_Header_Data);
		my $New_Header_Size = -s $patch;
		my $New_Header_Size_Hex = uc sprintf("%x", $New_Header_Size);
		my $New_Header = "0".$New_Header_Size_Hex;
		$New_Header = unpack "H*", reverse pack "H*", $New_Header;
		$New_Header = hex($New_Header); 
		$New_Header = uc sprintf("%x", $New_Header);
		printf $New_Header_Data pack "H*", $New_Header;
		close $New_Header_Data;
		

		open (my $patchdata, '<', $patch) or die $!; binmode($patchdata);
		open (my $patchdata_2, '<', $patch) or die $!; binmode($patchdata_2); #IF I DONT DO THIS - THE PATCH IS INJECTED WRONG
		open ($fillerdata, '<', \$fillerdata_file) or die $!; binmode($fillerdata);
		open ($New_Header_Data, '<', \$New_Header_File) or die $!; binmode($New_Header_Data);
		open (my $patchdataMD5, '<', $patch) or die $!; binmode($patchdataMD5); #IF I DONT DO THIS - THE PATCH ISNT INJECTED - WEIRD AS FUCK!
		
		my $patchedmd5sum = uc Digest::MD5->new->addfile($patchdataMD5)->hexdigest;
		my $patchsize = -s $patch;
		my $patchsizehex = uc sprintf("%x", $patchsize);

		my $C0020001_Patch_Version;
		seek($patchdata_2, 0x1E, 0); 
		read($patchdata_2, my $C0020001_Patch_Version_Detector, 0xD);
		$C0020001_Patch_Version_Detector = uc ascii_to_hex($C0020001_Patch_Version_Detector); 
		
		if ($C0020001_Patch_Version_Detector eq "746F727573325F66772E62696E") {
			$C0020001_Patch_Version = "Torus 2";
			} elsif ($C0020001_Patch_Version_Detector eq "9FE51CF09FE51CF09FE51CF09F") {
				$C0020001_Patch_Version = "Torus 1";
				} else {
					$C0020001_Patch_Version = "Unknown/Invalid Version $oswarning";
					}

		print $clear_screen;
		print $BwE;

		print "\nFile: $file";
		print "\nSKU: $whatisthesku"; 
		print "\nVersion: $whatistheversion"; 
		print "\nMD5: $md5sum"; 
		print "\n\nC0020001 Version: $C0020001_Version";
		print "\nC0020001 Size: 0x$C0020001_patch_size_hex $C0020001_Size_Validation";
		print "\nC0020001 MD5: $C0020001_MD5";
		print "\n\nMD5 Based Validation: $C0020001_Validation";
		if ($C0020001_Entropy eq "0") {
			print "\nEntropy Validation: $C0020001_Entropy_Validation (Unable To Calculate)";
				} else {
					print "\nEntropy Validation: $C0020001_Entropy $C0020001_Entropy_Validation";
					}
		if ($C0020001_Alternative_Validation_Count > 10) {
			print "\nAlternative Validation: $C0020001_Alternative_Validation_Result (Too Many To Display!)\n";
			} else {
				print "\nAlternative Validation: $C0020001_Alternative_Validation_Result\n";
				print "$_ $osdanger\n" foreach @C0020001_Alternative_Validation; 
				}
		color 'black on yellow';
		print "\nYour Patch Will Replace The Original Completely (Header Modification & Original File Deletion)\n";
		color 'reset';
		print "\nPatch: $patch";
		print "\nPatch Version: $C0020001_Patch_Version";
		print "\nPatch Size: 0x$patchsizehex";
		print "\nPatch MD5: $patchedmd5sum";

		print "\n\nYou will be patching from: 0x144200";
		print "\n\nContinue? (y/n): "; 
		my $input = <STDIN>; chomp $input; 
		if ($input eq "n") { goto FAILURE } else { 
		
			#NOW YOU CAN COPY AND OPEN THE FILE
			(my $fileminusbin = $file) =~ s/\.[^.]+$//;
			my $patched = $fileminusbin."_patched.bin"; copy $file, $patched;
			open (my $patchbin, '+<',$patched) or die $!; binmode($patchbin);
			
			#NEW HEADER FIRST
			my $area3; use Fcntl 'SEEK_SET';
			read ($New_Header_Data, $area3, 3);
			sysseek $patchbin, hex(144024), SEEK_SET; syswrite ($patchbin, $area3);
			close ($patched);

			#DELETE C0020001 PRIOR TO PATCHING
			my $area4; use Fcntl 'SEEK_SET';
			read ($fillerdata, $area4, $C0020001_patch_size);
			sysseek $patchbin, hex(144200), SEEK_SET; syswrite ($patchbin, $area4);
			close ($patched);
			
			#OK PATCH THE PATCH!
			my $area5; use Fcntl 'SEEK_SET';
			sysread ($patchdata, $area5, $patchsize);
			sysseek $patchbin, hex(144200), SEEK_SET; syswrite ($patchbin, $area5);
			close ($patched);

			my $patchlength = uc sprintf("%x", 0x0144200 + $patchsize);
			
			color 'black on green';
			print "\nDump has been successfully patched as $fileminusbin\_patched.bin with $patch from 0x144200 to 0x$patchlength\n\n";
			color 'reset';

		}	
	}}

} ########## END SELECTION 1

if ($input eq "2") {


if (exists $C002001_file_sizes{$C0020001_patch_size_hex}) {	
	print $clear_screen;
	print $BwE;
	color 'black on yellow';
	print "\n\nNo Need To Extract! Your version of the C0002001.bin is already in /Patches/ directory!\n\n";
	color 'reset';
	goto FAILURE;
	}
	else {

		my $filemd5sum = uc Digest::MD5->new->addfile($bin)->hexdigest;

		print $clear_screen;
		print $BwE;

		print "\nFile: $file";
		print "\nSKU: $whatisthesku"; 
		print "\nVersion: $whatistheversion"; 
		print "\nMD5: $md5sum"; 
		print "\n\nC0020001 Version: $C0020001_Version";
		print "\nC0020001 Size: 0x$C0020001_patch_size_hex $C0020001_Size_Validation";
		print "\nC0020001 MD5: $C0020001_MD5";
		print "\n\nMD5 Based Validation: $C0020001_Validation";
		if ($C0020001_Entropy eq "0") {
			print "\nEntropy Validation: $C0020001_Entropy_Validation (Unable To Calculate)";
				} else {
					print "\nEntropy Validation: $C0020001_Entropy $C0020001_Entropy_Validation";
					}
		if ($C0020001_Alternative_Validation_Count > 10) {
			print "\nAlternative Validation: $C0020001_Alternative_Validation_Result (Too Many To Display!)\n";
				} else {
					print "\nAlternative Validation: $C0020001_Alternative_Validation_Result\n";
					print "$_ $osdanger\n" foreach @C0020001_Alternative_Validation; 
					}
		print "\nYou will be extracting C0020001.bin from $file...";
		print "\n\nContinue? (y/n): "; 
		my $input = <STDIN>; chomp $input; 
		if ($input eq "n") { goto FAILURE } else { 
			#EXTRACT
			(my $fileminusbin = $file) =~ s/\.[^.]+$//;
			open(my $extract, '+>', $fileminusbin."_C0020001.bin") or die $!; binmode($extract);
			seek($bin, 0x0144200, 0);
			read($bin, my $C0020001, $C0020001_patch_size);
			print $extract $C0020001;

			my $extract_size = uc sprintf("%x", $C0020001_patch_size);
			
			color 'black on green';
			print "\nC0020001.bin has been extracted as $fileminusbin\_C0020001.bin with the length of 0x$extract_size\n\n";
			color 'reset';
	}}

} #### YEAH END SELECTION 2 YO!

FAILURE:

print "\nPress Enter to Exit... ";
while (<>) {
chomp;
last unless length;
}


#### HEY! THIS WAS NOT WRITTEN WITH PROFESSIONAL METHODOLOGIES, IT WAS WRITTEN QUICKLY (POORLY) IN A METHOD THAT I UNDERSTAND! SORRY BUDDY! IF IT HELPS, I AM NOW DOING C# IN MY POST-GRAD COURSE. 
