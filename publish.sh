while getopts ":s:p:?:h" arg; do
  case $arg in
    s) BUCKET_SUFFIX=$OPTARG;;
    p) KEY_PREFIX=$OPTARG;;
    ?|h) SHOW_HELP=Yes;;
  esac
done

if [ $SHOW_HELP ] || [ -z $BUCKET_SUFFIX ] || [ -z $KEY_PREFIX ]; then
  echo "Usage: $0 -s <BUCKET SUFFIX> -p <KEY PREFIX>"
  echo "Publish a SAR application to every region."
  echo "Where"
  echo "  <BUCKET SUFFIX> - a suffix to append to the region name"
  echo "  <KEY PREFIX> - a prefix to prepend to the location of the SAM template."
  echo ""
  echo "NOTE: This script assumes that you have buckets named <region>.<BUCKET SUFFIX> in every region you want to publish your SAR app."
  exit -1;
fi;

if [ $BUCKET_SUFFIX != */ ]; then
    BUCKET_SUFFIX="$BUCKET_SUFFIX/"
fi;
if [ $KEY_PREFIX != */ ]; then
    KEY_PREFIX="$KEY_PREFIX/"
fi;

for i in $(aws ec2 describe-regions --query "Regions[].[RegionName]" --output text); 
do 
    if [[ "$i" == "us-east-1"  ]]; then 
        continue; 
    fi;  
    echo "{ \"RegionName\": \"$i\" }" | j2 -f json -o sam.template sam.template.j2
    aws s3 cp sam.template s3://$i.$BUCKET_SUFFIX${KEY_PREFIX}convert-to-bluegreen/sam.template --acl public-read
    aws s3 cp README.md s3://$i.$BUCKET_SUFFIX${KEY_PREFIX}convert-to-bluegreen/README.md --acl public-read
    aws serverlessrepo create-application \
    --region $i \
    --name ConvertToBlueGreen \
    --semantic-version 1.0.0 \
    --author "Andy Hopper" \
    --description "This SAR app is designed for use in CloudFormation as a Custom Resource to convert an in-place deployment group to a blue/green group." \
    --home-page-url "https://github.com/andyhopp/convert-to-bluegreen" \
    --spdx-license-id "MIT" \
    --labels "CodeDeploy" "CloudFormation" \
    --readme-url "https://s3.amazonaws.com/$i.$BUCKET_SUFFIX${KEY_PREFIX}convert-to-bluegreen/README.md" \
    --template-url "https://s3.amazonaws.com/$i.$BUCKET_SUFFIX${KEY_PREFIX}convert-to-bluegreen/sam.template"
done
