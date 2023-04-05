WORKSPACE_DIR=$(readlink -f $0 | xargs dirname)
WORKSPACE_SOURCE_DIR="${WORKSPACE_DIR}/source"
WORKSPACE_BUILD_DIR="${WORKSPACE_DIR}/build"
WORKSPACE_INSTALL_DIR="${WORKSPACE_DIR}/install"
if [ ! -d ${WORKSPACE_SOURCE_DIR} ]; then mkdir -p ${WORKSPACE_SOURCE_DIR}; fi
if [ ! -d ${WORKSPACE_BUILD_DIR} ]; then mkdir -p ${WORKSPACE_BUILD_DIR}; fi
if [ ! -d ${WORKSPACE_INSTALL_DIR} ]; then mkdir -p ${WORKSPACE_INSTALL_DIR}; fi
for PROJECT in ProjetCMake
do
    PROJECT_SOURCE_DIR="${WORKSPACE_SOURCE_DIR}/${PROJECT}"
    PROJECT_BUILD_DIR="${WORKSPACE_BUILD_DIR}/${PROJECT}"
    PROJECT_INSTALL_DIR="${WORKSPACE_INSTALL_DIR}/${PROJECT}"
    if [ ! -d ${PROJECT_SOURCE_DIR} ]; then git clone https://github.com/lovehina13/${PROJECT} ${PROJECT_SOURCE_DIR}; fi
    # Clean
    cd ${PROJECT_SOURCE_DIR}
#   git reset --hard
#   git clean -fx -d
    git fetch --all --prune
    git pull --all
#   git reflog expire --expire=now --expire-unreachable=now --all
#   git gc --aggressive --prune=now
    if [ -f "${PROJECT_SOURCE_DIR}/CMakeLists.txt" ]
    then
        # Compile and install
        PLATFORM="linux"
        ARCHITECTURE="x64"
        for C_COMPILER in gcc clang
        do
            if [ ${C_COMPILER} == "gcc" ]; then CXX_COMPILER="g++"; CXX_FLAGS="-pedantic -Wall -Wextra -Wconversion -Wsign-conversion -Wold-style-cast"; fi
            if [ ${C_COMPILER} == "clang" ]; then CXX_COMPILER="clang++"; CXX_FLAGS="-Weverything -Wno-padded -Wno-c++98-compat"; fi
            for BUILD in debug release
            do
                TARGET="${PLATFORM}-${C_COMPILER}-${ARCHITECTURE}"
                TARGET_BUILD_DIR="${PROJECT_BUILD_DIR}/${TARGET}/${BUILD}"
                TARGET_INSTALL_DIR="${PROJECT_INSTALL_DIR}/${TARGET}/${BUILD}"
                cmake -S ${PROJECT_SOURCE_DIR} -B ${TARGET_BUILD_DIR} -G "Ninja" -DCMAKE_BUILD_TYPE=${BUILD} -DCMAKE_C_COMPILER=${C_COMPILER} -DCMAKE_CXX_COMPILER=${CXX_COMPILER} -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" -DCMAKE_INSTALL_PREFIX=${TARGET_INSTALL_DIR}
                cmake --build ${TARGET_BUILD_DIR} --target install --parallel
            done
        done
    fi
done
