#!/bin/bash

function my_help()
{
  echo " " 
  echo " test_script"
  echo " ------------"
  echo " Run Test suite and verify the results"
  echo " " 
  echo " Use with arguments : "
  echo " -help              : print this help & exit"
  echo " "
  echo " -type=[default,pon] : test type"
  echo "                       -type=default : test suite with numerical results verification"
  echo "                       -type=pon     : check parallel arithmetic"
  echo " -pon_run=\"MPIxThreds,...\" : comma separated list of #mpix#threads"
  echo " " 
  echo " -arch=arch         : Set the executable architecture. "
  echo "                      -arch=built_in (Default) : "
  echo "                               linux64_gf for linux"
  echo "                               win64 for windows "
  echo "                               linuxa64 for Linux/Arm"
  echo " "
  echo " -mpi=[smp|impi|ompi]"
  echo "         -mpi=smp  : Engine is SMP only executable (default)"
  echo "         -mpi=ompi : engine is using OpenMPI"
  echo "         -mpi=ompi : engine is using Intel MPI"
  echo " " 
  echo "-debug=[0,1,asan]   : Debug flag for executable : 0 (default) 1 debug (_db),asan (gfortran address sanitizer)"
  echo " "
  echo " -np=#MPI Domains    : Set # MPI Domains test will run through"
  echo " -nt=#Threads        : Set # Threads"
  echo " -prec=[dp|sp]       : set executable precision - dp (default) |sp "
  echo " -stdout             : print Test output"
  echo " -tests=\"Test list\"  : Run specific tests"
  echo "                       use CTest regular expression form"
  echo "                       -tests=\"test1|test2|...\"       "
  echo " " 
  echo " -keep_results       : Keep computation results"
  echo " -clean              : Clean execution directory"
  echo " " 
}

arch=built_in
mpi=smp
prec=dp
np=1
nt=1
stdout=0
keep_results=0
tests=()
clean=0
debug=0
ddebug=optimized
verbose=''
qa_type=default
pon_run="4x1,1x4"


for var in "$@"
do
    IFS='=' read -r arg value <<< "$var"
    case $arg in
        -help) my_help; exit 0 ;;
        -type) qa_type="${value}" ;;
        -pon_run) pon_run="${value}"; qa_type=pon ;;
        -arch) arch="${value}" ;;
        -mpi) mpi="${value}" ;;
        -np) np="${value}" ;;
        -nt) nt="${value}" ;;
        -debug) ddebug="${value}" ;;
        -prec) prec="${value}" ;;
        -tests) tests=( -R "${value}" ) ;;
        -stdout) stdout=1; verbose="--verbose" ;;
        -keep_results) keep_results=1 ;;
        -clean) clean=1 ;;
    esac

   done

# As this is a bash script it is intended to be executed on Linux Platforms.
test_directory=ctest_suite_linux

echo " " 
echo " test_script"
echo " ------------"
echo " " 

# Clean & Exit
if (( clean == 1 ))
then
   echo "Clean ${test_directory}"
   echo " "
   if [[ -d ${test_directory} ]]
   then
     rm -rf "${test_directory}"
   fi
   exit 0
fi

# create build directory & enter
if [[ ! -d ${test_directory} ]]
then
   mkdir "${test_directory}"
fi
cd "${test_directory}"


# MPI=smp,impi,ompi : depending on the flavors

#rem cmake -DMPI=impi -DNP=4 ..

cmake -Darch="$arch" -DPREC="$prec" -DMPI="$mpi" -DNP="$np" -DNT="$nt" -DSTDOUT="$stdout" -DKEEP="$keep_results" -DDEBUG="$ddebug" -Dtype="$qa_type" -Dpon_run="$pon_run" ..
echo " " 
ctest -C Release --output-on-failure --timeout 600 "${tests[@]}" $verbose

cd ..
