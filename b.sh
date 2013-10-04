#!/bin/bash

#Usage: redirect pts (you can find this by typing tty) of terminals you wish to send the projects to a different terminal 
#ie $ echo "0 1 2 3 4 5 6 7 8 9 10 11" | ./{name_of_script} 

#start timing 
time_start=`date +%s`

cd $(dirname $0)

clear

#how long should the message be displayed for
display_timeout=2000

echo "Enter the terminals you wich to redirect the build output to (type tty to find out the terminal pts)"

#read pts's to array from user input (stdin)
read -r -a pts

#array with the projects that need to be compiled
proj=(appbase publishedTypes ossFramework nos-dist ThinClientStrutsApplications ThinClientCoreFramework ThinClientCommonFramework ThinClientFrameworkApplications ThinClientNiGuardianApplications ThinClientInternalFramework ThinClientNiGuardian) 

#array with how the projects are cleaned 
clean=('ant clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean-nos clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean spotless' 'ant clean spotless')

#array with how the projects are build 
build=('ant' 'ant' 'ant' 'ant' 'ant' 'ant' 'ant' 'ant' 'ant' 'ant all autodeploy-internalframework' 'ant all autodeploy-niguardian')

#update all projects from SVN 
cd $MY_WORKSPACE && svn update * 

#rebuild 3rd party
cd $THIRD_PARTY
time=$( ./rebuild.sh 2>&1 | tee /dev/pts/${pts[0]} | tail -1; exit ${PIPESTATUS[0]} )
if [ $? -eq 0 ]; then
 notify-send "3rd-party" "BUILD SUCCESSFUL\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png
else
 notify-send "3rd-party" "BUILD FAILED\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
fi

#clean the projects
for (( i=0; i<${#proj[@]}; i++)); do 
 cd $MY_WORKSPACE/${proj[$i]}
 time=$( ${clean[$i]} 2>&1 | tee /dev/pts/${pts[$(($i+1))]} | tail -1; exit ${PIPESTATUS[0]} ) 
 if [ $? -eq 0 ]; then
  notify-send ${proj[$i]} "CLEAN SUCESSFUL\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
 else
  notify-send ${proj[$i]} "CLEAN FAILED\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
 fi
done

#build the projects 
for (( i=0; i<${#proj[@]}; i++)); do 
 cd $MY_WORKSPACE/${proj[$i]}
 time=$( ${build[$i]} 2>&1 | tee /dev/pts/${pts[$(($i+1))]} | tail -1; exit ${PIPESTATUS[0]} )
 if [ $? -eq 0 ]; then
  notify-send ${proj[$i]} "BUILD SUCCESSFUL\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
 else 
  notify-send ${proj[$i]} "BUILD FAILED\n$time" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
 fi
done

#stop timing
time_end=`date +%s`
time_exec=`expr $(( $time_end - $time_start ))`
time_msg="Time Elapsed:$(($time_exec/3600))h:$(($time_exec%3600/60))m:$(($time_exec%60))s" 
echo $time_msg
notify-send "Finished" "$time_msg" -t $display_timeout -i /usr/share/pixmaps/terminator.png 
