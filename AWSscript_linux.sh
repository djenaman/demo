#!/bin/sh
awsProjectARN="arn:aws:devicefarm:us-west-2:409629073475:project:cdf9a723-8fe3-433e-90f2-e02cb9686ee5"
awsDevicePoolARN="arn:aws:devicefarm:us-west-2:409629073475:devicepool:cdf9a723-8fe3-433e-90f2-e02cb9686ee5/1c366a73-ff92-4b0d-8d40-63260023d3b9"
awsTestSpecARN8=""
awsTestRunName="testAWSCLIRUN"
awsTestType="APPIUM_JAVA_TESTNG"
bamboobuildworkingdirectory="/home/ubuntu/Downloads/"
apkLocation="/home/ubuntu/Downloads/app.apk"
testPackageLocation="/home/ubuntu/myfiles/prucea-qaautomation/prudentialAutomation/target/prudentialAutomationArchive.zip"
echo "Script is uploading the APK file to AWS.... "
awsCreateAPKUploadJSONResponse=`aws devicefarm create-upload --project-arn $awsProjectARN --name app.apk --type ANDROID_APP`
awsAPKARN=`echo "$awsCreateAPKUploadJSONResponse"|jq -r '.upload.arn'`
echo "APKARN response = $awsCreateAPKUploadJSONResponse"
awsAPKUploadSignURL=`echo "$awsCreateAPKUploadJSONResponse"|jq -r '.upload.url'`
`curl -T $apkLocation "$awsAPKUploadSignURL"`
echo "Script is uploading the maven application zip file to AWS"
awsCreateTestPackageUploadJSONResponse=`aws devicefarm create-upload --project-arn $awsProjectARN --name prudentialAutomationArchive.zip --type APPIUM_JAVA_TESTNG_TEST_PACKAGE`
echo "TESTPACK response = $awsCreateTestPackageUploadJSONResponse"
awsTestPackageUploadSignURL=`echo "$awsCreateTestPackageUploadJSONResponse"|jq -r '.upload.url'`
awsTestPackageARN=`echo "$awsCreateTestPackageUploadJSONResponse"|jq -r '.upload.arn'`
`curl -T $testPackageLocation "$awsTestPackageUploadSignURL"`
echo "Script is scheduling the run with above uploaded files and configuration"
awsScheduleRunJSONResponse=`aws devicefarm schedule-run --project-arn $awsProjectARN --app-arn $awsAPKARN --device-pool-arn $awsDevicePoolARN --name $awsTestRunName --test type=$awsTestType,testPackageArn=$awsTestPackageARN`
awsScheduleRunARN=`echo "$awsScheduleRunJSONResponse"|jq -r '.run.arn'`
