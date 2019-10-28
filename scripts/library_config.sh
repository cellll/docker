for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   
    
    case "$KEY" in
            CT_ID) CT_ID=${VALUE} ;;
            PW)    PW=${VALUE} ;;     
            SSH)   SSH=${VALUE} ;;     
            DIGITS) DIGITS=${VALUE} ;;
            JUPYTER) JUPYTER=${VALUE} ;;
            TENSORBOARD) TENSORBOARD=${VALUE} ;;
            *)   
    esac  
done

if [ -n "$SSH" ]
then
    SSH_CONFIG_FILE='/etc/ssh/sshd_config'

    echo -e "$PW\n$PW" | docker exec -i $CT_ID passwd
    docker exec $CT_ID sed -i "s/Port 22/Port $SSH/g" /etc/ssh/sshd_config
    docker exec $CT_ID sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
    docker exec $CT_ID /etc/init.d/ssh restart
fi

if [ -n "$DIGITS" ]
then

    DIGITS_CONFIG_PATH='/root/DIGITS-6.1.0/digits/'
    DIGITS_CONFIG_FILE='__main__.py'

    docker exec $CT_ID sed -i "s/5000/$DIGITS/g" $DIGITS_CONFIG_PATH$DIGITS_CONFIG_FILE
fi

if [ -n "$JUPYTER" ]
then
    JUPYTER_CONFIG_FILE='/root/.jupyter/jupyter_notebook_config.py'
    
    docker exec $CT_ID sed -i "s/#c.NotebookApp.port = 8888/c.NotebookApp.port = $JUPYTER/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/#c.NotebookApp.open_browser = True/c.NotebookApp.open_browser = False/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/#c.NotebookApp.allow_root = False/c.NotebookApp.allow_root = True/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/#c.NotebookApp.password = ''/from notebook.auth import passwd; \nc.NotebookApp.password = passwd('$PW')/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/c.NotebookApp.password = passwd('1')/c.NotebookApp.password = passwd('$PW')/g" $JUPYTER_CONFIG_FILE
    docker exec $CT_ID sed -i "s/#c.NotebookApp.password = u''/from notebook.auth import passwd; \nc.NotebookApp.password = passwd('$PW')/g" $JUPYTER_CONFIG_FILE
    

fi

if [ -n "$TENSORBOARD" ]
then
    TENSORBOARD_CONFIG_PATH='/usr/local/lib/python3.5/dist-packages/tensorboard/plugins/core/'
    ### python3.6
    TENSORBOARD_CONFIG_FILE='core_plugin.py'
    docker exec $CT_ID sed -i "s/6006/$TENSORBOARD/g" $TENSORBOARD_CONFIG_PATH$TENSORBOARD_CONFIG_FILE
    
    ###python2.7
    TENSORBOARD_CONFIG_PATH='/usr/local/lib/python2.7/dist-packages/tensorboard/plugins/core/'
    docker exec $CT_ID sed -i "s/6006/$TENSORBOARD/g" $TENSORBOARD_CONFIG_PATH$TENSORBOARD_CONFIG_FILE
fi




