#!/usr/bin/env bash

C_COMPILERS='CMake_Compilers'
C_COMPILERS_C='CMake_Compilers_c'

function my_help()
{
  echo " " 
  echo " build_script"
  echo " ------------"
  echo " " 
  echo " Use with arguments : "
  echo " -arch=[build architecture]"
  if  [[ -f "${C_COMPILERS}/platforms.txt" ]]
  then
       cat "${C_COMPILERS}/platforms.txt" 
  fi
  if  [[ -f "${C_COMPILERS_C}/platforms.txt" ]]
  then
       cat "${C_COMPILERS_C}/platforms.txt" 
  fi
  echo " -prec=[dp|sp]                       : set precision - dp (default) |sp "
  echo " -static-link                        : Fortran, C & C++ runtime are linked in binary"
  echo " -debug=[0|1|asan]                   : debug version for gfortran"
  echo "                                          0 : no debug flags (default)"
  echo "                                          1 : usual debug flag"
  echo "                                          asan : gfortran address sanitizer"
  echo " -open_reader                        : link with open_reader"
  echo " -release                            : Set build for release (optimized)"
  echo " "
  echo " -addflag=\"list of additional flags\" : add compiler flags to usual set"
  echo " "
  echo " Execution control "
  echo " -nt=[threads]      : number of threads for build "
  echo " -verbose           : Verbose build"
  echo " -clean             : clean build directory"
  echo " " 
  echo " -no-python : do not link with python"
  echo " " 
}

# Variable initialization
# -----------------------
OTHER_MAKE_ARGS=" " 
# -----------------------------
# Parse command line arguments
# -----------------------------
arch=none
prec=dp
threads=1
got_arch=0
debug=0
ddebug=""
sanitize=0
jenkins_release=0
no_rr_clean=0
no_python=0
changelist=00000
cf=""
dc=()
qd=""
ADF=""
static_link=0
number_of_arguments=$#
clean=0
verbose=()
st_vers="starter"
com=0
release=0
ad=none
use_openreader=0
orb=()

if [[ "$(uname -m)" == "x86_64" ]]
then
  built_in_arch=linux64
else
  built_in_arch=linuxa64
fi


if (( number_of_arguments == 0 ))
then
  my_help
  exit 1
else
  for var in "$@"
  do
    IFS='=' read -r arg value <<< "$var"
    case "$arg" in
      '-arch')
          arch="${value}"
          got_arch=1
          ;;
      '-prec')
          prec="${value}"
          if [[ "${prec}" == 'sp' ]]
          then
            suffix=_sp
          fi
          ;;
      '-addflag')
          ad="${value}"
          export ADFL=${ad}
          ;;
      '-debug')
          debug="${value}"
          ddebug=_${debug}
          case "$debug" in
            0) ddebug="" ;;
            1) ddebug="_db" ;;
            2) debug=1
               sanitize=1
               ddebug="_db2"
               ;;
          esac
        ;;
      '-nt')
          threads="${value}"
          ;;
      '-open_reader')
          use_openreader=1
          ;;
      '-static-link')
          static_link=1
          ;;
      '-no-python')
          no_python=1
          ;;
      '-release')
          release=1
          ;;
      '-verbose')
          verbose=( "VERBOSE=1" )
          ;;
      '-clean')
          clean=1
          ;;
      '-c')
          com=1
          dc=( "-DCOM=1" )
          cf="_c"
          orb=( "-c" )
          vers="$(grep version "${C_COMPILERS_C}/cmake_st_version.txt" | cut -d '"' -f2)"
          st_vers="s_${vers}"
          ;;
      *)
          echo "Unknown argument: $arg"
          my_help
          exit 1
          ;;
      esac
  done

  if (( got_arch == 0 ))
  then
    echo " " 
    echo " --- Error "
    echo " No architecture flag set ! "
    echo " -arch=[architecture]" 
    echo "       Available arch:"
    my_help
    exit 1
  fi

  if (( release == 1 ))
  then
    debug=0
    ddebug=""
  fi

  starter_exec=${st_vers}_${arch}${dmpi}${suffix}${ddebug}
  build_directory=cbuild_${starter_exec}${cf}

  echo " " 
  echo " Build OpenRadioss Starter "
  echo " --------------------------"
  echo " Build Arguments :"
  echo " arch =                 : $arch"
  echo " precision =            : $prec"
  echo " debug =                : $debug"
  echo " static_link =          : $static_link"
  if (( use_openreader == 1 ))
  then
      echo " "
      echo " linking with open_reader"
  fi

  echo " " 
  echo " Executable name        : $starter_exec"
  if [[ "$ad" != "none" ]]  
  then
    echo " Addflag                : \"$ad\" "
  fi
  echo " "
  echo " #threads for Makefile : $threads"
  echo " "
