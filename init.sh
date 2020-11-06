
#!/bin/bash
while getopts ":o:f:p:" opt; do
    case $opt in
        o) arg1="$OPTARG"
        ;;
        f) arg2="$OPTARG"
        ;;
        p) arg3="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&3
        ;;
    esac
done


filePath() {
    cp -a "$arg2" "./serviceaccount.json"
}

val=$(echo "$arg1" | tr '[:lower:]' '[:upper:]')
if [[ "$val" == "CREATE" ]] && ![ -z "$arg2" ] && ![ -z "$arg3" ];
then
    filePath
    cd terraform
    terraform init
    terraform plan
    terraform apply
    gcloud container clusters get-credentials gke-example --region us-central1-a
    docker login -u _json_key -p "$(cat ../serviceaccount.json)" https://gcr.io
    docker build -t gcr.io/"$arg3"/mypythonapp:test ../.
    docker push us.gcr.io/"$arg3"/mypythonapp:test
    kubectl apply -f ../k8s.yml

    echo "This is create"
elif [[ "$val" == "DESTROY" ]] && ![ -z "$arg2" ] && ![ -z "$arg3" ];
then
    filePath
    cd terraform
    terraform init
    terraform plan
    terraform destroy
    echo " This is destroy "
elif [[ "$val" == "OUTPUT" ]] && ![ -z "$arg2" ] && ![ -z "$arg3" ];
then
    echo " This is output "
else
    echo "First argument -o to choose between options CREATE, DESTROY, OUTPUT"
    echo "then second argument -p for path of json file"
    echo "then thid argument -p for gcloud project-id"
fi

