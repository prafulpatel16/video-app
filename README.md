## Video Upload and Play Application - AWS Serverless Deployment Guide

This is a serverless video upload and play application.

python --version

# Step 2: Create the Automation Script
Create a Python script to generate the folder structure and files.

create_project_structure.py

import os

# Define the directory structure
project_structure = {
    "video-app": {
        "frontend": {
            "index.html": "<!DOCTYPE html>\n<html>\n<head>\n<title>Video App</title>\n</head>\n<body>\n<h1>Video App</h1>\n</body>\n</html>",
            "app.js": "// Placeholder JavaScript file for frontend functionality.",
            "style.css": "/* Placeholder CSS file for frontend styling. */",
        },
        "backend": {
            "upload_handler.py": "# Placeholder for upload handler code.",
            "fetch_handler.py": "# Placeholder for fetch handler code.",
            "requirements.txt": "# Add Python dependencies here, e.g., boto3",
        },
        "infrastructure": {
            "main.tf": "# Terraform main configuration file.",
            "variables.tf": "# Terraform variables file.",
            "outputs.tf": "# Terraform outputs file.",
        },
        "README.md": "# Video App\n\nThis is a serverless video upload and play application.",
    }
}

def create_structure(base_path, structure):
    for name, content in structure.items():
        path = os.path.join(base_path, name)
        if isinstance(content, dict):
            os.makedirs(path, exist_ok=True)
            create_structure(path, content)
        else:
            with open(path, 'w') as file:
                file.write(content)

if __name__ == "__main__":
    base_path = os.getcwd()  # Use the current working directory
    create_structure(base_path, project_structure)
    print(f"Project structure created at {os.path.join(base_path, 'video-app')}")

# Step 3: Run the Script

Open a terminal in VS Code.
Save the script as create_project_structure.py in your desired folder.
Run the script:

# python create_project_structure.py

## Phase 1: Project Planning and Skeleton Setup

## 1. Define Components
 # Frontend: HTML/CSS for UI integration into your portfolio.
 # Backend: AWS Lambda for API endpoints.
 # Storage: Amazon S3 for storing videos.
 # Streaming: Amazon CloudFront for video delivery.
 # Database: Amazon DynamoDB for metadata storage.
 # Authentication (Optional): AWS Cognito for user access control.

# 2. Project Structure
Create a directory structure:

video-app/
│
├── frontend/
│   ├── index.html
│   ├── app.js
│   ├── style.css
│
├── backend/
│   ├── upload_handler.py
│   ├── fetch_handler.py
│   ├── requirements.txt
│
├── infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│
└── README.md

## Phase 2: Frontend Implementation

# 1. Create index.html
This will be the main HTML page for the application.

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Video Upload and Play</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Video Upload & Play</h1>
    <form id="uploadForm">
        <input type="file" id="videoFile" accept="video/*" required>
        <button type="submit">Upload Video</button>
    </form>
    <div id="videoList"></div>
    <script src="app.js"></script>
</body>
</html>


# 2. Create app.js
Write JavaScript to interact with the backend API.

document.getElementById("uploadForm").onsubmit = async function (e) {
    e.preventDefault();
    const fileInput = document.getElementById("videoFile");
    const file = fileInput.files[0];
    const formData = new FormData();
    formData.append("file", file);

    const response = await fetch("YOUR_API_GATEWAY_UPLOAD_URL", {
        method: "POST",
        body: formData,
    });

    if (response.ok) {
        alert("Video uploaded successfully!");
        fileInput.value = "";
        fetchVideos();
    } else {
        alert("Error uploading video.");
    }
};

async function fetchVideos() {
    const response = await fetch("YOUR_API_GATEWAY_FETCH_URL");
    const videos = await response.json();

    const videoList = document.getElementById("videoList");
    videoList.innerHTML = videos
        .map(
            (video) =>
                `<video controls>
                    <source src="${video.url}" type="video/mp4">
                </video>`
        )
        .join("");
}

fetchVideos();

# 3. Create style.css
Add minimal styling.

body {
    font-family: Arial, sans-serif;
    text-align: center;
    margin: 20px;
}

form {
    margin-bottom: 20px;
}

video {
    width: 80%;
    margin-top: 10px;
}


# Phase 3: Backend Implementation
 # 1. Create upload_handler.py
Handles video uploads to S3 and metadata storage in DynamoDB.

import json
import boto3
import uuid
import os

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

BUCKET_NAME = os.environ['BUCKET_NAME']
TABLE_NAME = os.environ['TABLE_NAME']

def lambda_handler(event, context):
    try:
        file_content = event['body']
        file_name = str(uuid.uuid4()) + ".mp4"
        s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=file_content)

        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                'videoId': file_name,
                'url': f"https://{BUCKET_NAME}.s3.amazonaws.com/{file_name}",
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Video uploaded successfully!'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

# 2. Create fetch_handler.py
Fetches metadata from DynamoDB.

import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['TABLE_NAME']

def lambda_handler(event, context):
    try:
        table = dynamodb.Table(TABLE_NAME)
        response = table.scan()
        return {
            'statusCode': 200,
            'body': json.dumps(response['Items'])
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

Add TABLE_NAME as an environment variable.

Attach the AmazonDynamoDBFullAccess policy to this Lambda.

# ----------------------------------------------------























