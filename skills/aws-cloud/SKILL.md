---
name: aws-cloud
description: Deploy and manage applications on AWS. Use when setting up Lambda, API Gateway, S3, DynamoDB, or implementing serverless architectures.
---

# AWS Cloud

## When to Use

- Deploying serverless applications
- Setting up Lambda functions
- Configuring API Gateway
- Managing S3 storage
- Working with DynamoDB
- Setting up CloudWatch monitoring

## Input

- Application architecture requirements
- Infrastructure needs
- Security requirements

## Output

- AWS infrastructure configuration
- Lambda functions
- API Gateway configuration
- IAM policies
- CloudFormation/CDK templates

## Checklist

1. **IAM Setup**
   - Create least privilege policies
   - Use roles, not access keys
   - Enable MFA for root account
   - Use AWS Organizations

2. **Lambda Functions**
   - Set appropriate memory/timeout
   - Use environment variables
   - Implement error handling
   - Configure dead letter queues

3. **API Gateway**
   - Set up REST or HTTP API
   - Configure authentication
   - Enable CORS
   - Set up rate limiting

4. **Storage (S3)**
   - Configure bucket policies
   - Enable versioning
   - Set lifecycle rules
   - Enable encryption

5. **Database (DynamoDB)**
   - Design partition keys
   - Set up indexes
   - Configure capacity
   - Enable backups

## Best Practices

- Use Infrastructure as Code (CDK/CloudFormation)
- Implement least privilege IAM
- Enable CloudTrail for audit
- Use AWS Secrets Manager
- Configure VPC for networking
- Enable encryption at rest/transit
- Use AWS Organizations

## Anti-Patterns

❌ Hardcoded credentials
❌ Overly permissive IAM policies
❌ No encryption
❌ No backup strategy
❌ Not using IaC
❌ Ignoring CloudWatch alarms

## Validation

- IAM policies follow least privilege
- Lambda functions have proper error handling
- API Gateway has authentication
- S3 buckets have proper policies
- DynamoDB has backups enabled
- CloudWatch alarms configured

## Examples

### Example 1: Lambda Function (Node.js)
```typescript
// src/handlers/users.ts
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const getUser = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const userId = event.pathParameters?.id;
    
    const result = await docClient.send(
      new GetCommand({
        TableName: process.env.USERS_TABLE,
        Key: { id: userId },
      })
    );

    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: 'User not found' }),
      };
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
};
```

### Example 2: CDK Stack
```typescript
// lib/app-stack.ts
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import { Construct } from 'constructs';

export class AppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // DynamoDB Table
    const usersTable = new dynamodb.Table(this, 'UsersTable', {
      partitionKey: { name: 'id', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // Lambda Function
    const getUserLambda = new lambda.Function(this, 'GetUserFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'users.getUser',
      code: lambda.Code.fromAsset('dist'),
      environment: {
        USERS_TABLE: usersTable.tableName,
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 256,
    });

    // Grant Lambda access to DynamoDB
    usersTable.grantReadData(getUserLambda);

    // API Gateway
    const api = new apigateway.RestApi(this, 'UsersApi', {
      restApiName: 'Users Service',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
      },
    });

    const users = api.root.addResource('users');
    const user = users.addResource('{id}');
    
    user.addMethod(
      'GET',
      new apigateway.LambdaIntegration(getUserLambda)
    );
  }
}
```

### Example 3: IAM Least Privilege Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DynamoDBReadAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "arn:aws:dynamodb:us-east-1:123456789012:table/Users",
        "arn:aws:dynamodb:us-east-1:123456789012:table/Users/index/*"
      ]
    },
    {
      "Sid": "S3ReadAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

## AWS Services Reference

| Service | Use Case |
|---------|----------|
| Lambda | Serverless compute |
| API Gateway | API management |
| S3 | Object storage |
| DynamoDB | NoSQL database |
| RDS | Relational database |
| SQS | Message queue |
| SNS | Notifications |
| CloudWatch | Monitoring |
| Secrets Manager | Secrets storage |
| IAM | Access control |

## Output Structure

```
├── cdk/
│   ├── lib/
│   │   └── app-stack.ts
│   ├── bin/
│   │   └── app.ts
│   └── cdk.json
├── src/
│   └── handlers/
│       └── users.ts
├── iam/
│   └── policies/
│       └── lambda-policy.json
├── serverless.yml (if using Serverless Framework)
└── .env
```
