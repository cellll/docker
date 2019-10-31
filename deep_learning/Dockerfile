FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 

# INSTALL base PKGS/LIBS 
ENV LANG en_US.UTF-8 
ENV LANGUAGE en_US:en 
ENV LC_ALL en_US.UTF-8 
RUN rm -rf  /var/lib/apt/lists/*  && apt-get update && apt-get install locales  
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen 
RUN apt-get install -y build-essential cmake curl git wget openjdk-8-jdk python3-dev swig python3 python3-pip libcurl3-dev libfreetype6-dev libhdf5-serial-dev libjpeg-dev libpng12-dev libzmq3-dev pkg-config rsync software-properties-common unzip zip zlib1g-dev vim libffi-dev locales openssh-server openssh-client pwgen  

RUN pip3 install --upgrade setuptools pip && rm -rf /usr/bin/pip3 && ln -s /usr/local/bin/pip3 /usr/bin/pip3 

# INSTALL caffe PKGS/LIBS 
ENV CAFFE_ROOT /root/caffe 
ENV PYCAFFE_ROOT /root/caffe/python
ENV PYTHONPATH $PYTHONPATH:$PYCAFFE_ROOT 

RUN apt-get install -y --no-install-recommends gfortran libatlas-base-dev libboost-filesystem-dev libboost-python-dev libboost-system-dev libboost-thread-dev libgflags-dev libgoogle-glog-dev libleveldb-dev liblmdb-dev libopencv-dev libsnappy-dev python-all-dev python-dev python-h5py python-matplotlib python-numpy python-opencv python-pil python-pip python-pydot python-skimage python-sklearn libboost-all-dev libprotobuf-dev  python-tk 
# RUN apt-get install -y --no-install-recommends gfortran libatlas-base-dev libboost-filesystem-dev libboost-python-dev libboost-system-dev libboost-thread-dev libgflags-dev libgoogle-glog-dev libleveldb-dev liblmdb-dev libopencv-dev libsnappy-dev python-all-dev python-dev python-h5py python-matplotlib python-numpy python-opencv python-pil python-pip python-pydot python-scipy python-skimage python-sklearn libboost-all-dev libprotobuf-dev  python-tk 
RUN pip2 install --upgrade setuptools pip

# INSTALL PROTOBUF
WORKDIR /root
RUN wget https://github.com/protocolbuffers/protobuf/archive/v3.2.0.tar.gz \
    && tar -zxvf  v3.2.0.tar.gz \
    && rm -rf v3.2.0.tar.gz
    
WORKDIR /root/protobuf-3.2.0
RUN apt-get install -y autoconf automake libtool curl make g++ unzip \
    && ./autogen.sh \
    && ./configure \
    && make -j32 \
    && make install -j32 \
    && ldconfig

# INSTALL CAFFE
ENV CAFFE_ROOT /root/caffe
RUN git clone https://github.com/NVIDIA/caffe.git $CAFFE_ROOT -b 'caffe-0.15'
WORKDIR /root/caffe

RUN cd $CAFFE_ROOT \
    && pip2 install -r $CAFFE_ROOT/python/requirements.txt \
    && rm -rf Makefile*

ADD caffe_Makefile $CAFFE_ROOT/Makefile
ADD caffe_Makefile.config $CAFFE_ROOT/Makefile.config

RUN cd $CAFFE_ROOT \
    && make -j32 \
    && make pycaffe -j32 \
    && echo "export CAFFE_ROOT=/root/caffe" >> /etc/profile \
    && echo "export PYCAFFE_ROOT=/root/caffe/python" >> /etc/profile

# # INSTALL digits PKGS/LIBS 
WORKDIR  /root  
RUN wget https://github.com/NVIDIA/DIGITS/archive/v6.1.0.tar.gz \
    && tar -zxvf v6.1.0.tar.gz \
    && rm -rf v6.1.0.tar.gz

RUN cd /root/DIGITS-6.1.0 \
    && pip2 install -r requirements.txt \
    && apt-get install -y --no-install-recommends graphviz python-flask python-flaskext.wtf python-gevent \
    && pip2 install -e . \
    && pip2 install plugins/data/imageGradients plugins/view/imageGradients plugins/data/gan plugins/view/gan plugins/data/textClassification plugins/view/textClassification

# GET BASIC DATASET
RUN mkdir -p /root/dataset \
    && python2 -m digits.download_data mnist /root/dataset/mnist
ADD dbpedia_csv.tar.gz /root/dataset/


# INSTALL TORCH
RUN git clone https://github.com/torch/distro.git /root/torch --recursive
RUN apt-get install -y --no-install-recommends libreadline-dev sudo 

ENV TORCH_NVCC_FLAGS -D__CUDA_NO_HALF_OPERATORS__
ENV TORCH_HOME /root/torch/install/bin
ENV PATH $PATH:$TORCH_HOME

RUN cd /root/torch \
    && ./install-deps \
    && ./install.sh -b \
    && echo "export TORCH_HOME=/root/torch/install/bin" >> /etc/profile 
    
RUN luarocks install tds
RUN luarocks install "https://raw.github.com/deepmind/torch-hdf5/master/hdf5-0-0.rockspec"
RUN luarocks install "https://raw.github.com/Neopallium/lua-pb/master/lua-pb-scm-0.rockspec"
RUN luarocks install lightningmdb 0.9.18.1-1 LMDB_INCDIR=/usr/include LMDB_LIBDIR=/usr/lib/x86_64-linux-gnu
RUN luarocks install "https://raw.githubusercontent.com/ngimel/nccl.torch/master/nccl-scm-1.rockspec"
RUN luarocks install dpnn

# INSTALL pytorch PKGS/LIBS 
RUN pip3 install torch torchvision  
RUN pip2 install torch torchvision 

# INSTALL TENSORFLOW 
RUN pip3 install tensorflow-gpu==1.12.0  
RUN pip2 install tensorflow-gpu==1.12.0

# INSTALL keras PKGS/LIBS 
RUN pip3 install keras==2.2.4 h5py  
RUN pip2 install keras==2.2.4 h5py

# INSTALL tensorflow PKGS/LIBS 
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH 
ENV NCCL_VERSION 2.3.5-2+cuda9.0 

RUN pip3 install setuptools jupyter Pillow opencv-python h5py keras_applications keras_preprocessing matplotlib mock numpy scipy sklearn pandas enum34  
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH\nexport LANG=en_US.UTF-8\nexport LANGUAGE=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8" >> /etc/profile 

RUN apt-get install -y --allow-downgrades --allow-change-held-packages libnccl2=${NCCL_VERSION} libnccl-dev=${NCCL_VERSION} 

# JUPYTER CONFIG
RUN pip install jupyter notebook \
    && jupyter notebook --generate-config

RUN sed -i -e 's/"python",/"python3",/g' /usr/local/share/jupyter/kernels/python3/kernel.json \
    && sed -i "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/g" /root/.jupyter/jupyter_notebook_config.py \ 
    && sed -i "s/#c.NotebookApp.open_browser = True/c.NotebookApp.open_browser = False/g" /root/.jupyter/jupyter_notebook_config.py \
    && sed -i "s/#c.NotebookApp.allow_root = False/c.NotebookApp.allow_root = True/g" /root/.jupyter/jupyter_notebook_config.py \ 
    && sed -i "s/#    from notebook.auth import passwd; passwd()/from notebook.auth import passwd/g" /root/.jupyter/jupyter_notebook_config.py \ 
    && sed -i "s/#c.NotebookApp.password = u''/c.NotebookApp.password = passwd('1')/g" /root/.jupyter/jupyter_notebook_config.py \ 
    && sed -i "s/#c.NotebookApp.password = ''/c.NotebookApp.password = passwd('1')/g" /root/.jupyter/jupyter_notebook_config.py

# SSH CONFIG
RUN sed -i -e "s/PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

# INSTALL OPENMPI
RUN mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.0.tar.gz && \
    tar zxf openmpi-4.0.0.tar.gz && \
    cd openmpi-4.0.0 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j32 all && \
    make install && \
    ldconfig && \
    rm -rf /tmp/openmpi

# INSTALL HOROVOD 
RUN ldconfig /usr/local/cuda-9.0/targets/x86_64-linux/lib/stubs && \
    HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 \
         pip3 install --no-cache-dir horovod==0.16.1 && \
    HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 \
         pip2 install --no-cache-dir horovod==0.16.1 && \
    ldconfig
    
# Install OpenSSH for MPI to communicate between containers
RUN mkdir -p /var/run/sshd

# Allow OpenSSH to talk to containers without asking for confirmation
RUN mkdir -p /var/run/sshd && \ 
    cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config

WORKDIR / 
# Download horovod examples
RUN apt-get install -y --no-install-recommends subversion && \
    svn checkout https://github.com/horovod/horovod/trunk/examples && \
    rm -rf /examples/.svn && \
    mv /examples /horovod_examples

# MPIRUN CONFIG
RUN mv /usr/local/bin/mpirun /usr/local/bin/mpirun.real  && \
    echo '#!/bin/bash' > /usr/local/bin/mpirun  && \
    echo 'mpirun.real --allow-run-as-root "$@"' >> /usr/local/bin/mpirun   && \
    chmod a+x /usr/local/bin/mpirun  && \
    echo "hwloc_base_binding_policy = none" >> /usr/local/etc/openmpi-mca-params.conf  && \
    echo "rmaps_base_mapping_policy = slot" >> /usr/local/etc/openmpi-mca-params.conf  && \
    echo "btl_tcp_if_exclude = lo,docker0" >> /usr/local/etc/openmpi-mca-params.conf   && \
    echo NCCL_DEBUG=INFO >> /etc/nccl.conf 
    
# NUMPY UPGRADE
RUN pip2 install numpy==1.16.0 --upgrade
RUN pip3 install numpy==1.16.0 --upgrade

ADD keras_mnist_advanced.py /horovod_examples/


# INFINIBAND
# Set MOFED directory, image and working directory
ENV MOFED_DIR MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64
ENV MOFED_SITE_PLACE MLNX_OFED-4.5-1.0.1.0
ENV MOFED_IMAGE MLNX_OFED_LINUX-4.5-1.0.1.0-ubuntu16.04-x86_64.tgz

RUN apt-get install -y dpatch libmnl0 ethtool bison flex kmod lsof python-libxml2 libnl-route-3-200 libnl-3-200 chrpath tk tcl pciutils

# Download and install Mellanox OFED 4.5.1.0.1 for Ubuntu 16.04
RUN wget http://content.mellanox.com/ofed/${MOFED_SITE_PLACE}/${MOFED_IMAGE}
RUN tar -xzvf ${MOFED_IMAGE}
RUN ${MOFED_DIR}/mlnxofedinstall --user-space-only --without-fw-update --all -q --force

WORKDIR /root







