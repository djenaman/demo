#!/bin/sh
awsProjectARN="arn:aws:devicefarm:us-west-2:249933210673:project:3ecc7790-408c-47ae-844f-fd1f0afd6a1d"
awsDevicePoolARN="arn:aws:devicefarm:us-west-2::devicepool:082d10e5-d7d7-48a5-ba5c-b33d66efa1f5"
awsTestRunName="testAWSCLIRUN_TestWorkaround"
awsTestType="APPIUM_JAVA_TESTNG"
apkLocation="/home/dipak/xml-data/build-dir/PRUD-PCA-JOB1/Resources/app-release.apk"
testSpecFileLocation="/home/dipak/xml-data/build-dir/PRUD-PCA-JOB1/Configuration/Testspec_LatestWO.yml"
testPackageLocation="/home/dipak/xml-data/build-dir/PRUD-PCA-JOB1/target/prudentialAutomationArchive.zip"
echo "Script is uploading the customized testspec yaml file to AWS"
awsCreateTestSpecUploadJSONResponse=`aws devicefarm create-upload --name WorkaroundTestSpec.yml --type APPIUM_JAVA_TESTNG_TEST_SPEC --project-arn $awsProjectARN`
echo "TestSpec create-upload JSON response = $awsCreateTestSpecUploadJSONResponse"
awsTestSpecUploadSignURL=`echo "$awsCreateTestSpecUploadJSONResponse"|jq -r '.upload.url'`
awsTestSpeceARN=`echo "$awsCreateTestSpecUploadJSONResponse"|jq -r '.upload.arn'`
`curl -T $testSpecFileLocation "$awsTestSpecUploadSignURL"`
echo "Waiting for the TestSpec upload to be success..."
k=0
while [ $k -le 160 ]
  do
	echo "aws devicefarm get-upload --arn $awsTestSpeceARN"
    awsGetTestSpecUpload=`aws devicefarm get-upload --arn $awsTestSpeceARN`
    awsTestSpecStatus=`echo "$awsGetTestSpecUpload"|jq -r '.upload.status'`
    if [ $awsTestSpecStatus = "SUCCEEDED" ]
    then
	 echo "TestSpec upload success..."
	 break
    fi
  k=$(($k+1))
  sleep 1
 done
if [ $k -ge 160 ]
then
     echo "TestSpec upload is not successful after waiting for 160 second...Cant proceed with AWS run..quiting the run...."
     exit 1
fi
echo "Script is uploading the APK file to AWS.... "
awsCreateAPKUploadJSONResponse=`aws devicefarm create-upload --project-arn $awsProjectARN --name app.apk --type ANDROID_APP`
awsAPKARN=`echo "$awsCreateAPKUploadJSONResponse"|jq -r '.upload.arn'`
echo "APK upload JSON response = $awsCreateAPKUploadJSONResponse"
awsAPKUploadSignURL=`echo "$awsCreateAPKUploadJSONResponse"|jq -r '.upload.url'`
`curl -T $apkLocation "$awsAPKUploadSignURL"`
echo "Waiting for the APK upload to be success..."
i=0
while [ $i -le 160 ]
  do
    awsGetAPKUpload=`aws devicefarm get-upload --arn $awsAPKARN`
    awsAPKUploadStatus=`echo "$awsGetAPKUpload"|jq -r '.upload.status'`
    if [ $awsAPKUploadStatus = "SUCCEEDED" ]
    then
	 echo "APK upload success..."
	 break
    fi
  i=$(($i+1))
  sleep 1
 done
if [ $i -ge 160 ]
then
     echo "APK upload is not successful after waiting for 160 second...Cant proceed with AWS run..quiting the run...."
     exit 1
fi
echo "Script is uploading the maven application zip file to AWS"
awsCreateTestPackageUploadJSONResponse=`aws devicefarm create-upload --project-arn $awsProjectARN --name prudentialAutomationArchive.zip --type APPIUM_JAVA_TESTNG_TEST_PACKAGE`
echo "TESTPACK response = $awsCreateTestPackageUploadJSONResponse"
awsTestPackageUploadSignURL=`echo "$awsCreateTestPackageUploadJSONResponse"|jq -r '.upload.url'`
awsTestPackageARN=`echo "$awsCreateTestPackageUploadJSONResponse"|jq -r '.upload.arn'`
`curl -T $testPackageLocation "$awsTestPackageUploadSignURL"`
echo "Waiting for the Testpackage upload to be success..."
j=0
while [ $j -le 160 ]
  do
    awsGetTestPackUpload=`aws devicefarm get-upload --arn $awsTestPackageARN`
    awsTestPackStatus=`echo "$awsGetTestPackUpload"|jq -r '.upload.status'`
    if [ $awsTestPackStatus = "SUCCEEDED" ]
    then
	 echo "Testpackage upload success..."
	 break
    fi
  j=$(($j+1))
  sleep 1
 done
if [ $j -ge 160 ]
then
     echo "Testpackage upload is not successful after waiting for 160 second...Cant proceed with AWS run..quiting the run...."
     exit 1
fi
echo "Script is scheduling the run with above uploaded files and configuration"
echo "Schedule run command--> aws devicefarm schedule-run --project-arn $awsProjectARN --app-arn $awsAPKARN --device-pool-arn $awsDevicePoolARN --name $awsTestRunName --test type=$awsTestType","testPackageArn=$awsTestPackageARN","testSpecArn=$awsTestSpeceARN"
awsScheduleRunJSONResponse=`aws devicefarm schedule-run --project-arn $awsProjectARN --app-arn $awsAPKARN --device-pool-arn $awsDevicePoolARN --name $awsTestRunName --test type=$awsTestType","testPackageArn=$awsTestPackageARN","testSpecArn=$awsTestSpeceARN`
awsScheduleRunARN=`echo "$awsScheduleRunJSONResponse"|jq -r '.run.arn'`
