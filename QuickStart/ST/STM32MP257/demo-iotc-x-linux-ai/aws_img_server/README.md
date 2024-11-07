# Image Classification System Using AWS

This tutorial outlines how to set up an image classification system using AWS services. The system uses two S3 buckets: one to store images for classification, and another to display classified images as a web page. AWS Lambda automates the image processing, while EventBridge triggers Lambda when new images are uploaded.

---

## **System Overview**

- **S3 Bucket 1**: Stores images for classification.
- **S3 Bucket 2**: Displays classified images on a web page.
- **Lambda Function**: Processes and classifies images using a pre-trained model.
- **EventBridge Rule**: Triggers Lambda on image uploads.
- **CloudWatch**: Monitors Lambda executions.

---

## **Step 1: Set Up Two S3 Buckets**

### **S3 Bucket 1: For Image Storage**

1. **Create S3 Bucket**:
   - Go to the **S3 Console**: [S3 Management Console](https://s3.console.aws.amazon.com/s3/home).
   - Click on "Create bucket".
   - Name it something like `image-classification-input`.
   - Select your region.
   - Disable **Block all public access** (for internal use).
   - Click **Create bucket**.

2. **Upload Images to Bucket**:
   - Upload images manually via the S3 console or programmatically using AWS CLI or SDK (e.g., Boto3).

### **S3 Bucket 2: For Web Display**

1. **Create S3 Bucket for Web Hosting**:
   - Create another bucket (e.g., `image-classification-web`).
   - Disable **Block all public access**.
   - Click **Create bucket**.

2. **Enable Static Website Hosting**:
   - Go to **Properties** → **Static website hosting**.
   - Enable static hosting, set `index.html` as the **Index document**, and save changes.

3. **Set Permissions**:
   - In **Permissions** → **Bucket Policy**, add the following policy:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Sid": "PublicReadGetObject",
           "Effect": "Allow",
           "Principal": "*",
           "Action": "s3:GetObject",
           "Resource": "arn:aws:s3:::image-classification-web/*"
         }
       ]
     }
     ```

---

## **Step 2: Create an AWS Lambda Function for Image Classification**

1. **Create Lambda Function**:
   - Go to the **AWS Lambda Console**: [Lambda Management Console](https://console.aws.amazon.com/lambda/home).
   - Click **Create function**, name it `ImageClassificationLambda`, and configure the execution role to access S3 and CloudWatch Logs.
   - Click **Create function**.

2. **Add Code**:
   - In the **Function code** section, add the following Python code to:
     - Download the image from `image-classification-input`.
     - Classify the image.
     - Upload the results to `image-classification-web`.

   ```python
   import json
   import boto3
   import cv2

   s3 = boto3.client('s3')

   def lambda_handler(event, context):
       bucket_name = event['Records'][0]['s3']['bucket']['name']
       object_key = event['Records'][0]['s3']['object']['key']
       
       download_path = f'/tmp/{object_key}'
       s3.download_file(bucket_name, object_key, download_path)

       image = cv2.imread(download_path)
       
       # (Placeholder) Process image through classification model
       label = "cat"
       confidence = 98.5

       html_content = f"<html><body><h2>Classification: {label}</h2><p>Confidence: {confidence}%</p><img src='https://{bucket_name}.s3.amazonaws.com/{object_key}' /></body></html>"

       result_key = object_key.replace('.jpg', '.html')
       s3.put_object(Bucket='image-classification-web', Key=result_key, Body=html_content, ContentType='text/html')

       return {
           'statusCode': 200,
           'body': json.dumps('Image processed and uploaded successfully!')
       }
