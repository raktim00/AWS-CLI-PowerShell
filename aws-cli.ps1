$key_name = "MyWebKey"
$sg_name = "WebSG"
$image_id = "ami-0e306788ff2473ccb"
$instance_type = "t2.micro"
$instance_count = 1
$subnet_id = "subnet-6dfdc705"
$az = "ap-south-1a"
$volume_size = 1
$volume_type = "gp2"


aws ec2 create-key-pair --key-name "$key_name" --query 'KeyMaterial' --output text | out-file -encoding ascii -filepath "$key_name.pem"

$sg_id = aws ec2 create-security-group --group-name "$sg_name" --description "Security group allowing SSH" |  jq ".GroupId"

aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 22 --cidr 0.0.0.0/0

$instance_id = aws ec2 run-instances --image-id "$image_id" --instance-type "$instance_type" --count "$instance_count"  --subnet-id "$subnet_id" --security-group-ids "$sg_id" --key-name "$key_name" | jq ".Instances[0].InstanceId"

$volume_id = aws ec2 create-volume --availability-zone "$az" --size "$volume_size" --volume-type "$volume_type" | jq ".VolumeId"

Start-Sleep 15

aws ec2 attach-volume --volume-id "$volume_id" --instance-id "$instance_id" --device /dev/xvdh
