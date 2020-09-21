if [ -z $1] || [ -z $2 ]
then
    echo -e "\nneed user and version params"
    echo -e "ex: ./build docker_user 1.0\n"
else
    docker build -t $1/vote:$2 vote

    docker push $1/vote:$2

    docker build -t $1/result:$2 result

    docker push $1/result:$2

    docker build -t $1/worker:$2 worker

    docker push $1/worker:$2
fi
