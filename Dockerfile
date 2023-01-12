FROM osgeo/gdal:ubuntu-full-3.5.2

LABEL NAME="fields2cover" \
      VERSION="1.2.0" \
      DESC="Fields2Cover is a complete coverage path planning package for autonomous robots" \
      MAINTAINER="Gonzalo Mier"


ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /usr/include/new_gdal && \
    cp -r /usr/include/gdal* /usr/include/new_gdal/ && \
    cp /usr/include/ogr* /usr/include/new_gdal/ && \
    cp /usr/include/cpl* /usr/include/new_gdal/ && \
    mv /usr/include/new_gdal/ /usr/include/gdal/

RUN apt-get -y update
RUN apt-get install -y --no-install-recommends apt-utils software-properties-common
RUN apt-get -y update

RUN apt-get install wget && \
      wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /usr/bin/cmake \
      && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
      && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"


RUN apt-get install -y --no-install-recommends ranger vim
RUN apt-get install -y --no-install-recommends \
                    build-essential \
                    ca-certificates \
                    doxygen \
                    g++ \
                    git \
                    libeigen3-dev \
                    libpython3-dev \
                    python3 \
                    python3-pip \
                    python3-matplotlib \
                    python3-pytest \
                    lcov \
                    libboost-dev \
                    libgtest-dev \
                    libtbb-dev \
                    swig \
                    && \
                    apt-get autoclean && \
                    apt-get autoremove && \
                    apt-get clean && \
                    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install gcovr

RUN apt-get install -y libgtest-dev \
    && cd /usr/src/gtest \
    && cmake CMakeLists.txt \
    && make \
    && cp lib/*.a /usr/lib/


COPY . /workspace/fields2cover
RUN rm -rf /workspace/fields2cover/build && mkdir /workspace/fields2cover/build
WORKDIR /workspace/fields2cover/build

RUN cmake -DBUILD_CPP=ON \
          -DBUILD_PYTHON=ON \
          -DBUILD_TUTORIALS=OFF \
          -DBUILD_TESTS=ON \
          -DBUILD_DOC=OFF \
          -DCMAKE_BUILD_TYPE=Release ..
RUN make -j8
RUN make install



