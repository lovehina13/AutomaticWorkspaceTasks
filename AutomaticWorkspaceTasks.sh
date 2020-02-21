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
    if [ ! -d ${PROJECT_BUILD_DIR} ]; then mkdir -p ${PROJECT_BUILD_DIR}; fi
    if [ ! -d ${PROJECT_INSTALL_DIR} ]; then mkdir -p ${PROJECT_INSTALL_DIR}; fi

    # Clean
    cd ${PROJECT_SOURCE_DIR}
    git clean -fx -d
    git reset --hard
    git gc --aggressive
    git fetch --all --prune
    git pull --all

    # Compile and install
    PLATFORM="linux"
    ARCHITECTURE="x64"
    for C_COMPILER in gcc clang
    do

        if [ ${C_COMPILER} == "gcc" ]; then CXX_COMPILER="g++"; CXX_FLAGS="-pedantic -Wall -Wextra -Wconversion -Wsign-conversion -Wold-style-cast"; fi
        if [ ${C_COMPILER} == "clang" ]; then CXX_COMPILER="clang++"; CXX_FLAGS="-Weverything"; fi

        for BUILD in debug release
        do

            TARGET="${PLATFORM}-${C_COMPILER}-${ARCHITECTURE}"
            TARGET_BUILD_DIR="${PROJECT_BUILD_DIR}/${TARGET}/${BUILD}"
            TARGET_INSTALL_DIR="${PROJECT_INSTALL_DIR}/${TARGET}/${BUILD}"

            if [ ! -d ${TARGET_BUILD_DIR} ]; then mkdir -p ${TARGET_BUILD_DIR}; fi
            if [ ! -d ${TARGET_INSTALL_DIR} ]; then mkdir -p ${TARGET_INSTALL_DIR}; fi

            cd ${TARGET_BUILD_DIR}
            cmake ${PROJECT_SOURCE_DIR} -DCMAKE_INSTALL_PREFIX=${TARGET_INSTALL_DIR} -DCMAKE_C_COMPILER=${C_COMPILER} -DCMAKE_CXX_COMPILER=${CXX_COMPILER} -DCMAKE_CXX_FLAGS="${CXX_FLAGS}"
            # cmake ${PROJECT_SOURCE_DIR} -G "Eclipse CDT4 - Unix Makefiles" -DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE -DCMAKE_ECLIPSE_VERSION=4.12 -DCMAKE_ECLIPSE_MAKE_ARGUMENTS=-j8 -DCMAKE_INSTALL_PREFIX=${TARGET_INSTALL_DIR} -DCMAKE_C_COMPILER=${C_COMPILER} -DCMAKE_CXX_COMPILER=${CXX_COMPILER} -DCMAKE_CXX_FLAGS="${CXX_FLAGS}"
            cmake --build . --config ${BUILD} --target install

        done

    done

done
