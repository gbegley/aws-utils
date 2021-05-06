

###################################################################################################
# Get stopped ec2 instances and parse/output their attached volume IDS into the VOLUMES variable
###################################################################################################
aws ec2 describe-instances --filter Name=instance-state-name,Values=stopped --query 'Reservations[].Instances[]' | jq '{instances:[.[]]}' > ec2-stopped-instances.json
VOLUMES=`jq -r '[.instances[].BlockDeviceMappings[].Ebs.VolumeId] | join(" ")' ec2-stopped-instances.json`



###################################################################################################
# Get the describe-volumes details, and then correlate these two data sets
###################################################################################################
aws ec2 describe-volumes --volume-ids $VOLUMES > ec2-stopped-volumes.json
jq --slurpfile volumesFile ec2-stopped-volumes.json 'INDEX($volumesFile[].Volumes[]; .VolumeId) as $volumes | .instances[0].BlockDeviceMappings[].Ebs |= . + {volume:$volumes[.VolumeId]}' ec2-stopped-instances.json > ec2-stopped-sized.json



###################################################################################################
# Generate the report in JSON and TSV
###################################################################################################
jq '.instances[] | . as $i | .BlockDeviceMappings[].Ebs.volume | {InstanceId:$i.InstanceId,VolumeId:.VolumeId,SnapshotId:.SnapshotId,name:($i.Tags[]? | select(.Key=="Name").Value?),Size:.Size}' ec2-stopped-sized.json > ec2-stopped-ivsn.json
jq -r '[.InstanceId,.VolumeId,.SnapshotId,.name,.Size] | @tsv' ec2-stopped-ivsn.json > ec2-stopped-volumes-report.tsv






