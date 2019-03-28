#! /usr/bin/perl -w
use strict;

my $log_dir_destination = shift;
my $email = shift;

my $id = `id`;
my @id = split(/\s/, $id);
my @onyen = split(/\(/, $id[0]);
$onyen[1] =~ s/\)//;
my $pine_junk = "/pine/scr/".substr($onyen[1], 0, 1)."/".substr($onyen[1], 1, 1)."/".$onyen[1]."/junk"; 
system("mkdir $pine_junk");

my $ssub = `grep ssub ~/.bashrc`;
if($ssub ne ""){
	die "You already have some ssub in your ~/.bashrc file. Please remove it before continuing.\n";
}

open(OUT, ">$pine_junk/ssub.txt");
my $ssub_command = "export SLURMLOGLOC=$log_dir_destination/SLURM_logs/

function ssub {
        day=\$(date '+%Y/%m/%d')
        mkdir -p \$SLURMLOGLOC/SLURM_logs/\$day
        log=\$(date '+%Y%m%d_%H-%M-%S-%3N')
        cmd=\"sbatch -o \$SLURMLOGLOC/SLURM_logs/\$day/\$log -e \$SLURMLOGLOC/SLURM_logs/\$day/\$log --time=10-12 --open-mode=append \$*\"
        notify=\$(echo \$cmd | sed -nE 's/.+notify.(\\w+).+/\1/p')
        if ! { [ \"\$notify\" = \"ON\" ] || [ \"\$notify\" = \"OFF\" ]; }; then
                notify=\"ON\"
        fi

            cmd2=\$(echo \$cmd | sed -E 's/--notify\=\\w+ //')

        echo -e \"Your job looked like:\\n###################################################################################\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        echo \$cmd2 \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        echo -e \"\\n###################################################################################\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        jobID=\"\$(eval \$cmd2 | cut -f 4 -d ' ')\"

        if [ \"\$notify\" = \"ON\" ]; then
                memory=\"sbatch -o $pine_junk/\$log -d afterany:\$jobID --partition general --wrap=\\\"echo -e '\\n\\nJob runtime metrics:\\n###################################################################################\\n' \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log;\
                sacct --format=\"JobID,JobName,Partition,AllocCPUS,Submit,Elapsed,State,CPUTime,MaxRSS\" --units=G -j \$jobID \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log;\
                echo -e '\\n###################################################################################\\n' \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log;\
                echo 'Subject: SLURM job \$jobID' | cat - \$SLURMLOGLOC/SLURM_logs/\$day/\$log | sendmail $email\\\"\"
        elif [ \"\$notify\" = \"OFF\" ]; then
                memory=\"sbatch -o $pine_junk/\$log -d afterany:\$jobID --partition general --wrap=\\\"echo -e '\\n\\nJob runtime metrics:\\n###################################################################################\\n' \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log;\
                sacct --format=\"JobID,JobName,Partition,AllocCPUS,Submit,Elapsed,State,CPUTime,MaxRSS\" --units=G -j \$jobID \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log;\
                echo -e '\\n###################################################################################\\n' \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log\\\"\"
        fi
            memoryID=\"\$(eval \$memory | cut -f 4 -d ' ')\"

        queue=\$(echo \$cmd2 | sed -nE 's/.+partition.(\\w+).+/\1/p')
        if [ \"\$partition\" = \"\" ]; then
                queue=\"general\"
        fi

            echo \"Job \<\$jobID\> submitted to partition \<\$queue\>\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log

        if [ \$notify = \"ON\" ]; then
                echo -e \"Job email notification enabled\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        elif [ \$notify = \"OFF\" ]; then
                echo -e \"Job email notification disabled\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        fi

            echo \"\$jobID\"
        wd=\$(pwd)
        echo -e \"Current Working Directory: \$wd\\n\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
        echo -e \"The output (if any) follows:\\n\" \>\> \$SLURMLOGLOC/SLURM_logs/\$day/\$log
}
";
print OUT $ssub_command;
close(OUT);

my $cat_command = `cat $pine_junk/ssub.txt >> ~/.bashrc`;
