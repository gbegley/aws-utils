##########################################################
# Describe Instances to text output 
##########################################################

aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Platform,Placement.AvailabilityZone,RootDeviceType,[Tags[?Key==`Name`].Value][0][0],State.Name,LaunchTime]' --output text 


##########################################################
# To Query Instances By Tag Name,Value: 
########################################################## 

aws ec2 describe-instances --filter "Name=tag:Name,Values={SOME_TAG_VALUE}" --query "Reservations[*].Instances[*].[InstanceId,InstanceType,Platform,Placement.AvailabilityZone,RootDeviceType,[Tags[?Key==`Name`].Value][0][0],State.Name,LaunchTime]" --output text 

 

##########################################################
# And to extend the use of this output list, append to the command: 
# print only the ec2 instance ID, then pipe to 
########################################################## 

while (each item) read into variable ec2id, do Echo some output, including the read variable:| awk '{print $2}' | while read ec2id; do echo Instance ID: $ec2id; done 
 

########################################################## 
# List Route 53 Resource Records in a Hosted ZONE 
########################################################## 
 
aws route53 list-resource-record-sets --hosted-zone-id=/hostedzone/{SOME_ID} --query 'ResourceRecordSets[*].[Type,ResourceRecords[0].Value,Name]' --output table 

 

 

########################################################## 
# List all your instances across all regions with the AWS CLI 
# (make sure your account hasn't been hacked for mining bitcoin)
########################################################## 
 
#!/usr/bin/sh 
for r in `aws ec2 describe-regions --output text | cut -f3` 
do 
echo "Instances in region  |$r|" 
#AWS_LS_CMD="aws ec2 describe-instances --region "$r" --filter Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Platform,Placement.AvailabilityZone,RootDeviceType,[Tags[?Key==`Name`].Value][0][0],State.Name,LaunchTime]' --output text" 
#echo $AWS_LS_CMD 
#$AWS_LS_CMD 
done 

 

 
########################################################## 
# Using JQ to Parse AWS EC2 describe-instances, 
# and extract the id, name 'tag', instance type, and 
# ip-address for all running instances: 
########################################################## 

aws ec2 describe-instances --output json --filters '[{"Name":"availability-zone","Values":["us-east-1e"]}]' | jq '{instances: [.Reservations | .[] | .Instances | .[] | select(.State.Name=="running") | {id: .InstanceId, ip: .PrivateIpAddress, type: .InstanceType, name: .Tags[0].Value}]}' 