fi

if (( clean == 1 ))
then
   if [[ -d "${build_directory}" ]]
   then
     echo "Clean ${build_directory} directory"
     rm -rf "./${build_directory}"
   else
     echo "Clean ${build_directory} directory requested but not found"
   fi
   echo " "
   exit 0
fi

#
# OpenReader if -open_reader was set 
# Build open_reader 
#
if (( use_openreader == 1 ))
then
    echo " "
    echo "Build open_reader: ${built_in_arch} "
    echo "----------------"
    cd ../reader
    ./build_script.bash -arch=${built_in_arch} -nt="${threads}" "${orb[@]}" || return_value=$?

    if (( return_value != 0 ))
    then
       echo " " 
       echo " " 
       echo "-- Errors in Build found"
       cd ..
       exit 1
    fi
    cd ../starter
fi

# create build directory
mkdir -p ../exec
# create build directory
mkdir -p "${build_directory}"


echo " -- Remove executable in build_script "
rm -f "${build_directory}/${starter_exec}"

echo " -- Remove executable in exec "
 
rm -f "../exec/${starter_exec}"

echo " "

cd "${build_directory}"

# Get compiler settings
if (( com == 1 ))
then
    compiler_script_dir="../${C_COMPILERS_C}"
else
    compiler_script_dir="../${C_COMPILERS}"
fi

compiler_script="${compiler_script_dir}/"cmake_${arch}_compilers.sh""

if [[ -f "${compiler_script}" ]]
then
    source "${compiler_script}"
else
    echo "-- Error: -arch=${arch} does not exist"
    echo "-- See help below"
    echo " " 
    my_help
    exit 1
fi

Fortran_path="$(which "$Fortran_comp")"
C_path="$(which "$C_comp")"
CPP_path="$(which "$CPP_comp")"
CXX_path="$(which "$CXX_comp")"


# Apply cmake

if [[ ${arch} == "win64" ]]
then
  Fortran_path_w="$(cygpath.exe -m "${Fortran_path}")"
  C_path_w="$(cygpath.exe -m "${C_path}")"
  CPP_path_w="$(cygpath.exe -m "${CPP_path}")"
  CXX_path_w="$(cygpath.exe -m "${CXX_path}")"
  cmake.exe -G "Unix Makefiles" -Darch="${arch}" -Dprecision="${prec}" ${DAD} \
            -Ddebug="${debug}" -DEXEC_NAME="${starter_exec}" "${dc[@]}" \
            -Dno_python="${no_python}" -Dstatic_link="${static_link}" \
            -DCMAKE_BUILD_TYPE=Release -DCMAKE_Fortran_COMPILER="${Fortran_path_w}" \
            -DCMAKE_C_COMPILER="${C_path_w}" -DCMAKE_CPP_COMPILER="${CPP_path_w}" \
            -DCMAKE_CXX_COMPILER="${CXX_path_w}" .. || return_value=$?
else
  cmake -Darch="${arch}" -Dprecision="${prec}" ${DAD} -Ddebug="${debug}" \
        -DEXEC_NAME="${starter_exec}" -Dstatic_link="${static_link}" \
        -Dno_python="${no_python}" "${dc[@]}" -Dsanitize="${sanitize}" \
        -DCMAKE_Fortran_COMPILER="${Fortran_path}" -DCMAKE_C_COMPILER="${C_path}" \
        -DCMAKE_CPP_COMPILER="${CPP_path}" -DCMAKE_CXX_COMPILER="${CXX_path}" \
        -DUSE_OPEN_READER=${use_openreader} .. || return_value=$?
fi

if (( return_value != 0 ))
then
   echo " " 
   echo " " 
   echo "-- Errors in Cmake found"
   cd ..
   if [[ -d "${build_directory}" ]]
   then
     echo "-- Cleaning ${build_directory} directory"
     rm -rf "./${build_directory}"
   fi
   echo " " 
   exit 1
fi

make -j "${threads}" "${verbose[@]}" || return_value=$?
#ninja -v -j "${threads}" -d explain || return_value=$?

case "${debug}" in
  asan)
    echo " "
    echo "Warning:"
    echo "--------"
    echo "Build was made with debug configuration."
    echo "To enable optimization, add -release flag."
    echo " "
    ;;
  analysis)
    if (( return_value == 0 ))
    then
        pwd
        cd ../../scripts
        python3 ./static_analysis.py starter || return_value=$?
    fi
    ;;
esac



if (( return_value != 0 ))
then
   echo " " 
   echo " " 
   echo "-- Errors in Build found"
   cd ..
   exit 1
fi

cd ..
echo " "

